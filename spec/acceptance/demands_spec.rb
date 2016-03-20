require "spec_helper"

RSpec.describe Endpoints::Demands do
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
      latitude: 30,
      longitude: 51,
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

  describe 'GET /demands' do
    it 'returns correct status code and conforms to schema' do
      get '/demands'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /demands' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/demands', MultiJson.encode({
        name: 'Foo',
        description: 'Bar',
        radius: 0.5,
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

end
