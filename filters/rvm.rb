class RVMFilter < DynPrompt::Filter::Base

  sub 'rvm', :version

  def version
    @version.sub(/^ruby-/,'').sub(/-p\d*/,'')
  end

end

