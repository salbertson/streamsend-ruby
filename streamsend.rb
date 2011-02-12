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
    def initialize(data)
      @data = data
    end

    def self.all
      url = URI.parse("https://#{StreamSend::HOST}/audiences/1/people.xml")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.port == 443

      get = Net::HTTP::Get.new(url.path)
      get.basic_auth StreamSend.username, StreamSend.password

      response = http.start { |http| http.request(get) }

      people = []
      doc = REXML::Document.new(response.body)
      doc.elements.first.elements.each do |element|
        data = {}
        
        %w[id email-address opt-status tracking-hash created-at].each do |attribute|
          data[attribute.intern] = element.elements[attribute].text
        end
        people << new(data)
      end

      return people
    end
  end
end
