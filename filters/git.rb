module DynPrompt::Filter
  class GitFilter < Base

    sub 'nm', :name
    sub 'df' do |m| @diff ? m : nil end
    sub 'tg', :tags
    sub 'fl', :flags
    sub 'rb' do @rebasing ? ' - %BREBASING%b -' : '' end

    def names
      res = @names ? @names.map {|name|
        n = name.dup
        n.sub!(/refs\/((remotes\/)|(heads\/)|(tags\/))/,'')
        n.sub!(/\^[{][}]$/,'')
        n
      } : []
      max_refs = ENV['prompt_git_refs_max'].to_i
      (res.size > max_refs) ? res[0..max_refs]+['...'] : res
    end

    def branch
      @branch && @inside_work_tree ? "%B#@branch%b" : @branch
    end

    def name
      others = names.map{|n| n unless n == @branch }.compact
      if @branch.nil? && others.empty?
        @short_head
      else
        if others.empty?
          branch
        else
          others = others.join(',')
          max_chars = ENV['prompt_git_refs_max_chars'].to_i
          others = (others.size > max_chars) ? "#{others[0..max_chars]}..." : others
          "#{branch}(#{others})"
        end
      end
    end

    def tags
      @tags ? @tags : []
    end

    def flags
      st = @status
      if st[:commited] || st[:changes] || st[:untracked]
        "[#{st[:commited] ? 'a' : ''}#{st[:changes] ? 'm' : ''}#{st[:untracked] ? 'u' : ''}]"
      else
        ""
      end
    end

  end # Git
end
