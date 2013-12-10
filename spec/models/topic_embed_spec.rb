require 'spec_helper'

describe TopicEmbed do

  it { should belong_to :topic }
  it { should belong_to :post }
  it { should validate_presence_of :embed_code }
  it { should validate_presence_of :content_sha1 }


  context '.import' do

    let(:user) { Fabricate(:user) }
    let(:title) { "How to turn a fish from good to evil in 30 seconds" }
    let(:url) { 'http://eviltrout.com/123' }
    let(:contents) { "hello world new post" }

    it "returns nil when the URL is malformed" do
      TopicEmbed.import(user, "invalid url", title, contents).should be_nil
      TopicEmbed.count.should == 0
    end

    context 'creation of a post' do
      let!(:post) { TopicEmbed.import(user, url, title, contents) }

      it "works as expected with a new URL" do
        post.should be_present
        TopicEmbed.where(topic_id: post.topic_id).should be_present
      end

      it "Supports updating the post" do
        post = TopicEmbed.import(user, url, title, "muhahaha new contents!")
        post.cooked.should =~ /new contents/
      end

    end

  end

end
