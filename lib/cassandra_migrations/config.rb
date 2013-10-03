# encoding: utf-8

module CassandraMigrations
  module Config
  
    mattr_accessor :config
    
    def self.method_missing(method_sym, *arguments, &block)
      load_config unless config    
      config[method_sym.to_s]
    end

    def self.connection_options
      options = {
        :host => host,
        :port => port
      }

      options.merge!(:credentials => credentials) if credentials
      options
    end
    
  private

    def self.load_config
      begin
        self.config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))[Rails.env]
      
        if config.nil?
          raise Errors::MissingConfigurationError, "No configuration for #{Rails.env} environment! Complete your config/cassandra.yml."
        end
      rescue Errno::ENOENT
        raise Errors::MissingConfigurationError
      end
    end
  
  end
end
