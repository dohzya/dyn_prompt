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
      vars = nil
      Dir.chdir(dir) do
        vars = @prompt.generate
        @filters.each do |filter|
          vars << [filter.class.filter_name, filter.env.vars]
        end
      end
      vars
    end
  end
  class Env
    def initialize(opts={})
      generator = opts[:generator] || Generator.new(opts)
      @vars = generator.generate(opts).inject({}) do |vars, (name, value)|
        name = name.sub(/.*::/, '')
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
    def json(value, first=true)
      case value
      when true
        first ? '"true"' : value
      when nil
        first ? '""' : "null"
      when false
        first ? '""' : value
      when String,Symbol
        value.to_s.inspect.gsub(/\\#/, '#')
      when Array
        res = "[%s]" % value.map{|e| json(e,false)}.join(',')
        first ? res.inspect : res
      when Hash
        res = "{%s}" % value.map{|k,v| "%s:%s" % [json(k,false),json(v,false)] }.join(',')
        first ? res.inspect : res
      else
        value
      end
    end
  end
end # DynPrompt

require DYNPROMPT_HOME/:options
require DYNPROMPT_HOME/:helpers
require DYNPROMPT_HOME/:parser
require DYNPROMPT_HOME/:filter
require DYNPROMPT_HOME/:prompt
