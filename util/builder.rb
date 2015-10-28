require_relative '../config/settings'

class Builder

  def initialize(path, extension, arguments = {})
    @path = path
    @extension = extension
    @arguments = arguments
  end

  def command
    puts "#{base} #{arguments}"
    "#{base} #{arguments}"
  end

  protected

  def arguments
    arguments_str = ''
    @arguments.each do |key, value|
      arguments_str += "-#{key} #{value} "
    end
    arguments_str
  end

  def base
    "python #{DefaultSettings.executables_path}/#{@path}.#{@extension}"
  end

end