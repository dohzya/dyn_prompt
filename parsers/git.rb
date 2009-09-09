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
    branch = nil if branch =~ /[(]nobranch[)]/
    branch
  end

  def parse_names
    refs = %x(git show-ref --head --dereference 2> /dev/null).split("\n")
    refs = refs.select do |r|
      h,n = r.split
      (h == head) && !(n =~ /HEAD/)
    end
    refs.map{|s| s.sub(/[^ ]* /,'')}
  end

  def parse_rebasing?
    File.exist?(dir/'rebase-apply')
  end
  def parse_dir
    Pathname.new(%x(git rev-parse --git-dir 2> /dev/null).sub(/\n/,''))
  end
  def parse_bare?
    !!%x(git rev-parse --is-bare-repository 2> /dev/null).match(/true/)
  end
  def parse_diff?
    status[:diff]
  end
  def parse_tags
    %x(git show-ref --tags)
  end
  def parse_head
    %x(git rev-parse HEAD 2> /dev/null).sub(/\n/,'')
  end
  def parse_short_head
    %x(git rev-parse --short HEAD 2> /dev/null).sub(/\n/,'')
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
