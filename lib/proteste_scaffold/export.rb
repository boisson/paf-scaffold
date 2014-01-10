require 'prawn'
require 'csv'
require 'tempfile'
require 'simple_xlsx'

module ProtesteScaffold
  module Export
    URL_PDF   = File.join('public', 'pdf_exporteds')
    URL_XLSX  = File.join('public', 'xlsx_exporteds')

    module Common
      ARRAY_SEPARATOR = ']['

      def initialize(directory_path = nil)
        @directory_path = directory_path
      end

      def columns=(value)
        @columns = value.to_s.split(ARRAY_SEPARATOR).collect{|t| t.to_sym}
      end

      def columns
        @columns
      end

      def column_names=(value)
        @column_names = value.to_s.split(ARRAY_SEPARATOR).find_all{|t| !t.blank?}
        @column_names = columns if @column_names.size == 0
      end

      def column_names
        @column_names
      end

      def page_title=(value)
        @page_title = value
      end

      def page_title
        @page_title
      end

      def records=(value)
        @records = value
      end

      def records
        @records
      end

      def build_class
        raise 'no records' if records.blank?
        @object_instance ||= records.first.class
      end

      def many_to_many_columns
        if @many_to_many_columns.nil?
          @many_to_many_columns = []
          @many_to_many_columns += build_class.reflect_on_all_associations(:has_many).collect{|t| t.name.to_sym if t.options[:through]}.compact
          @many_to_many_columns += build_class.reflect_on_all_associations(:has_and_belongs_to_many).collect{|t| t.name.to_sym }.compact
        end
        @many_to_many_columns
      end

      def belongs_to_columns
        @belongs_to_columns ||= build_class.reflect_on_all_associations(:belongs_to).collect{|t| t.name.to_sym }.compact
      end

      def has_many_columns
        @has_many_columns ||= build_class.reflect_on_all_associations(:has_many).collect{|t| t.name.to_sym unless t.options[:through]}.compact
      end

      def date_columns
        @date_columns ||= build_class.columns.collect{|t| t.name.to_sym if t.type == :date || t.type == :datetime}.compact
      end

      def boolean_columns
        @boolean_columns ||= build_class.columns.collect{|t| t.name.to_sym if t.type == :boolean }.compact
      end

      def parse_value(object, column)
        if column_is_association?(column)
          column_parts       = column.to_s.split('.')
          association_name   = column_parts.first.to_sym
          association_column = column_parts.size > 1 ? column_parts.last.to_sym : :name

          if belongs_to_columns.include?(association_name.to_s.singularize.to_sym)
            object.send(association_name.to_s.singularize.to_sym).send(association_column)
          elsif has_many_columns.include?(association_name)
            object.send(association_name).collect{|t| t.read_attribute(association_column)}.find_all{|t| !t.blank? }.join(',')
          elsif many_to_many_columns.include?(association_name)
            object.send(association_name).collect{|t| t.read_attribute(association_column)}.find_all{|t| !t.blank? }.join(',')
          end
        else
          column = column.to_s.split('.').last.to_sym
          if boolean_columns.include?(column)
            if object.send(column)
              I18n.t('general.terms.yes')
            else
              I18n.t('general.terms.no')
            end
          else
            object.send(column)
          end
          
        end
      rescue => e
        puts "--error: #{e.message}"
        ""
      end

      def column_is_association?(column)
        column_parts        = column.to_s.split('.')
        possible_table_name = column_parts.first.to_sym

        if column_parts.length == 1
          (has_many_columns.include?(possible_table_name) || belongs_to_columns.include?(possible_table_name) || many_to_many_columns.include?(possible_table_name))
        else
          second_part_of_column_parts = column_parts[1].to_sym
          if possible_table_name.to_s == build_class.table_name
            (has_many_columns.include?(second_part_of_column_parts) || belongs_to_columns.include?(second_part_of_column_parts.to_s.singularize.to_sym) || many_to_many_columns.include?(second_part_of_column_parts))            
          else
            (has_many_columns.include?(possible_table_name) || belongs_to_columns.include?(possible_table_name.to_s.singularize.to_sym) || many_to_many_columns.include?(possible_table_name))
          end
        end
      end

      def line_item_rows=(value)
        @line_item_rows = value
      end

      def line_item_rows
        unless @line_item_rows
          @line_item_rows = []
          @line_item_rows << column_names
          records.each do |record|
            @line_item_rows << columns.collect{|column| parse_value(record, column).to_s}
          end
        end
        @line_item_rows
      end

      def file_name=(value)
        @file_name = value
      end
    end

    class Print
      include ProtesteScaffold::Export::Common

      def headers
        @headers ||= line_item_rows.first
      end

      def table_lines
        @table_lines ||= line_item_rows[1..-1]
      end
    end

    class XLSX
      include ProtesteScaffold::Export::Common

      def mime_type
        "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
      end

      def file_name
        @file_name || "#{page_title}.xlsx"
      end

      def render
        raise "Directory path is empty" if @directory_path.blank?
        
        FileUtils.mkdir_p(@directory_path)
        file_name = File.join(@directory_path, self.file_name)
        File.delete(file_name) if File.exists?(file_name)

        SimpleXlsx::Serializer.new(file_name) do |doc|
          doc.add_sheet(page_title) do |sheet|
            rows = line_item_rows
            rows.each do |row|
              sheet.add_row(row)
            end
          end
        end

        file_name
      end
    end
 
    class PDF < Prawn::Document
      include ProtesteScaffold::Export::Common

      def mime_type
        "application/pdf"
      end

      def file_name
        @file_name || "#{page_title}.pdf"
      end

      def render
        raise "Directory path is empty" if @directory_path.blank?
        
        FileUtils.mkdir_p(@directory_path)
        file_name = File.join(@directory_path, self.file_name)
        File.delete(file_name) if File.exists?(file_name)

        pdf = Prawn::Document.new :page_layout => :landscape
        pdf.text page_title, size: 20, style: :bold
        pdf.table(line_item_rows, :column_widths => columns.collect{|t| 720/columns.size.to_f}, :width => 720) do |tt|
          tt.row_colors = ["DDDDDD", "FFFFFF"]
          tt.header     = true
        end
        pdf.render_file file_name

        file_name
      end
    end
  end
end
