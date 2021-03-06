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
  one_to_many :reviews
  one_to_many :notifications

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
    User.where("id <> '#{self.id}'").near([self.latitude, self.longitude], 1, units: :km)
  end

  def neighbors_count
    self.neighbors.count
  end

  def neighbors_image_url
    return unless self.latitude && self.longitude
    decimals = 3
    neighbors = self.neighbors.map{ |neighbor| [neighbor.latitude.round(decimals), neighbor.longitude.round(decimals)].join(",") }.uniq
    # Removes users from the list in a well distributed fashion until we have fewer neighbors
    remove_from = :start
    while neighbors.length > 100 do
      if remove_from == :start
        index = 1
        remove_from = :middle
      elsif remove_from == :middle
        index = neighbors.length / 2
        remove_from = :end
      elsif remove_from == :end
        index = neighbors.length - 2
        remove_from = :start
      end
      neighbors = neighbors[0..index - 1] + neighbors[index + 1...neighbors.length]
    end
    params = {
      :center => [self.latitude, self.longitude].join(","),
      :zoom => "14",
      :size => "600x240",
      :markers => "icon:http://goo.gl/GP6PtM%7C" + neighbors.join("%7C")
    }
    query_string = params.map{ |key, value| "#{key}=#{value}" }.join("&")
    url = "http://maps.googleapis.com/maps/api/staticmap?#{query_string}"
    # Redirects from Bitly are not working on Android. Let's use the long URL for now
    # Bitly.client.shorten(url).short_url
  end

  def neighborhood_demands
    Demand
      .select(:id, :user_id, :state, :name, :description, :latitude, :longitude, :radius, :created_at, :updated_at)
      .select_append(Sequel.lit("(6371.0 * 2 * ASIN(SQRT(POWER(SIN((#{self.latitude} - latitude) * PI() / 180 / 2), 2) + COS(#{self.latitude} * PI() / 180) * COS(latitude * PI() / 180) * POWER(SIN((#{self.longitude} - longitude) * PI() / 180 / 2), 2)))) AS distance"))
      .where("id NOT IN (SELECT demand_id FROM refusals WHERE user_id = '#{self.id}')")
      .where("id NOT IN (SELECT demand_id FROM transactions WHERE user_id = '#{self.id}')")
      .where("user_id <> '#{self.id}'")
      .where("state = 'active' OR (state = 'notifying' AND id IN (SELECT DISTINCT demand_id FROM notifications WHERE user_id = '#{self.id}'))")
      .where("((6371.0 * 2 * ASIN(SQRT(POWER(SIN((#{self.latitude} - latitude) * PI() / 180 / 2), 2) + COS(#{self.latitude} * PI() / 180) * COS(latitude * PI() / 180) * POWER(SIN((#{self.longitude} - longitude) * PI() / 180 / 2), 2)))) BETWEEN 0.0 AND demands.radius)")
      .order(Sequel.desc(Sequel.function(:date_trunc, 'day', :created_at)), :distance)
  end

  def demands_with_transactions
    Demand
      .where("id IN (SELECT DISTINCT demand_id FROM transactions INNER JOIN demands ON transactions.demand_id = demands.id WHERE demands.user_id = '#{self.id}') OR id IN (SELECT DISTINCT demand_id FROM transactions WHERE user_id = '#{self.id}')")
      .near([self.latitude, self.longitude], 41000, units: :km, order: false)
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
    Workers::Email.perform_async(self.id, subject, message)
  end

  def send_password_token
    length = 4
    rlength = (length * 3) / 4
    token = SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')[0, length].upcase
    self.send_email('Instruções para nova senha', "Para criar uma nova senha, digite o código abaixo no app do Tem Açúcar:\n\n#{token}\n\nSe você não solicitou uma nova senha, por favor desconsidere.")
    self.password_token = token
    self.password_token_sent_at = Time.now
    self.save
  end
end
