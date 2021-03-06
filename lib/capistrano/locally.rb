require "capistrano/locally/version"
require "capistrano/dsl"

module Capistrano
  module Locally
  end
end


module Capistrano
  module DSL
    alias original_on on

    def on(hosts, options={}, &block)
      return unless hosts
      if hosts.is_a? Capistrano::Configuration::Server
        if hosts.hostname.to_s == 'localhost'
          localhost = hosts
        else
          localhost = nil
        end
      else
        localhosts, remotehosts = hosts.partition { |h| h.hostname.to_s == 'localhost' }
        localhost = Configuration.env.filter(localhosts).first
      end

      unless localhost.nil?
        if dry_run?
          SSHKit::Backend::Printer
        else
          SSHKit::Backend::Local
        end.new(localhost, &block).run
      end

      original_on(remotehosts, options={}, &block)
    end

    private
    def dry_run?
      fetch(:sshkit_backend) == SSHKit::Backend::Printer
    end
  end
end
