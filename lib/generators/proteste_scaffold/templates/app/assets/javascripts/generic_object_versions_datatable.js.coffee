$("#object_versions").dataTable
  sPaginationType: "bootstrap"
  aaSorting: [[0, "desc"]]
  aoColumnDefs: [
    bSortable: false
    aTargets: [1, 2, 3]
  ]
  oLanguage:
    sUrl: "/datatable/i18n"
