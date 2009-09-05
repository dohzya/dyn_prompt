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
      #   [symbol]               => the method(value) will be called
      #   [proc]                 => the proc will be called inside instance context
      #   [*]                    => the value will not be changed
      # &bloc                  => [can't take parameters']
      def self.sub(pattern, value=nil, &bloc)
        value ||= bloc
        raise "can't use a bloc with arity > 0'" if value.is_a?(Proc) && !value.arity.zero?
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
        self.class.subs.inject(str) do |res, (ptn, value)|
          reg   = /[$]#{ptn}[{][^}]*[}]/ unless ptn.is_a? Regexp
          repl = 
            case value
            when Symbol
              method(value)
            when Proc
              value
            else
              lambda{value}
            end
          res.gsub(reg) do |match|
            match = match[/[{].*[}]/]
            if repl.arity.zero?
              instance_exec(&repl)
            else
              repl.call(*[env, match][0...repl.arity])
            end
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
