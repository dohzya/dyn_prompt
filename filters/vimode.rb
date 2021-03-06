module DynPrompt::Filter
  class VimodeFilter < Base

    # sub 'vm', :mode
    sub 'vm', '%vimode%'

    def mode
      case @mode
      when /insert/i
        '%Bi%b'
      else
        '%Bn%b'
      end
    end

  end
end

