require 'optparse'
require_relative 'load'

options = {}
default_options = {}
config = nil

OptionParser.new do |opts|
  opts.banner = 'Usage: init.rb [options]'

  opts.on('-i', '--input FILE', 'Input file') { |v| options[:input] = v }
  opts.on('-f', '--first_column COLUMN', 'First column in file') { |v| default_options[:first_column] = v }
  opts.on('-l', '--last_column COLUMN', 'Last column in file') { |v| default_options[:last_column] = v }
  opts.on('-p', '--polygon POLYGON', 'Polygon file') { |v| default_options[:polygon] = v }
  opts.on('-u', '--fuel FUEL', 'Fuel file') { |v| default_options[:fuel] = v }
  opts.on('-c', '--co2 CO2', 'CO2 file') { |v| default_options[:co2] = v }
  opts.on('-a', '--capacity Capactiy', 'Capacity file') { |v| default_options[:capacity] = v }
  opts.on('-t', '--clients Clients', 'Clients file') { |v| default_options[:clients] = v }
  opts.on('-t', '--output_name Output name', 'Output file name') { |v| default_options[:output_name] = v }
  opts.on('-t', '--demand Demand', 'Demand file') { |v| default_options[:demand] = v }
  opts.on('-t', '--distance_to_customers Distance file', 'Distance file') { |v| default_options[:distance_to_customers] = v }
  opts.on('-t', '--config Configuration', 'Configuration file') { |v| config = v }

end.parse!

class Init

  attr_accessor :config

  def initialize(default_options = {}, options = {}, config = nil)
    @default_options = default_options
    @options = options
    self.config = configuration_source(config)
  end

  def configuration_source(new_source)
    new_source ? Settings.new(new_source) : Settings
  end

  def start
    assert_configuration
    initial_state = config['flow']['initial']
    initial_extension = config['flow'][initial_state]['extension']
    launch_worker(initial_state, initial_extension, @default_options, config)
  end

  def launch_worker(state, extension, general_arguments, settings)
    Resque.enqueue(CommandWorker, state, extension, general_arguments, {input: @options[:input]}, settings)
  end

  protected

  def assert_configuration
    assert_option(:input)
  end


  def assert_option(option)
    raise "Error: #{option} not given" if @options[option].nil?
  end

end

init = Init.new(default_options, options, config)
init.start
