require 'yaml'
require 'optparse'
require_relative 'load'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-p', '--path FILE', 'Base working path') { |v| options[:path] = v }

end.parse!

File.open('config/setup.yml', 'w') do |h|
  h.write(options.to_yaml)
end