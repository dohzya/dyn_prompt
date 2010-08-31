module DynPrompt::Filter
  class RubyVersionFilter < Base

    sub 'rv', :version
    sub 'rgs', :gemset

    def version
      @version.sub(/^ruby-/,'').sub(/-p\d*/,'')
    end

    def gemset(ptn)
      if ptn && @gemset
        ptn.sub(/[$]_/, @gemset)
      else
        @gemset
      end
    end

  end
end

