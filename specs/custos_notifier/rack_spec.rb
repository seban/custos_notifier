require "specs/spec_helper"

describe Rack do

  before do
    CustosNotifier.configure do |config|
     config.url = 'localhost'
     config.project = 'awsome'
     config.stage = 'production'
     config.api_key = 'secret'
    end
    @app = lambda { |env| raise RuntimeError, 'My test error' }
    @env = Rack::MockRequest.env_for("/foo",
      'FOO' => 'BAR',
      :method => 'GET',
      :input => 'THE BODY'
    )
    @middleware = CustosNotifier::Rack.new(@app)
    RestClient.stub(:post).and_return { "OK" }
  end

  it "should notify Custos Service about error" do
    # TODO: how to mock class method, consider use of rr
  end

end