require 'spec_helper'
<% first_string_attribute = attributes.find{|t| t.type == :string || t.type == :text}.name rescue 'id' %>
describe <%=controller_class_name%>Controller do

  fixtures :<%=plural_table_name%>

  before do
    user = Proteste::Auth::User.create(uid: 1, info: {name: 'root', login: 'root'})
    session[:user_id] = {'uid' => user.uid}
    request.env["HTTP_REFERER"] = <%= plural_table_name %>_path
  end

  let(:valid_attributes) {
    {
    }
  }

  describe "GET index" do
    it "render index" do
      get :index
      response.should render_template("index")
    end

    it "get <%=plural_table_name%> in json" do
      get :index, datatable_params
      response.body.should have_elements_in_json_response(0)
    end
    
    it "get in json filtered with ransack" do
      get :index, datatable_ransack_params('id','eq','1')
      response.body.should have_elements_in_json_response(0)
    end

    it "get <%=plural_table_name%> in xlsx" do
      get :index, datatable_xlsx_params
      response.should render_xlsx
    end

    it "get <%=plural_table_name%> in pdf" do
      get :index, datatable_pdf_params
      response.should render_pdf
    end
  end

  describe "GET show" do
    it "assigns the requested <%=singular_table_name%> as @<%=singular_table_name%>" do
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      get :show, {:id => <%=singular_table_name%>.to_param}
      assigns(:<%=singular_table_name%>).should eq(<%=singular_table_name%>)
    end
  end

  describe "GET new" do
    it "assigns a new <%=singular_table_name%> as @<%=singular_table_name%>" do
      get :new, {}
      assigns(:<%=singular_table_name%>).should be_a_new(<%=class_name%>)
    end
  end

  describe "GET edit" do
    it "assigns the requested <%=singular_table_name%> as @<%=singular_table_name%>" do
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      get :edit, {:id => <%=singular_table_name%>.to_param}
      assigns(:<%=singular_table_name%>).should eq(<%=singular_table_name%>)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new <%=class_name%>" do
        expect {
          post :create, {:<%=singular_table_name%> => valid_attributes}
        }.to change(<%=class_name%>, :count).by(1)
      end

      it "assigns a newly created <%=singular_table_name%> as @<%=singular_table_name%>" do
        post :create, {:<%=singular_table_name%> => valid_attributes}
        assigns(:<%=singular_table_name%>).should be_a(<%=class_name%>)
        assigns(:<%=singular_table_name%>).should be_persisted
      end

      it "create and redirects" do
        post :create, {:<%=singular_table_name%> => valid_attributes}
        response.should redirect_to(edit_<%=singular_table_name%>_path(assigns(:<%=singular_table_name%>)))
      end

      it "create and render js" do
        post :create, {:<%=singular_table_name%> => valid_attributes, format: :js}
        response.should render_template("save")
      end

      it "create and render js and go to new" do
        post :create, {:<%=singular_table_name%> => valid_attributes, submit_and_go_to_new: true, format: :js}
        response.should render_template("save")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved <%=singular_table_name%> as @<%=singular_table_name%>" do
        # Trigger the behavior that occurs when invalid params are submitted
        <%=class_name%>.any_instance.stub(:save).and_return(false)
        post :create, {:<%=singular_table_name%> => { "<%= first_string_attribute %>" => "invalid value" }}
        assigns(:<%=singular_table_name%>).should be_a_new(<%=class_name%>)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        <%=class_name%>.any_instance.stub(:save).and_return(false)
        post :create, {:<%=singular_table_name%> => { "<%= first_string_attribute %>" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested <%=singular_table_name%>" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        # Assuming there are no other <%=plural_table_name%> in the database, this
        <%=class_name%>.any_instance.should_receive(:update_attributes).with({ "<%= first_string_attribute %>" => "MyString" })
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => { "<%= first_string_attribute %>" => "MyString" }}
      end

      it "assigns the requested <%=singular_table_name%> as @<%=singular_table_name%>" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => valid_attributes}
        assigns(:<%=singular_table_name%>).should eq(<%=singular_table_name%>)
      end

      it "update and redirects" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => valid_attributes}
        response.should redirect_to(edit_<%=singular_table_name%>_path(assigns(:<%=singular_table_name%>)))
      end

      it "update and render js" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => valid_attributes, format: :js}
        response.should render_template("save")
      end
    end

    describe "with invalid params" do
      it "assigns the <%=singular_table_name%> as @<%=singular_table_name%>" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        <%=class_name%>.any_instance.stub(:save).and_return(false)
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => { "<%= first_string_attribute %>" => "invalid value" }}
        assigns(:<%=singular_table_name%>).should eq(<%=singular_table_name%>)
      end

      it "re-renders the 'edit' template" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        <%=class_name%>.any_instance.stub(:save).and_return(false)
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => { "<%= first_string_attribute %>" => "invalid value" }}
        response.should render_template("edit")
      end

      it "re-renders the 'edit' template js" do
        <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        <%=class_name%>.any_instance.stub(:save).and_return(false)
        put :update, {:id => <%=singular_table_name%>.to_param, :<%=singular_table_name%> => { "<%= first_string_attribute %>" => "invalid value" }, :format => :js}
        response.should render_template("save")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested <%=singular_table_name%>" do
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      expect {
        delete :destroy, {:id => <%=singular_table_name%>.to_param}
      }.to change(<%=class_name%>, :count).by(-1)
    end

    it "redirects to the <%=plural_table_name%> list" do
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      delete :destroy, {:id => <%=singular_table_name%>.to_param}
      response.should redirect_to(<%=plural_table_name%>_url)
    end

    it "fail on destroy" do
      <%=class_name%>.any_instance.stub(:destroy).and_return(false)
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      delete :destroy, {:id => <%=singular_table_name%>.to_param}
      flash[:error].should eql(I18n.t('general.messages.delete_error'))
    end
  end

  describe "DELETE batch_destroy" do
    it "dont destroy with association" do
      <%=class_name%>.stub(:destroy_all).and_raise('error in association')
      expect {
        delete :batch_destroy, {:ids => [] }
      }.to raise_error('error in association')
    end

    it "destroys many requested <%=singular_table_name%> by ids" do
      <%=singular_table_name%> = <%=class_name%>.create! valid_attributes
      expect {
        delete :batch_destroy, {:ids => [<%=singular_table_name%>.id]}
      }.to change(<%=class_name%>, :count).by(-1)
    end

    it "fail on destroy" do
      <%=class_name%>.stub(:destroy_all).and_return(false)
      delete :batch_destroy, {ids: []}
      flash[:error].should eql(I18n.t('general.messages.delete_error'))
    end
  end
end