class GitFilter < DynPrompt::Filter::Base

  sub 'nm', :name
  sub 'df' do @diff ? match[2] : nil end
  sub 'tg' do @tag ? "%B#{@tag}%b" : nil end
  sub 'fl', :flags

  def name
    br = @branch
    unless br.blank?
      br = "%B#{br}%b" if @inside_work_tree
      br = "(#{br})" if @inside_git_dir
      br = "#{br}(#{tag})" if @tag
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
