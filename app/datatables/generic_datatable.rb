class GenericDatatable
  EMPTY_VALUE = 'N/A'
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TranslationHelper

  delegate :strip_tags, :url_for, :content_tag, :yes_or_no, 
  :link_to, :number_to_currency, :form_for, :simple_form_for,
  :update_column_path, :session, to: :@view

  # to_dump discard @view to possibility dump object to delayed job
  def initialize(view, to_dump = false)
    @params = view.params
    @view   = view unless to_dump
  end

  def as_json(options = {})
    {
      sEcho: merged_params[:sEcho].to_i,
      iTotalRecords: total_records,
      iTotalDisplayRecords: total_entries,
      aaData: data
    }
  end

  def as_pdf(path = nil)
    path           ||= File.join(Rails.root, ProtesteScaffold::Export::URL_PDF)
    pdf              = ProtesteScaffold::Export::PDF.new(path)
    pdf.records      = fetch_results.page(1).per_page(total_records + 1)
    pdf.page_title   = merged_params[:page_title]
    pdf.columns      = merged_params[:columns]
    pdf.column_names = merged_params[:column_names]
    pdf
  end

  def as_xlsx(path = nil)
    path            ||= File.join(Rails.root, ProtesteScaffold::Export::URL_XLSX)
    xlsx              = ProtesteScaffold::Export::XLSX.new(path)
    xlsx.records      = fetch_results.page(1).per_page(total_records + 1)
    xlsx.page_title   = merged_params[:page_title]
    xlsx.columns      = merged_params[:columns]
    xlsx.column_names = merged_params[:column_names]
    xlsx
  end

  def as_print
    print              = ProtesteScaffold::Export::Print.new
    print.records      = fetch_results
    print.page_title   = merged_params[:page_title]
    print.columns      = merged_params[:columns]
    print.column_names = merged_params[:column_names]
    print
  end

  def total_entries
    results.total_entries
  end

  def total_records
    0
  end

  def export(path, file_name, format = :xlsx)
    case format
    when :pdf
      exporter = self.as_pdf(path)
    else
      exporter = self.as_xlsx(path)
    end

    exporter.file_name = file_name
    exporter.render
  end

  protected
    def crud_buttons(object)
      content_tag(:div, [
        button_show(object),
        button_edit(object),
        button_versions(object),
        button_delete(object),
        ].join(' ').html_safe, class: 'center_actions')
    end

    def button_show(object)
      link_to(text_with_icon(t('general.actions.show'),'icon-zoom-in',t('general.actions.show')), url_for(action: :show, id: object, only_path: true), title: t('general.actions.show'), class: 'btn btn-mini', remote: true)
    end

    def button_edit(object)
      link_to(text_with_icon(t('general.actions.edit'),'icon-edit',t('general.actions.edit')), url_for(action: :edit, id: object, only_path: true), title: t('general.actions.edit'), class: 'btn btn-mini', remote: true)
    end

    def button_versions(object)
      link_to(text_with_icon(t('general.actions.versions'),'icon-folder-open',t('general.actions.versions')), url_for(action: :edit, id: object, only_path: true, tab_versions: true), title: t('general.actions.versions'), class: 'btn btn-mini', remote: true)
    end

    def button_delete(object)
      link_to(text_with_icon('','icon-trash',I18n.t('general.actions.delete')), url_for(action: :show, id: object, only_path: true), remote: true, method: :delete, confirm: t('general.actions.confirm'), alt: t('general.actions.delete'), title: t('general.actions.delete'), class: 'btn btn-mini disabled')
    end

    def text_with_icon(text,icon,alt = nil)
      alt ||= text
      alt   = 'alt="'+alt+'" title="'+alt+'"' unless alt.blank?
      ('<i '+alt+' class="'+icon+'"></i> '+text).html_safe
    end

    def merged_params
      @params
    end

    def data
      []
    end

    def empty_or_value(value)
      css = 'show'

      if value.blank?
        css  += ' empty'
        value = EMPTY_VALUE
      end

      content_tag(:span, value, class: css)
    end

    def results
      @results ||= fetch_results
    end

    def fetch_results
      []
    end

    def page
      merged_params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      merged_params[:iDisplayLength] = merged_params[:iDisplayLength].to_i
      merged_params[:iDisplayLength] = total_records if merged_params[:iDisplayLength] == -1
      
      if merged_params[:iDisplayLength] > 0
        merged_params[:iDisplayLength]
      else
        10
      end
    end

    def sort_columns(default_column = 'id', columns_before_real_data = 1)
      columns = merged_params[:sColumns].split(',').reject{|t| t.blank?} unless merged_params[:sColumns].blank?

      sort_collection = []
      0.upto(merged_params[:iSortingCols].to_i - 1).each do |n_column|

        real_column     = merged_params["iSortCol_#{n_column}".to_sym].to_i - columns_before_real_data
        fields_on_table = columns[real_column].split("|")
        sort_collection << fields_on_table.collect{|t| "#{t} #{merged_params["sSortDir_#{n_column}".to_sym]}"}.join(',')
      end

      sort_collection.empty? ? default_column : sort_collection.join(', ')
    end


    def input_boolean(object, display_value,column)
      output = [empty_or_value(display_value)]

      return output.join.html_safe if object.class.columns_hash[column.to_s].type != :boolean

      form_for(object) do |ff|
        output << ff.check_box(column, class: 'hide', data: {update_column_path: update_column_path(object.class.to_s,column.to_s, object.id)})
        output << ff.label(column, object.class.human_attribute_name(column)+'?', class: 'hide')
      end

      output.join.html_safe
    end

    def input_text(object, display_value,column)
      output = [empty_or_value(display_value)]

      return output.join.html_safe unless [:string, :integer, :float, :number, :decimal].include?(object.class.columns_hash[column.to_s].type)

      form_for(object) do |ff|
        output << ff.text_field(column, class: 'input-small hide', data: {update_column_path: update_column_path(object.class.to_s,column.to_s,object.id)})
      end

      output.join.html_safe
    end

    def input_date(object, display_value, column)
      output = [empty_or_value(display_value)]

      return output.join.html_safe if object.class.columns_hash[column.to_s].type != :date

      simple_form_for(object) do |ff|
        output << content_tag(:span, 
          ff.input(column, as: :datepicker, label: false, input_html: { data: {update_column_path: update_column_path(object.class.to_s,column.to_s,object.id)} }).html_safe,
          class: 'hide content-for-datepicker')
      end

      output.join.html_safe
    end
end
