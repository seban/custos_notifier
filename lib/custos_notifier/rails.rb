require 'custos_notifier'
require 'custos_notifier/rails/action_controller_catcher'

if defined?(ActionController::Base)
  ActionController::Base.send(:include, CustosNotifier::Rails::ActionControllerCatcher)
end