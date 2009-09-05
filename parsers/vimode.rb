class VimodeParser < DynPrompt::Parser::Base
    def self.active?
      ENV.has_key? 'VIMODE'
    end

  # parsers

  def parse_vimode
    ENV['VIMODE']
  end

  # end of parsers

end