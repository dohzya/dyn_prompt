class GitFilter < DynPrompt::Filter::Base

  subs 'br' => :branch
  subs 'df' => lambda {|env| env.diff? ? '*' : '' }
  subs 'tg' => lambda {|env| env.tag ? "%B#{env.tag}%b " : '' }
  subs 'fl' => :flags

  def branch
    br = env.branch
    unless br.blank?
      br = "%B#{br}%b" if env.inside_work_tree?
      br = "(#{br})" if env.inside_scm_dir?
      br
    end
    br
  end

  def flags
    st = env.status
    if st[:commited] || st[:changes] || st[:untracked]
      "[#{st[:commited] ? 'a' : ''}#{st[:changes] ? 'm' : ''}#{st[:untracked] ? 'u' : ''}]"
    else
      ""
    end
  end

end # Git
