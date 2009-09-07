class VimodeFilter < DynPrompt::Filter::Base

  sub 'vm', :mode

  def mode
    case env.mode
    when /insert/i
      '%Bi%b'
    else
      '%Bn%b'
    end
  end

end

