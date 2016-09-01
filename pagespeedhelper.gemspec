Gem::Specification.new do |s|
  s.name          = 'pagespeedhelper'
  s.version       = '0.5.3'
  s.date          = Date.today.to_s
  s.summary       = 'A wrapper for Google\'s PageSpeed API'
  s.description   = 'Utilizes Google\'s Api for ruby to batch query 20 websites, accessible immediately, and formattable.'
  s.authors       = ['Kirk Stennett']
  s.email         = 'kirk.stennett@getg5.com'
  s.files         = ['lib/pagespeedhelper.rb']
  s.homepage      = 'http://rubygems.org/gems/pagespeedhelper'
  s.license       = 'MIT'

  s.add_dependency "google-api-client", "0.9"

  s.add_dependency "rspec"

  s.add_dependency "webmock", "2.1.0"

  s.add_dependency "vcr", "3.0.3"

  s.add_dependency "dotenv"
end
