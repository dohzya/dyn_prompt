class GitFilter < DynPrompt::Filter::Base

  sub 'br', :branch
  sub 'df' do |match| env.diff? ? match[2] : '' end
  sub 'tg' do env.tag ? "%B#{env.tag}%b " : '' end
  sub 'fl', :flags

  def branch(match)
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
