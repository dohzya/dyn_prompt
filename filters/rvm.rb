class RVMFilter < DynPrompt::Filter::Base

  sub 'rvm' do env.rvm_version.sub(/ruby-/,'').sub(/-p\d*/,'') end

end

