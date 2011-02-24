require 'uri'
require 'webmock/rspec'
require 'streamsend'

describe "StreamSend" do
  before(:each) do
    stub_http_request(:any, //).to_return(:body => "Page not found.")

    @username = "scott"
    @password = "topsecret"
    @host = "test.host"
  end

  describe ".configure" do
  end

  describe ".get" do
    before(:each) do
      @path = "/valid/path.xml"
      stub_http_request(:get, "https://#{@username}:#{@password}@#{@host}#{@path}").to_return(:body => "response body")
    end

    describe "with valid configuration" do
      before(:each) do
        StreamSend.configure(@username, @password, @host)
      end

      it "should return response body" do
        StreamSend.get(@path).should == "response body"
      end
    end

    describe "with no configuration" do
      it "should raise exception"
    end
  end

  describe "Resource" do
    describe "#xml_to_hash" do
      before(:each) do
        @xml = <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <people type="array">
            <person>
              <id type="integer">2</id>
              <email-address>scott@gmail.com</email-address>
              <created-at type="datetime">2009-09-18T01:27:05Z</created-at>
            </person>
          </people>
        XML
      end

      it "should return hash" do
        StreamSend::Resource.xml_to_hash(@xml).should be_instance_of Hash
      end

      it "should return array of people hashes" do
        person_hash = StreamSend::Resource.xml_to_hash(@xml)
        person_hash["people"].size.should == 1
        person_hash["people"].first["id"].should == 2
        person_hash["people"].first["email_address"].should == "scott@gmail.com"
        person_hash["people"].first["created_at"].should be_instance_of Time
      end
    end
  end

  describe "Subscriber" do
    before(:each) do
      StreamSend.configure(@username, @password, @host)

      xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <people type="array">
          <person>
            <id type="integer">2</id>
            <email-address>scott@gmail.com</email-address>
            <created-at type="datetime">2009-09-18T01:27:05Z</created-at>
          </person>
        </people>
      XML

      stub_http_request(:get, "https://#{@username}:#{@password}@#{@host}/audiences/1/people.xml").to_return(:body => xml)
    end

    describe ".all" do
      describe "with the default audience ID" do
        before(:each) do
          @subscribers = StreamSend::Subscriber.all
        end

        it "should return array of subscriber objects" do
          @subscribers.size.should == 1
          @subscribers.first.should be_an_instance_of(StreamSend::Subscriber)
        end
      end

      describe "with an explicit audience ID" do
        before(:each) do
          @subscribers = StreamSend::Subscriber.all(1)
        end

        it "should return array of subscriber objects" do
          @subscribers.size.should == 1
          @subscribers.first.should be_an_instance_of(StreamSend::Subscriber)
        end
      end
    end

    describe "#id" do
      before(:each) do
        @subscriber = StreamSend::Subscriber.all.first
      end

      it "should return id" do
        @subscriber.id.should == 2
      end
    end

    describe "#email_address" do
      before(:each) do
        @subscriber = StreamSend::Subscriber.all.first
      end

      it "should return email address" do
        @subscriber.email_address.should == "scott@gmail.com"
      end
    end
  end
end
