module Smartfocus

  # Relation is used for API-chained call
  # 
  # e.g. emv.get.campaign.last(:limit => 5).call
  # 
  class Relation

    def initialize(instance, request)
      @instance = instance
      @request = request
      @uri = []
      @options = {}
    end

    # Trigger the API call
    #
    # @param [Object] parameters
    # @return [Object] data returned from Smartfocus
    #
    def call(*args)
      @options.merge! extract_args(args)
      @request.prepare(@uri.join('/'), @options)
      @instance.call(@request)
    end

    def method_missing(method, *args)
      @uri << method.to_s.camelize(:lower)
      @options.merge! extract_args(args)
      self
    end

    private

    def extract_args(args)
      (args[0] and args[0].kind_of? Hash) ? args[0] : {}
    end

  end
end