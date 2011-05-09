module CustosNotifier

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