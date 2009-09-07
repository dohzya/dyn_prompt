require 'pathname'

PATH = Pathname.new(ENV['PWD'])
DYNPROMPT_HOME = Pathname.new(__FILE__).dirname

require DYNPROMPT_HOME+'exts'

module DynPrompt
  def self.export_env(opts={})
    filters = Filter.filters
    str = {}
    str.merge! Prompt.new.generate(filters)
    filters.each do |filter|
      str.merge! filter.name => filter.env.vars
    end
    str
  end
end # DynPrompt

require DYNPROMPT_HOME/:options
require DYNPROMPT_HOME/:parser
require DYNPROMPT_HOME/:filter
require DYNPROMPT_HOME/:prompt
