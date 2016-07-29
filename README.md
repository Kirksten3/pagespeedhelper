# Google PageSpeed Helper gem

A gem for Google's PageSpeed API.<br />
Leverages Google's generated APIs and in doing so can do batch queries of 20 requests at a time.<br />
Returns a hash of the results.<br />

## Installing

Add to your Gemfile:
```
gem 'pagespeedhelper', :git => 'git://github.com/Kirksten3/pagespeed-gem.git'
```

## Example

Setup:
```
require 'pagespeedhelper'
ps = PageSpeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY')
```

Query:
```
ps.query('www.example.com')
# OR
ps.query(['www.foo.com', 'www.bar.com'])
```

Parse Results:
```
ps.parse
```

View Results:
```
ps.results
```

View Errors:
```
ps.errors
```

## Running the tests

Tests are under spec/, run with rspec
```
rspec /spec/lib/pagespeedhelper_spec.rb
```
