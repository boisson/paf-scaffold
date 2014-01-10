require 'fileutils'
require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ScaffoldGenerator < ResourceGenerator #metagenerator
      source_root File.expand_path('../templates', __FILE__)

      remove_hook_for :resource_controller
      remove_class_option :actions

      class_option :stylesheets, :type => :boolean, :desc => "Generate Stylesheets"
      class_option :stylesheet_engine, :desc => "Engine for Stylesheets"

      hook_for :scaffold_controller, :required => true

      hook_for :assets do |assets|
        invoke assets, [controller_name]
      end

      hook_for :stylesheet_engine do |stylesheet_engine|
        invoke stylesheet_engine, [controller_name] if options[:stylesheets] && behavior == :invoke
      end

      # Copia os arquivos de datatable para as pastas de javascripts e buscas de acordo com o modelo
      def copy_datatable
        template('datatable.js.coffee', File.join('app/assets/javascripts', "#{plural_table_name}_datatable.js.coffee"))
        template('datatable.rb', File.join('app/datatables', "#{plural_table_name}_datatable.rb"))
        template('views/list.html.erb', File.join('app/views/', controller_file_path, "_list.html.erb"))
      end

      # copia os arquivos de internacionalizacao
      def copy_i18n_models
        FileUtils.mkpath(File.join('config/locales/models', plural_table_name))
        ['en','pt-BR','pt','es-ES','nl','fr','it'].each do |t|
          @current_language = t
          template('i18n_model.yml', File.join('config/locales/models', plural_table_name, "#{t}.yml"))
        end
      end

      def copy_migration_file
        file_name = "_create_#{singular_table_name}_versions.rb"
        Dir["db/migrate/**#{file_name}"].each{|i| File.delete(i) }
        time_now = (Time.now+5.seconds).utc.strftime("%Y%m%d%H%M%S")
        template('create_versions.rb', "db/migrate/#{time_now}#{file_name}")
        template('model_version.rb', File.join('app/models', "#{singular_table_name}_version.rb"))
        template('versions.html.erb', File.join('app/views/', controller_file_path, "_versions.html.erb"))
      end

      def fix_model
        if File.exists?(File.join('app/models',class_path,"#{singular_table_name}.rb"))
          content = []
          File.open(File.join('app/models',class_path,"#{singular_table_name}.rb"), 'r') do |f1|  
            while line = f1.gets  
              content << line
              if line.scan(/< ActiveRecord::Base/).size > 0
                content << "  acts_as_xlsx\n" 
                content << "  has_paper_trail class_name: '#{class_name}Version'\n"

                custom_accessibles      = []
                associations_to_exclude = []
                attributes.each do |_attribute|
                  # references fixes
                  if _attribute.type == :references
                    custom_accessibles << ":#{_attribute.name}_id"
                    custom_accessibles << ":#{_attribute.name}"
                    associations_to_exclude << "#{_attribute.name}_id"
                    associations_to_exclude << "#{_attribute.name}"
                  end

                  # n to n fixes
                  if _attribute.type == :n_to_n_inline || _attribute.type == :n_to_n_2_columns
                    classes = [plural_table_name, _attribute.name].sort
                    association_n_to_n_name = "#{classes.first}_#{classes.last}"

                    content << "\thas_many :#{association_n_to_n_name}\n"
                    content << "\thas_many :#{_attribute.name}, through: :#{association_n_to_n_name}\n"
                    custom_accessibles << ":#{_attribute.name.singularize}_ids"
                    associations_to_exclude << "#{_attribute.name.singularize}_ids"
                  end

                  # one to n fixes
                  if _attribute.type == :one_to_n
                    content << "\thas_many :#{_attribute.name}\n"
                    custom_accessibles << ":#{_attribute.name.singularize}_ids" 
                    associations_to_exclude << "#{_attribute.name.singularize}_ids"
                  end
                  
                end

                content << "\tattr_accessible #{custom_accessibles.join(', ')}\n" if custom_accessibles.size > 0
                content << "\n\tUNRANSACKABLE_ATTRIBUTES = %w[#{associations_to_exclude.join(' ')}]\n" if associations_to_exclude.size > 0
                content << "\tinclude RansackableAttributes\n\n"
                
              end
            end
          end
          File.open(File.join('app/models',class_path,"#{singular_table_name}.rb"), 'w') do |f1|
            f1.write(content.join)
          end
        end
      end
      
      def fix_crud
        template('views/show.html.erb', File.join('app/views/', controller_file_path, "_show.html.erb"))
        template('views/show.js.erb', File.join('app/views/', controller_file_path, "show.js.erb"))
        
        template('views/edit.html.erb', File.join('app/views/', controller_file_path, "_edit.html.erb"))
        template('views/edit.js.erb', File.join('app/views/', controller_file_path, "edit.js.erb"))
        
        template('views/save.js.erb', File.join('app/views/', controller_file_path, "save.js.erb"))
        
        show_html_path = File.join('app/views',class_path,"show.html.erb")
        File.delete(show_html_path) if File.exists?(show_html_path)
        
        edit_html_path = File.join('app/views',class_path,"edit.html.erb")
        File.delete(edit_html_path) if File.exists?(edit_html_path)
      end
      
      def fix_routes
        insert_into_file "config/routes.rb", "\tmatch '#{plural_table_name}/batch_destroy', :via => :delete\n", :after => "::Application.routes.draw do\n"
        # gsub_file 'config/routes.rb', "  resources :#{plural_table_name}", "  resources :#{plural_table_name} do\n    get 'batch_destroy', :on => :collection\n  end"
      end

      def fix_rspecs
        template('spec/controllers/controller_spec.rb', File.join('spec/controllers', "#{plural_table_name}_controller_spec.rb"))
        create_file("spec/fixtures/#{plural_table_name}.yml")
      end

    end
  end
end
