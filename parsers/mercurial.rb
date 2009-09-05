module DynPrompt::Parser
  class MercurialParser < SCM
    def self.active?
      (PATH/'.hg').directory?
    end
    def parse_branch
        %x(hg branch 2> /dev/null).chomp
    end
    def parse_diff?
        not %x(hg diff 2> /dev/null).empty?
    end
  end # Mercurial
end
