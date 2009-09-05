require 'pathname'

PATH = Pathname.new(ENV['PWD'])
DYNPROMPT_HOME = Pathname.new(__FILE__).dirname

require DYNPROMPT_HOME+'exts'

module DynPrompt
  def self.export(opts={})
    Prompt.new.generate
  end
end # DynPrompt

require DYNPROMPT_HOME/:options
require DYNPROMPT_HOME/:parser
require DYNPROMPT_HOME/:filter
require DYNPROMPT_HOME/:prompt
