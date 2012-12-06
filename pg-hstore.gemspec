$spec = Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'pg-hstore'
  s.version = '1.0'
  s.date = '2011-11-10'

  s.description = "postgresql hstore parser/deparser"
  s.summary     = ""

  s.authors = ["Peter van Hardenberg"]
  s.email = ["pvh@heroku.com"]

  s.files = Dir["lib/**/*.rb"]

  s.executables = []

  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.homepage = "http://github.com/pvh/pg-hstore"
  s.require_paths = %w[lib]
end
