require 'uri'
require 'net/http'
require 'net/https'
require 'rexml/document'

module StreamSend
  HOST = "app.streamsend.com"

  def self.configure(username, password)
    @username = username
    @password = password
  end

  def self.username
    @username
  end

  def self.password
    @password
  end

  def self.get(path)
    http = Net::HTTP.new(StreamSend::HOST, 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new(path)
    request.basic_auth(StreamSend.username, StreamSend.password)
    http.request(request).body
  end

  def self.xml_to_attribute_hashes(xml, fields)
    collection = []
    doc = REXML::Document.new(xml)
    doc.elements.first.elements.each do |element|
      data = {}
      fields.each do |field_name|
        field = element.elements[field_name]
        data[field_name.gsub(/-/, "_")] = case field.attribute("type").to_s
        when "integer"
          field.text.to_i
        else
          field.text
        end
      end
      collection << data
    end

    collection
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
    def self.all(audience_id = 1)
      xml = StreamSend.get("/audiences/#{audience_id}/people.xml")
      subscriber_data = StreamSend.xml_to_attribute_hashes(xml, %w[id email-address opt-status tracking-hash created-at])
      subscribers = []
      subscriber_data.each do |data|
        subscribers << new(data)
      end
      subscribers
    end
  end
end
