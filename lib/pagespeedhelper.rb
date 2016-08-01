require 'google/apis/pagespeedonline_v2'
require 'google/apis'
require 'logger'

class PageSpeedHelper
  attr_reader :errors, :results
  
  Pagespeedonline = Google::Apis::PagespeedonlineV2
  
  def initialize(key, debug=false)
    @psservice = Pagespeedonline::PagespeedonlineService.new
    @psservice.key = key
    
    if debug
      Google::Apis.logger = Logger.new(STDERR)
      Google::Apis.logger.level = Logger::DEBUG
    end
  end

  def query(urls, secure=false, strategy="desktop")
    @data = []
    @errors = []
    urls = [urls] if !urls.is_a?(Array)
    @urls = urls.each { |url| add_protocol_if_absent!(url, secure) }
    @urls.each_slice(20).to_a.each do |url_list|
      send_request(url_list, strategy)
      sleep(0.5)
    end
  end

  def parse
    @results = []
   
    @data.each_with_index do |result, i|
      result_hash = Hash.new
      result_hash["url"] = @urls[i]
      result_hash["score"] = result.rule_groups["SPEED"].score
      result_hash["results"] = Hash.new
      build_rule_hash(result_hash["results"], result.formatted_results.rule_results)

      @results.push(result_hash)
    end
  end


  private

  def send_request(urls, strategy="desktop")
    @psservice.batch do |ps|
      urls.each do |url|
        ps.run_pagespeed(url, filter_third_party_resources: nil, locale: nil, rule: nil, screenshot: nil, 
                         strategy: strategy, fields: nil, quota_user: nil, user_ip: nil, options: nil) do |result, err|
          err.nil? ? @data.push(result) : @errors.push({ "url" => url, "error" => err })
        end
      end
    end
  end

  def build_rule_hash(hash, rule_res)
    rule_names = ["AvoidLandingPageRedirects", "EnableGzipCompression", "LeverageBrowserCaching",
                  "MainResourceServerResponseTime", "MinifyCss", "MinifyHTML",
                  "MinifyJavaScript", "MinimizeRenderBlockingResources", "OptimizeImages",
                  "PrioritizeVisibleContent"]
  
    rule_names.each do |rule|
      hash[rule] = Hash.new
      hash[rule]["name"] = rule_res[rule].localized_rule_name
      hash[rule]["impact"] = rule_res[rule].rule_impact
        
      if !rule_res[rule].summary.nil?
        hash[rule]["summary"] = build_summary_string!(rule_res[rule].summary)
      end
    end
  end
  
  def build_summary_string!(summary)
    if summary.to_h.key?(:args)
      summary.args.each do |arg|
        summary.format.sub!('{{' + arg.key + '}}', arg.value) if arg.key != 'LINK'
      end
    end 

    summary.format.include?(" Learn more") ? summary.format.split(" Learn more")[0] : summary.format 
  end

  def add_protocol_if_absent!(url, secure=false)  
    if !url.include? "http://" and !url.include? "https://"
      secure ? url.replace("https://" + url) : url.replace("http://" + url)
    end
  end

end
