require "specs/spec_helper"

describe "Notice" do

  before do
    exception = begin
      raise RuntimeError.new("My test exception")
    rescue => ex
      ex
    end
    @notice = CustosNotifier::Notice.new({
      :exception => exception,
      :rack_env => {
        "HTTP_HOST"=>"localhost:9090",
        "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "SERVER_NAME"=>"localhost",
        "REQUEST_PATH"=>"/",
        "rack.url_scheme"=>"http",
        "HTTP_KEEP_ALIVE"=>"115",
        "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; pl; rv:1.9.2.17) Gecko/20110420 Firefox/3.6.17",
        "REMOTE_HOST"=>"user1.info.localhost",
        #"rack.errors"=>#<Rack::Lint::ErrorWrapper:0x1005ba760 @error=#<IO:0x1001c9b88>>,
        "HTTP_ACCEPT_LANGUAGE"=>"pl,en-us;q=0.7,en;q=0.3",
        "SERVER_PROTOCOL"=>"HTTP/1.1",
        "rack.version"=>[1, 1],
        "rack.run_once"=>false,
        "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.8.7/2011-02-18)",
        "REMOTE_ADDR"=>"127.0.0.1",
        "PATH_INFO"=>"/",
        "SCRIPT_NAME"=>"",
        "HTTP_VERSION"=>"HTTP/1.1",
        "rack.multithread"=>true,
        "rack.multiprocess"=>false,
        "REQUEST_URI"=>"http://localhost:9090/",
        "HTTP_ACCEPT_CHARSET"=>"ISO-8859-2,utf-8;q=0.7,*;q=0.7",
        "SERVER_PORT"=>"9090",
        "REQUEST_METHOD"=>"GET",
        "rack.input"=> Rack::Lint::InputWrapper.new(StringIO.new), #<Rack::Lint::InputWrapper:0x1005bac10 @input=#<StringIO:0x10112bba8>>,
        "HTTP_ACCEPT_ENCODING"=>"gzip,deflate",
        "HTTP_CONNECTION"=>"keep-alive",
        "QUERY_STRING"=>"",
        "GATEWAY_INTERFACE"=>"CGI/1.1"
      }
    })
  end

  describe "when call #to_param method" do
    before do
      @params = @notice.to_param
    end

    it "should return a Hash instance" do
      @params.should be_kind_of Hash
    end

    it "returned hash should contain :error key witch Hash instance" do
      @params[:error].should be_kind_of Hash
    end

    it "errors should include :exception_class key" do
      @params[:error][:exception_class].should eql "RuntimeError"
    end

    it "error should include :message key" do
      @params[:error][:message].should eql "My test exception"
    end

    it "error should include :backtrace key" do
      @params[:error][:backtrace].should be_kind_of String
    end

    it "error should include :server key" do
      @params[:error][:server].should be_kind_of String
    end

    it "error should include :source key" do
      @params[:error][:source].should be_kind_of String
    end

    it "error should include :process_id key" do
      @params[:error][:process_id].should be_kind_of Fixnum
    end

    it "error should include :request key with another Hash instance as value and special keys in it" do
      @params[:error][:request].should be_instance_of Hash
      @params[:error][:request][:uri].should be_instance_of String
      @params[:error][:request][:parameters].should be_instance_of String
      @params[:error][:request][:document_root].should be_instance_of String
      @params[:error][:request][:content_length].should be_instance_of String
      @params[:error][:request][:http_accept].should be_instance_of String
      @params[:error][:request][:http_cookie].should be_instance_of String
      @params[:error][:request][:http_host].should be_instance_of String
      @params[:error][:request][:http_referer].should be_instance_of String
      @params[:error][:request][:user_agent].should be_instance_of String
      @params[:error][:request][:path_info].should be_instance_of String
      @params[:error][:request][:query_string].should be_instance_of String
      @params[:error][:request][:connection].should be_instance_of String
      @params[:error][:request][:server_name].should be_instance_of String
      @params[:error][:request][:http_method].should be_instance_of String
    end
  end

end