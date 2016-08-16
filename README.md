# Google PageSpeed Helper gem

A gem for Google's PageSpeed API.<br />
Leverages Google's generated APIs and in doing so can do batch queries of 20 requests at a time.<br />
Can take any number of elements in a list, and will split list for batch queries.
Returns a hash of the results.<br />

## Installing

Add to your Gemfile:
```
gem 'pagespeedhelper', '0.3.0'
```

## Example

**Setup:**
```ruby
require 'pagespeedhelper'

ps = PagespeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY')

# OR with verbose debugging to STDERR
ps = PagespeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY', true)
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

Parse can be run even if errors occurred, see the Errors section for more information.
```ruby
results = PagespeedHelper.parse(data)
```


**Getting Data from Results:**

Each of the rule results from Google are parsed and set in the results hash.<br />
This set of rules varies depending on which strategy is used. Mobile will also include "USABILITY" rule results.

Results being parsed now need to be checked to see if they have an error.
If so there will be no accompanying data, just the URL and the error.

Result for one site checked:
```ruby
results[0]["url"]                                        # url checked
results[0]["score"]                                      # site overall pagespeed score
results[0]["results"][ONE_OF_GOOGLES_RULES]["name"]    # localized name for printing
results[0]["results"][ONE_OF_GOOGLES_RULES]["impact"]  # impact of rule on pagespeed result
results[0]["results"][ONE_OF_GOOGLES_RULES]["summary"] # text explanation of rule result or what could be improved
```
*A note:* Make sure to check if the result had an error, this can be seen further in the bulk results example, and the errors section.

To get the Page Stats:<br />
```
List of Page Stats:
css_response_bytes, html_response_bytes, image_response_bytes, javascript_response_bytes,
number_css_resources, number_hosts, number_js_resources, number_resources,
number_static_resources, other_response_bytes, total_request_bytes
```

Stats now have additional hashes for localized names and their value
```ruby
results[0]["stats"][STAT_FROM_ABOVE]["name"]
results[0]["stats"][STAT_FROM_ABOVE]["value"]
```

Bulk results example:
```ruby
results.each do |res|
  if !res.key?("error")
    # do something with valid result
  else
    # do something with error
  end
end
```

**Errors:**

As seen above, errors are now listed in the result hash, a manual check needs to be done to see if the site had an issue with the request. It will also contain the reason why it failed.

Errors will not be changed when `PagespeedHelper.parse()` is run. In fact, it is advantageous to parse before checking for errors as then you can simply do the bulk results example above. Otherwise to check the return from `ps.query()` requires examining hashes and objects, which is trickier.

The available error information is:
```ruby
results[0]["error"] # the error that occurred, MainResource, etc.
results[0]["url"]   # the url where the error occurred
```

## Running the tests

Tests are under spec/, run with rspec
```
rspec /spec/lib/pagespeedhelper_spec.rb
```
