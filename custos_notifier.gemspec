Gem::Specification.new do |spec|
  spec.name = "custos_notifier"
  spec.summary = "Notifier for Custos service."
  spec.description = "With this gem you can submit error messages to Custos service."
  spec.authors = ["Sebastian Nowak"]
  spec.email = "sebastian.nowak@implix.com"
  spec.version = "0.3.6"

  spec.add_dependency("rest-client", "~>1.6")
  spec.add_dependency("json")

  spec.require_path = "lib"
  spec.files = Dir["lib/**/*.rb"]
end
