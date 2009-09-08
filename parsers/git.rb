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
    %x(git status 2> /dev/null).each_line do |line|
      (md = line.match(/On branch (.+)/)) && res[:branch] = md[1]
      res[:commited]  = true if /Changes to be committed/ === line 
      res[:changes]   = true if /Changed but not updated/ === line
      res[:untracked] = true if /Untracked files/ === line
    end
    res[:diff] = res[:commited] || res[:changes]
    res
  end

  def parse_branch
    branch = status[:branch] 
    %x(git branch).each_line {|line| branch = line.sub(/[*]\s*([^\s]*)\s*/,'\1') if /^[*]/ === line} unless branch
    branch
  end

  def parse_bare?
    !!%x(git rev-parse --is-bare-repository 2> /dev/null).match(/true/)
  end
  def diff?
    status[:diff]
  end
  def parse_tags
    %x(git show-ref --tags)
  end
  def parse_head
    refs = %x(git show-ref --head 2> /dev/null)
    if refs
      refs.lines.first.sub( / .*\n$/, '' )
    else
      ''
    end
  end
  def parse_inside_git_dir?
    !!%x(git rev-parse --is-inside-git-dir 2> /dev/null).match(/true/)
  end
  def parse_inside_work_tree?
    !!%x(git rev-parse --is-inside-work-tree 2> /dev/null).match(/true/)
  end

  # end of parsers

  def tag
    res = tags && tags.lines.find do |line|
      line.sub( / .*$/, '' ) == head
    end
    res ? res.sub( /^.*\//, '' ).chomp : nil
  end

end # Git
