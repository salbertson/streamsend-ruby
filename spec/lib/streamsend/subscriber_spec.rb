require File.join(File.dirname(__FILE__), "../../spec_helper")

module StreamSend
  describe "Subscriber" do
    before(:each) do
      stub_http_request(:any, //).to_return(:body => "Page not found.", :status => 404)

      @username = "scott"
      @password = "topsecret"
      @host = "test.host"

      xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <audiences type="array">
          <audience>
            <id type="integer">2</id>
          </audience>
        </audiences>
      XML
      stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences.xml").to_return(:body => xml)

      StreamSend.configure(@username, @password, @host)
    end

    describe ".audience_id" do
      it "should return the id of the first audience" do
        StreamSend::Subscriber.audience_id.should == 2
      end
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/people.xml").to_return(:body => xml)
        end

        it "should return array of one subscriber object" do
          subscribers = StreamSend::Subscriber.all
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/people.xml").to_return(:body => xml)
        end

        it "should return an empty array" do
          StreamSend::Subscriber.all.should == []
        end
      end

      describe "with invalid audience" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <people type="array"/>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/99/people.xml").to_return(:body => xml)
        end

        it "should raise an exception" do
          lambda { StreamSend::Subscriber.all }.should raise_error
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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/people.xml?email_address=scott@gmail.com").to_return(:body => xml)
        end

        it "should return subscriber" do
          subscriber = StreamSend::Subscriber.find("scott@gmail.com")

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

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/people.xml?email_address=bad.email@gmail.com").to_return(:body => xml)
        end

        it "should return nil" do
          StreamSend::Subscriber.find("bad.email@gmail.com").should == nil
        end
      end

      describe "with invalid audience" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <people type="array"\>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/99/people.xml?email_address=bad.email@gmail.com").to_return(:body => xml)
        end

        it "should raise an exception" do
          lambda { StreamSend::Subscriber.find("scott@gmail.com") }.should raise_error
        end
      end
    end

    describe "#show" do
      describe "with valid subscriber instance" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <person>
              <id type="integer">2</id>
              <email-address>scott@gmail.com</email-address>
              <created-at type="datetime">2009-09-18T01:27:05Z</created-at>
              <first-name>Scott</first-name>
              <last-name>Albertson</last-name>
            </person>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/1/people/2.xml").to_return(:body => xml)
        end

        it "should return subscriber" do
          subscriber = StreamSend::Subscriber.new({"id" => 2, "audience_id" => 1}).show

          subscriber.should be_instance_of(StreamSend::Subscriber)
          subscriber.id.should == 2
          subscriber.email_address.should == "scott@gmail.com"
          subscriber.created_at.should == Time.parse("2009-09-18T01:27:05Z")
          subscriber.first_name.should == "Scott"
          subscriber.last_name.should == "Albertson"
        end
      end

      describe "with invalid subscriber instance" do
        it "should raise exception" do
          lambda { StreamSend::Subscriber.new({"id" => 99, "audience_id" => 1}).show }.should raise_error
        end
      end

      describe "with invalid audience" do
        it "should raise exception" do
          lambda { StreamSend::Subscriber.new({"id" => 2}).show }.should raise_error
        end
      end
    end

    describe "#activate" do
      before(:each) do
        stub_http_request(:post, "http://#{@username}:#{@password}@#{@host}/audiences/1/people/2/activate.xml").to_return(:body => nil)
      end

      describe "with valid subscriber" do
        it "should be successful" do
          response = StreamSend::Subscriber.new({"id" => 2, "audience_id" => 1}).activate
          response.should be_true
        end
      end

      describe "with invalid subscriber" do
        it "should raise exception" do
          lambda { StreamSend::Subscriber.new({"id" => 99, "audience_id" => 1}).activate }.should raise_error
        end
      end
    end

    describe "#unsubscribe" do
      before(:each) do
        stub_http_request(:post, "http://#{@username}:#{@password}@#{@host}/audiences/1/people/2/unsubscribe.xml").to_return(:body => nil)
      end

      describe "with valid subscriber" do
        it "should be successful" do
          response = StreamSend::Subscriber.new({"id" => 2, "audience_id" => 1}).unsubscribe
          response.should be_true
        end
      end

      describe "with invalid subscriber" do
        it "should raise exception" do
          lambda { StreamSend::Subscriber.new({"id" => 99, "audience_id" => 1}).unsubscribe }.should raise_error
        end
      end
    end
  end
end

