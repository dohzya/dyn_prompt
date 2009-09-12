module DynPrompt
  module Helpers

    # Execute a shell command and return the result or the standard output
    # 
    # cmd[shell cmd]     => the command to execute
    # opts
    #   :return            => choose the type of return
    #     :result            => return the result of the command
    #     :all               => return the standard output
    #     :one               => return the first line (or line)
    #     [no-symbol]        => return arg === line
    #   :select[hash,proc] => select what line to return
    #   :filter[hash,proc] => filter line 
    #   :test              => 
    def sh(cmd, opts={}, &bloc)
      result_type = opts[:result] || :all
      select = opts[:select]
      filter = opts[:filter]
      res = []
      IO.popen cmd do |f|
        f.each_line do |line|
          l = line.sub(/\n$/,'')
          if !select || select[l]
            res << (filter ? filter[l] : l)
          end
        end
      end
      result = case result_type
               when :result_type
                 $?.success?
               when :all
                 res.empty? ? nil : res
               when :one
                 res.empty? ? nil : res.first
               when Regexp
                 result_type === res.first
               else
                 result_type === res
               end
      bloc&&result ? bloc.call(result) : result
    end
  end
end
