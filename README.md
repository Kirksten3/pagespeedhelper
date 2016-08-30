# Google PageSpeed Helper gem

A gem for Google's PageSpeed API.<br />
[![Gem Version](https://badge.fury.io/rb/pagespeedhelper.svg)](https://badge.fury.io/rb/pagespeedhelper)

## Features
Leverages Google's generated APIs and in doing so can do batch queries of 20 requests at a time.<br />
Can take any number of domains in a list to look up.<br />
Uses exponential backoff to handle rate limit errors from Google.</br >
Failed rate limit queries are automatically re-run.<br />

## Installing

Add to your Gemfile:
```ruby
gem 'pagespeedhelper', '>=0.4.7'
```
Minor updates should no longer break functionality.

## Example

**Setup:**
```ruby
require 'pagespeedhelper'

ps = PagespeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY')

# With exponential backoff the max time to wait can be set as:
# See more in the Errors Section
ps = PagespeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY', 32)

# Verbose debugging can be set by:
ps = PagespeedHelper.new('YOUR_GOOGLE_PAGESPEED_API_KEY', 32, true)
```


**Query:**
```ruby
data = ps.query('www.example.com')

# OR can take any number of elements in a list
data = ps.query(['www.foo.com', 'www.bar.com'])

# the strategy parameter can be either "mobile" or "desktop" for pagespeed, default is desktop
# query() WILL also add http/https to the url if not present, default is false which is http
data = ps.query([LIST_OF_URLS], "mobile", true)
```


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

**Bulk results example:**
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

As of `v0.4.1` this gem utilizes exponential backoff which waits in between sending batch requests if a query returns a rate limit error (`rateLimitExceeded` or `userRateLimitExceeded`). This starts at one and goes to the values set in the initialization, or 32 which is default. This value is the max amount of time it will wait, after which if another rate error occurs it will be added into the results hash with the rest of the errors / results.

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
rspec spec/lib/pagespeedhelper_spec.rb
```
