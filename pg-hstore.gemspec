Gem::Specification.new do |s|
  s.name = 'pg-hstore'
  s.version = '1.1.4'

  s.description = "postgresql hstore parser/deparser - provides PgHstore.dump and PgHstore.load (aka parse)"
  s.summary     = ""

  s.authors = ["Peter van Hardenberg", "Seamus Abshere"]
  s.email = ["pvh@heroku.com", "seamus@abshere.net"]

  s.files = Dir["lib/**/*.rb"]

  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.homepage = "https://github.com/seamusabshere/pg-hstore"
  s.require_paths = %w[lib]
end
