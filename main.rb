#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/dyn_prompt"

def die(msg)
  $stderr.puts msg
  exit 1
end

def print_usage
  name = File.basename(__FILE__)
  $stderr.puts <<USAGE
usage: #{name} [-h]
USAGE
  exit
end

args = ARGV.dup
opts = {}
while arg = args.shift
  case arg
  when '-h','--help'
    print_usage
  when /^-/
    die("unknown argument: #{arg}")
  end
end

vars = DynPrompt.export(opts)
puts vars.map {|name, value| %(export #{name}="#{value}")}.join("\n")