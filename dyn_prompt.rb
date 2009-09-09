require 'pathname'

PATH = Pathname.new(ENV['PWD'])
DYNPROMPT_HOME = Pathname.new(__FILE__).dirname

require DYNPROMPT_HOME+'exts'

module DynPrompt
  class Generator
    def initialize(opts={})
      @filters = opts[:filters] || Filter.filters
      @prompt  = opts[:prompt]  || Prompt.new(opts)
    end
    def generate(opts={})
      dir = opts[:dir] || ENV['PWD']
      vars = {}
      Dir.chdir(dir) do
        vars.merge!(@prompt.generate)
        @filters.each do |filter|
          vars.merge!(filter.name => filter.env.vars)
        end
      end
      vars
    end
  end
  class Env
    def initialize(opts={})
      generator = opts[:generator] || Generator.new(opts)
      @vars = generator.generate(opts).inject({}) do |vars, (name, value)|
        if value.is_a? Hash
          value.each do |n,v|
            vars["dyn_#{name.downcase}_#{n}"] = json(v)
          end
        else
          vars[name] = json(value)
        end
        vars
      end
    end
    def to_shell
      @vars.map{|name, value| %(export #{name}=#{value}) }.join("\n")
    end
    private
    def json(v)
      if v then v.respond_to?(:to_json) ? v.to_json : v.inspect else nil end
    end
  end
end # DynPrompt

require DYNPROMPT_HOME/:options
require DYNPROMPT_HOME/:parser
require DYNPROMPT_HOME/:filter
require DYNPROMPT_HOME/:prompt
