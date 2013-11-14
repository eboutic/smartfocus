module Smartfocus
  
  # Toolbox for the API
  # This class is mainly used to convert data
  #  
  class Tools

    # Sanitize values from a Hash
    #
    # @param [Hash] hash to sanitize
    # @return [Hash] sanitized hash
    #
    def self.sanitize_parameters(parameters)
      r_each(parameters) do |value|
        if value.kind_of?(DateTime) or value.kind_of?(Time)
          date_time_format(value.to_datetime)
        elsif value.kind_of?(Date)
          date_format(value.to_date)
        else
          value
        end
      end
    end

    def self.date_time_format(datetime)
      datetime.strftime("%Y-%m-%dT%H:%M:%S")
    end

    def self.date_format(date)
      date.strftime('%d/%m/%Y')
    end

    # Convert hash keys to camel case
    #
    # @param [Object] structure to camelize
    # @return [Object] structure with keys camelized (if any)
    #
    def self.r_camelize(obj)
      if obj.is_a?(Hash)
        new_obj = {}
        obj.each do |key, value|
          new_obj[key.to_s.camelize(:lower).to_sym] = r_camelize value
        end
        new_obj
      elsif obj.is_a?(Array)
        new_obj = []
        obj.each_with_index do |item, index|
          new_obj[index] = r_camelize item
        end
        new_obj
      else
        obj
      end
    end

    # Convert data structure to XML
    #
    # @param [Object] structure to convert
    # @return [String] XML structure
    #
    def self.to_xml_as_is(obj)
      obj_xml = ""

      unless obj.nil? or obj.empty?
        xml = ::Builder::XmlMarkup.new(:target=> obj_xml)
        xml.instruct! :xml, :version=> "1.0"
        tag_obj xml, obj
      end

      obj_xml
    end

    # Iterate throught a Hash recursively
    #
    # @param [Hash] structure to iterate
    # @yield called for each data
    #
    def self.r_each(hash, &block)
      return enum_for(:dfs, hash) unless block
 
      result = {}
      if hash.is_a?(Hash)
        hash.map do |k,v|
          result[k] = if v.is_a? Array
            v.map do |elm|
              r_each(elm, &block)
            end
          elsif v.is_a? Hash
            r_each(v, &block)
          else
            yield(v)
          end
        end
      else
        result = yield(hash)
      end

      result
    end

    private

      def self.tag_obj(xml, obj)
        if obj.is_a? Hash
          obj.each do |key, value|
            if value.is_a?(Hash)
              eval(%{
                xml.#{key} do
                  tag_obj(xml, value)
                end
              })
            elsif value.is_a?(Array)
              value.each do |item|
                eval(%{
                  xml.#{key} do
                    tag_obj(xml, item)
                  end
                })
              end
            else
              eval %{xml.#{key}(%{#{value}})}
            end
          end
        else
          obj
        end
      end

  end
end