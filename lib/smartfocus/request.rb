module Smartfocus

  # Request object
  #
  # This class aims to format the request for Smartfocus
  #
  class Request

    attr_reader(
        :http_verb,
        :token,
        :server_name,
        :endpoint,
        :uri,
        :body,
        :parameters
    )

    def initialize(http_verb, token, server_name, endpoint)
      @http_verb = http_verb
      @token = token
      @server_name = server_name
      @endpoint = endpoint
    end

    def prepare(uri, parameters)
      @uri = uri
      @parameters = parameters || {}

      @uri = prepare_uri
      @body = prepare_body
    end

    private

    def prepare_uri
      uri = @uri
      if parameters[:uri]
        uri += token ? "/#{token}/" : '/'
        uri += (parameters[:uri].respond_to?(:join) ? parameters[:uri] : [parameters[:uri]]).compact.join '/'
        parameters.delete :uri
      elsif parameters[:body]
        uri += token ? "/#{token}/" : '/'
      else
        parameters[:token] = token
      end
      uri
    end

    def prepare_body
      body = parameters[:body] || {}
      parameters.delete :body
      # 2. Camelize all keys
      body = Smartfocus::Tools.r_camelize body
      # 3. Convert to xml
      Smartfocus::Tools.to_xml_as_is body
    end

    def assign_attributes(attibutes)
      attibutes or return
      attibutes.each do |attribute, value|
        public_send("#{attribute}=", value)
      end
    end

  end
end