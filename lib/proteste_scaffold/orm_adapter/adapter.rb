require 'active_support'
require 'active_record'

module ProtesteScaffold
  module OrmAdapter
    module SchemaDefinitions

      # for simple effect that works on migration
      module ExtraMethod
        def n_to_n_inline(*args)
          # options = args.extract_options!
          true
        end

        def n_to_n_2_columns(*args)
          # options = args.extract_options!
          true
        end

        def one_to_n(*args)
          # options = args.extract_options!
          true
        end
      end

      def self.load!
        ::ActiveRecord::ConnectionAdapters::TableDefinition.class_eval { include ProtesteScaffold::OrmAdapter::SchemaDefinitions::ExtraMethod }
      end
    end
  end
end


ActiveSupport.on_load :active_record do
  ProtesteScaffold::OrmAdapter::SchemaDefinitions.load!
end