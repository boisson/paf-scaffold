module ActionDispatch::Routing
  class Mapper
    def paf_scaffold(*resources)
      if resources.include?(:datatable)
        get  "datatable/i18n"
        post "datatable/update_column/:base_class/:column/:id" => "datatable#update_column", :as => "update_column"
      end

      if resources.include?(:versions)
        post "versions/:id/revert/:base_class" => "versions#revert", :as => "revert_version"
        get  "versions/of_model/:base_class" => "versions#versions_of_model", :as => "versions_of_model"
      end

      if resources.include?(:import)
        post "import_rows/import/:base_class" => "import_rows#import", :as => "import_rows"
        get  "import_rows/download/:base_class" => "import_rows#download", :as => "download_example_file_to_import"
      end

      if resources.include?(:export)
        get  "export_data/export_xlsx/:base_class" => "datatable#export_xlsx", :as => "export_data_in_xlsx"
        get  "export_data/export_pdf/:base_class" => "datatable#export_pdf", :as => "export_data_in_pdf"
      end
    end
  end
end