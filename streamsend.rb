require 'uri'
require 'net/http'
require 'net/https'
require 'activesupport'

module StreamSend
  class Error < StandardError; end

  def self.configure(username, password, host = "app.streamsend.com")
    @username = username
    @password = password
    @host     = host
  end

  def self.username
    @username
  end

  def self.password
    @password
  end

  def self.host
    @host
  end

  def self.get(path)
    raise StreamSend::Error.new("You must call StreamSend.configure with a username and password.")  if !StreamSend.username || !StreamSend.password || !StreamSend.host

    http = Net::HTTP.new(StreamSend.host, 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new(path)
    request.basic_auth(StreamSend.username, StreamSend.password)
    http.request(request).body
  end

  class Resource
    attr_reader :data

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

    def self.xml_to_hash(xml)
      Hash.from_xml(xml)
    end
  end

  class Subscriber < Resource
    def self.all(audience_id)
      xml = StreamSend.get("/audiences/#{audience_id}/people.xml")
      xml_to_hash(xml)["people"].collect { |data| new(data) }
    end
  end
end
