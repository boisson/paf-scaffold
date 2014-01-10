$ ->
  $("#batch_destroy_link").click ->
    _href = $("#batch_destroy_link").attr("href")
    _new_href = _href
    $(".crud_datatable [name='ids[]']:checked").each (i) ->
      _new_href = _new_href + "&"  if i > 0
      _new_href = _new_href + "ids%5B%5D=" + $(this).val()

    if(_href != _new_href)
      $("#batch_destroy_link").attr "href", _new_href
    else
      return false
