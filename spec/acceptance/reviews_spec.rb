require "spec_helper"

RSpec.describe Endpoints::Reviews do
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
    @user2 = User.create(
      email: 'bar@foo.com',
      first_name: 'Bar',
      last_name: 'Foo',
      encrypted_password: 'barfoo',
      latitude: 30,
      longitude: 51,
    )
    @token = @user.add_token({client: 'foo', token: 'bar'})
    @demand = Demand.create(
      user: @user2,
      name: 'Foo',
      description: 'Bar',
      latitude: 30,
      longitude: 50,
      radius: 1,
    )
    @transaction = Transaction.create(
      demand: @demand,
      user: @user,
    )
  end

  before :each do
    header "Token-Type", "Bearer"
    header "Client", 'foo'
    header "Access-Token", 'bar'
    header "Uid", @user.id
    header "Expiry", @token.expiry
  end

  describe 'GET /reviews' do
    it 'returns correct status code and conforms to schema' do
      get '/reviews?user_id=' + @user.id
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /reviews' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/reviews', MultiJson.encode({
        transaction_id: @transaction.id,
        rating: 5,
        text: 'Foo bar',
      })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end
end
