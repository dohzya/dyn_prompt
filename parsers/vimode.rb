module DynPrompt::Parser
  class VimodeParser < Base

    def self.active?
      ENV.has_key? 'VIMODE'
    end

    # parsers

    parser_for :mode, ENV['VIMODE']

    # end of parsers

  end
end
