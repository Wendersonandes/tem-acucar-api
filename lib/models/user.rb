class User < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  def password=(password)
    # TODO encrypt password
    self.encrypted_password = password
  end
end
