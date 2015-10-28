require 'optparse'
require_relative 'load'

options = {}
default_options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: init.rb [options]'

  opts.on('-i', '--input FILE', 'Input file') { |v| options[:input] = v }
  opts.on('-f', '--first_column COLUMN', 'First column in file') { |v| default_options[:f] = v }
  opts.on('-l', '--last_column COLUMN', 'Last column in file') { |v| default_options[:l] = v }
  opts.on('-p', '--polygon POLYGON', 'Polygon file') { |v| default_options[:p] = v }
  opts.on('-u', '--fuel FUEL', 'Fuel file') { |v| default_options[:u] = v }
  opts.on('-c', '--co2 CO2', 'CO2 file') { |v| default_options[:c] = v }
  opts.on('-a', '--capacity Capactiy', 'Capacity file') { |v| default_options[:a] = v }
  opts.on('-t', '--clients Clients', 'Clients file') { |v| default_options[:t] = v }

end.parse!

class Init

  def initialize(default_options = {}, options = {})
    @default_options = default_options
    @options = options
  end

  def start
    assert_configuration
    initial_state = Settings.flow.initial
    initial_extension = Settings.flow[initial_state]['extension']
    launch_worker(initial_state, initial_extension, @default_options)
  end

  def launch_worker(state, extension, general_arguments)
    CommandWorker.perform_async(state, extension, general_arguments, {i: @options[:input]})
  end

  protected

  def assert_configuration
    assert_option(:input)
  end


  def assert_option(option)
    raise "Error: #{option} not given" if @options[option].nil?
  end

end

init = Init.new(default_options, options)
init.start
