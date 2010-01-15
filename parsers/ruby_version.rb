class RubyVersionParser < DynPrompt::Parser::SCM
    def self.active?
      true
    end

  # parsers

  def parse_version
    RUBY_DESCRIPTION.sub(/\s*\(.*/, '')
  end

  # end of parsers

end
