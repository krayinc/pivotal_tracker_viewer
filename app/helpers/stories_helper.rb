require "uri"

module StoriesHelper
  PIVOTAL_TRACKER_PATH_REGEX = %r{/(?:story|stories)/show/(\d+)}.freeze
  PIVOTAL_TRACKER_URL_REGEX = %r{https?://(?:www\.)?pivotaltracker\.com/(?:story|stories)/show/(\d+)}i.freeze

  def local_story_url(story)
    tracker_id = story&.tracker_id.presence || tracker_id_from_url(story&.url)
    return unless tracker_id

    return story_tracker_url(tracker_id) if Story.exists?(tracker_id: tracker_id)

    nil
  end

  def tracker_id_from_url(url)
    return if url.blank?

    URI.parse(url).path[PIVOTAL_TRACKER_PATH_REGEX, 1]
  rescue URI::InvalidURIError
    nil
  end

  def rewrite_pivotal_story_urls(text)
    return text if text.blank?

    text.to_s.gsub(PIVOTAL_TRACKER_URL_REGEX) do |match|
      tracker_id = Regexp.last_match(1)
      if Story.exists?(tracker_id: tracker_id)
        story_tracker_url(tracker_id)
      else
        deleted_story_reference(match, tracker_id)
      end
    end
  end

  def render_story_markdown(text)
    render_markdown(rewrite_pivotal_story_urls(text))
  end

  private

  def deleted_story_reference(original_url, tracker_id)
    message = I18n.t("stories.detail.deleted_story_reference", id: tracker_id)
    "#{message} (`#{original_url}`)"
  end
end
