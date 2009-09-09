module DynPrompt
  module Filter
    # the list of filters
    @@filters = []

    # return a list of instance of all active filters
    def self.filters
      actives.collect do |filter, parser|
        filter = filter.new
        filter.env = parser.new.env
        filter.env.vars.each do |name, value|
          filter.instance_variable_set("@#{name}", value)
        end
        filter
      end
    end

    # all active filters
    # an active filter is a filter wich accept an active parser
    def self.actives
      # use [] instead of {} because ruby 1.8 doesn't save the order
      @@actives ||= @@filters.inject([]) do |actives, filter|
        res = Parser.actives.find do |parser|
          filter.accept? parser
        end
        actives << [filter, res] if res
        actives
      end
    end

    # add a filter
    def self.<<( filter )
      @@filters.unshift(filter)
    end

    class Base
      attr_accessor :env
      # each child of this class:
      # - will be saved in the @@filters vars
      # - will have a Subs module containing all substitute variables
      def self.inherited(child)
        Filter << child
        unless child.const_defined?('Subs') && child.const_get('Subs').name === "#{child.name}::Subs"
          child.const_set('Subs', {})
        end
      end

      def self.filter_name
        name.sub(/Filter$/,'')
      end

      # by default a filter accept a parser with same prefix
      #   example: DefaultFilter accept DefaultParser
      def self.accept?(parser)
        self.name[/[^:]+$/].sub(/Filter$/,'') == parser.name[/[^:]+$/].sub(/Parser$/,'')
      end

      # add a substitution variable
      # 
      # pattern[string,regexp] => the pattern to substitute
      # value:                 => the value [replaced by &bloc if nil]
      #   [method]               => the method will be called
      #   [symbol]               => the method(value) will be called
      #   [proc]                 => the proc will be transformed in method
      #   [*]                    => the value will not be changed
      def self.sub(pattern, value=nil, &bloc)
        value ||= bloc
        subs[pattern] = value
      end

      # get all substitutions variables
      def self.subs(hash=nil, &bloc)
        subs = const_get('Subs')
        bloc.call(subs) if bloc
        subs
      end

      # filter a string with all registered substitute variables
      def filter(str)
        subs = self.class.subs
        changes = []
        result = subs.inject(str) do |res, (ptn, (value, *type))|
          if type.empty?
            old_ptn, old_value = ptn, value
            subs.delete(ptn)
            case ptn
            when Regexp
              ptn, type = ptn, :user
            else
              ptn, type = /[$](?:[{]([^}]*)[}])?#{ptn}[(]([^)]*)[)](?:[{]([^}]*)[}])?/, :auto
            end
            case value
            when Method
              # do nothing
            when Symbol
              value = method(value)
            when Proc
              method_name = "__method_for_#{ptn.inspect}"
              self.class.module_eval do
                define_method(method_name, value)
              end
              value = method(method_name)
            else
              value = lambda{|*_| old_value }
            end
            changes << [old_ptn, ptn, value, type]
          else
            type = type.first
          end
          arity = value.arity < 0 ? -1 : value.arity
          res.gsub(ptn) do |match|
            match = match.match(ptn)
            if type == :auto && [0,1].include?(arity)
              "%s%s%s" % [match[1], value.call(*[match[2]][0...arity]), match[3]]
            else
              value.call(*match[0...arity])
            end
          end
        end
        changes.each do |(old_ptn, ptn, value, type)|
          subs.delete(old_ptn)
          subs[ptn] = [value, type]
        end
        result
      end
    end # Base

    class DefaultFilter < Base
      sub '[^\s]*' do |m1, m2, m3| '' end
    end # Default

  end # Filter
end

# load all user defined filters
Dir["#{DYNPROMPT_HOME}/filters/*.rb"].each do |filter|
  require filter
end
