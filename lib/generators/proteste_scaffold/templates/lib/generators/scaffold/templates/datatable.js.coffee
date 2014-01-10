window.crud_datatable = $('#<%=plural_table_name%>_datatable').dataTable
  fnDrawCallback: (oSettings) ->
    gebo_datatables.draw_callback('#<%=plural_table_name%>_datatable')
  sPaginationType: "bootstrap"
  bProcessing: true
  bServerSide: true
  aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, terms['all']]]
  aaSorting: [[1, "desc"]]
  sAjaxSource: $('#<%=plural_table_name%>_datatable').data('source')
  aoColumnDefs: [{ "bSortable": false, "aTargets": [ 0, <%= attributes.size + 2 %> ] }]
  aoColumns: [
    {sClass: "center"},
    {sClass: "center", sName: "<%= plural_table_name %>.id"},
<% attributes.each do |t| -%> 
<% if t.type == :references -%>
    {sName: "<%= t.name.tableize %>.name"},
<% elsif t.type == :n_to_n_inline || t.type == :n_to_n_2_columns -%>
    {sName: "<%= t.name %>.name"},
<% else -%>
    {sName: "<%= plural_table_name %>.<%=t.name%>"},
<% end -%>
<% end -%>
    {sClass: "center"}
  ]
  "sDom": "<'dt_export_actions'><'dt_other_actions'T><'clear'>lfrti<'dt_batch_destroy_action'>p"
  "oTableTools":
    "sSwfPath": "/lib/datatables/extras/TableTools/media/swf/copy_csv_xls_pdf.swf"
    "aButtons": gebo_datatables.crud_buttons('#<%=plural_table_name%>_datatable',<%= (1..attributes.size+1).to_a.inspect %>)
  oLanguage:
    "sUrl": "/datatable/i18n"

window.advanced_search_columns = 
  id: 'integer'
<% attributes.each do |t| -%> 
  <%=t.name%>: '<%=t.type%>'
<% end %>