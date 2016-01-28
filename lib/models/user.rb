require 'bcrypt'

class User < Sequel::Model
  include BCrypt

  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  one_to_many :tokens
  one_to_many :authentications

  def self.from_facebook(facebook)
    user = where(facebook_uid: facebook['id']).first
    return user if user
    user = where(email: facebook['email']).first if facebook['email'] && !facebook['email'].empty?
    if user
      user.update(facebook_uid: facebook['id'])
      return user
    end
    User.create do |user|
      user.facebook_uid = facebook['id']
      user.email = facebook['email']
      user.password = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')[0, 20]
      user.first_name = facebook['first_name']
      user.last_name = facebook['last_name']
    end
  end

  def password
    @password ||= Password.new(self.encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
end
