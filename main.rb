require 'pathname'

class Pathname
  def /(where)
    self + "#{where}"
  end
end
class Object
  def blank?
    empty?
  end
end
class NilClass
  def blank?
    true
  end
end
class String
  unless instance_method(:each_line)
    alias :each :each_line
  end
end

$path = Pathname.pwd
$src_path = Pathname.new( ARGV[0] )

module DynPrompt
  def self.export
    parsers = Parser.actives
    prompt = Prompt.new
    vars   = []
    prompt.generate.each do |name, value|
      vars << %(export #{name}='#{value}')
    end
    vars.join("\n")
  end
end # DynPrompt

require $src_path/:options
require $src_path/:parser
require $src_path/:filter
require $src_path/:prompt

puts DynPrompt.export
