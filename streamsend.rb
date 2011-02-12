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

  class Subscriber
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def id
      @data["id"]
    end

    def method_missing(method, *args, &block)
      #if method.to_s =~ /\?$/
        #send(method.to_s[0..-2])
      if @data.include?(method.to_s)
        @data[method.to_s]
      else
        super
      end
    end

    def self.all
      http = Net::HTTP.new(StreamSend::HOST, 443)
      http.use_ssl = true
      response = http.start do
        get = Net::HTTP::Get.new("/audiences/1/people.xml")
        get.basic_auth(StreamSend.username, StreamSend.password)
        http.request(get)
      end

      people = []
      doc = REXML::Document.new(response.body)
      doc.elements.first.elements.each do |element|
        data = {}
        
        %w[id email-address opt-status tracking-hash created-at].each do |field_name|
          field = element.elements[field_name]

          data[field_name.gsub(/-/, "_")] = case field.attribute("type").to_s
            when "integer"
              field.text.to_i
            else
              field.text
          end
        end
        people << new(data)
      end

      return people
    end
  end
end
