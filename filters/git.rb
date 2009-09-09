class GitFilter < DynPrompt::Filter::Base

  sub 'nm', :name
  sub 'df' do |m| @diff ? m : nil end
  sub 'tg' do @tag ? "%B#{@tag}%b" : nil end
  sub 'fl', :flags
  sub 'rb' do @rebasing ? ' - %BREBASING%b -' : '' end

  def names
    @names.map {|n| n.sub(/refs\/((remotes\/)|(heads\/))/,'') }
  end

  def other_names
    names.select {|n| n != @branch }
  end

  def name
    br = @branch
    if br
      br = "%B#{br}%b" if @inside_work_tree
      br = "(#{br})" unless @branch
    else
      br = @short_head
    end
    br << "(#{other_names.join(',')})" unless other_names.blank?
    br << "(t:#{tag})" if @tag
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
