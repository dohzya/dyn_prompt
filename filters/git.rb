class GitFilter < DynPrompt::Filter::Base

  sub 'br', :branch
  sub 'df', :diff
  sub 'tg', :tag
  sub 'fl', :flags

  def diff(arg='*')
    @diff ? arg : nil
  end

  def tag
    @tag ? "%B#{@tag}%b" : nil
  end

  def branch
    br = @branch
    unless br.blank?
      br = "%B#{br}%b" if @inside_work_tree
      br = "(#{br})" if @inside_git_dir
      br
    end
    br
  end

  def flags
    st = @status
    if st[:commited] || st[:changes] || st[:untracked]
      "[#{st[:commited] ? 'a' : ''}#{st[:changes] ? 'm' : ''}#{st[:untracked] ? 'u' : ''}]"
    else
      ""
    end
  end

end # Git
