$(document).ready(function() {
  p_scaffold.init();
});

$('a[data-remote], button[data-remote]').live('click',function(e){
  p_scaffold.show_loading();
})


$(document).ajaxError(function(event, xhr, settings, exception) {
  if (xhr.status != 0) {
    $('#modal-ajax-error').modal()
  }
});

var closePrintView = function(e, columnsToClose) {
    if(e.which == 27) {
        printViewClosed(columnsToClose); 
    }
};
     
function printViewClosed(columnsToClose) {
  $(columnsToClose).each(function(i,column){
    crud_datatable.fnSetColumnVis(column, true);
  })
    
  $(window).unbind('keyup', function(e){
    closePrintView(e,columnsToClose)
  });
}

$(document).ajaxComplete(function(event, xhr, settings) {
  p_scaffold.hide_loading()
});

p_scaffold = {
  init: function(){
    p_scaffold_form.init_all()
    gebo_datatables.init();
  },

  show_loading: function(){
    $(".qtip").remove();
    document.getElementsByTagName('html')[0].className = 'js';
  },

  hide_loading: function(){
    //* show all elements & remove preloader
    setTimeout('$("html").removeClass("js")',1000);
  },

  remove_message_on_top: function(){
    $('#contentwrapper .main_content .alert.fade.in').remove()
  },

  show_message_by_ajax: function(message){
    p_scaffold.remove_message_on_top();
    $('#contentwrapper .main_content').prepend(message);
  }
}

p_scaffold_form = {
  init_all: function(){
    p_scaffold_form.init_chosen()
    p_scaffold_form.init_multipleselect()
    p_scaffold_form.init_datepicker()
    p_scaffold_form.init_spinner()
    p_scaffold_form.init_currency()
  },

  init_spinner: function(){
    $('.spinner').parent().attr('class', 'span2')
    $('.spinner').spinner();
  },

  init_currency: function(){
    $(".currency").maskMoney({showSymbol:false, decimal:'.',thousands:''});
  },

  init_chosen: function(){
    $(".chosen-options").chosen({
      allow_single_deselect: true
    });
    $(".chosen-multiple").chosen();
  },

  init_multipleselect: function(){
    $('.chosen-multiple-2-columns').each(function(){
      var container = $(this)

      container.multiSelect({
        selectableHeader : '<input type="text" class="multi_search" autocomplete="off" placeholder="'+container.data('search-placeholder')+'" />',
        selectedHeader   : '<a href="javascript:void(0)" id="deselect_all_'+ container.attr('id')+'" class="sForm_deselect btn">'+container.data('deselect-all')+'</a>'
      });
    
      $('#ms-'+ container.attr('id')+ ' input.multi_search').quicksearch('#ms-'+ container.attr('id') + ' .ms-selectable li');
      container.multiSelect();
      
      $('#deselect_all_'+container.attr('id')).click(function(){
        container.multiSelect('deselect_all');
        return true;
      });
    });
  },
  
  init_datepicker: function(){
      $('.control-group.datepicker').addClass('string').removeClass('datepicker');
      $("input.datepicker").each(function(i){
          $(this).datepicker({ format: "dd/mm/yyyy" }).on("change", function(ev){
              var currentDate = $(this).val()
              currentDate = currentDate.split('/').reverse().join('-')
              $(this).next().val(currentDate)
              $(this).next().blur()
          })
      })
  },

  go_to_edit_from_versions: function(){
    $('a[href="#tab-edit"]').tab('show')
  }
}


gebo_datatables = {

  init: function() {
    gebo_datatables.tab_nav_binds()
    gebo_datatables.select_rows_binds()
    gebo_datatables.import_data_binds()
    gebo_datatables.ransack_binds()
  },

  visible_columns_indexes: function(datatable_id){
    var hide_columns       = []
    var oTable             = $(datatable_id).dataTable()
    $.each(oTable.fnSettings().aoColumns, function(i,value){
      if(value.sName != '' && value.sName != undefined && value.bVisible){
        hide_columns.push(i)
      }
    })
  },

  crud_buttons: function(datatable_id, columns){
    return [
      {
        "fnClick": function(nButton, oConfig, oFlash) {
          return $('#modal-import').modal();
        },
        'sButtonText': '<i class="icon-download-alt"></i> ' + terms['import'],
        "sExtends": "text",
        "sToolTip": terms['import_hint']
      }, {
        "sExtends": "copy",
        'sButtonText': '<i class="icon-random"></i> ' + terms['copy'],
        "mColumns": 'visible',
        "sToolTip": terms['copy_hint']
      }, {
        "fnClick": function(nButton, oConfig, oFlash) {
          return $('#advanced_search').modal().css({
            width: '774px',
            'margin-left': function () {
                return -($(this).width() / 2);
            }
          });
        },
        'sButtonText': '<i class="icon-search"></i> ' + terms['advanced_search'],
        "sExtends": "text",
        "sToolTip": terms['advanced_search_hint']
      }, {
        "fnClick": function(nButton, oConfig, oFlash) {
          return gebo_datatables.export_print(datatable_id);
        },
        'sButtonText': '<i class="icon-print"></i> ' + terms['print'],
        "sExtends": "text",
        "sToolTip": terms['print_hint']
      }, {
        'sButtonText': '<i class="icon-eye-close"></i> '+ terms['hide_columns'] + '<span class="caret"></span>',
        "sExtends": "div",
        "sToolTip": terms['hide_column_hint'],
        'sButtonClass': 'btn dropdown-toggle',
        'fnInit': function(nButton) {
          return $(nButton).dropdown();
        },
        'fnClick': function(nButton) {
          $(nButton).next('#dt_d_nav:first').remove();
          $(nButton).after('<ul class="dropdown-menu dropdown-menu-on-the-right tableMenu" id="dt_d_nav"></ul>');
          var hide_columns       = $(nButton).next('#dt_d_nav:first')
          var oTable             = $(datatable_id).dataTable()
          $.each(oTable.fnSettings().aoColumns, function(i,value){
            if(value.sName != '' && value.sName != undefined){
              var checked = '';
              if(value.bVisible){
                checked = 'checked="checked"'
              }
              hide_columns.append('<li><label class="checkbox" for="dt_col_'+i+'"><input type="checkbox" value="'+i+'" id="dt_col_'+i+'" name="toggle-cols" '+ checked +' data-attribute-name="'+value.sName+'" /> '+ value.sTitle +'</label></li>')
            }
          })

          gebo_datatables.hide_columns_binds()
        }
      }
    ]
  },

  tab_nav_binds: function(){
    $("#crud-tab").unbind("show");
    $("#crud-tab").bind("show", function(e) {
      p_scaffold.show_loading()
      $('a[href="#tab-show"]').parent().hide();
      if($(e.target).attr('href') != "#tab-versions-of-object" && $(e.target).attr('href') != "#tab-edit"){
        $('a[href="#tab-edit"]').parent().hide();
        $('a[href="#tab-versions-of-object"]').parent().hide();
        $('a[href="#tab-versions"]').parent().show();
      }
      
      var action_path = $(e.target).data("action-path");
      if(action_path != undefined){
        $($(e.target).attr("href")).html('');
        return $($(e.target).attr("href")).load($(e.target).data("action-path"), function() {
          $('.tab-pane.active').height($('.tab-pane.active').height()+160)
          p_scaffold.remove_message_on_top();
          gebo_datatables.toggle_top_buttons_on_list(e.target)
          gebo_datatables.update_breadcrumb($(e.target).text())
          gebo_crumbs.init();
          return $("#crud-tab").tab();
        });
      }else{
        p_scaffold.hide_loading()
        p_scaffold.remove_message_on_top();
        gebo_datatables.toggle_top_buttons_on_list(e.target)
        gebo_datatables.update_breadcrumb($(e.target).text())
        gebo_crumbs.init();
        return $("#crud-tab").tab();
      }

    });
  },

  hide_columns_binds: function(){
    var oTable = $('.crud_datatable').dataTable();
    function fnShowHide( iCol ) {
      /* Get the DataTables object again - this is not a recreation, just a get of the object */
      oTable = $('.crud_datatable').dataTable();
       
      var bVis = oTable.fnSettings().aoColumns[iCol].bVisible;
      oTable.fnSetColumnVis( iCol, bVis ? false : true );
    }
    
    $('#dt_d_nav').on('click','li input',function(){
      fnShowHide( $(this).val() );
    });

    var totalColumns = oTable.fnSettings().aoColumns.size;
    var totalVisible = 0;

    $.each(oTable.fnSettings().aoColumns, function(i, column){
      if(column.bVisible){
        totalVisible++;
      }
    })

    $('#footer-td-colspaned').attr('colspan', totalVisible)
  },

  select_rows_binds: function() {
    $('.select_rows').click(function () {
      $('.crud_datatable').find('input[name="ids[]"]').attr('checked', this.checked);
    });
  },

  toggle_buttons_binds: function(table_id){
    $(table_id+' tr').each(function(){
      $(this).find('td:last a.disabled').each(function(){
        var data_method = '';
        if($(this).attr('data-method') != undefined){
          data_method = 'data-method="'+$(this).attr('data-method')+'"'
        }
        var cloned = '<a href="javascript:;" '+data_method+' class="'+$(this).attr('class')+'">'+$(this).html()+'</a>'
        $(this).hide()
        $(this).removeClass('disabled')
        $(this).addClass('toActive')
        $(this).parent().append(cloned)
      })
      $(this).find('td:last a.toActive').hide()
      $(this).find('td:last a.disabled').show()
    })
    $(table_id).find('input[name="ids[]"]').each(function(){
      $(this).click(function(){
        if($(this).is(':checked')){
          $(this).parent().parent().find('td:last a.toActive').show()
          $(this).parent().parent().find('td:last a.disabled').hide()
        }else{
          $(this).parent().parent().find('td:last a.toActive').hide()
          $(this).parent().parent().find('td:last a.disabled').show()
        }
      })
    });
  },

  update_breadcrumb: function(text){
    if($('#jCrumbs ul').length > 0){
      $('#jCrumbs ul li.last').html(text)
      // $('#jCrumbs ul').append('<li class="last">'+text+'</li>')
    }
  },

  toggle_top_buttons_on_list: function(e){;
    if($(e).attr('href') == '#tab-list'){
      $('#btns-on-tabs').show()
    }else{
      $('#btns-on-tabs').hide()
    }
  },


  import_data_binds: function(){
    $('#btn-import-data').click(function(e){
      $('#import-content-upload').hide()
      $('#import-loader').show()
      $(this).removeClass('btn-primary').addClass('btn-danger')
      return true;
    })
  },

  ransack_binds: function(){
    $('#btn-advanced-search').click(function(e){
      e.preventDefault()
      $('#advanced_search').modal().css({
        width: '774px',
        'margin-left': function () {
            return -($(this).width() / 2);
        }
      });
    })

    $('#advanced_search').on('click', '.remove_fields', function(event) {
      $(this).closest('.field').remove();
      return event.preventDefault();
    });

    $('#advanced_search').on('click', '.add_fields', function(event) {
      var regexp, time;
      time = new Date().getTime();
      regexp = new RegExp($(this).data('id'), 'g');
      $(this).before($(this).data('fields').replace(regexp, time));
      $('#advanced_search .field:last select:first').trigger('change')
      return event.preventDefault();
    });


    var ransack_definitions = {
      'date':       ['eq','not_eq','lt','lteq','gt','gteq'],
      'string':     ['eq','not_eq','matches','does_not_match','start','not_start','end','not_end','cont','not_cont'],
      'text':       ['eq','not_eq','matches','does_not_match','start','not_start','end','not_end','cont','not_cont'],
      'integer':    ['eq','not_eq','lt','lteq','gt','gteq'],
      'float':      ['eq','not_eq','lt','lteq','gt','gteq'],
      'boolean':    ['eq'],
      'references': ['eq','not_eq','matches','does_not_match','start','not_start','end','not_end','cont','not_cont'],
    }


    function disable_and_hide(obj){
      obj.hide();
      obj.attr('disabled', 'disabled');
    }

    function enable_and_show(obj){
      obj.show()
      obj.attr('disabled',false)
    }

    $('#advanced_search select[id$="_name"]').live('change',function(){
      var attribute_name        = $(this).val()
      var column_type           = advanced_search_columns[attribute_name]
      var select_filter_type    = $(this).next()
      var input_value           = select_filter_type.next()
      input_value.val('')
      enable_and_show(input_value)
      var back_input_value      = input_value.clone()      

      select_filter_type.html($('#q_p').html())

      select_filter_type.find('option').each(function(){
        if($.inArray($(this).val(), ransack_definitions[column_type]) == -1){
          $(this).remove()
        }
      })

      $(this).parent().find('.aux-field').remove()
      
      if(column_type == 'date'){
        $(this).parent().append('<input class="aux-field" type="hidden" name="'+input_value.attr('name')+'" />')
        input_value.datepicker({ autoclose: true, format: "dd/mm/yyyy" }).on("change", function(ev){
          var currentDate   = $(this).val()
          var hidden_field  = $(this).parent().find('.aux-field')
          currentDate = currentDate.split('/').reverse().join('-')
          hidden_field.val(currentDate)
        })
      }else if(column_type == 'boolean'){
        disable_and_hide(input_value)
        $('<select class="aux-field" name="'+input_value.attr('name')+'"><option value="1">True</option><option value="0">False</option></select>').insertBefore($(this).parent().find('.remove_fields.btn'))
      }else{
        $(back_input_value).insertAfter(input_value)
        input_value.remove()
      }
      
    })

    $('#advanced_search select[id$="_name"]').each(function(){
      var attribute_name        = $(this).val()
      var column_type           = advanced_search_columns[attribute_name]
      var select_filter_type    = $(this).next()
      var input_value           = select_filter_type.next()
      var current_filter_type   = select_filter_type.val()

      select_filter_type.html($('#q_p').html())

      select_filter_type.find('option').each(function(){
        if($.inArray($(this).val(), ransack_definitions[column_type]) == -1){
          $(this).remove()
        }
      })
      
      if(column_type == 'date'){
        $(this).parent().append('<input type="hidden" class="aux-field" name="'+input_value.attr('name')+'" value="'+ input_value.val() +'" />')
        input_value.val(input_value.val().split('-').reverse().join('/'))
        input_value.datepicker({ autoclose: true, format: "dd/mm/yyyy" }).on("change", function(ev){
          var currentDate   = $(this).val()
          var hidden_field  = $(this).parent().find('.aux-field')
          currentDate = currentDate.split('/').reverse().join('-')
          hidden_field.val(currentDate)
        })
      }else if(column_type == 'boolean'){
        disable_and_hide(input_value)
        var select_value = $('<select class="aux-field" name="'+input_value.attr('name')+'"><option value="1">True</option><option value="0">False</option></select>').insertBefore($(this).parent().find('.remove_fields.btn'))
        select_value.val(input_value.val())
      }

      select_filter_type.val(current_filter_type)
    });


    // #advanced_search_filtered_terms is in paf-scaffold modal form
    var filtered_terms = []
    $('#advanced_search select[id$="_name"] option:selected').each(function(i){
      filtered_terms.push('<span class="label label-info">'+$(this).text()+' '+
        $('#advanced_search select[name$="q[c]['+i+'][p]"] option:selected').text()+' \''+
        $('#advanced_search input[name$="q[c]['+i+'][v][0][value]"]').val()+'\'</span>')
    })
    // $('#advanced_search_filtered_terms').append(filtered_terms.join('&nbsp;'))
    $('#advanced_search_filtered_terms #filtered_terms_list').append(filtered_terms.join('&nbsp;'))
      
  },

  save_text_field: function(object_text){
    object_text.removeClass('hide').addClass('show').focus()
    object_text.parent().find('span.show').removeClass('show').addClass('hide')

    object_text.unbind('blur')
    object_text.blur(function(){

      var parent = $(this).parent();
      object_text.attr('disabled','disabled')
      
      $.post(object_text.data('update-column-path'),{new_value: object_text.val()}, function(data){
        parent.find('input.show').removeClass('show').addClass('hide')
        parent.find('span.hide').removeClass('hide').addClass('show')
        
        if(data == '1'){
          parent.find('span.show').html(object_text.val())
        }else{
          object_text.val(parent.find('span.show').html())
          $.sticky(data, {autoclose : 5000, position: "top-center", type: "st-error" });
        }
        object_text.attr('disabled',false)
        
      })

      
    })
  },

  save_boolean_field: function(object_boolean){
    object_boolean.removeClass('hide').addClass('show').focus()
    object_boolean.parent().find('label.hide').removeClass('hide').addClass('show')
    object_boolean.parent().find('span.show').removeClass('show').addClass('hide')

    object_boolean.unbind('click')
    object_boolean.click(function(){

      var parent = $(this).parent();
      object_boolean.attr('disabled','disabled')
      var is_checked = object_boolean.is(':checked');
      
      $.post(object_boolean.data('update-column-path'),{new_value: is_checked}, function(data){
        parent.find('input.show').removeClass('show').addClass('hide')
        parent.find('label.show').removeClass('show').addClass('hide')
        parent.find('span.hide').removeClass('hide').addClass('show')
        
        if(data == '1'){
          if(is_checked){
            parent.find('span.show').html(terms['yes'])
          }else{
            parent.find('span.show').html(terms['no'])
          }
          
        }else{
          object_boolean.attr('checked',!object_boolean.is(':checked'))
          $.sticky(data, {autoclose : 5000, position: "top-center", type: "st-error" });
        }
        object_boolean.attr('disabled',false)
        
      })

      
    })
  },

  save_date_field: function(object_hidden){
    var div_container = object_hidden.parent().parent().parent()
    div_container.removeClass('hide').addClass('show')
    div_container.parent().find('span.show:first').removeClass('show').addClass('hide')
    p_scaffold_form.init_datepicker()
    
    var parent      = div_container.parent();
    var object_text = parent.find('input:text:first')

    object_text.datepicker('show')
    
    var initial_value_text = object_text.val()

    object_text.unbind('change')
    object_text.change(function(){

      
      $.post(object_text.data('update-column-path'),{new_value: object_hidden.val()}, function(data){
        parent.find('span.hide').removeClass('hide').addClass('show')
        div_container.removeClass('show').addClass('hide')

        object_text.datepicker('hide')
        
        if(data == '1'){
          parent.find('span.show').html(object_text.val())
        }else{
          object_text.val(initial_value_text)
          $.sticky(data, {autoclose : 5000, position: "top-center", type: "st-error" });
        }
        //object_text.attr('disabled',false)
        
      })

      
    })
  },

  export_print: function(table_id){
    var oTable       = $(table_id).dataTable();
    var page_title   = $('.main_content h3.heading:first').text()
    var columns      = []
    var column_names = []

    $.each(oTable.fnSettings().aoColumns, function(i,value){
      if(value.bVisible && value.sName != '' && value.sName != undefined){
        if (value.sDisplayColumn != undefined) {
          columns.push(value.sDisplayColumn)
        }else{
          columns.push(value.sName)
        }
        column_names.push(value.sTitle)
      }
    })

    if(page_title == undefined){
      page_title = ''
    }

    if(columns.length > 0){
      var url  = new Url(oTable.data('export-print-url'));

      if (datatable_params = oTable._fnAjaxParameters()) {
        $.each(datatable_params, function(index, value) {
          url.query[this.name] = this.value }
        )
      }

      url.query.columns      = columns.join('][')
      url.query.column_names = column_names.join('][')
      url.query.page_title   = page_title

      window.location.href = url.toString()
    }
  },

  export_xlsx: function(table_id){
    var oTable       = $('.crud_datatable').dataTable();
    var page_title   = $('.main_content h3.heading:first').text()
    var columns      = []
    var column_names = []

    $.each(oTable.fnSettings().aoColumns, function(i,value){
      if(value.bVisible && value.sName != '' && value.sName != undefined){
        if (value.sDisplayColumn != undefined) {
          columns.push(value.sDisplayColumn)
        }else{
          columns.push(value.sName)
        }
        column_names.push(value.sTitle)
      }
    })

    if(page_title == undefined){
      page_title = ''
    }

    if(columns.length > 0){
      var url  = new Url(oTable.data('export-xlsx-url'));

      if (datatable_params = oTable._fnAjaxParameters()) {
        $.each(datatable_params, function(index, value) {
          url.query[this.name] = this.value }
        )
      }

      url.query.columns      = columns.join('][')
      url.query.column_names = column_names.join('][')
      url.query.page_title   = page_title

      window.location.href = url.toString()
    }
  },

  export_pdf: function(table_id){
    var oTable       = $('.crud_datatable').dataTable();
    var page_title   = $('.main_content h3.heading:first').text()
    var columns      = []
    var column_names = []
    
    $.each(oTable.fnSettings().aoColumns, function(i,value){
      if(value.bVisible && value.sName != '' && value.sName != undefined){
        if (value.sDisplayColumn != undefined) {
          columns.push(value.sDisplayColumn)
        }else{
          columns.push(value.sName)
        }
        column_names.push(value.sTitle)
      }
    })

    if(page_title == undefined){
      page_title = ''
    }

    if(columns.length > 0){
      var url  = new Url(oTable.data('export-pdf-url'));

      if (datatable_params = oTable._fnAjaxParameters()) {
        $.each(datatable_params, function(index, value) {
          url.query[this.name] = this.value }
        )
      }

      url.query.columns      = columns.join('][')
      url.query.column_names = column_names.join('][')
      url.query.page_title   = page_title

      window.location.href = url.toString()
    }
  },

  go_to_list: function(){
    $('a[href="#tab-list"]').tab('show')
  },

  export: function(object, datatable_id){
    if($(object).val() == 'xlsx'){
      gebo_datatables.export_xlsx(datatable_id)
    }else if($(object).val() == 'pdf'){
      gebo_datatables.export_pdf(datatable_id)
    }
  },

  draw_callback: function(datatable_id){
    var datatable_id = $.trim(datatable_id)
    gebo_datatables.toggle_buttons_binds(datatable_id)
    $(".crud_datatable input:checkbox.hide").each(function(){
      $(this).parent().dblclick(function(){
        gebo_datatables.save_boolean_field($(this).find('input:checkbox'))
      })
    })
      
    $(".crud_datatable input:text.hide").each(function(){
      $(this).parent().dblclick(function(){
        gebo_datatables.save_text_field($(this).find('input:text'))
      })
    })
    
    $(".crud_datatable span.hide.content-for-datepicker").each(function(){
      $(this).parent().dblclick(function(){
        gebo_datatables.save_date_field($(this).find('input:hidden:first'))
      })
    })

    var export_actions = '<div class="row-fluid">'+
        '<div class="span6" style="width:200px">'+terms['export']
          +'<br />'+
          '<select style="width:95%" title="'+terms['export_tip']+'" id="slt-export" onchange="gebo_datatables.export(this,\''+datatable_id+'\')">'+
            '<option value="">CSV, XLSX, PDF</option>'+
            '<option value="xlsx">CSV</option>'+
            '<option value="xlsx">XLSX</option>'+
            '<option value="pdf">PDF</option>'+
          '</select>'+
        '</div>'+
      '</div>'

    

    // Change element sDom to apply permission on export
    if($(datatable_id).data('permissions') != undefined && $.inArray('export', $(datatable_id).data('permissions').split(',')) == -1){
      $('.dt_export_actions').remove()
    }else{
      $('.dt_export_actions').html(export_actions);
      $('#slt-export').qtip($.extend({}, qtip_css_custom, {
        position: {
          my: "left center",
          at: "right center",
          viewport: $(window)
        }
      }));
    }

    $('.dt_other_actions #dt-editing-title').remove()
    $('.dt_other_actions').prepend('<div id="dt-editing-title">'+ terms['editing'] +'</div>')
    $('.dt_other_actions button[title!=""],.dt_other_actions div[title!=""]').each(function(){
      $(this).qtip($.extend({}, qtip_css_custom, {
        position: {
          my: "left center",
          at: "right center",
          viewport: $(window)
        }
      }));
    })
  }
};


$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});



var qtip_css_custom;

qtip_css_custom = {
  style: {
    classes: "ui-tooltip-shadow ui-tooltip-tipsy"
  },
  show: {
    delay: 100,
    event: "mouseenter focus"
  },
  hide: {
    delay: 0
  }
};
