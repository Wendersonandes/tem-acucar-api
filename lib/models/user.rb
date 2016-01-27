require 'bcrypt'

class User < Sequel::Model
  include BCrypt

  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  def password
    @password ||= Password.new(self.encrypted_password)
  end

  def password=(password)
    @password = Password.create(password)
    self.encrypted_password = @password
  end
end
