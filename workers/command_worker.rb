require 'resque'
require_relative '../config/base'
require_relative '../util/execute'
require_relative '../util/builder'

class CommandWorker
  @queue = :command

  def self.perform(*args)
    new.perform(*args)
  end

  def perform(state, extension, general_arguments = {}, arguments = {}, settings = Settings)
    Execute.new.to_state(state, extension, general_arguments, arguments, settings)
  end
end