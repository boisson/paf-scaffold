class VersionsController < ApplicationController
  skip_before_filter :can_access?, :check_user_status
  
  def revert
    base_class = Kernel.const_get("#{params[:base_class]}Version")
    @version = base_class.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => t('general.actions.revert_success')
  end

  def versions_of_model
    respond_to do |format|
      format.html { render layout: nil } # index.html.erb
      format.json { render json: GenericVersionsDatatable.new(view_context, params[:base_class]) }
    end
  end
end