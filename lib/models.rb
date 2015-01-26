require 'data_mapper'
require 'bcrypt'

# Initialize the DataMapper to use a database, if available. Fall back to an
# sqlite file, if no database has been set up.
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:persistent.db')

# Set object model for settings
class Setting
  include DataMapper::Resource

  property :name, String, :key => true
  property :value, Text
end

# User model
class User
    include DataMapper::Resource
    include BCrypt

    property :id, Serial, :key => true
    property :username, String, :length => 1..64
    property :password, BCryptHash 

    def authenticate(password)
        self.password == password
    end
end

# Finalize all models
DataMapper.finalize

# Up-migrate the schema
DataMapper.auto_upgrade!
