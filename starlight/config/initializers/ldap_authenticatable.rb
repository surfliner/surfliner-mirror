# frozen_string_literal: true

require 'net/ldap'
require 'devise/strategies/authenticatable'

# https://github.com/plataformatec/devise/wiki/How-To:-Authenticate-via-LDAP
module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        return unless params[:user]

        conf = ldap_conf[Rails.env]
        connection = Net::LDAP.new(makeopts(conf))

        return fail(:invalid_login) unless connection.bind

        groups = connection.bind_as(
          password: password,
          filter: "(#{conf['filter']}=#{email})",
          base: conf['group_base']
        )

        return fail(:invalid_login) unless groups

        user = User.find_or_create_by(email: email)

        success!(user)
      end

      def email
        # Active Directory always uses @library.ucsb.edu, so convert adunn and
        # adunn@ucsb.edu to adunn@library.ucsb.edu
        params[:user][:email]
          .sub(/@(library\.)?ucsb\.edu/, '') + '@library.ucsb.edu'
      end

      def password
        params[:user][:password]
      end

      def ldap_conf
        @conf ||= YAML.safe_load(
          ERB.new(File.read(Rails.root.join('config', 'ldap.yml'))).result,
          # by default #safe_load doesn't allow aliases
          # https://github.com/ruby/psych/blob/2884f7bf8d1bd6433babe6b7b8e4b6007e59af97/lib/psych.rb#L290
          [], [], true
        )
      end

      def makeopts(conf)
        opts = {
          host: conf['host'],
          port: conf['port'],
          auth: {
            method: :simple,
            username: conf['admin_user'],
            password: conf['admin_pass']
          }
        }
        opts[:encryption] = { method: :simple_tls } if conf['ssl']
        opts
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
