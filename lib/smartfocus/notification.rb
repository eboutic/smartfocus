module Smartfocus
  class Notification
    include HTTParty
    default_timeout 30
    format :xml
    headers 'Content-Type' => 'application/xml;charset=utf-8', 'encoding' => 'UTF-8', 'Accept' => '*/*'

    class << self
      attr_accessor :debug
    end
    attr_accessor :debug

    def initialize(params = {})
      yield(self) if block_given?

      self.debug ||= params[:debug] || self.class.debug
    end

    def send(body, params = {})
      # == Processing body ==
      body_xml = Smartocus::Tools.to_xml_as_is body

      # == Send request ==
      logger.send "#{base_uri} with body : #{body_xml}"
      response = self.class.send :post, base_uri, :body => body_xml
      logger.receive "#{base_uri} with status : #{response.header.inspect}"

      # == Check result ==
      response.header.code == '200'
    end

    # Base uri
    def base_uri
      'http://api.notificationmessaging.com/NMSXML'
    end

    private

    def logger
      if @logger.nil?
        @logger = Smartocus::Logger.new(STDOUT)
        @logger.level = (debug ? Logger::DEBUG : Logger::WARN)
      end
      @logger
    end

  end
end