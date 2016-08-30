Gem::Specification.new do |s|
  s.name          = 'pagespeedhelper'
  s.version       = '0.4.8'
  s.date          = Date.today.to_s
  s.summary       = 'A wrapper for Google\'s PageSpeed API'
  s.description   = 'Utilizes Google\'s Api for ruby to batch query 20 websites at a time, and format the results.'
  s.authors       = ['Kirk Stennett']
  s.email         = 'kirk.stennett@getg5.com'
  s.files         = ['lib/pagespeedhelper.rb']
  s.homepage      = 'http://rubygems.org/gems/pagespeedhelper'
  s.license       = 'MIT'

  s.add_dependency "google-api-client", "0.9"

  s.add_dependency "rspec"
end
