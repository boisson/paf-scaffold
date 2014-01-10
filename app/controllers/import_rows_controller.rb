class ImportRowsController < ApplicationController
  skip_before_filter :can_access?, :check_user_status
  
  def import
    proteste_import = ProtesteScaffold::Import.new(params[:base_class], params[:import][:file])
    proteste_import.import
    if proteste_import.rows_error.size == 0
      flash[:notice] = t('general.actions.import_success')
      redirect_to :back
    else
      errors_file   = proteste_import.errors_file(File.join(Rails.root,'public',params[:base_class]))
      flash[:info] = t('general.actions.import_error_not_import_at_all', link_error_file: view_context.link_to(t('general.actions.import_click_for_errors_details'), File.join(params[:base_class], File.basename(errors_file.path))))
      redirect_to :back
    end
      
  rescue => e
    flash[:error] = t('general.actions.import_error_file_type')
    redirect_to :back
  end

  def download
    file = ProtesteScaffold::Import.example_file(params[:base_class], 
      File.join(Rails.root,'tmp',params[:base_class]), 
      params[:excluded_columns],
      params[:forced_columns]
      )
    send_file file.path, filename: "#{params[:base_class]}.xlsx"
  end
end