module StreamSend
  class List < Resource
    def self.all
      response = StreamSend.get("/audiences/#{audience_id}/lists.xml")

      case response.code
      when 200
        response["lists"].collect { |data| new(data) }
      else
        raise "Could not find any lists. (#{response.code})"
      end
    end

    def self.find(list_id)
      response = StreamSend.get("/audiences/#{audience_id}/lists/#{list_id}.xml")

      case response.code
      when 200
        new(response["list"])
      else
        raise "Could not find any lists. (#{response.code})"
      end
    end

    def self.create(list_name)
      response = StreamSend.post("/audiences/#{audience_id}/lists.xml", :query => {:list => {:name => list_name}})

      if response.code == 201
        response.headers["location"] =~ /audiences\/\d\/lists\/(\d+)$/
        new_list_id = $1.to_i
      else
        raise "Could not create a list. (#{response.body})"
      end
    end
  end
end
