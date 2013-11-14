require 'rails'

module Smartocus
  class Railtie < Rails::Railtie

    generators do
      require 'generators/install'
    end

    config.to_prepare do  
      file = "#{Rails.root}/config/smartfocus.yml"
      if File.exist?(file)
        config = YAML.load_file(file)[Rails.env] || {}
        Smartfocus::Api.server_name    = config['server_name']
        Smartfocus::Api.endpoint       = config['endpoint']
        Smartfocus::Api.login          = config['login']
        Smartfocus::Api.password       = config['password']
        Smartfocus::Api.key            = config['key']
        Smartfocus::Api.debug          = config['debug']
        Smartfocus::Notification.debug = config['debug']
      end
    end
  end
end