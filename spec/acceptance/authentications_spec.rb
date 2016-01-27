require "spec_helper"

RSpec.describe Endpoints::Authentications do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./schema/schema.json"
  end

  before do
    @user = User.create(
      email: 'foo@bar.com',
      first_name: 'Foo',
      last_name: 'Bar',
      password: 'foobarfoo',
    )
    @token = @user.add_token({client: 'foo', token: 'bar'})

    # temporarily touch #updated_at until we can fix prmd
    @user.updated_at
    @user.save
  end

  describe 'POST /authentications' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/authentications', MultiJson.encode({
        email: 'foo@bar.com',
        password: 'foobarfoo',
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'DELETE /authentications' do
    it 'returns correct status code and conforms to schema' do
      header "Token-Type", "Bearer"
      header "Client", 'foo'
      header "Access-Token", 'bar'
      header "Uid", @user.id
      header "Expiry", @token.expiry
      delete "/authentications"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
