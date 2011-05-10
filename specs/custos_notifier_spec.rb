require "rspec"

describe CustosNotifier do

  it "should be able to get/set configuration" do
    CustosNotifier.should respond_to :configuration
    CustosNotifier.should respond_to :configuration=
  end

  describe "when call #configure method" do
    before(:each) do
      @configuration = CustosNotifier.configure do |config|
        config.url      = "my_custos.domain.com"
        config.project  = "myProjectName"
        config.api_key  = "my_secret_api_key"
        config.stage    = "beta"
      end
    end

    it "should return CustosNotifier::Configuration instance" do
      @configuration.should be_instance_of CustosNotifier::Configuration
    end

    it "should evaluate passed block on configuration and set all options" do
      CustosNotifier.configuration.url.should eql "my_custos.domain.com"
      CustosNotifier.configuration.project.should eql "myProjectName"
      CustosNotifier.configuration.api_key.should eql "my_secret_api_key"
      CustosNotifier.configuration.stage.should eql "beta"
    end
  end

end