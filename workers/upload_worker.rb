require 'sidekiq'
#require 'cartodb-api'

class UploadWorker
  include Sidekiq::Worker

  def perform(file)
    payload = {file: Faraday::UploadIO.new(file, 'text/csv')}
    CartoDB::Api.imports.create(payload: payload)
  end

  def build_configuration
    configuration = CartoDB::Api::Configuration.new
    configuration.api_key = ENV['CARTODB_API_KEY']
    configuration.account = 'pcardenasoliveros'
    configuration.version = 1
  end
end