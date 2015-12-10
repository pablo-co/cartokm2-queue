require 'settingslogic'
require 'securerandom'
require_relative 'builder'
require_relative '../workers/command_worker'
require_relative '../workers/upload_worker'

class Execute
  attr_accessor :outputs
  attr_accessor :settings

  def initialize
    self.outputs = []
  end

  def to_state(next_state, extension, general_arguments, arguments, settings)
    puts "state: #{next_state}"
    self.settings = settings
    current_arguments = general_arguments.dup
    current_arguments.merge!(arguments)
    current_arguments.merge!(generate_output_arguments(next_state))
    current_arguments = filter_flags(next_state, current_arguments)
    builder = Builder.new(next_state, extension, current_arguments)
    if system(builder.command)
      #remove_file(arguments['i'])
      launch_workers(general_arguments)
    else
      raise "Error executing command: #{builder.command}"
    end
  end

  protected

  def remove_file(file)
    begin
      FileUtils.rm(file)
    rescue => _
    end
  end

  def unique_states
    states = []
    outputs.each do |output|
      output.states.each do |state|
        states << state
      end
    end
    states.uniq
  end

  def launch_workers(general_arguments)
    transform_options
    states = unique_states

    states.each do |state|
      args = {}
      outputs.each do |output|
        if output.states.include? state
          args[output.key] = output.file_name
        end
      end
      if state == 'upload'
        args.each do |key, value|
          Resque.enqueue(UploadWorker, value)
        end
      else
        extension = settings['flow'][state]['extension']
        Resque.enqueue(CommandWorker, state, extension, general_arguments, args, settings)
      end
    end

  end

  def filter_flags(state, flags)
    inputs = settings['flow'][state]['input']
    flags = flags.delete_if { |key, value| !inputs.include?(key) } if inputs
    flags
  end

  def generate_output_arguments(next_state)
    arguments = {}
    output_args = settings['flow'][next_state]['output']
    if output_args
      output_args.each do |output|
        flag = output[0]
        extension = output[1]['extension']
        output_states = output[1]['programs']
        if output_states
          output_states.each do |output_state|
            arguments[flag] = create_output(output_state, flag, extension)
          end
        else
          file_name = get_file_name(extension)
          arguments[flag] = file_name
        end
      end
    else
      file_name = get_file_name('csv')
      arguments['o'] = file_name
    end
    arguments
  end

  def create_output(output_state, flag, extension)
    begin
      file_name = get_file_name(extension)
      add_to_outputs(output_state, flag, file_name)
    rescue => _
    end
  end

  def get_file_name(extension)
    "#{DefaultSettings.files_path}/#{SecureRandom.hex}.#{extension}"
  end

  def add_to_outputs(state, key, file_name)
    output = find_output(key)
    unless output
      output = Output.new
      output.key = key
      output.file_name = file_name
      outputs << output
    end
    output.states << state
    output.file_name
  end

  def find_output(key)
    outputs.each do |output|
      return output if output.key == key
    end
    nil
  end

  def transform_options
    outputs.each do |output|
      output.key = settings['arguments'][output.key]
    end
  end

end

class Output

  def initialize
    self.states = []
  end

  attr_accessor :key
  attr_accessor :file_name
  attr_accessor :states
end