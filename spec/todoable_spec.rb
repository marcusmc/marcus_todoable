require 'Todoable'
require 'HTTParty'
require 'Timecop'

describe Todoable do
    before(:all) do
        @test_storage = {}
        Timecop.travel("Thu, 01 Nov 2018 22:05:44 GMT")
    end
    it "includes the HTTParty methods" do
        expect(Todoable).to include HTTParty
    end
    it "raises an error on incorrect authentication", :vcr do
        expect { Todoable.new("nonexistent@gmail.com", "todoable") }.to raise_error(Todoable::TodoableError)
    end
    subject { Todoable.new("marcustest@gmail.com", "todoable") }
    it "can be initialized with username and password", :vcr do
        expect(subject.username).to eq "marcustest@gmail.com"
        expect(subject.password).to eq "todoable"
    end
    it "retrieves an authentication token", :vcr do
        expect(subject.send(:token)).not_to be_empty
    end
    it "creates a list given a name", :vcr do
        result = subject.create_list("List10")
        expect(a_request(:post, "#{Todoable.base_uri}/lists")
            .with(:body=> {"list": { "name": "List10" } }))
        .to have_been_made
        @test_storage[:list_id] = result.parsed_response["id"]
    end
    it "retrieves all available lists", :vcr do
        subject.get_lists
        expect(a_request(:get, "#{Todoable.base_uri}/lists"))
        .to have_been_made
    end
    it "retrieves an individual list", :vcr do
        list_id = @test_storage[:list_id]
        subject.get_list(list_id)
        expect(a_request(:get, "#{Todoable.base_uri}/lists/#{list_id}"))
        .to have_been_made
    end
    it "updates a lists name", :vcr do
        list_id = @test_storage[:list_id]
        subject.update_list(list_id, "aNewTestList")
        expect(a_request(:patch, "#{Todoable.base_uri}/lists/#{list_id}")
        .with(:body => {"list": { "name": "aNewTestList"}}))
        .to have_been_made
    end
    it "adds an item to list", :vcr do
        list_id = @test_storage[:list_id]
        result = subject.add_item(list_id, "aNewTestListItem")
        expect(a_request(:post, "#{Todoable.base_uri}/lists/#{list_id}/items")
        .with(:body => {"item": { "name": "aNewTestListItem"}}))
        .to have_been_made
        @test_storage[:item_id] = result.parsed_response["id"]
    end
    it "finishes an item", :vcr do
        list_id, item_id = @test_storage.values_at(:list_id, :item_id)
        subject.finish_item(list_id, item_id)
        expect(a_request(:put, "#{Todoable.base_uri}/lists/#{list_id}/items/#{item_id}/finish"))
        .to have_been_made
    end
    it "deletes an item", :vcr do
        list_id, item_id = @test_storage.values_at(:list_id, :item_id)
        subject.delete_item(list_id, item_id)
        expect(a_request(:delete, "#{Todoable.base_uri}/lists/#{list_id}/items/#{item_id}"))
        .to have_been_made
    end
    it "deletes a list", :vcr do
        list_id = @test_storage[:list_id]
        subject.delete_list(list_id)
        expect(a_request(:delete, "#{Todoable.base_uri}/lists/#{list_id}"))
        .to have_been_made
    end
    it "retrieves a new token when it has expired", :vcr do
        subject.get_lists
        Timecop.freeze(DateTime.now.to_time + 1210) do
            puts DateTime.now
            subject.get_lists
            expect(a_request(:post, "#{Todoable.base_uri}/authenticate"))
            .to have_been_made.times(2)
        end
    end
end