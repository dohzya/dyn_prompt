module DynPrompt::Parser
  class GitParser < SCM
    @@msg_no_diff = /nothing to commit/
    @@msg_changes = /nothing added to commit/

    def self.active?
      not %x(git rev-parse --git-dir 2> /dev/null).empty?
    end

    # parsers

    def parse_status
      res = { :bare => bare? }
      return res if res[:bare]
      sh("git status 2> /dev/null") do |lines|
        lines.each do |line|
          (md = line.match(/On branch (.+)/)) && res[:branch] = md[1]
          res[:commited]  = true if /Changes to be committed/ === line
          res[:changes]   = true if /Changed but not updated|Changes not staged for commit/ === line
          res[:untracked] = true if /Untracked files/ === line
        end
        res[:diff] = res[:commited] || res[:changes]
      end
      res
    end

    def parse_branch
      status[:branch] || sh("git branch") do |branches|
        branch = branches.find{|line| /^[*]/ === line }
        if branch
          branch = branch.sub(/[*]\s*([^\s]*)\s*/,'\1')
          branch.match(/[(]nobranch[)]/) ? nil : branch
        else
          nil
        end
      end
    end

    def parse_names
      sh("git show-ref --head --dereference 2> /dev/null") do |refs|
        refs = refs.map do |ref|
          h,n = ref.split(/\s+/)
          if (h == head) && !(n =~ /HEAD/) then n else nil end
        end.compact
      end
    end

    def parse_rebasing?
      !Dir[dir/'rebase-*'].empty?
    end
    def parse_dir
      sh("git rev-parse --git-dir 2> /dev/null", :result => :one){|dir| Pathname.new(dir) }
    end
    def parse_bare?
      sh("git rev-parse --is-bare-repository 2> /dev/null", :result => /true/)
    end
    def parse_diff?
      status[:diff]
    end
    def parse_tags
      sh("git name-rev --tags HEAD 2> /dev/null") do |tags|
        tags.map do |tag|
          tag.sub(/.* tags\/([^^]*)(?:^.*)?/,'\1')
        end
      end
    end
    def parse_head
      sh("git rev-parse HEAD 2> /dev/null", :result => :one)
    end
    def parse_short_head
      sh("git rev-parse --short HEAD 2> /dev/null", :result => :one)
    end
    def parse_inside_git_dir?
      sh("git rev-parse --is-inside-git-dir 2> /dev/null", :result => /true/)
    end
    def parse_inside_work_tree?
      sh("git rev-parse --is-inside-work-tree 2> /dev/null", :result => /true/)
    end

    # end of parsers

  end # Git
end
