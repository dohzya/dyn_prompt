class RVMParser < DynPrompt::Parser::SCM
    def self.active?
      ENV.has_key? 'rvm_prompt'
    end

  # parsers

  def parse_version
    ENV['rvm_prompt']
  end

  # end of parsers

end
