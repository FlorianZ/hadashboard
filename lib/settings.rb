require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:persistent.db')

class Setting
  include DataMapper::Resource

  property :name, String, :key => true
  property :value, Text
end

DataMapper.finalize
DataMapper.auto_upgrade!
