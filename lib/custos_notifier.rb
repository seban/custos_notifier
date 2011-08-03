require 'rubygems'
require 'rack'
require 'rest-client'

require 'custos_notifier/configuration'
require 'custos_notifier/rack'

require "custos_notifier/railtie" if defined?(Rails::Railtie)

module CustosNotifier

  class << self

    attr_accessor :configuration

    # Notify Custos service about raised exceptions. Exception will be ignored if notifier is
    # configured with "development" stage. Raised exception is passed to this method, additional
    # request attributes can be passed.
    # Very simple example you can find in <tt>CustosNotifier::Rack</tt> middleware.
    # Example:
    #   begin
    #     raise "My example exception"
    #   rescue => ex
    #     CustosNotifier.notify ex, :rack_env => env
    #   end
    #
    # exception:: Exception ancestors
    # options:: Hash, default empty hash.
    def notify(exception, options = {})
      return if ["development", "test"].include? configuration.stage.downcase

      options[:exception] = exception
      notice = Notice.new(options)

      url = URI.parse("#{ configuration.url }/errors")
      RestClient.post(url.to_s, notice.to_param)
    end


    # Configure Custos notifier. Sets configuration options based on passed block.
    # Example:
    #   CustosNotifier.configure do |config|
    #     config.url = "blah.foo.bar'
    #     config.project = 'awsome'
    #     config.stage = 'production'
    #     config.api_key = 'secret'
    #   end
    #
    # returns:: Configuration
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.configuration.stage ||= detect_stage
      configuration
    end


    # Send custom notification to Custos service. Any messages can be sent to service in
    # <tt>message</tt> param. Second parameter is optional and could be anything you want.
    def custom_notify(message, parameters = {})
      return if ["test"].include? configuration.stage.downcase

      url = "#{ configuration.url }/notifications"
      notify_params = {
        :project => CustosNotifier.configuration.project,
        :api_key => CustosNotifier.configuration.api_key
      }
      notify_params["notification"] = {"title" => message, "customs" => parameters.inspect,
        "stage" => CustosNotifier.configuration.stage
      }
      RestClient.post(url, notify_params)
    end


    protected


    # Try to auto-detect stage. If detection is impossible method returns <tt>nil</tt>.
    def detect_stage
      ENV['RACK_ENV'] || ENV['RAILS_ENV'] || Rails.env
    rescue NameError
      nil
    end

  end


  # Mainly goal of this class is evaulate HTTP request attributes and build a hash object containing
  # all parameters needed to post error to Custos Service.
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
      @parameters = rack_env(:params) || {}
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
      @session = rack_env(:env) { |env| env["rack.session"].inspect }
    end


    # Method builds (based on parameters passed to constructor) a parameter hash which i posted
    # to Custos service.
    #
    # returns:: Hash
    def to_param
      {
        :project => CustosNotifier.configuration.project,
        :api_key => CustosNotifier.configuration.api_key,
        :error => {
          :exception_class => @exception_class,
          :message => @message,
          :stage => CustosNotifier.configuration.stage,
          :backtrace => @backtrace,
          :server => @server,
          :source => @source,
          :process_id => @process_id,
          :request => {
            :uri => @request_uri,
            :parameters => filter(@parameters).inspect,
            :document_root => @document_root,
            :content_length => @content_length,
            :http_accept => @http_accept,
            :http_cookie => @http_cookie,
            :http_host => @http_host,
            :http_referer => @http_referer,
            :user_agent => @user_agent,
            :path_info => @path_info,
            :query_string => @query_string,
            :connection => @connection,
            :server_name => @server_name,
            :http_method => @http_method,
            :session => @session
          }
        }
      }
    end


    protected


    def request
      @args[:request] || rack_request
    end


    # Get a value from <tt>Rack</tt> request object. Block can be passed to method and it will be
    # evaluated on <tt>method's</tt> return.
    def rack_env(method)
      return unless request
      value = request.send(method)
      if block_given?
        yield(value) if block_given?
      else
        value
      end
    end


    # Method returns <tt>Rack</tt> request object based on <tt>self.args[:rack_env]</tt> values.
    # If there aren't values <tt>nil</tt> will be returned.
    #
    # returns:: Rack::Request || NilClass
    def rack_request
      @rack_request ||= if args[:rack_env]
        ::Rack::Request.new(args[:rack_env])
      end
    end


    def filter(hash)
      unless filters.empty?
        hash.each do |key, value|
          if filter_key?(key)
            hash[key] = "[FILTERED]"
          elsif value.respond_to?(:to_hash)
            filter(hash[key])
          end
        end
      end
      hash
    end


    def filters
      @filters ||= @args[:rack_env]["action_dispatch.parameter_filter"] || []
    end


    def filter_key?(key)
      filters.any? {|filter| key.to_s.include? filter.to_s }
    end

  end

end
