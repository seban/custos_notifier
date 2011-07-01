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
        if rails_3_app?
          if rails_3_not_dev?
            [500, {"Content-Type" => "text/html"}, File.read(File.join Rails.root, "public/500.html")]
          else
            raise
          end
        else
          [500, {"Content-Type" => "text/html"},"Something went wrong"]
        end
      end
    end


    protected


    def rails_3_app?
      defined?(Rails).nil? != true
    end


    def rails_3_not_dev?
      !%w(development test).include?(Rails.env)
    end

  end

end
