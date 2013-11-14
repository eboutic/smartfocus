require 'rails/generators'

module Smartfocus
  module Generators
    class Install < Rails::Generators::Base
      
      source_root File.expand_path('../templates', __FILE__)

      def generate_config        
        copy_file "smartfocus.yml", "config/smartfocus.yml" unless File.exist?("config/smartfocus.yml")
      end

    end    
  end
end