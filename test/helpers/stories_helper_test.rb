# frozen_string_literal: true

require "test_helper"

class StoriesHelperTest < ActionView::TestCase
  include StoriesHelper

  test "local_story_url returns nil when tracker is missing" do
    story = Story.new(url: "https://www.pivotaltracker.com/story/show/999999")

    assert_nil local_story_url(story)
  end

  test "rewrite_pivotal_story_urls converts existing story links" do
    story = Story.create!(
      tracker_id: 9_900_001,
      title: "temporary",
      story_type: "feature",
      import_position: Story.maximum(:import_position).to_i + 1
    )

    text = "See https://www.pivotaltracker.com/story/show/#{story.tracker_id}"

    rewritten = rewrite_pivotal_story_urls(text)

    assert_includes rewritten, story_tracker_url(story.tracker_id)
  ensure
    story&.destroy
  end

  test "rewrite_pivotal_story_urls marks deleted stories" do
    text = "See https://www.pivotaltracker.com/story/show/999999"
    rewritten = rewrite_pivotal_story_urls(text)

    assert_includes rewritten, I18n.t("stories.detail.deleted_story_reference", id: "999999")
    assert_includes rewritten, "`https://www.pivotaltracker.com/story/show/999999`"
  end
end
