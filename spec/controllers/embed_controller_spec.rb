require 'spec_helper'

describe EmbedController do

  let(:topic) { Fabricate(:topic) }
  let(:host) { "http://discourse.org" }

  pending "is 404 without a topic_id" do
    SiteSetting.stubs(:embeddable_host).returns(host)
    get :best
    response.code.should == "404"
  end

  it "raises an error with a missing host" do
    SiteSetting.stubs(:embeddable_host).returns('')
    get :best, topic_id: topic.id
    response.should_not be_success
  end

  it "succeeds with a valid host" do
    SiteSetting.stubs(:embeddable_host).returns(host)
    get :best, topic_id: topic.id
    response.should be_success
    response.headers['X-Frame-Options'].should == "ALLOWALL"
  end

end
