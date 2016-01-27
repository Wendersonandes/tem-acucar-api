require 'bcrypt'

class Token < Sequel::Model
  include BCrypt

  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :user

  subset(:valid) { expiry > Time.now }

  def before_validation
    return super unless self.new?
    self.client  ||= SecureRandom.urlsafe_base64(nil, false)
    self.token ||= SecureRandom.urlsafe_base64(nil, false)
    self.expiry ||= DateTime.now + 14
    super
  end

  def token
    return unless @token || self.encrypted_token
    @token ||= Password.new(self.encrypted_token)
  end

  def token=(new_token)
    @token = Password.create(new_token)
    self.encrypted_token = @token
  end
end
