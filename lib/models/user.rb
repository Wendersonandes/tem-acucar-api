require 'bcrypt'

class User < Sequel::Model
  include BCrypt

  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence
  plugin :geocoder
  reverse_geocoded_by :latitude, :longitude

  one_to_many :tokens
  one_to_many :authentications
  one_to_many :demands

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
      user.email = facebook['email'] || "#{facebook['id']}@facebook.com"
      user.password = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')[0, 20]
      user.first_name = facebook['first_name'] || 'Nome'
      user.last_name = facebook['last_name'] || 'Sobrenome'
    end
  end

  def neighbors
    User.near([self.latitude, self.longitude], 1, units: :km)
  end

  def neighborhood_demands
    Demand
      .where("id NOT IN (SELECT demand_id FROM refusals WHERE user_id = '#{self.id}')")
      .where("user_id <> '#{self.id}'")
      .with_state(:active)
      .near([self.latitude, self.longitude], 1, units: :km, order: false)
      .order(:distance, Sequel.desc(:created_at))
  end

  def demands_with_transactions
    Demand
      .where("id IN (SELECT DISTINCT demand_id FROM transactions INNER JOIN messages ON messages.transaction_id = transactions.id INNER JOIN demands ON transactions.demand_id = demands.id WHERE messages.user_id = '#{self.id}' OR demands.user_id = '#{self.id}')")
      .reverse(:updated_at)
  end

  def image_url
    uploaded_image_url || facebook_image_url || facebook_picture_url || gravatar_url
  end

  def facebook_picture_url
    return unless self.facebook_uid
    "http://graph.facebook.com/#{self.facebook_uid}/picture?type=normal"
  end

  def gravatar_url
    gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=128&d=mm"
  end

  def password
    @password ||= Password.new(self.encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end

  def password_token
    @password_token ||= (self.encrypted_password_token && Password.new(self.encrypted_password_token))
  end

  def password_token=(new_token)
    @password_token = Password.create(new_token.upcase)
    self.encrypted_password_token = @password_token
  end

  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end

  def send_email(subject, message)
    @mandrill ||= Mandrill::API.new
    message = @mandrill.messages.send_template 'tem-acucar', [{name: 'first_name', content: self.first_name}, {name: 'message', content: message}], {subject: subject, to: [{email: self.email, name: self.full_name}]}
    message.is_a?(Array) && message[0] && message[0]["status"] == "sent"
  end

  def send_password_token
    token = SecureRandom.urlsafe_base64(6).tr('lIO0', 'sxyz')[0, 8].upcase
    if self.send_email('Instruções para nova senha', "Para criar uma nova senha, digite o código abaixo no app do Tem Açúcar:<br/><br/>#{token}<br/><br/>Se você não solicitou uma nova senha, por favor desconsidere.")
      self.password_token = token
      self.password_token_sent_at = Time.now
      self.save
    else
      false
    end
  end
end
