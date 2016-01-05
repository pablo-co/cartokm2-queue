require 'optparse'
require_relative 'load'

options = {}
default_options = {}
config = nil

OptionParser.new do |opts|
  opts.banner = 'Usage: init.rb [options]'

  opts.on('-a', '--input FILE', 'Input file') { |v| options[:input] = v }
  opts.on('-b', '--first_column COLUMN', 'First column in file') { |v| default_options[:first_column] = v }
  opts.on('-c', '--last_column COLUMN', 'Last column in file') { |v| default_options[:last_column] = v }
  opts.on('-d', '--polygon POLYGON', 'Polygon file') { |v| default_options[:polygon] = v }
  opts.on('-e', '--fuel FUEL', 'Fuel file') { |v| default_options[:fuel] = v }
  opts.on('-f', '--co2 CO2', 'CO2 file') { |v| default_options[:co2] = v }
  opts.on('-g', '--capacity Capactiy', 'Capacity file') { |v| default_options[:capacity] = v }
  opts.on('-h', '--clients Clients', 'Clients file') { |v| default_options[:clients] = v }
  opts.on('-i', '--output_name Output name', 'Output file name') { |v| default_options[:output_name] = v }
  opts.on('-j', '--demand Demand', 'Demand file') { |v| default_options[:demand] = v }
  opts.on('-k', '--traces_name Traces name', 'Name of the traces file'){ |v| default_options[:traces_name] = v }
  opts.on('-l', '--stats_name Stats name', 'Name of the stats file'){ |v| default_options[:stats_name] = v }
  opts.on('-m', '--stops_name Stats name', 'Name of the stops file'){ |v| default_options[:stops_name] = v }
  opts.on('-n', '--distance_to_customers Distance file', 'Distance file') { |v| default_options[:distance_to_customers] = v }
  opts.on('-o', '--config Configuration', 'Configuration file') { |v| config = v }

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

#ruby init.rb --input=/home/pablo/projects/python/data/files/input.xlsx --polygon=/home/pablo/projects/python/data/data/polygon.csv --fuel=/home/pablo/projects/python/data/data/fuel.csv --co2=/home/pablo/projects/python/data/data/co2.csv --capacity=/home/pablo/projects/python/data/data/capacity.csv --clients=/home/pablo/projects/python/data/data/clients.csv --first_column=CODIGO --last_column=TEMPERATURA_2 --demand=/home/pablo/projects/python/data/data/demand.csv --distance_to_customers=/home/pablo/projects/python/data/data/distance_to_customers.csv --config=examples/config/traces.yml
