require 'sidekiq'
require_relative '../config/base'
require_relative '../util/execute'
require_relative '../util/builder'

# Start up sidekiq via
# ./bin/sidekiq -r ./examples/por.rb
# and then you can open up an IRB session like so:
# irb -r ./examples/por.rb
# where you can then say
# PlainOldRuby.perform_async "like a dog", 3
#

class CommandWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(state, extension, general_arguments = {}, arguments = {})
    execute = Execute.new
    execute.to_state(state, extension, general_arguments, arguments)
  end
end