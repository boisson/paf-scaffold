<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  
  # GET <%= route_url %>
  # GET <%= route_url %>.json
  def index
    @search = <%=class_name%>.search(params[:q])
    respond_to_grid(<%=controller_class_name%>Datatable)
  end
  
  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
      format.js
    end
  end

  # GET <%= route_url %>/new
  # GET <%= route_url %>/new.json
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>

    respond_to do |format|
      format.html { render layout: nil } # new.html.erb
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
    end
  end

  # GET <%= route_url %>/1/edit
  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_to do |format|
      format.html { render layout: nil } # edit.html.erb
      format.js
    end
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.json
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        if params[:submit_and_go_to_new]
          flash.now[:notice] = t('general.messages.create_success', model_name: t('activerecord.models.<%=singular_table_name%>'))
        else
          flash[:notice] = t('general.messages.create_success', model_name: t('activerecord.models.<%=singular_table_name%>'))
        end
        format.html { redirect_to edit_<%=singular_table_name%>_path(@<%= singular_table_name %>) }
        format.json { render <%= key_value :json, "@#{singular_table_name}" %>, <%= key_value :status, ':created' %>, <%= key_value :location, "@#{singular_table_name}" %> }
        format.js { render action: 'save.js.erb' }
      else
        flash.now[:error] = t('general.messages.create_error', model_name: t('activerecord.models.<%=singular_table_name%>'))
        format.html { render <%= key_value :action, '"new"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
        format.js { render action: 'save.js.erb' }
      end
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.json
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        flash[:notice] = t('general.messages.update_success', model_name: t('activerecord.models.<%=singular_table_name%>'))
        format.html { redirect_to edit_<%=singular_table_name%>_path(@<%= singular_table_name %>) }
        format.json { head :no_content }
        format.js { render action: 'save.js.erb' }
      else
        flash.now[:error] = t('general.messages.update_error', model_name: t('activerecord.models.<%=singular_table_name%>'))
        format.html { render <%= key_value :action, '"edit"' %> }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
        format.js { render action: 'save.js.erb' }
      end
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    if @<%= orm_instance.destroy %>
      flash[:notice] = t('general.messages.delete_success', model_name: t('activerecord.models.<%=singular_table_name%>'))
    else
      flash[:error] = t('general.messages.delete_error')
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
      format.js { render template: 'shared/batch_destroy.js.erb'}
    end
  end

  # DELETE <%= route_url %>/batch_destroy?ids[]=1&ids[]=2
  # DELETE <%= route_url %>/batch_destroy.json?ids[]=1&ids[]=2
  def batch_destroy 
    if params[:ids]
      if <%= class_name %>.destroy_all(id: params[:ids])
        flash[:notice] = t('general.messages.delete_success', model_name: t('activerecord.models.<%=singular_table_name%>'))
      else
        flash[:error] = t('general.messages.delete_error')
      end
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
      format.js { render template: 'shared/batch_destroy.js.erb' }
    end
  end
end
<% end -%>