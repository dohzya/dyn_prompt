class RubyVersionParser < DynPrompt::Parser::SCM
    def self.active?
      true
    end

  # parsers

  def parse_version
    RUBY_DESCRIPTION.sub(/\s*\(.*/, '')
  end

  def parse_gemset
    ENV['rvm_gemset_name']
  end

  # end of parsers

end
