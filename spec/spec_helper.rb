require 'bundler'
Bundler.setup

require 'rails/all'
require 'pry'

require 'rspec'
require 'cassandra_migrations'

CassandraMigrations.load_config_from_file(Pathname.new("spec/fixtures/config/cassandra.yml"), 'test')
CassandraMigrations.configure do |c|
  c.migrations_path = Pathname.new("spec/fixtures/migrations/")
end