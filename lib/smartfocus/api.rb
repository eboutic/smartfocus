module Smartfocus

  # This is where the communication with the API is made.
  #
  class Api
    include HTTParty
    default_timeout 30
    format :xml
    headers 'Content-Type' => 'text/xml'

    # HTTP verbs allowed to trigger a call-chain
    HTTP_VERBS = [:get, :post].freeze
    ATTRIBUTES = [:token, :server_name, :endpoint, :login, :password, :key, :debug].freeze

    # Attributes
    class << self
      attr_accessor *ATTRIBUTES
    end
    attr_accessor *ATTRIBUTES

    # Initialize
    #
    # @param [Hash] Instance attributes to assign
    # @yield Freshly-created instance (optionnal)
    #
    def initialize(params = {})
      yield(self) if block_given?
      assign_attributes(params)
    end

    # ----------------- BEGIN Pre-configured methods -----------------

    # Reset session
    #
    # Useful when the session has expired.
    #
    def reset_session
      close_connection
      open_connection
    end

    # Login to Smartfocus API
    #
    # @return [Boolean] true if the connection has been established.
    #
    def open_connection
      return false if connected?
      self.token = get.connect.open.call :login => @login, :password => @password, :key => @key
      connected?
    end

    # Logout from Smartfocus API
    #
    # @return [Boolean] true if the connection has been destroyed
    #
    def close_connection
      if connected?
        get.connect.close.call
      else
        return false
      end
    rescue Smartfocus::Exception => e
    ensure
      invalidate_token!
      not connected?
    end

    # Check whether the connection has been established or not
    #
    # @return [Boolean] true if the connection has been establshed
    #
    def connected?
      !token.nil?
    end

    # When a token is no longer valid, this method can be called.
    # The #connected? method will return false
    #
    def invalidate_token!
      self.token = nil
    end
    # ----------------- END Pre-configured methods -----------------    

    # Perform an API call
    #
    # @param [Smartfocus::Request] Request to perform
    #
    def call(request)
      # == Check presence of these essential attributes ==
      unless server_name and endpoint
        raise Smartfocus::Exception, "Cannot make an API call without a server name and an endpoint !"
      end

      with_retries do
        logger.send "#{request.uri} with query : #{request.parameters} and body : #{request.body}"

        response = perform_request(request)

        Smartfocus::Response.new(response, logger).extract
      end
    end

    # Set a new token
    #
    # @param [String] new token
    #
    def token=(value)
      @token = value
    end

    # Change API endpoint.
    # This will close the connection to the current endpoint
    #
    # @param [String] new endpoint (apimember, apiccmd, apitransactional, ...)
    #
    def endpoint=(value)
      close_connection
      @endpoint = value
    end

    # Base uri
    #
    def base_uri
      "http://#{server_name}/#{endpoint}/services/rest/"
    end

    # Generate call-chain triggers
    HTTP_VERBS.each do |http_verb|
      define_method(http_verb) do
        Smartfocus::Relation.new(self, build_request(http_verb))
      end
    end

    private

    def build_request(http_verb)
      Smartfocus::Request.new(http_verb, token, server_name, endpoint)
    end

    def perform_request(request)
      self.class.send request.http_verb, base_uri + request.uri, :query => request.parameters, :body => request.body, :timeout => 30
    end

    def assign_attributes(parameters)
      parameters or return
      ATTRIBUTES.each do |attribute|
        public_send("#{attribute}=", (parameters[attribute] || self.class.public_send(attribute)))
      end
    end

    def with_retries
      retries = 3
      begin
        yield
      rescue Errno::ECONNRESET, Timeout::Error => e
        if ((retries -= 1) > 0)
          retry
        else
          raise e
        end
      end
    end

    def logger
      if @logger.nil?
        @logger = Smartfocus::Logger.new(STDOUT)
        @logger.level = (debug ? Logger::DEBUG : Logger::WARN)
      end
      @logger
    end

  end
end