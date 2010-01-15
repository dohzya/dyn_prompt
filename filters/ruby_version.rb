class RubyVersionFilter < DynPrompt::Filter::Base

  sub 'rv', :version

  def version
    @version.sub(/^ruby-/,'').sub(/-p\d*/,'')
  end

end

