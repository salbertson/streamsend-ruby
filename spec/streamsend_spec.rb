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
      before(:each) do
        StreamSend.configure(nil, nil, nil)
      end

      it "should raise exception" do
        lambda { StreamSend.get(@path) }.should raise_error(StreamSend::Error)
      end
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

      it "should return array of hashes with person data" do
        person_hash = StreamSend::Resource.xml_to_hash(@xml)
        person_hash["people"].size.should == 1
        person_hash["people"].first["id"].should == 2
        person_hash["people"].first["email_address"].should == "scott@gmail.com"
        person_hash["people"].first["created_at"].should be_instance_of Time
      end
    end
  end

  describe "Subscriber" do
    describe ".all" do
      describe "with audience" do
        before(:each) do
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

          StreamSend.should_receive(:get).with("/audiences/1/people.xml").and_return xml
        end

        it "should return array of one subscriber object" do
          @subscribers = StreamSend::Subscriber.all(1)
          @subscribers.size.should == 1
          @subscribers.first.should be_an_instance_of(StreamSend::Subscriber)
        end

        it "should create subscriber object with data" do
          StreamSend::Subscriber.should_receive(:new).once.with({
            "id" => 2,
            "email_address" => "scott@gmail.com",
            "created_at" => Time.parse("2009-09-18T01:27:05Z")
          })
          subscriber = StreamSend::Subscriber.all(1).first
        end
      end

      describe "with no audience" do
        it "should raise an exception" do
          lambda { StreamSend::Subscriber.all }.should raise_error
        end
      end
    end
  end
end
