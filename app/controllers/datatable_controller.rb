# encoding: utf-8
class DatatableController < ApplicationController
  skip_before_filter :can_access?, :check_user_status
  
  def i18n
    locale = {
      "sProcessing" => I18n.t('general.datatable.sProcessing'),
      "sLengthMenu" => I18n.t('general.datatable.sLengthMenu'),
      "sZeroRecords" =>  I18n.t('general.datatable.sZeroRecords'),
      "sInfo" =>       I18n.t('general.datatable.sInfo'),
      "sInfoEmpty" =>  I18n.t('general.datatable.sInfoEmpty'),
      "sInfoFiltered" => I18n.t('general.datatable.sInfoFiltered'),
      "sInfoPostFix" =>  I18n.t('general.datatable.sInfoPostFix'),
      "sSearch" =>     I18n.t('general.datatable.sSearch'),
      "sUrl" =>        I18n.t('general.datatable.sUrl'),
      "oPaginate" => {
        "sFirst" =>  I18n.t('general.datatable.sFirst'),
        "sPrevious" => I18n.t('general.datatable.sPrevious'),
        "sNext" =>   I18n.t('general.datatable.sNext'),
        "sLast" =>   I18n.t('general.datatable.sLast')
      }
    }

    render :json => locale
  end


  def update_column
    klass = Kernel.const_get(params[:base_class])
    @object = klass.find(params[:id])
    if @object.update_attributes({params[:column] => params[:new_value]})
      render text: '1'
    else
      render text: view_context.j(@object.errors.full_messages.join(', '))
    end
  end
end
