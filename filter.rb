module DynPrompt
  module Filter
    # the list of filters
    @@filters = []

    # return a list of instance of all active filters
    def self.filters
      actives.collect do |filter, parser|
        filter = filter.new
        filter.parser = parser.new
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
      # the parser associated
      attr_accessor :parser

      # each child of this class:
      # - will be saved in the @@filters vars
      # - will have a Subs module containing all substitute variables
      def self.inherited(child)
        Filter << child
        unless child.const_defined?('Subs') && child.const_get('Subs').name === "#{child.name}::Subs"
          child.const_set('Subs', {})
        end
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
        subs.inject(str) do |res, (ptn, value)|
          reg   = ptn.is_a?(Regexp) ? ptn : /[$]#{ptn}[{]([^}]*)[}]/ 
          repl = 
            case value
            when Method
              value
            when Symbol
              method(value)
            when Proc
              method_name = "__method_for_#{reg.inspect}"
              self.class.module_eval do
                define_method(method_name, value)
              end
              method(method_name)
            else
              lambda{|*_| value }
            end
          subs.delete(ptn) if reg != ptn
          subs[reg] = repl if reg != ptn || repl != value
          arity = repl.arity < 0 ? -1 : repl.arity
          res.gsub(reg) do |match|
            match = match.match(reg)
            repl.call(*[match][0...arity])
          end
        end
      end

      # the parser environment
      def env
        @parser
      end
    end # Base

    class DefaultFilter < Base
      subs '[^\s]+' => ''
    end # Default

  end # Filter
end

# load all user defined filters
Dir["#{DYNPROMPT_HOME}/filters/*.rb"].each do |filter|
  require filter
end
