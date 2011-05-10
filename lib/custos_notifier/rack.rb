module CustosNotifier

  # Simple middleware for handling raised exceptions in Rack applications
  # Example:
  #   class MyApp
  #     def call(env)
  #       raise "my exception"
  #     end
  #   end
  #
  #   use CustosNotifier::Rack
  #   run MyApp
  class Rack

    def initialize(app)
      @app = app  
    end


    def call(env)
      begin
        @app.call(env)
      rescue Exception => raised
        CustosNotifier.notify(raised, :rack_env => env)
        raise
      end
    end

  end

end