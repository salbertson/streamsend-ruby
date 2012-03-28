require File.join(File.dirname(__FILE__), "../../spec_helper")

module StreamSend
  describe "List" do
    let(:app_host) { "http://test.host" }
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
        StreamSend::List.audience_id.should == 2
      end
    end

    describe ".all" do
      describe "with lists" do
        before(:each) do
          xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<lists type="array">
  <list>
    <active-people-count type="integer">11</active-people-count>
    <checked-by-default type="boolean" nil="true"></checked-by-default>
    <created-at type="datetime">2012-01-14T18:11:50Z</created-at>
    <deleted-at type="datetime" nil="true"></deleted-at>
    <description nil="true"></description>
    <id type="integer">42</id>
    <inactive-people-count type="integer">0</inactive-people-count>
    <name>First list</name>
    <pending-people-count type="integer">0</pending-people-count>
    <public type="boolean" nil="true"></public>
    <status type="enum">idle</status>
    <unsubscribed-people-count type="integer">0</unsubscribed-people-count>
    <updated-at type="datetime">2012-01-14T18:11:50Z</updated-at>
    <audience-id type="integer">2</audience-id>
  </list>
</lists>
XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/lists.xml").to_return(:body => xml)
        end

        it "should return array of one list object" do
          lists = StreamSend::List.all
          lists.size.should == 1

          lists.first.should be_instance_of(StreamSend::List)
          lists.first.id.should == 42
          lists.first.name.should == "First list"
          lists.first.created_at.should == Time.parse("2012-01-14T18:11:50Z")
        end
      end

      describe "with no lists" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <lists type="array"/>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/lists.xml").to_return(:body => xml)
        end

        it "should return an empty array" do
          StreamSend::List.all.should == []
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
          lambda { StreamSend::List.all }.should raise_error
        end
      end
    end

    describe ".find" do
      describe "with matching list" do
        before(:each) do
          xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
  <list>
    <active-people-count type="integer">11</active-people-count>
    <checked-by-default type="boolean" nil="true"></checked-by-default>
    <created-at type="datetime">2012-01-14T18:11:50Z</created-at>
    <deleted-at type="datetime" nil="true"></deleted-at>
    <description nil="true"></description>
    <id type="integer">42</id>
    <inactive-people-count type="integer">0</inactive-people-count>
    <name>First list</name>
    <pending-people-count type="integer">0</pending-people-count>
    <public type="boolean" nil="true"></public>
    <status type="enum">idle</status>
    <unsubscribed-people-count type="integer">0</unsubscribed-people-count>
    <updated-at type="datetime">2012-01-14T18:11:50Z</updated-at>
    <audience-id type="integer">2</audience-id>
  </list>
          XML

          stub_http_request(:get, /audiences\/2\/lists\/42.xml/).with(:id => "42").to_return(:body => xml)
        end

        it "should return list" do
          list = StreamSend::List.find(42)

          list.should be_instance_of(StreamSend::List)
          list.id.should == 42
          list.name.should == "First list"
          list.created_at.should == Time.parse("2012-01-14T18:11:50Z")
        end
      end

      describe "with no matching list" do
        before(:each) do
          xml = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <lists type="array"\>
          XML

          stub_http_request(:get, "http://#{@username}:#{@password}@#{@host}/audiences/2/people.xml?email_address=bad.email@gmail.com").to_return(:status => 404)
        end

        it "should return throw an exception" do
          lambda {
            StreamSend::List.find(-1)
          }.should raise_error
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
          lambda { StreamSend::List.find("scott@gmail.com") }.should raise_error
        end
      end
    end


    describe ".create" do
      describe "with no existing list using the same name" do
        before(:each) do
          @new_list_name = "list 1"
          new_list_params = { :list => {:name => @new_list_name} }
          stub_http_request(:post, /audiences\/2\/lists.xml/).with(new_list_params).to_return(:status => 201, :headers => {:location => "#{app_host}/audiences/2/lists/42"} )
        end

        it "should return list" do
          list_id = StreamSend::List.create(@new_list_name)
          list_id.should == 42
        end
      end

      describe "with an existing list using the same name" do
        before(:each) do
          @new_list_name = "list 1"
          new_list_params = { :list => {:name => @new_list_name} }
          @error_message = "<error>Name has already been taken<error>"
          stub_http_request(:post, /audiences\/2\/lists.xml/).with(new_list_params).to_return(:status => 422, :body => @error_message)
        end

        it "should raise an error" do
          lambda {
            StreamSend::List.create(@new_list_name)
          }.should raise_error
        end
      end
    end

  end
end
