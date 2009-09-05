require 'yaml'

module DynPrompt
  class Prompt
    @@prompt_file = DYNPROMPT_HOME/'prompt.yml'
    @@default_verbosity = 'medium'

    def initialize(file=@@prompt_file)
      @yaml = YAML.load_file(file)[verbosity]
    end
    
    def verbosity
      @verbosity ||= 
        case ENV['prompt_verbosity']
        when '1', 'low'    then  'low'
        when '2', 'medium' then  'medium'
        when '3', 'high'   then  'high'
        else @@default_verbosity
        end
    end

    def generate(filters=Filter.filters)
      filters.inject(@yaml) do |yaml, filter|
        yaml.inject(yaml.dup) do |new, (name, item)|
          new[name] = filter.filter(item)
          new
        end
      end
    end

  end
end
