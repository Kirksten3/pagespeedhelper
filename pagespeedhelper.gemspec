Gem::Specification.new do |s|
  s.name          = 'pagespeedhelper'
  s.version       = '0.1.0'
  s.date          = '2016-07-26'
  s.summary       = 'A simple wrapper for Google\'s PageSpeed API'
  s.description   = 'Has commands like query and does the work for you, given an API key'
  s.authors       = ['Kirk Stennett']
  s.email         = 'kirk.stennett@getg5.com'
  s.files         = ['lib/pagespeedhelper.rb']
  s.homepage      = 'http://rubygems.org/gems/pagespeedhelper'
  s.license       = 'MIT'

  s.add_dependency "rails", "~> 4.2"

  s.add_dependency "google-api-client", "0.9"

  s.add_dependency "rspec", "~> 3.5"

  s.add_dependency 'pry', '~> 0.9.12'
end
