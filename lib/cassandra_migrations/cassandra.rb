# encoding: utf-8

require 'yaml'
require 'cql'
require 'cassandra_migrations/cassandra/queries'
require 'cassandra_migrations/cassandra/query_result'
require 'cassandra_migrations/cassandra/keyspace_operations'

module CassandraMigrations
  module Cassandra
    extend Queries
    extend KeyspaceOperations
    
    def self.start!
      use(Config.keyspace)
    end
    
    def self.restart!
      raise Errors::ClientNotStartedError unless client

      client.close if client && client.connected?
      self.client = nil
      start!
    end
    
    def self.shutdown!
      raise Errors::ClientNotStartedError unless client

      client.close if client.connected?
      self.client = nil
    end
    
    def self.use(keyspace)
      connect_to_server unless client

      begin
        client.use(keyspace)
      rescue Cql::QueryError # keyspace does not exist
        raise Errors::UnexistingKeyspaceError, keyspace
      end
    end

    def self.execute(cql)
      connect_to_server unless client
      result = client.execute(cql, Config.consistency )
      QueryResult.new(result) if result
    end  
    
    def self.client=(value)
      @client = value
    end
    def self.client
      @client
    end
    
  private
    
    def self.connect_to_server
      begin
        self.client = Cql::Client.connect(Config.connection_options)
        use(Config.keyspace)
        self.client
        
      rescue Cql::Io::ConnectionError => e
        raise Errors::ConnectionError, e.message      
      end
    end
  end
end
