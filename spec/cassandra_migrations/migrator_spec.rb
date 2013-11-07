# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Migrator do
  
  subject{ CassandraMigrations::Migrator }
  
  its(:get_all_migration_names){ should eq ['spec/fixtures/migrations/100_create_posts.rb']}
  
end