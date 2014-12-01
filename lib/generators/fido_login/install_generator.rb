require 'rails/generators/base'
require 'securerandom'

module FidoLogin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a FidoLogin migration"

      # Rails implies Migration is mixed into Base (false), and there's no
      # explanation for why I must define this method. Clearly I'm missing
      # something stupid because there are no docs for this in Rails 4.
      include Rails::Generators::Migration
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migration
        migration_template "migration.rb", "db/migrate/create_fido_login_registrations.rb"
      end

      def copy_initializer
        copy_file "initializer.rb", "config/initializers/fido_login.rb"
      end

      def show_readme
        readme "README.md" if behavior == :invoke
      end
    end
  end
end
