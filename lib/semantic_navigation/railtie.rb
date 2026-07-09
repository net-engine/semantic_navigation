require 'rails/railtie'

module SemanticNavigation
  class Railtie < Rails::Railtie
    initializer 'semantic_navigation.helpers' do
      ActiveSupport.on_load(:action_view) do
        include SemanticMenuHelper
      end

      ActiveSupport.on_load(:action_controller) do
        include SemanticMenu::Controller
      end
    end
  end
end
