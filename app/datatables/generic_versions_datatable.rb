class GenericVersionsDatatable
  delegate :params, :strip_tags, :t, :l, :h, :url_for, :content_tag, :yes_or_no, :truncate,
  :link_to, :number_to_currency, to: :@view
  attr_accessor :version_model, :base_model

  def initialize(view, base_class)
    @view          = view
    @version_model = Kernel.const_get("#{base_class}Version")
    @base_model    = Kernel.const_get(base_class)
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: self.version_model.count,
      iTotalDisplayRecords: generic_versions.total_entries,
      aaData: data
    }
  end

private

  def before_data(version)
    return I18n.t('general.versions.destroy') if version.nil?
    case version.event
    when 'create'
      return I18n.t('general.versions.created')
    when 'destroy'
      return after_data(version.previous)
    end

    output = version.changeset.collect do |field, values|
      content_value(field, values[0])
    end
    output.join("\n").html_safe
  end

  def after_data(version)
    return I18n.t('general.versions.destroy') if version.nil?
    case version.event
    when 'destroy'
      return I18n.t('general.versions.destroy')
    end

    output = version.changeset.collect do |field, values|
      content_value(field, values[1])
    end
    output.join("\n").html_safe
  end

  def content_value(field,value)
    value = content_tag(:span, truncate(value, length: 45), alt: value, title: value).html_safe if value.is_a?(String)
    content_tag(:div, content_tag(:strong, self.base_model.human_attribute_name(field)).html_safe + ': ' + content_tag(:em, value).html_safe).html_safe
  end

  def data
    generic_versions.map do |version|
      [
        version.item_id,
        l(version.created_at, format: :long),
        before_data(version),
        after_data(version),
        (name_by_whodunnit(version.whodunnit))
      ]
    end
  end

  def generic_versions
    @generic_versions ||= fetch_generic_versions
  end

  def fetch_generic_versions
    generic_versions = self.version_model.order("#{sort_column} #{sort_direction}")
    
    generic_versions = generic_versions.page(page).per_page(per_page)
    if params[:sSearch].present?
      generic_versions = generic_versions.where("#{self.version_model.table_name}.object LIKE :search OR #{self.version_model.table_name}.object_changes LIKE :search", search: "%#{params[:sSearch]}%")
    end
    generic_versions
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength] = params[:iDisplayLength].to_i
    if params[:iDisplayLength] == -1
      self.version_model.count
    elsif params[:iDisplayLength] > 0
      params[:iDisplayLength]
    else
      10
    end
  end

  def sort_column
    columns = params[:sColumns].split(',').reject{|t| t.blank?}
    columns[params[:iSortCol_0].to_i] || "#{self.version_model.table_name}.created_at"
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  protected

  def name_by_whodunnit(whodunnit_id)
    user = false
    begin
      user = Proteste::Auth::User.find_by_id(whodunnit_id)
    rescue
      user = User.find_by_id(whodunnit_id)
    end

    if user
      user.name
    else
      whodunnit_id
    end
  end
end