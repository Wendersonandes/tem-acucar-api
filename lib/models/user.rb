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

  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end

  def send_email(subject, message)
    @mandrill ||= Mandrill::API.new
    message = @mandrill.messages.send_template 'tem-acucar', [{name: 'first_name', content: self.first_name}, {name: 'message', content: message}], {subject: subject, to: [{email: self.email, name: self.full_name}]}
    message.is_a?(Array) && message[0] && message[0]["status"] == "sent"
  end

  def send_reset_password_token
    token = SecureRandom.urlsafe_base64(6).tr('lIO0', 'sxyz')[0, 8].upcase
    if self.send_email('Instruções para nova senha', "Para criar uma nova senha, digite o código abaixo no app do Tem Açucar:<br/><br/>#{token}<br/><br/>Se você não solicitou uma nova senha, por favor desconsidere.")
      self.update({
        reset_password_token: Password.create(token),
        reset_password_sent_at: Time.now,
      })
    else
      false
    end
  end
end
