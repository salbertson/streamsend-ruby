require 'httparty'

module StreamSend
  include HTTParty
  format :xml

  def self.configure(username, password, host = "app.streamsend.com")
    base_uri host
    basic_auth username, password
  end

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
  end

  class Subscriber < Resource
    def self.all(audience_id)
      response = StreamSend.get("/audiences/#{audience_id}/people.xml")

      case response.code
      when 200
        response["people"].collect { |data| new(data) }
      else
        raise "Could not find any subscribers. Make sure your audience ID is correct. (#{response.code})"
      end
    end
  end
end
