module StreamSend
  class Resource
    def initialize(data)
      @data = data
    end

    def method_missing(method, *args, &block)
      if @data.include?(method.to_s)
        @data[method.to_s]
      else
        super
      end
    end

    def id
      @data["id"]
    end

    def self.audience_id
      @audience_id ||= StreamSend.get("/audiences.xml").parsed_response["audiences"].first["id"]
    end
  end
end
