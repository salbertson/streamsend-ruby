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

  describe "Resource" do
    describe "with missing method" do
      before(:each) do
        @resource = StreamSend::Resource.new({"name" => "scott"})
      end

      it "should return value" do
        @resource.name.should == "scott"
      end
    end

    describe "#id" do
      it "should return id" do
        StreamSend::Resource.new({"id" => 99}).id.should == 99
      end
    end
  end

  describe "Subscriber" do
    before(:each) do
      StreamSend.configure(@username, @password, @host)
    end

    describe ".all" do
      describe "with subscribers" do
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml").to_return(:body => xml)
        end

        it "should return array of one subscriber object" do
          @subscribers = StreamSend::Subscriber.all(1)
          @subscribers.size.should == 1
          @subscribers.first.should be_an_instance_of(StreamSend::Subscriber)
        end

        it "should create subscriber" do
          StreamSend::Subscriber.should_receive(:new).once.with({
            "id" => 2,
            "email_address" => "scott@gmail.com",
            "created_at" => Time.parse("2009-09-18T01:27:05Z")
          })
          StreamSend::Subscriber.all(1)
        end
      end

      describe "with no subscribers" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <people type="array"></people>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml").to_return(:body => xml)
        end

        it "should return an empty array" do
          @subscribers = StreamSend::Subscriber.all(1)
          @subscribers.should == []
        end

        it "should not create subscriber instance" do
          StreamSend::Subscriber.should_not_receive(:new)
          StreamSend::Subscriber.all(1)
        end
      end

      describe "with invalid audience" do
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml").to_return(:body => xml)
        end
      end

      describe "with invalid audience" do
        it "should raise an exception" do
          lambda { StreamSend::Subscriber.all(99) }.should raise_error
        end

        it "should not create subscriber instance" do
          StreamSend::Subscriber.should_not_receive(:new)
          lambda { StreamSend::Subscriber.all(99) }
        end
      end
    end
  end
end
