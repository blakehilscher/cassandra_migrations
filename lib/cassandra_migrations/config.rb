# encoding: utf-8

module CassandraMigrations
  module Config
  
    mattr_accessor :config
    
    def self.method_missing(method_sym, *arguments, &block) 
      CassandraMigrations.configuration.send(method_sym)
    end

    def self.connection_options
      options = {
        host:         host,
        port:         port,
        consistency:  consistency,
      }
      options.merge!(:credentials => credentials) if credentials
      options
    end
    
  end
  
  class << self
    attr_accessor :configuration
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end
  
  def self.configure
    yield(configuration)
    true
  end
  
  class Configuration
  
    attr_accessor :host, :port, :keyspace, :replication, :credentials, :consistency, :migrations_path
    
    def initialize
      @host = "127.0.0.1"
      @port = 9042
      @keyspace = "cassandra_migrations_test"
      @replication = { 'class' => "SimpleStrategy", 'replication_factor' => 1 }
      @consistency = :one
    end
    
    def to_h
      self.attributes
    end
    
  end
  
end