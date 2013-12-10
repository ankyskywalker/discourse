require 'nokogiri'

class EmbedController < ApplicationController
  skip_before_filter :check_xhr
  skip_before_filter :preload_json
  before_filter :ensure_embeddable

  layout 'embed'

  def best

    embed_code = params[:embed_code]
    topic_embed = TopicEmbed.where(embed_code: params[:embed_code]).first

    if topic_embed
      @topic_view = TopicView.new(topic_embed.topic_id, current_user, {best: 5})
    else
      # TODO: Async, make sure referers match allowed site, show loading?
      # doc = Nokogiri::HTML(open(request.referer))
      # title_node = doc.css('title')
      # if title_node
      #   # Not current user, configurable
      #   topic = nil
      #   Topic.transaction do
      #     topic = TopicCreator.create(current_user, Guardian.new(current_user), title: title_node.text)
      #     TopicEmbed.create(topic: topic, embed_code: embed_code, url: request.referer)
      #   end

      #   @topic_view = TopicView.new(topic.id, current_user, {best: 5})
      # end
      render nothing: true
    end

    discourse_expires_in 1.minute
  end

  private

    def ensure_embeddable
      raise Discourse::InvalidAccess.new('embeddable host not set') if SiteSetting.embeddable_host.blank?
      response.headers['X-Frame-Options'] = "ALLOWALL"
    end


end
