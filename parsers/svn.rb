module DynPrompt::Parser
  class SVNParser < SCM

    def self.active?
      not %x(svn info 2> /dev/null).empty?
    end

    # parsers

    def parse_info
      res = {}
      sh("svn info 2> /dev/null") do |lines|
        lines.each do |line|
          (m=line.match(/Path: (.*)/)) && res[:path] = m[1]
          (m=line.match(/URL: (.*)/)) && res[:url] = m[1]
          (m=line.match(/Repository Root: (.*)/)) && res[:root] = m[1]
          (m=line.match(/Repository UUID: (.*)/)) && res[:uuid] = m[1]
          (m=line.match(/Revision: (.*)/)) && res[:rev] = m[1]
          (m=line.match(/Node Kind: (.*)/)) && res[:node_kind] = m[1]
          (m=line.match(/Schedule: (.*)/)) && res[:schedule] = m[1]
          (m=line.match(/Last Changed Author: (.*)/)) && res[:last_author] = m[1]
          (m=line.match(/Last Changed Rev: (.*)/)) && res[:last_rev] = m[1]
          (m=line.match(/Last Changed Date: (.*)/)) && res[:last_date] = m[1]
        end
      end
      res
    end

    def parse_status
      res = {}
      sh("svn status 2> /dev/null") do |lines|
        lines.each do |line|
        end
      end
      res
    end

    def parse_branch
      info[:url].sub(info[:root],'').sub(/^\//,'')
    end

    def parse_diff?
      status[:diff]
    end

    # end of parsers

  end # SVN
end

