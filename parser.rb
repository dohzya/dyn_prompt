require 'ostruct'

module DynPrompt
  module EnvMod
    def parse(var, value)
      @parse ||= {}
      @parse[var] = value
    end
    def [](var)
      vars[var]
    end
    def []=(var, value)
      vars[var] = value
    end
    def vars
      @vars ||= {}
    end
  end
  class Env
    attr_reader :parser
    def initialize(parser)
      @parser = parser
      @vars = {}
    end
    def [](var)
      unless @vars[var]
        val = self.class[var]
        value = 
          case val
          when Symbol
            @parser.send(val)
          when Proc
            @parser.instance_eval(&val)
          else
            val
          end
        @vars[var] = value
      end
      @vars[var]
    end
    def vars
      self.class.vars.keys.inject({}) do |res, var|
        res[var] = self[var]
        res
      end
    end
  end # Env
  module Parser
    # list of all parsers
    @@parsers = []

    # get list of all active parsers
    def self.actives
      @@actives ||= @@parsers.select do |parser|
        parser.active?
      end
      @@actives
    end

    # add a parser (order is preserved)
    def self.<<( parser )
      @@parsers.unshift(parser)
    end

    class Base
      # environment of the parser
      attr_reader :env

      # each child of this class will:
      # - be saved in the @@parser variable
      # - have a class Env
      def self.inherited(child)
        if not child.const_defined?('Env') && child.const_get('Env').name === "#{child.name}::Env"
          env = child.const_set('Env', Class.new(Env))
        else
          env = child.const_get('Env')
        end
        unless env.ancestors.include? EnvMod
          env.extend(EnvMod)
        end
        $stderr.puts "add #{child.const_get('Env')}" if $DEBUG
        Parser << child
      end

      # for each new method:
      # - generate getter method if the name begin with 'parse_'
      # - generate getter method in the environment class
      def self.method_added(meth_name)
        return unless env # self == Base
        if meth_name.to_s =~ /^parse_/
          new_name = meth_name.to_s.sub(/parse_/, '')
          var_name = new_name.to_s.sub(/[?!]$/, '')
          meth = "def #{new_name}() @#{var_name} ||= #{meth_name} end"
          $stderr.puts "#{self}: #{meth}" if $DEBUG
          module_eval(meth)
          parser_for(var_name, meth_name)
        else
          meth = "def #{meth_name}(*args, &bloc) @parser.#{meth_name}(*args, &bloc) end"
          $stderr.puts "#{env}: #{meth}" if $DEBUG
          env.module_eval(meth)
        end
      end

      def self.parser_for(name, meth=nil, &bloc)
        env[name] = meth || bloc
      end

      def self.env
        const_get('Env') if const_defined?('Env')
      end

      # get the environment
      def env
        @env ||= self.class.const_get('Env').new(self)
      end

      # if this parser active?
      def self.active?
        false
      end
    end # Base

    class DefaultParser < Base
      def self.active?
        true
      end
    end # Default

    class SCM < Base
    end # SCM

  end # Parser
end # DynPrompt

# load all user defined parsers
Dir["#{DYNPROMPT_HOME}/parsers/*.rb"].each do |parser|
  require parser
end
