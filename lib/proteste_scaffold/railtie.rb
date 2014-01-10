require 'rails/railtie'
require 'proteste_scaffold/view_helpers'
require 'proteste_scaffold/controller'
module ProtesteScaffold
  class Railtie < Rails::Railtie

    initializer "proteste_scaffold.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, ProtesteScaffold::Controller)
      end
    end

    initializer "proteste_scaffold.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end