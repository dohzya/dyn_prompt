class SVNFilter < DynPrompt::Filter::Base

  sub 'nm', :branch
  sub 'df' do |m| @diff ? m : nil end
  sub 'tg', :tags
  sub 'fl', :flags

  def branch
    @branch ? "%B#@branch%b" : @branch
  end

  def tags
    @tags ? @tags : []
  end

  def flags
  end

end # SVN
