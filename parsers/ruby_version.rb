module DynPrompt::Parser
  class RubyVersionParser < Base
    def self.active?
      true
    end

    # parsers

    def parse_version
      if defined?(RUBY_DESCRIPTION)
        RUBY_DESCRIPTION.sub(/\s*\(.*/, '')
      else
        "ruby 1.8.6"
      end
    end

    def parse_gemset
      ENV['rvm_gemset_name']
    end

    # end of parsers

  end
end
