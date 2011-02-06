require 'uri'
require 'net/http'
require 'net/https'
require 'rexml/document'

module StreamSend
  HOST = "https://app.streamsend.com"

  def self.configure(login_id, key)
    @login = login_id
    @password = key
  end

  def self.login
    @login
  end

  def self.password
    @password
  end

  class Email
    def initialize(data)
      @data = data
    end

    def self.all
      url = URI.parse(HOST + "/emails.xml")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.port == 443

      get = Net::HTTP::Get.new(url.path)
      get.basic_auth StreamSend.login, StreamSend.password

      response = http.start { |http| http.request(get) }

      emails = []
      doc = REXML::Document.new(response.body)
      doc.elements.first.elements.each do |element|
        data = {}
        
        %w[id name].each do |attribute|
          data[attribute.intern] = element.elements[attribute].text
        end
        emails << new(data)
      end

      return emails
    end
  end
end
