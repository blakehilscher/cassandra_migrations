# encoding: utf-8

module CassandraMigrations
  module Config
    
    def self.method_missing(method_sym, *arguments, &block) 
      CassandraMigrations.configuration.send(method_sym)
    end

    def self.connection_options
      options = {
        host:         host,
        port:         port,
      }
      options.merge!(consistency: consistency) if consistency
      options.merge!(credentials: credentials) if credentials
      options
    end
    
  end
  
  class << self
    attr_accessor :configuration
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.load_config_from_file(path, env)
    begin
      config = YAML.load_file( path )[ env ]
      # raise missing config
      raise Errors::MissingConfigurationError, "No configuration for #{env} environment in #{path}!" if config.nil?
      # assign config
      config.each{|k,v| self.configuration.send("#{k}=",v) if configuration.respond_to?("#{k}=") }
    rescue Errno::ENOENT
      raise Errors::MissingConfigurationError
    end
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
    end
    
  end
end