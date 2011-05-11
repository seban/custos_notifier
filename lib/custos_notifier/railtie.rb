module CustosNotifier

  class Railtie < Rails::Railtie

    # Use CustosNotifier::Rack as one of used middlewares.
    initializer "custos_notifier.user_middleware" do |app|
      app.config.middleware.use CustosNotifier::Rack
    end
  end

end