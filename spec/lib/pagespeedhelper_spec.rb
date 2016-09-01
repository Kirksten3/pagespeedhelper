require 'spec_helper'
require 'pagespeedhelper'
require 'pry'
require 'dotenv'

RSpec.describe PagespeedHelper do
  
  Pagespeedonline = Google::Apis::PagespeedonlineV2

  describe '#query' do
    let(:ps) { PagespeedHelper.new(ENV['PAGESPEED_API_TOKEN']) }
    let(:url) { "www.foo.org" }
    let(:url2) { "www.foo2.org" }

    it 'should return a ruby object of results' do 
      VCR.use_cassette 'lib/pagespeedhelper' do
        expect(ps.query(url)[0].rule_groups.key?("SPEED")).to eq(true)
      end
    end

    #it 'should return empty array and an error' do
    #VCR.use_cassette 'lib/pagespeedhelper' do
    #expect(ps.query(url2)[0].key?('error')).to eq(true)
    #end
    #end
  end

  describe '.parse' do
    let(:rule_groups) { { "SPEED" => Pagespeedonline::Result::RuleGroup.new({score: 100 }) } }

    let(:arginfo) { Pagespeedonline::FormatString::Arg.new({ key: "NUM_TIMES", value: "3" }) }
    let(:info) { { format: "Foo occurs {{NUM_TIMES}}. Learn more", args: [arginfo] } }
    let(:format) { Pagespeedonline::FormatString.new(info) }
    let(:rule) { {  "AvoidLandingPageRedirects" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', rule_impact: 5.5599, summary: format }) } }

    let(:stats) { Pagespeedonline::Result::PageStats.new({ css_response_bytes: 500 }) }

    let(:form_results) { Pagespeedonline::Result::FormattedResults.new({ locale: 'en-us', rule_results: rule }) }
    let(:data) { Pagespeedonline::Result.new({ formatted_results: form_results, rule_groups: rule_groups, page_stats: stats }) }

    let(:res) { PagespeedHelper.parse([data, { "url" => 'http://www.bar.com', "error" => "Bad Request" }]) }

    context 'parse default creates proper generic hash' do

      it 'should set results to have the formatted hash results' do
        expect(res[0].key?("score")).to eq(true)
        expect(res[0].key?("results")).to eq(true)
      end

      it 'should set the results hash' do
        expect(res[0]["results"].key?("AvoidLandingPageRedirects")).to eq(true)
        expect(res[0]["results"]["AvoidLandingPageRedirects"]["summary"]).to eq("Foo occurs 3")
        expect(res[0]["results"]["AvoidLandingPageRedirects"]["impact"]).to eq(5.56)
      end

      it 'should set the stats hash' do
        expect(res[0]["stats"].key?("css_response_bytes")).to eq(true)
        expect(res[0]["stats"]["css_response_bytes"]["name"]).to eq('Css response bytes')
        expect(res[0]["stats"]["css_response_bytes"]["value"]).to eq(500)
      end

      it 'should catch and append the error' do
        expect(res[1].key?("error")).to eq(true)
      end
    end

  end  

end
