require 'resque'
require 'cartodb/api'

class UploadWorker
  @queue = :upload

  def self.perform(*args)
    new.perform(*args)
  end

  def perform(file)
    build_configuration
    payload = {file: Faraday::UploadIO.new(file, 'text/csv')}
    CartoDB::Api.imports.create(payload: payload)
  end

  def build_configuration
    configuration = CartoDB::Api::Configuration.new
    configuration.api_key = ENV['CARTODB_API_KEY']
    configuration.account = ENV['CARTODB_ACCCOUNT']
    configuration.version = 1
    CartoDB::Api.default_configuration = configuration
  end
end