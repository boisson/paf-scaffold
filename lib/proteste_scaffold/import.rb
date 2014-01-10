require 'csv'
require 'iconv'
require 'tempfile'
require 'simple_xlsx'

module ProtesteScaffold
  class Import
    attr_accessor :rows_success, :rows_error, :total_entries, :klass, :file

    def initialize(class_name, file)
      self.klass          = Kernel.const_get(class_name)
      self.file           = file
      self.total_entries  = 0
      self.rows_success   = []
      self.rows_error     = []
    end

    def errors_file(directory_path = nil)      
      filename    = Time.now.strftime("%d%m%Y")+"_#{self.klass.to_s}_"+Time.now.strftime("%H%M")+".csv"
      if directory_path
        FileUtils.mkdir_p(directory_path)
        filename  = File.join(directory_path,filename)
      end
      File.delete(filename) if File.exists?(filename)

      CSV.open(filename, "wb", col_sep: ';') do |csv|
        csv << [I18n.t('general.export.errors.quantity_registers'), self.total_entries]
        csv << [I18n.t('general.export.errors.quantity_success'),   self.rows_success.size]
        csv << [I18n.t('general.export.errors.quantity_rejected'),  self.rows_error.size]
        self.rows_error.each do |object|
          csv << [I18n.t('general.export.errors.line_rejected', line: object[:row]), object[:object].errors.full_messages.join(", ")]
        end        
      end
      File.open(filename)
    end

    def import
      spreadsheet = ProtesteScaffold::Import.open_spreadsheet(self.file)
      header      = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        self.total_entries = self.total_entries + 1

        row = Hash[[header, spreadsheet.row(i)].transpose]
        object = self.klass.find_by_id(row["id"]) || self.klass.new
        object.attributes = parse_values(row)
        if object.save
          self.rows_success << object
        else
          self.rows_error << {row: i, object: object}
        end
      end
      true
    end

    def parse_values(row)
      boolean_columns       = self.klass.columns.collect{|t| t.name.to_s if t.type == :boolean}
      float_columns         = self.klass.columns.collect{|t| t.name.to_s if t.type == :float}
      integer_columns       = self.klass.columns.collect{|t| t.name.to_s if t.type == :integer}
      belongs_to_columns    = self.klass.reflect_on_all_associations(:belongs_to).collect{|t| t.name.to_s}
      has_many_columns      = self.klass.reflect_on_all_associations(:has_many).collect{|t| t.name.to_s unless t.options[:through]}.compact
      many_to_many_columns  = self.klass.reflect_on_all_associations(:has_many).collect{|t| t.name.to_s if t.options[:through]}.compact

      attributes = row.to_hash.slice(*self.klass.accessible_attributes)
      attributes.each do |column,value|
        begin
          if belongs_to_columns.include?(column) || (column[-3,3] == '_id' && belongs_to_columns.include?(column[0..-4]))
            _column = column[-3,3] == '_id' ? column[0..-4] : column

            klass_association   = belongs_to_columns.find{|t| t == _column }.classify.constantize
            association_object  = klass_association.find_by_name(value.strip)
            if association_object
              if _column == column
                attributes[column] = association_object 
              else
                attributes[column] = association_object.id
              end
            end
          elsif has_many_columns.include?(column)
            klass_association   = column.singularize.classify.constantize
            names               = value.split(',').collect{|t| t.strip}
            attributes[column]  = []
            names.each do |name|
              association_finded = klass_association.where(
                ["name LIKE :s", s: "%#{name}%"]
              ).first
              attributes[column] << association_finded if association_finded
            end
          elsif many_to_many_columns.include?(column)
            klass_association   = column.singularize.classify.constantize
            names               = value.split(',').collect{|t| t.strip}
            attributes[column]  = []
            names.each do |name|
              association_finded = klass_association.where(
                ["name LIKE :s", s: "%#{name}%"]
              ).first
              attributes[column] << association_finded if association_finded
            end
          elsif boolean_columns.include?(column)
            attributes[column] = value.to_f > 0 ? true :  false
          elsif float_columns.include?(column)
            attributes[column] = value.to_f
          elsif integer_columns.include?(column)
            attributes[column] = value.to_i
          end
        rescue => m
          puts m.message
          puts m.backtrace
          puts "---------------"
          # attributes[column] = nil
        end
        
      end
      attributes
    end

    def self.open_spreadsheet(file)
      # raise File.extname(file.original_filename).inspect
      if File.extname(file.original_filename).include?(".xlsx")
        Roo::Excelx.new(file.path, nil, :ignore)
      # when ".ods" then Roo::Openoffice.new(file.path)
      # when ".csv" then Roo::Csv.new(file.path, {:col_sep => ";"}, :ignore)
      # when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      else
        raise 'Use xlsx files'
      end
    end

    def self.example_file(class_name, directory_path, excluded_columns = [], forced_columns = [])
      excluded_columns ||= []
      forced_columns   ||= []
      class_name         = Kernel.const_get(class_name)
      filename           = "#{class_name}.xlsx"
      filename           = File.join(directory_path,filename)
      belongs_to_columns = class_name.reflect_on_all_associations(:belongs_to).collect{|t| t.name.to_s}
      FileUtils.mkdir_p(directory_path)
      File.delete(filename) if File.exists?(filename)

      f = SimpleXlsx::Serializer.new(filename) do |doc|
        doc.add_sheet("Sheet 1") do |sheet|
          accessible_attributes = class_name.accessible_attributes.to_a
          accessible_attributes = accessible_attributes.delete_if do |t|
            (
              t.blank? || excluded_columns.include?(t) || t[-4,4] == '_ids' || 
              (t[-3,3] == '_id' && belongs_to_columns.include?(t[0..-4]))
            )
          end
          sheet.add_row((forced_columns+accessible_attributes).uniq)
        end
      end

      File.open(filename)
    end
  end
end