class RVMParser < DynPrompt::Parser::SCM
    def self.active?
      ENV.has_key? 'rvm_ruby_version'
    end

  # parsers

  def parse_version
    ENV['rvm_ruby_version']
  end

  # end of parsers

end
