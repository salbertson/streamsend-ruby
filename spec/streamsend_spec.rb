require 'uri'
require 'fakeweb'
require 'streamsend'

describe "StreamSend::Subscriber" do
  before(:each) do
    @username = "testloginid"
    @password = "testkey"
    StreamSend.configure(@username, @password)
  end

  describe ".all" do
    before(:each) do
      xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <people type="array">
          <person>
            <id type="integer">2</id>
            <email-address>scott.onix@gmail.com</email-address>
            <email-content-format>html</email-content-format>
            <opt-status>active</opt-status>
            <ip-address></ip-address>
            <user-agent></user-agent>
            <tracking-hash type="binary" encoding="base64">YlhlalFpWA==</tracking-hash>
            <soft-bounce-count type="integer">0</soft-bounce-count>
            <created-at type="datetime">2009-09-18T01:27:05Z</created-at>
            <updated-at type="datetime">2010-10-16T18:37:18Z</updated-at>
            <subscribed-at type="datetime">2009-09-18T01:27:06Z</subscribed-at>
            <unsubscribed-at type="datetime"></unsubscribed-at>
            <audience-id type="integer">1</audience-id>
          </person>
        </people>
      XML

      FakeWeb.register_uri(:get, "https://#{@username}:#{@password}@#{StreamSend::HOST}/audiences/1/people.xml", :body => xml)
    end

    it "should return array of subscriber objects" do
      subscribers = StreamSend::Subscriber.all
      subscribers.size.should == 1
      subscribers.first.should be_an_instance_of(StreamSend::Subscriber)
    end
  end
end
