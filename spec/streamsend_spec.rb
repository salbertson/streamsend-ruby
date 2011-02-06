require 'uri'
require 'fake_web'
require 'streamsend.rb'

describe "StreamSend::Email" do
  before(:each) do
    StreamSend.configure("WGHCrtvaJIRp", "kHE6TUjrQmNOsEvO")
  end

  describe ".all" do
    before(:each) do
      xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <emails type="array">
          <email>
            <content-type type="enum">html_text</content-type>
            <created-at type="datetime">2010-07-13T16:32:18Z</created-at>
            <creator-id type="integer">264381</creator-id>
            <creator-type>User</creator-type>
            <description nil="true"></description>
            <html-part>
            </html-part>
            <id type="integer">158</id>
            <name>Sushi Restaurant</name>
            <size-in-bytes type="integer">19693</size-in-bytes>
            <subject nil="true"></subject>
            <template-type>PrebuiltTemplate</template-type>
            <text-part nil="true"></text-part>
            <updated-at type="datetime">2010-07-13T16:32:54Z</updated-at>
          </email>
        </emails>
      XML

      FakeWeb.register_uri(URI.join(StreamSend::HOST, "emails.xml"), :string => xml)
    end

    it "should return array of email objects" do
      emails = StreamSend::Email.all
      emails.size.should == 1
      emails.first.should be_an_instance_of(StreamSend::Email)
    end
  end
end
