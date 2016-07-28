require 'google/apis/pagespeedonline_v2'
require 'google/apis'
require 'logger'
require 'pry'
# left to do: implement the options parameter and get the format string data

class PageSpeedHelper
  attr_reader :errors, :results
  
  Pagespeedonline = Google::Apis::PagespeedonlineV2
  
  def initialize(key, debug=false)
    @psservice = Pagespeedonline::PagespeedonlineService.new
    @psservice.key = key
    @errors = []
    @urls = []
    @results = []
    if debug
      Google::Apis.logger = Logger.new(STDERR)
      Google::Apis.logger.level = Logger::DEBUG
    end
  end

  def self.add_protocol_if_absent!(url, secure=false)  
    if !url.include? "http://" and !url.include? "https://"
      if secure
        url.replace "https://" + url
      else
        url.replace "http://" + url
      end
    end
  end

  def self.build_summary_string(summary)
    if summary.to_h.key(:args=) or summary.to_h.key(:args)
      summary.args.each do |arg|
        if arg.key != 'LINK'
          summary.format.sub! '{{' + arg.key + '}}', arg.value
        end
      end
    end 

    summary.format = summary.format.include?(" Learn more") ? summary.format.split(" Learn more")[0] : summary.format 
  end

  def query(urls, secure=false, strategy="desktop")
    urls = [urls] if !urls.is_a?(Array)
    @urls = urls.each { |url| PageSpeedHelper.add_protocol_if_absent!(url, secure) }
    @data = []
    @urls.each_slice(20).to_a.each do |url_list|
      send_request(url_list, strategy)
      sleep(0.5)
    end
  end

  def parse
    rule_result_names = ["AvoidLandingPageRedirects", "EnableGzipCompression", "LeverageBrowserCaching", "MainResourceServerResponseTime", "MinifyCss", "MinifyHTML", "MinifyJavaScript", "MinimizeRenderBlockingResources", "OptimizeImages", "PrioritizeVisibleContent"]
   
    @data.each_with_index do |result, i|
      if result.nil?
        next
      end
      result_hash = Hash.new
      result_hash["url"] = @urls[i]
      result_hash["score"] = result.rule_groups["SPEED"].score

      result_hash["results"] = Hash.new
      rule_result_names.each do |rule|
        result_hash["results"][rule] = Hash.new
        result_hash["results"][rule]["name"] = result.formatted_results.rule_results[rule].localized_rule_name
        result_hash["results"][rule]["impact"] = result.formatted_results.rule_results[rule].rule_impact
        result_hash["results"][rule]["summary"] = PageSpeedHelper.build_summary_string(result.formatted_results.rule_results[rule].summary) if !result.formatted_results.rule_results[rule].summary.nil?
      end
      @results.push(result_hash)
    end
  end


  private

  def send_request(urls, strategy="desktop")
    @psservice.batch do |ps|
      urls.each do |url|
        ps.run_pagespeed(url, filter_third_party_resources: nil, locale: nil, rule: nil, screenshot: nil, strategy: strategy, fields: nil, quota_user: nil, user_ip: nil, options: nil) do |result, err|
          err.nil? ? @data.push(result) : @errors.push("#{url}, #{err}")
        end
      end
    end
  end

end
