require "uri"

module StoriesHelper
  PIVOTAL_TRACKER_PATH_REGEX = %r{/(?:story|stories)/show/(\d+)}.freeze

  def local_story_url(story)
    tracker_id = story&.tracker_id.presence || tracker_id_from_url(story&.url)
    return story.url unless tracker_id

    story_tracker_url(tracker_id)
  end

  def tracker_id_from_url(url)
    return if url.blank?

    URI.parse(url).path[PIVOTAL_TRACKER_PATH_REGEX, 1]
  rescue URI::InvalidURIError
    nil
  end
end
