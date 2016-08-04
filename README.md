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
```ruby
require 'pagespeedhelper'

ps = PageSpeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY')

# OR with verbose debugging to STDERR
ps = PageSpeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY', true)
```


**Query:**
```ruby
data = ps.query('www.example.com')

# OR can take any number of elements in a list
data = ps.query(['www.foo.com', 'www.bar.com'])

# query can also add http protocol
# and switch between mobile and desktop strategy for pagespeed, default is desktop
# setting the second parameter to true will prepend 'https://' to the url
data = ps.query([LIST_OF_URLS], true, "mobile")
```
A note: Each time a query is run, the errors field will get emptied and replaced, make sure the errors are copied out before running subsequent queries!


**Parse Results:**
```ruby
results = PageSpeedHelper.parse(data)
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
```ruby
results[0]["url"]                                        # url checked
results[0]["score"]                                      # site overall pagespeed score
results[0]["results"][ONE_OF_THE_RULES_ABOVE]["name"]    # localized name for printing
results[0]["results"][ONE_OF_THE_RULES_ABOVE]["impact"]  # impact of rule on pagespeed result
results[0]["results"][ONE_OF_THE_RULES_ABOVE]["summary"] # text explanation of rule result or what could be improved
```


**View Errors:**
```ruby
ps.errors     # list of errors
```

Errors are string of the form:
```ruby
ps.errors[0]["url"]   # url of site with error
ps.errors[0]["error"] # site error
```

## Running the tests

Tests are under spec/, run with rspec
```
rspec /spec/lib/pagespeedhelper_spec.rb
```
