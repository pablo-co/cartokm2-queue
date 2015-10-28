(%w{config/*.rb util/*.rb workers/*.rb}).each do |directory|
  Dir[directory].each { |file| require_relative file }
end
