jQuery ->
  $('#generic_versions_datatable').dataTable
    sPaginationType: "bootstrap"
    bProcessing: true
    bServerSide: true
    aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Todos"]]
    sAjaxSource: $('#generic_versions_datatable').data('source')
    aaSorting: [[ 1, "desc" ]]
    aoColumnDefs: [{ "bSortable": false, "aTargets": [ 2, 3, 4 ] }]
    aoColumns: [
      {sName: "item_id"},
      {sName: "created_at"}
    ]
    oLanguage:
      "sUrl": "/datatable/i18n"