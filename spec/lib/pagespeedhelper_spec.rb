require 'pagespeedhelper'
require 'pry'

RSpec.describe PageSpeedHelper do
  
  Pagespeedonline = Google::Apis::PagespeedonlineV2
  
  describe '#query' do
    let(:ps) { PageSpeedHelper.new('foo') }
    let(:url) { "www.foo.org" }
    
    it 'should add http protocol for the query' do
      ps.query(url)
      
      expect(ps.instance_variable_get(:@errors).count).to eq(1)
      expect(ps.instance_variable_get(:@urls)).to eq(['http://www.foo.org'])
    end
  end

  describe '#parse' do
    let(:ps) { PageSpeedHelper.new('foo') }
    let(:rule_groups) { { "SPEED" => Pagespeedonline::Result::RuleGroup.new({score: 100 }) } }
    let(:rule) { {  "AvoidLandingPageRedirects" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "EnableGzipCompression" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "LeverageBrowserCaching" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "MainResourceServerResponseTime" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "MinifyCss" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "MinifyHTML" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "MinifyJavaScript" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "MinimizeRenderBlockingResources" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "OptimizeImages" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }),
                    "PrioritizeVisibleContent" => Pagespeedonline::Result::FormattedResults::RuleResult.new({ localized_rule_name: 'none', impact: 5, summary: format }) } }
    let(:form_results) { Pagespeedonline::Result::FormattedResults.new({ locale: 'en-us', rule_results: rule }) }
    let(:data) { Pagespeedonline::Result.new({ formatted_results: form_results, rule_groups: rule_groups }) }
    
    context 'parse creates proper generic hash' do
      let(:format) { Pagespeedonline::FormatString.new({ format: "none" }) }
      
      it 'should set results to have the formatted hash results' do
        ps.instance_variable_set(:@data, [data])
        ps.instance_variable_set(:@urls, ['http://www.foo.com'])
        ps.parse
        expect(ps.results[0].key?("url")).to eq(true)
        expect(ps.results[0].key?("score")).to eq(true)
        expect(ps.results[0].key?("results")).to eq(true)
      end
    end
    
    context 'parse replaces constants in the format string per rule' do
      let(:arginfo) { Pagespeedonline::FormatString::Arg.new({ key: "NUM_TIMES", value: "3" }) }
      let(:info) { { format: "Foo occurs {{NUM_TIMES}}. Learn more", args: [arginfo] } }
      let(:format) { Pagespeedonline::FormatString.new(info) }

      it 'should replace variable and remove learn more' do
        ps.instance_variable_set(:@data, [data])
        ps.instance_variable_set(:@urls, ['http://www.foo.com'])
        ps.parse
        
        expect(ps.results[0]["results"]["AvoidLandingPageRedirects"]["summary"]).to eq("Foo occurs 3.")
      end
    end

  end  

end
