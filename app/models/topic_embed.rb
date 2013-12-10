class TopicEmbed < ActiveRecord::Base
  belongs_to :topic
  belongs_to :post
  validates_presence_of :embed_code
  validates_presence_of :content_sha1

  # Import an article from a source (RSS/Atom/Other)
  def self.import(user, url, title, contents)
    return unless url =~ /^https?\:\/\//

    embed = TopicEmbed.where(embed_url: url).first
    content_sha1 = Digest::SHA1.hexdigest(contents)
    post = nil

    # If there is no embed, create a topic, post and the embed.
    if embed.blank?
      Topic.transaction do
        creator = PostCreator.new(user, title: title, raw: contents, cooked: contents, skip_validations: true)
        post = creator.create
        if post.present?
          TopicEmbed.create!(topic_id: post.topic_id,
                             embed_url: url,
                             embed_code: url,
                             content_sha1: content_sha1,
                             post_id: post.id)
        end
      end
    else
      post = embed.post
      # Update the topic if it changed
      if content_sha1 != embed.content_sha1
        revisor = PostRevisor.new(post)
        revisor.revise!(user, contents, skip_validations: true, bypass_rate_limiter: true)
      end
    end

    post
  end

end
