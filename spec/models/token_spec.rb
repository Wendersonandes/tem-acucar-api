require "spec_helper"

RSpec.describe Token do
  before do
    @user = User.create(
      email: 'foo@bar.com',
      first_name: 'Foo',
      last_name: 'Bar',
      password: 'foobar',
    )
  end

  describe "#token=" do
    it "should set encrypted token" do
      token = Token.new
      token.token = '12345678'
      assert token.encrypted_token != '12345678'
      assert BCrypt::Password.new(token.encrypted_token) == '12345678'
    end
  end

  describe "#token" do
    it "should return encrypted token" do
      token = Token.new
      token.token = '12345678'
      assert !(token.token === '12345678')
      assert token.token == '12345678'
    end
  end

  describe "#before_create" do
    it "should create encrypted token" do
      token = @user.add_token({})
      assert_equal true, token.valid?
    end
  end
end
