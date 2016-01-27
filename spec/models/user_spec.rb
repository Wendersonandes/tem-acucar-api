require "spec_helper"
require "bcrypt"

RSpec.describe User do
  describe "#password=" do
    it "should set encrypted password" do
      user = User.new
      user.password = '12345678'
      assert user.encrypted_password != '12345678'
      assert BCrypt::Password.new(user.encrypted_password) == '12345678'
    end
  end

  describe "#password" do
    it "should return encrypted password" do
      user = User.new
      user.password = '12345678'
      assert !(user.password === '12345678')
      assert user.password == '12345678'
    end
  end
end
