require 'crack/xml'
require 'httparty'
require 'active_support/inflector'
require 'logger'
require 'builder'

# Smartfocus API wrapper
#
module Smartfocus
  autoload :Api, 'smartfocus/api'
  autoload :Exception, 'smartfocus/exception'
  autoload :Logger, 'smartfocus/logger'
  autoload :MalformedResponse, 'smartfocus/malformed_response'
  autoload :Relation, 'smartfocus/relation'
  autoload :Request, 'smartfocus/request'
  autoload :RequestError, 'smartfocus/request_error'
  autoload :Response, 'smartfocus/response'
  autoload :SessionError, 'smartfocus/session_error'
  autoload :Tools, 'smartfocus/tools'
  autoload :Notification, 'smartfocus/notification'
  autoload :Version, 'smartfocus/version'

  if defined?(Rails)
    require 'smartfocus/railtie'
    require 'generators/install'
  end
end