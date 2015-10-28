require 'settingslogic'
require_relative 'base'

class Settings < Settingslogic
  source "#{Base.root}/config/settings.yml"
  namespace Base.env
end

class DefaultSettings < Settingslogic
  source "#{Base.root}/config/setup.yml"
end