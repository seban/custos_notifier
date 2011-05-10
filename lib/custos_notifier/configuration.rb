module CustosNotifier

  # Class holds configuration (url, api_key, project, stage) access for Custos notifier.
  class Configuration
    attr_accessor :url
    attr_accessor :api_key
    attr_accessor :project
    attr_accessor :stage
  end

end
