require 'rubygems'
require 'httparty'

require File.join(File.dirname(__FILE__), "streamsend/resource")
require File.join(File.dirname(__FILE__), "streamsend/subscriber")

module StreamSend
  include HTTParty
  format :xml

  def self.configure(username, password, host = "app.streamsend.com")
    base_uri host
    basic_auth username, password
  end
end
