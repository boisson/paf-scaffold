require 'rails/generators'
module ProtesteScaffold
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy ProtesteScaffold files"
      source_root File.expand_path('../templates', __FILE__)
      class_option :first_install, :type => :boolean, :default => true, desc: 'install of simple_form, ckeditor and rspec.'


      def run_generators
        if options.first_install?
          generate("simple_form:install", "--bootstrap")
          generate("ckeditor:install", "--orm=active_record --backend=paperclip")
          generate("rspec:install")
        end
      end

      def adjust_rspec
        if options.first_install?
          copy_file '.rspec'
        end
      end

      def adjust_gemfile
        if options.first_install?
          gem_group :development, :test do
            gem "rspec"
            gem "rspec-rails"
          end
        end
      end

      def copy_app_files
        directory 'app'
      end

      def copy_config_files
        directory 'config'
      end

      def copy_generator_files
        directory 'lib'
      end

      def copy_public_files
        directory 'public'
      end

      def copy_spec_utilities_files
        directory 'spec'
      end

      def write_routes
        route("paf_scaffold :datatable, :versions, :import, :export")
      end
    end
  end
end