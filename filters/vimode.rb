class VimodeFilter < DynPrompt::Filter::Base

  subs 'vm' => :vimode

  def vimode(env)
    case env.vimode
    when /insert/i
      '%Bi%b'
    else
      '%Bn%b'
    end
  end

end

