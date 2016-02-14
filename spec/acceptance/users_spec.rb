require "spec_helper"

RSpec.describe Endpoints::Users do
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
      encrypted_password: 'foobar',
    )
    @token = @user.add_token({client: 'foo', token: 'bar'})
  end

  before :each do
    header "Token-Type", "Bearer"
    header "Client", 'foo'
    header "Access-Token", 'bar'
    header "Uid", @user.id
    header "Expiry", @token.expiry
  end

  describe 'GET /users' do
    it 'returns correct status code and conforms to schema' do
      get '/users'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /users' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/users', MultiJson.encode({
        email: 'bar@foo.com',
        first_name: 'Bar',
        last_name: 'Foo',
        password: '12345678',
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end

    it 'returns correct error when email is already taken' do
      header "Content-Type", "application/json"
      post '/users', MultiJson.encode({
        email: 'foo@bar.com',
        first_name: 'Bar',
        last_name: 'Foo',
        password: '12345678',
      })
      assert_equal 422, last_response.status
      assert_schema_conform
    end
  end

  describe 'GET /users/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/users/#{@user.id}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'PUT /users/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      put "/users/#{@user.id}", MultiJson.encode({})
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
