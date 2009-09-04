class RVMFilter < DynPrompt::Filter::Base

  subs 'rvm' => lambda {|env| env.rvm_version.sub(/ruby-/,'').sub(/-p\d*/,'') }

end

