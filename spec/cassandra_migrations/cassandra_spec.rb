# encoding : utf-8
require 'spec_helper'

describe CassandraMigrations::Cassandra do
  
  before do
    Rails.stub(:root).and_return Pathname.new("spec/fixtures")
    Rails.stub(:env).and_return ActiveSupport::StringInquirer.new("development")
  end
  
  after do
    CassandraMigrations::Cassandra.client = nil
    CassandraMigrations::Config.config = nil
  end
  
  describe '.execute' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = mock('cql_client')
      Cql::Client.should_receive(:connect).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      cql_client_mock.should_receive(:execute).with('anything').and_return(nil)
    
      CassandraMigrations::Cassandra.execute('anything').should be_nil
    end
    
    it 'raise exception if there is something wrong with the connection' do
      Cql::Client.should_receive(:connect).and_raise(Cql::Io::ConnectionError)

      expect {    
        CassandraMigrations::Cassandra.execute('anything')
      }.to raise_exception CassandraMigrations::Errors::ConnectionError
    end
    
    it 'should return a QueryResult if the query returns something' do
      CassandraMigrations::Cassandra.client = mock('cql_client')
      
      result_mock = mock('result_mock')
      CassandraMigrations::Cassandra.client.should_receive(:execute).with('anything').and_return(result_mock)
      
      result = CassandraMigrations::Cassandra.execute('anything')
      result.should_not be_nil
      result.should be_a(CassandraMigrations::Cassandra::QueryResult)
    end

  end
  
  describe '.use' do
    it 'should connect to cassandra using host and port configured' do
      cql_client_mock = mock('cql_client')
      Cql::Client.should_receive(:connect).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      cql_client_mock.should_receive(:use).with('anything').and_return(nil)
    
      CassandraMigrations::Cassandra.use('anything').should be_nil
    end
    
    it "should raise exception if configured keyspace does not exist" do
      cql_client_mock = mock('cql_client')
      Cql::Client.should_receive(:connect).with(:host => '127.0.0.1', :port => 9042).and_return(cql_client_mock)
      cql_client_mock.should_receive(:use).with('anything') { raise Cql::QueryError.new("code", "msg", "cql") }

      expect {
        CassandraMigrations::Cassandra.use('anything')
      }.to raise_exception CassandraMigrations::Errors::UnexistingKeyspaceError
    end
  end
  
  describe ".start!" do
    it "should use configured keyspace" do
      CassandraMigrations::Cassandra.should_receive(:use).with('cassandra_migrations_test')
      CassandraMigrations::Cassandra.start!
    end
  end
   
  describe "query interface" do
    it "should respond to query helper methods" do
      CassandraMigrations::Cassandra.should respond_to :select
      CassandraMigrations::Cassandra.should respond_to :write!
      CassandraMigrations::Cassandra.should respond_to :update!
      CassandraMigrations::Cassandra.should respond_to :delete!
      CassandraMigrations::Cassandra.should respond_to :truncate!
    end
  end
  
  describe "keyspace interface" do
    it "should respond to keyspace helper methods" do
      CassandraMigrations::Cassandra.should respond_to :create_keyspace!
      CassandraMigrations::Cassandra.should respond_to :drop_keyspace!
    end
  end
end
