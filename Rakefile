$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require 'resque/tasks'

task :'resque:setup' do
  Dir['./workers/*'].each { |file| require file }
end