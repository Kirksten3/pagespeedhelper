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

# query WILL also add http/https to the url if not present, default is false which is http
# and can switch between mobile and desktop strategy for pagespeed, default is desktop
data = ps.query([LIST_OF_URLS], true, "mobile")
```
*A note:* Each time a query is run, the errors field will get emptied and replaced, make sure the errors are copied out before running subsequent queries!


**Parse Results:**
```ruby
results = PageSpeedHelper.parse(data)
```


**Getting Data from Results:**

Each of the rule results from Google are parsed and set in the results hash.<br />
This set of rules varies depending on which strategy is used. Mobile will also include "USABILITY" rule results.

Results being parsed now need to be checked to see if they have an error.
If so there will be no accompanying data, just the URL and the error.

Result for one site checked:
*A note:* Make sure to check if the result had an error
```ruby
results[0]["url"]                                        # url checked
results[0]["score"]                                      # site overall pagespeed score
results[0]["results"][ONE_OF_GOOGLES_RULES]["name"]    # localized name for printing
results[0]["results"][ONE_OF_GOOGLES_RULES]["impact"]  # impact of rule on pagespeed result
results[0]["results"][ONE_OF_GOOGLES_RULES]["summary"] # text explanation of rule result or what could be improved
```

To get the Page Stats:<br />
```
List of Page Stats:
css_response_bytes, html_response_bytes, image_response_bytes, javascript_response_bytes,
number_css_resources, number_hosts, number_js_resources, number_resources,
number_static_resources, other_response_bytes, total_request_bytes
```

```ruby
results[0]["stats"][STAT_FROM_ABOVE]
```

Bulk results example:
```ruby
ps.results.each do |res|
  if !res.key?("error")
    # do something with valid result
  else
    # do something with error
  end
end
```

**Errors:**
As seen above, errors are now listed in the result hash, a manual check needs to be done to see if the site had an issue with the request. It will also contain the reason why it failed.

## Running the tests

Tests are under spec/, run with rspec
```
rspec /spec/lib/pagespeedhelper_spec.rb
```
