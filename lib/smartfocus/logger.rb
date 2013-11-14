module Smartfocus
  
  # API logger class
  #
  class Logger < ::Logger

    attr_accessor :debug

    def initializer(*args)
      debug = false
      super args
    end

    # Log a message sent to smartfocus
    #
    # @param [String] message
    def send(message)
      info("[Smartfocus] Send -> #{message}")
    end

    # Log a message received from smartfocus
    #
    # @param [String] message    
    def receive(message)
      info("[Smartfocus] Receive -> #{message}")
    end

  end
end