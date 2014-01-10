require 'active_support'
module ProtesteScaffold
  module Controller
    extend ActiveSupport::Concern

    included do
      
    end

    def respond_to_grid(datatable_class)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: datatable_class.new(view_context) }
        format.pdf { 
          export_pdf = datatable_class.new(view_context).as_pdf
          send_file export_pdf.render, filename: export_pdf.file_name, type: export_pdf.mime_type
        }
        format.xlsx { 
          export_xlsx = datatable_class.new(view_context).as_xlsx
          send_file export_xlsx.render, filename: export_xlsx.file_name, type: export_xlsx.mime_type
        }
        format.print {
          @print = datatable_class.new(view_context).as_print
          render layout: 'print.html.erb', file: 'export/output'
        }
      end
    end
  end
end