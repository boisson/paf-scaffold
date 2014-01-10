module ProtesteScaffold
  module ViewHelpers
    ALERT_TYPES = [:error, :info, :success, :warning]
  
    def bool_to_string(value)
      return false unless value.is_a?(TrueClass) or value.is_a?(FalseClass) 
      value ? t('general.terms.active') : t('general.terms.inactive')
    end
    
    def yes_or_no(value)
      value ? t('general.terms.yes') : t('general.terms.no')
    end

    def translate_js
      javascript_tag do
        "
        var terms                     = []
        terms['yes']                  = '#{t('general.terms.yes')}'
        terms['no']                   = '#{t('general.terms.no')}'
        terms['export_tip']           = '#{t('general.terms.export_tip')}'
        terms['import']               = '#{t('general.actions.import')}'
        terms['export']               = '#{t('general.actions.export')}'
        terms['print']                = '#{t('general.actions.print')}'
        terms['advanced_search']      = '#{t('general.actions.advanced-search.link')}'
        terms['hide_columns']         = '#{t('general.actions.hide_columns')}'
        terms['editing']              = '#{t('general.terms.editing')}'
        terms['copy']                 = '#{t('general.actions.copy')}'
        terms['required']             = '#{t('errors.messages.empty')}'
        terms['lines_copied']         = '#{t('general.terms.lines_copied')}'
        terms['import_hint']          = '#{t('general.terms.import_hint')}'
        terms['copy_hint']            = '#{t('general.terms.copy_hint')}'
        terms['print_hint']           = '#{t('general.terms.print_hint')}'
        terms['advanced_search_hint'] = '#{t('general.terms.advanced_search_hint')}'
        terms['hide_column_hint']     = '#{t('general.terms.hide_column_hint')}'
        terms['all']                  = '#{t('general.terms.all')}'
        ".html_safe
      end.html_safe
    end

    # used in the option advanced filters
    def link_to_add_fields(name, f, type, partial_name = nil)
      partial_name ||= (type.to_s + "_fields")
      new_object = f.object.send "build_#{type}"
      id = "new_#{type}"
      fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
        render(partial_name, f: builder)
      end
      link_to(name, '#', class: "add_fields btn btn-info", data: {id: id, fields: fields.gsub("\n", "")})
    end

    def bootstrap_flash_namespace(namespace = nil, html = {})
      return bootstrap_flash if namespace.blank?
      return '' if flash[namespace].blank?

      flash_messages = []
      flash[namespace].each do |type, message|
        # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
        next if message.blank?
        
        type = :success if type == :notice
        type = :error   if type == :alert
        next unless ALERT_TYPES.include?(type)

        html_defaults = {
          :class => "alert fade in alert-#{type}"
        }
        html_defaults.each do |key, attr|
          html_defaults[key] ||= ''
          html_defaults[key] += ' ' + html[key] unless html[key].blank?
        end

        Array(message).each do |msg|
          text = content_tag(:div,
                             content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                             msg.html_safe, html_defaults)
          flash_messages << text if msg
        end
      end
      flash_messages.join("\n").html_safe
    end

    ALERT_TYPES = [:error, :info, :success, :warning]

    def bootstrap_flash_on_login
      flash_messages = []
      flash.each do |type, message|
        # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
        next if message.blank?
        
        type = :success if type == :notice
        type = :error   if type == :alert
        next unless ALERT_TYPES.include?(type)

        Array(message).each do |msg|
          text = content_tag(:div, msg.html_safe, :class => "alert fade in alert-login alert-#{type}")
          flash_messages << text if msg
        end
      end
      flash_messages.join("\n").html_safe
    end

    def can_revert?(object)
      version = object.versions.scoped.last
      version && version.event != 'create'
    end

    def actions_for_versions_of_object
      output = []
      output << javascript_include_tag('generic_object_versions_datatable').html_safe
      output << content_tag(:div, link_to(I18n.t('general.terms.go_back'), 'javascript:p_scaffold_form.go_to_edit_from_versions()', class: 'btn').html_safe, class: 'form-actions versions-of-object').html_safe
      output.join.html_safe
    end

    def go_back_to_list
      content_tag(:div, link_to(I18n.t('general.terms.go_back'), 'javascript:gebo_datatables.go_to_list()', class: 'btn').html_safe, class: 'form-actions').html_safe
    end

    def datatable_object_paths(export_params = {})
      export_params = {q: params[:q], action: :index}.merge(export_params)

      paths = []
      ['xlsx', 'pdf', 'print'].each do |f|
        paths << "data-export-#{f}-url='#{url_for(export_params.merge(format: f))}'"
      end
      
      paths << "data-new-path='#{url_for(action: :new, only_path: true)}'"
      paths << "data-source='#{url_for(export_params.merge(format: 'json'))}'"
      paths.join(' ').html_safe
    end

    def datatable_build_table(datatable_id, &block)
      content_for_header = capture(&block) || ''
      number_of_columns  = content_for_header.downcase.scan(/<th/).size
      render partial: 'shared/datatable_table', locals: {datatable_id: datatable_id, content_for_header: content_for_header, number_of_columns: number_of_columns}
    end
  end
end