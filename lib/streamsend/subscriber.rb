module StreamSend
  class Subscriber < Resource
    def self.audience_id
      @audience_id ||= StreamSend.get("/audiences.xml").parsed_response["audiences"].first["id"]
    end

    def self.all
      response = StreamSend.get("/audiences/#{audience_id}/people.xml")

      case response.code
      when 200
        response["people"].collect { |data| new(data) }
      else
        raise "Could not find any subscribers. Make sure your audience ID is correct. (#{response.code})"
      end
    end

    def self.find(email_address)
      response = StreamSend.get("/audiences/#{audience_id}/people.xml?email_address=#{email_address}")

      case response.code
      when 200
        if subscriber = response["people"].first
          new(subscriber)
        else
          nil
        end
      else
        raise "Could not find the subscriber. Make sure your audience ID is correct. (#{response.code})"
      end
    end

    def show
      response = StreamSend.get("/audiences/#{audience_id}/people/#{id}.xml")

      case response.code
      when 200
        if subscriber = response["person"]
          self.class.new(subscriber)
        else
          nil
        end
      else
        raise "Could not show the subscriber. (#{response.code})"
      end
    end

    def activate
      response = StreamSend.post("/audiences/#{audience_id}/people/#{id}/activate.xml")

      case response.code
      when 200
        true
      else
        raise "Could not activate the subscriber. (#{response.code})"
      end
    end

    def unsubscribe
      response = StreamSend.post("/audiences/#{audience_id}/people/#{id}/unsubscribe.xml")

      case response.code
      when 200
        true
      else
        raise "Could not subscribe the subscriber. (#{response.code})"
      end
    end
  end
end
