require 'net/http'
require 'rubygems'
require 'rest-client'

module CustosNotifier

  class << self

    def notify(exception, options = {})
      @@url     = "http://localhost:9393"
      @@project = "testproject"
      @@stage    = "beta"
      @@api_key = "8862f9805854012e9117001b639f02f3 "

      options[:exception] = exception
      notice = Notice.new(options)


#      data = {
#        "project"                         => @@project,
#        "api_key"                         => @@api_key,
#        "error[exception_class]"          => exception.class.to_s,
#        "error[message]"                  => exception.message,
#        "error[stage]"                    => @@stage,
#        "error[backtrace]"                => sanitize_backtrace(exception.backtrace),
#        "error[server]"                   => `hostname -s`.chomp,
#        "error[source]"                   => "",
#        "error[process_id]"               => $$,
#        "error[request][uri]"             => notice.request_uri,
#        "error[request][parameters]"      => notice.parameters.inspect,
#        "error[request][document_root]"   => notice.document_root,
#        "error[request][content_length]"  => request.env["CONTENT_LENGTH"],
#        "error[request][http_accept]"     => request.env["HTTP_ACCEPT"],
#        "error[request][http_method]"     => request.env["REQUEST_METHOD"],
#        "error[request][http_cookie]"     => request.env["HTTP_COOKIE"],
#        "error[request][http_host]"       => request.env["HTTP_HOST"],
#        "error[request][http_referer]"    => request.env["HTTP_REFERER"],
#        "error[request][user_agent]"      => request.env["HTTP_USER_AGENT"],
#        "error[request][path_info]"       => request.env["PATH_INFO"],
#        "error[request][query_string]"    => request.env["QUERY_STRING"],
#        "error[request][connection]"      => request.env["CONNECTION"],
#        "error[request][server_name]"     => request.env["SERVER_NAME"]
#      }

      url = URI.parse("#{ @@url }/errors")

      puts notice.to_param.inspect

      RestClient.post(url.to_s, notice.to_param)
    end

  end


  class Notice

    attr_reader :args
    attr_reader :parameters

    def initialize(args)
      @args = args
      @exception = args[:exception]

      @exception_class = @exception.class.to_s
      @message = @exception.message
      @backtrace = @exception.backtrace.join("\n")
      @server = `hostname -s`.chomp
      @source = ""
      @process_id = $$
      @parameters = rack_env(:params).inspect || {}.inspect
      @request_uri  = rack_env(:url) || ""
      @document_root = rack_env(:env) { |env| env["DOCUMENT_ROOT"] } || ""
      @content_length = rack_env(:env) { |env| env["DOCUMENT_ROOT"] } || ""
      @http_accept = rack_env(:env) { |env| env["HTTP_ACCEPT"] } || ""
      @http_method = rack_env(:request_method)
      @http_cookie = rack_env(:env) { |env| env["HTTP_COOKIE"] } || ""
      @http_host = rack_env(:host) || ""
      @http_referer = rack_env(:referer) || ""
      @user_agent = rack_env(:user_agent) || ""
      @path_info = rack_env(:path_info) || ""
      @query_string = rack_env(:query_string) || ""
      @connection = rack_env(:env) { |env| env["HTTP_CONNECTION"] } || ""
      @server_name = rack_env(:env) { |env| env["SERVER_NAME"] } || ""
    end


    def to_param
      {
        :project => "testproject", #
        :api_key => "8862f9805854012e9117001b639f02f3", #
        :error => {
          :exception_class => @exception_class,
          :message => @message,
          :stage => "beta", #
          :backtrace => @backtrace,
          :server => @server,
          :source => @source,
          :process_id => @process_id,
          :request => {
            :uri => @request_uri,
            :parameters => @parameters,
            :document_root => @document_root,
            :content_length => @content_length,
            :http_accept => @http_accept,
            :http_cookie => @http_cookie,
            :http_host => @http_host,
            :http_cookie => @http_referer,
            :user_agent => @user_agent,
            :path_info => @path_info,
            :query_string => @query_string,
            :connection => @connection,
            :server_name => @server_name,
            :http_method => @http_method
          }
        }
      }
    end


    protected


    def rack_env(method)
      return unless rack_request
      value = rack_request.send(method)
      if block_given?
        yield(value) if block_given?
      else
        value
      end
    end


    def rack_request
      @rack_request ||= if args[:rack_env]
        ::Rack::Request.new(args[:rack_env])
      end
    end

  end

end