class RVMFilter < DynPrompt::Filter::Base

  sub 'rvm' do env.version.sub(/^ruby-/,'').sub(/-p\d*/,'') end

end

