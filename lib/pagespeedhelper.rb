require 'google/apis/pagespeedonline_v2'
require 'google/apis'
require 'logger'

class PagespeedHelper
  
  Pagespeedonline = Google::Apis::PagespeedonlineV2
  
  def initialize(key, limit=32, debug=false)
    @psservice = Pagespeedonline::PagespeedonlineService.new
    @psservice.key = key
    @wait_limit = limit

    if debug
      Google::Apis.logger = Logger.new(STDERR)
      Google::Apis.logger.level = Logger::DEBUG
    end
  end

  def query(urls, strategy="desktop", secure="false")
    @wait_time = 1
    data = Array.new 

    urls = [urls] if !urls.is_a?(Array)
    urls = urls.each { |url| add_protocol_if_absent!(url, secure) }
    
    urls.each_slice(20).to_a.each do |url_list|
     
      begin
        results = send_request(url_list, strategy)
      end while rate_error?(results)

      data.concat results
      sleep(3)
    end
    
    data
  end


  def self.parse(data) 
    results = Array.new
    
    data.each do |result|
      if !result.is_a?(Hash)
        result_hash = { 
          "url" => result.id, 
          "score" => result.rule_groups["SPEED"].score, 
          "stats" => Hash[result.page_stats.to_h.map{ |k, v| [k.to_s, { 
            "name" => k.to_s.capitalize.gsub!('_', ' '), 
            "value" => v } ] }],
          "results" => build_rule_hash(result.formatted_results.rule_results)
        }
      else
        result_hash = result
      end
      
      results.push(result_hash)
    end

    results
  end

  def self.build_rule_hash(rule_res)
    rule_hash = Hash.new
    
    rule_res.each do |rule, info|
      rule_hash[rule] = { 
        "name" => info.localized_rule_name, 
        "impact" => info.rule_impact.round(2), 
        "summary" => build_summary_string!(info.summary)
      }
    end
    
    rule_hash
  end
  
  def self.build_summary_string!(summary)
    return nil if summary.nil?

    if summary.to_h.key?(:args)
      summary.args.each do |arg|
        summary.format.sub!(arg.key, arg.value)
        summary.format.gsub!(/\{{2}|\}{2}/,'')
      end
    end 

    summary.format.split('.')[0]
  end


  private_class_method :build_rule_hash, :build_summary_string!

  private

  def rate_error?(data)
    return false if @wait_time > @wait_limit
    data.each do |d|
      if d.is_a?(Hash)
        if d["error"].include?("rateLimitExceeded") or d["error"].include?("userRateLimitExceeded")
          sleep(@wait_time)
          @wait_time <= @wait_limit ? @wait_time *= 2 : @wait_limit
          return true
        end
      end
    end
    return false
  end

  def send_request(urls, strategy="desktop")
    data = Array.new
    
    @psservice.batch do |ps|
      urls.each do |url|
        ps.run_pagespeed(url, strategy: strategy) do |result, err|
          err.nil? ? data.push(result) : data.push({ "url" => url, "error" => err.to_s })
        end
      end
    end
    data
  end

  def add_protocol_if_absent!(url, secure=false)  
    if !url.include? "http://" and !url.include? "https://"
      secure ? url.replace("https://" + url) : url.replace("http://" + url)
    end
  end

end
