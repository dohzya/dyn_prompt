class GitParser < DynPrompt::Parser::SCM
  @@msg_no_diff = /nothing to commit/
  @@msg_changes = /nothing added to commit/

  def self.active?
    not %x(git rev-parse --git-dir 2> /dev/null).empty?
  end

  # parsers

  def parse_status
    res = { :bare => bare? }
    return res if res[:bare]
    sh("git status 2> /dev/null").each do |line|
      (md = line.match(/On branch (.+)/)) && res[:branch] = md[1]
      res[:commited]  = true if /Changes to be committed/ === line 
      res[:changes]   = true if /Changed but not updated/ === line
      res[:untracked] = true if /Untracked files/ === line
    end
    res[:diff] = res[:commited] || res[:changes]
    res
  end

  def parse_branch
    status[:branch] || sh("git branch") do |branches|
      branches.each do |line|
        branch = line.sub(/[*]\s*([^\s]*)\s*/,'\1') if /^[*]/ === line
      end
      branch.match(/[(]nobranch[)]/) ? nil : branch
    end
  end

  def parse_names
    sh("git show-ref --head --dereference 2> /dev/null") do |refs|
      refs = refs.select do |r|
        h,n = r.split
        (h == head) && !(n =~ /HEAD/)
      end
      refs.map{|s| s.sub(/[^ ]* /,'')}
    end
  end

  def parse_rebasing?
    File.exist?(dir/'rebase-apply')
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
    sh("git show-ref --tags")
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

  def tag
    res = tags && tags.lines.find do |line|
      line.sub( / .*$/, '' ) == head
    end
    res ? res.sub( /^.*\//, '' ).chomp : nil
  end

end # Git
