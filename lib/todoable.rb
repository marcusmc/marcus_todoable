require 'httparty'

class Todoable
    include HTTParty
    base_uri 'http://todoable.teachable.tech/api'
    format :json
    headers 'Accept' => 'applicaton/json'
    headers 'Content-Type' => 'application/json'

    attr_accessor :username, :password

    def initialize(username, password)
        @username = username
        @password = password
        retrieve_token()
    end

    def create_list(name)
        body = create_list_request_body(name)
        self.class.post('/lists', with_authentication(body: body.to_json))
    end

    def get_lists
       self.class.get('/lists', with_authentication) 
    end

    def get_list(list_id)
        self.class.get("/lists/#{list_id}", with_authentication)
    end

    def update_list(list_id, name)
        body = create_list_request_body(name)
        self.class.patch("/lists/#{list_id}", with_authentication(body: body.to_json))
    end

    def delete_list(list_id)
        self.class.delete("/lists/#{list_id}", with_authentication)
    end

    def add_item(list_id, name)
        body = create_item_request_body(name)
        self.class.post("/lists/#{list_id}/items", with_authentication(body: body.to_json))
    end

    def finish_item(list_id, item_id)
        self.class.put("/lists/#{list_id}/items/#{item_id}/finish", with_authentication)
    end

    def delete_item(list_id, item_id)
        self.class.delete("/lists/#{list_id}/items/#{item_id}", with_authentication)
    end
        

    private

    def with_authentication(options = {})
        options.merge!(headers: { "Authorization" => "Token token=\"#{token}\""})
    end

    def create_list_request_body(name)
        {
            "list": {
                "name": name
            }
        }
    end

    def create_item_request_body(name)
        {
            "item": {
                "name": name
            }
        }
    end

    def token
        unless @token and @token_expiration > DateTime.now
            retrieve_token
        end
        @token
    end

    def retrieve_token
        result = self.class.post("/authenticate", 
            {
                basic_auth: {
                    username: @username,
                    password: @password
                },
            }
        )
        case result.code
        when 401
            raise TodoableError.new('Username and password are not valid.')
        when 200   
            @token = result.parsed_response["token"]
            @token_expiration = DateTime.parse(result.parsed_response["expires_at"])
        else
            raise TodoableError.new('Some other error happened.')
        end
    end

end

require 'todoable/todoable_error'