require 'rubygems'
require 'httparty'

require "streamsend/resource"
require "streamsend/subscriber"
require "streamsend/list"

module StreamSend
  include HTTParty
  format :xml

  def self.configure(username, password, host = "app.streamsend.com")
    base_uri host
    basic_auth username, password
  end
end
