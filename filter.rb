module DynPrompt
  module Filter
    @@filters = []
    def self.filters
      actives.collect do |filter, parser|
        filter = filter.new
        filter.parser = parser.new
        filter
      end
    end
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
    def self.<<( filter )
      @@filters.unshift(filter)
    end

    class Base
      attr_accessor :parser
      def self.inherited(child)
        Filter << child
        unless child.const_defined?('Subs') && child.const_get('Subs').name === "#{child.name}::Subs"
          child.const_set('Subs', {})
        end
      end
      def self.accept?(parser)
        filter_name = self.name[/[^:]+$/].sub(/Filter$/,'')
        parser_name = parser.name[/[^:]+$/].sub(/Parser$/,'')
        filter_name == parser_name
      end
      def self.subs(hash=nil, &bloc)
        subs = const_get('Subs')
        subs.merge!(hash) if hash
        bloc.call(subs) if bloc
        subs
      end
      def filter(str)
        self.class.subs.inject(str) do |res, (ptn, value)|
          reg   = /[$]#{ptn}[{][^}]*[}]/ unless ptn.is_a? Regexp
          repl = 
            case value
            when Symbol
              method(value)
            when String
              lambda{value}
            else
              value
            end
          arity = repl.arity
          res.gsub(reg) do |match|
            match = match[/[{].*[}]/]
            repl.call(*[env, match][0...arity])
          end
        end
      end
      def env
        @parser
      end
    end # Base

    class DefaultFilter < Base
      subs '[^\s]+' => ''
    end # Default

  end # Filter
end

Dir["#{DYNPROMPT_HOME}/filters/*.rb"].each do |filter|
  require filter
end
