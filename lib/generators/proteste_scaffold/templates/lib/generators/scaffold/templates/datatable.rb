class <%=controller_class_name%>Datatable < GenericDatatable
  delegate :<%=singular_table_name%>_path, :edit_<%=singular_table_name%>_path, to: :@view

protected

  def total_records
    <%=class_name%>.count
  end

  def data
    results.map do |<%=singular_table_name%>|
      [
        check_box_tag(:'ids[]', <%=singular_table_name%>.id),
        link_to(<%=singular_table_name%>.id,<%=singular_table_name%>_path(<%=singular_table_name%>), remote: true),
<% attributes.each do |attribute| -%>
<% if attribute.type == :text -%>
        strip_tags(<%=singular_table_name%>.<%= attribute.name %>),
<% elsif attribute.type == :references -%>
        ((<%=singular_table_name%>.<%= attribute.name %>.name rescue <%=singular_table_name%>.<%= attribute.name %>.id) if <%=singular_table_name%>.<%= attribute.name %>),
<% elsif attribute.type == :n_to_n_inline || attribute.type == :n_to_n_2_columns -%>
        (<%=singular_table_name%>.<%= attribute.name %>.collect{|t| t.name }.sort.to_sentence rescue <%=singular_table_name%>.<%= attribute.name %>.collect{|t| t.id }.to_sentence),
<% elsif [:string, :integer, :float, :number, :decimal].include?(attribute.type) -%>
        input_text(<%=singular_table_name%>,<%=singular_table_name%>.<%= attribute.name %>, :<%=attribute.name%>),
<% elsif attribute.type == :date -%>
        input_date(<%=singular_table_name%>,(l(<%=singular_table_name%>.<%= attribute.name %>) rescue nil), :<%=attribute.name%>),
<% elsif attribute.type == :datetime -%>
        (l(<%=singular_table_name%>.<%= attribute.name %>) rescue nil),
<% elsif attribute.type == :boolean -%>
        input_boolean(<%=singular_table_name%>,yes_or_no(<%=singular_table_name%>.<%= attribute.name %>), :<%=attribute.name%>),
<% else -%>
        <%=singular_table_name%>.<%= attribute.name %>,
<% end -%>
<% end -%>
        crud_buttons(<%=singular_table_name%>)
      ]
    end
  end

  def fetch_results
    results = build_result
<% attributes.find_all{|t| t.type == :references || t.type == :n_to_n_inline || t.type == :n_to_n_2_columns}.each do |t| -%>
<% if t.type == :references -%>
      .joins('LEFT JOIN <%= t.name.tableize %> ON <%= plural_table_name %>.<%= t.name %>_id = <%= t.name.tableize %>.id')
<% else -%>
<% classes                  = [plural_table_name, t.name].sort -%>
<% association_n_to_n_name  = "#{classes.first}_#{classes.last}" -%>
      .joins('LEFT JOIN <%= association_n_to_n_name %> ON <%= plural_table_name %>.id = <%= association_n_to_n_name %>.<%=singular_table_name %>_id LEFT JOIN <%= t.name %> ON <%= association_n_to_n_name %>.<%= t.name.singularize %>_id = <%= t.name %>.id')
<% end -%>
<% end -%>
      

<% where_params = ["#{plural_table_name}.id LIKE :search"] -%>
<% attributes.each do |t| -%>
<% if t.type == :references -%>
<% where_params << "#{t.name.tableize}.id LIKE :search OR #{t.name.tableize}.name LIKE :search" -%>
<% elsif t.type == :n_to_n_inline || t.type == :n_to_n_2_columns -%>
<% where_params << "#{t.name}.name LIKE :search" -%>
<% else -%>
<% where_params << "#{plural_table_name}.#{t.name} LIKE :search" -%>
<% end -%>
<% end -%>
    if merged_params[:sSearch].present?
      results = results.where("<%= where_params.join(" OR \n\t\t\t") %>", search: "%#{merged_params[:sSearch]}%")
    end
    results
  end

  def build_result
    if merged_params[:q].blank?
      results = <%= class_name %>.unscoped
    else
      results = <%= class_name %>.search(merged_params[:q]).result
    end

    results.order(sort_columns('<%=plural_table_name%>.id')).page(page).per_page(per_page)
  end
end