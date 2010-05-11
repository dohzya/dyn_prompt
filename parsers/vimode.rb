class VimodeParser < DynPrompt::Parser::Base

  def self.active?
    ENV.has_key? 'VIMODE'
  end

  # parsers

  parser_for :mode, ENV['VIMODE']

  # end of parsers

end
