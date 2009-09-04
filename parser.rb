require 'ostruct'

module DynPrompt
  class Env
    attr_reader :parser
    def initialize(parser)
      @parser = parser
    end
    # def method_missing(meth_name, *args, &bloc)
    #   if @parser.respond_to? meth_name or @parser.respond_to? "parse_#{meth_name}"
    #     @parser.send(meth_name, *args, &bloc)
    #     meth = "def #{meth_name}(*args,&bloc) @parser.#{meth_name}(*args#{bloc ? ", &bloc" : ""}) end"
    #     $stderr.puts "#{self.class}: #{meth}" if $DEBUG
    #     self.class.module_eval(meth)
    #   else
    #     super
    #   end
    # end
  end # Env
  module Parser
    @@parsers = []
    def self.actives
      @@actives ||= @@parsers.select do |parser|
        parser.active?
      end
      @@actives
    end
    def self.<<( parser )
      @@parsers.unshift(parser)
    end

    class Base
      attr_reader :env
      def self.inherited(child)
        unless child.const_defined?('Env') && child.const_get('Env').name === "#{child.name}::Env"
          child.const_set('Env', Class.new(Env))
        end
        $stderr.puts "add #{child.const_get('Env')}" if $DEBUG
        Parser << child
      end
      # def method_missing(meth_name, *args, &bloc)
      #   orig_name = "parse_#{meth_name}"
      #   if respond_to? orig_name
      #     send(orig_name, *args, &bloc)
      #     var_name = meth_name.to_s.sub(/[?!]$/, '')
      #     meth = "def #{meth_name}() @#{var_name} ||= #{orig_name} end"
      #     $stderr.puts "#{self}: #{meth}" if $DEBUG
      #     module_eval(meth)
      #   end
      # end
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
      def env(&bloc)
        @env ||= self.class.const_get('Env').new(self)
        bloc.call(@env) if bloc
        @env
      end
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

Dir["#$src_path/parsers/*.rb"].each do |parser|
  require parser
end
