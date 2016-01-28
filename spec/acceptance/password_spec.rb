require "spec_helper"

RSpec.describe Endpoints::Password do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./schema/schema.json"
  end

  describe 'POST /password' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/password', MultiJson.encode({
        email: 'foo@bar.com',
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'PATCH /password' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch '/password', MultiJson.encode({
        email: 'foo@bar.com',
        password: 'foobarfoo',
        token: 'foobar',
      })
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
