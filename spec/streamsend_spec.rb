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
          subscribers = StreamSend::Subscriber.all(1)
          subscribers.size.should == 1

          subscribers.first.should be_instance_of(StreamSend::Subscriber)
          subscribers.first.id.should == 2
          subscribers.first.email_address.should == "scott@gmail.com"
          subscribers.first.created_at.should == Time.parse("2009-09-18T01:27:05Z")
        end
      end

      describe "with no subscribers" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <people type="array"/>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml").to_return(:body => xml)
        end

        it "should return an empty array" do
          StreamSend::Subscriber.all(1).should == []
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

        it "should raise an exception" do
          lambda { StreamSend::Subscriber.all(99) }.should raise_error
        end
      end
    end

    describe ".find" do
      describe "with matching subscriber" do
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml?email_address=scott@gmail.com").to_return(:body => xml)
        end

        it "should return subscriber" do
          subscriber = StreamSend::Subscriber.find(1, "scott@gmail.com")

          subscriber.should be_instance_of(StreamSend::Subscriber)
          subscriber.id.should == 2
          subscriber.email_address.should == "scott@gmail.com"
          subscriber.created_at.should == Time.parse("2009-09-18T01:27:05Z")
        end
      end

      describe "with no matching subscriber" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <people type="array"\>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml?email_address=scott@gmail.com").to_return(:body => xml)
        end

        it "should return nil" do
          StreamSend::Subscriber.find(1, "scott@gmail.com").should == nil
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people.xml?email_address=scott@gmail.com").to_return(:body => xml)
        end

        it "should raise an exception" do
          lambda { StreamSend::Subscriber.find(99, "scott@gmail.com") }.should raise_error
        end
      end
    end
  end
end
