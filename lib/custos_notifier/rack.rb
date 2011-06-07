module CustosNotifier

  # Simple middleware for handling raised exceptions in Rack applications
  # Example:
  #   class MyApp
  #     def call(env)
  #       raise "my exception"
  #     end
  #   end
  #
  #   CustosNotifier.configure do |config|
  #     config.url      = "foo.blah.bar"
  #     config.project  = "awsomeSite"
  #     config.stage    = "production"
  #     config.api_key  = "secret"
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
        [500, {"Content-Type" => "text/html"},"Something went wrong"]
      end
    end

  end

end
