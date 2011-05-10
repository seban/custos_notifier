require "specs/spec_helper"

describe CustosNotifier::Configuration do

  describe "instance" do
    before(:each) do
      @configuration = CustosNotifier::Configuration.new
    end

    it("should allow to set/get service url") do
      @configuration.should respond_to :url
      @configuration.should respond_to :url=
    end

    it "should allow to set/get project name" do
      @configuration.should respond_to :project
      @configuration.should respond_to :project=
    end

    it "should allow to set/get api key" do
      @configuration.should respond_to :api_key
      @configuration.should respond_to :api_key=
    end

    it "should allow to set/get stage" do
      @configuration.should respond_to :stage
      @configuration.should respond_to :stage=
    end
  end

end