require 'ostruct'

module DynPrompt
  class Env
    attr_reader :parser
    def initialize(parser)
      @parser = parser
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
        unless child.const_defined?('Env') && child.const_get('Env').name === "#{child.name}::Env"
          child.const_set('Env', Class.new(Env))
        end
        $stderr.puts "add #{child.const_get('Env')}" if $DEBUG
        Parser << child
      end

      # for each new method:
      # - generate getter method if the name begin with 'parse_'
      # - generate getter method in the environment class
      def self.method_added(meth_name)
        if meth_name.to_s =~ /^parse_/
          new_name = meth_name.to_s.sub(/parse_/, '')
          var_name = new_name.to_s.sub(/[?!]$/, '')
          meth = "def #{new_name}() @#{var_name} ||= #{meth_name} end"
          $stderr.puts "#{self}: #{meth}" if $DEBUG
          module_eval(meth)
        else
          meth = "def #{meth_name}(*args, &bloc) @parser.#{meth_name}(*args, &bloc) end"
          env = const_defined?('Env') ? const_get('Env') : nil
          $stderr.puts "#{env}: #{meth}" if $DEBUG
          env.module_eval(meth) if env
        end
      end

      # get the environment (with tap comportment)
      def env(&bloc)
        @env ||= self.class.const_get('Env').new(self)
        bloc.call(@env) if bloc
        @env
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
