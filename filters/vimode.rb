class VimodeFilter < DynPrompt::Filter::Base

  sub 'vm', :vimode

  def vimode
    case env.vimode
    when /insert/i
      '%Bi%b'
    else
      '%Bn%b'
    end
  end

end

