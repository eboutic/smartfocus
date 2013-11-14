module Smartfocus

  # Response object
  # 
  # This class aims to extract the response from Smartfocus
  #
  class Response

    attr_reader :response, :logger

    def initialize(response, logger)
      @response = response
      @logger = logger
    end

    def extract
      logger.receive(content.inspect)

      if succeed?
        response = content["response"]["result"] || content["response"]
      else
        handle_errors
      end
    rescue MultiXml::ParseError, REXML::ParseException => error
      wrapped_error = Smartfocus::MalformedResponse.new(error)
      raise wrapped_error, "Error when parsing response body"
    end

    private

    def succeed?
      (http_code == "200") and (content and content["response"])
    end

    def handle_errors
      if content =~ /Your session has expired/ or content =~ /The maximum number of connection allowed per session has been reached/
        raise Smartfocus::SessionError, content
      else
        raise Smartfocus::RequestError, content
      end
    end

    def content
      @content ||= Crack::XML.parse(response.body)
    end

    def http_code
      response.header.code
    end

  end
end