# Google PageSpeed Helper gem

A gem for Google's PageSpeed API.<br />
Leverages Google's generated APIs and in doing so can do batch queries of 20 requests at a time.<br />
Can take any number of elements in a list, and will split list for batch queries.
Returns a hash of the results.<br />

## Installing

Add to your Gemfile:
```
gem 'pagespeedhelper', :git => 'git://github.com/Kirksten3/pagespeed-gem.git'
```

## Example

**Setup:**
```
require 'pagespeedhelper'

ps = PageSpeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY')

# OR with verbose debugging to STDERR
ps = PageSpeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY', true)
```

**Query:**
```
ps.query('www.example.com')

# OR can take any number of elements in a list
ps.query(['www.foo.com', 'www.bar.com'])
```

**Parse Results:**
```
ps.parse
```

**View Results:**
```
ps.results # list of results
```

**Getting Data from Results:**

Each of the rule results from Google are parsed and set in the results hash.

List of Google's Rules: 
```
"AvoidLandingPageRedirects", "EnableGzipCompression", "LeverageBrowserCaching", 
"MainResourceServerResponseTime", "MinifyCss", "MinifyHTML", 
"MinifyJavaScript", "MinimizeRenderBlockingResources", "OptimizeImages", 
"PrioritizeVisibleContent"
```

Result for one site checked:
```
ps.results[0]["url"]                                        # url checked
ps.results[0]["score"]                                      # site overall pagespeed score
ps.results[0]["results"][ONE_OF_THE_RULES_ABOVE]["name"]    # localized name for printing
ps.results[0]["results"][ONE_OF_THE_RULES_ABOVE]["impact"]  # impact of rule on pagespeed result
ps.results[0]["results"][ONE_OF_THE_RULES_ABOVE]["summary"] # text explanation of rule result or what could be improved
```

**View Errors:**
```
ps.errors # list of errors
```

Errors are string of the form:
```
ps.errors[0]["url"]   # url of site with error
ps.errors[0]["error"] # site error
```

## Running the tests

Tests are under spec/, run with rspec
```
rspec /spec/lib/pagespeedhelper_spec.rb
```
