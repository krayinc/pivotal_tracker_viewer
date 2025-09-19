# frozen_string_literal: true

require "test_helper"

class StoriesControllerTest < ActionDispatch::IntegrationTest
  SAMPLE_PATH = Rails.root.join("test/fixtures/files/stories_sample.xlsx")

  setup do
    Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call
  end

  test "index loads and lists stories" do
    get stories_url
    assert_response :success
    assert_select "h1", "ストーリー一覧"
    assert_select "table tbody tr", minimum: 1
    assert_select "a", text: "ID/PWでログインできる"
  end

  test "show displays story details" do
    story = Story.find_by!(tracker_id: 61531244)

    get story_url(story)
    assert_response :success
    assert_select "h1", story.title
    assert_select "section", text: /コメント/
  end

  test "root redirects to stories index" do
    get root_url
    assert_response :success
    assert_select "h1", "ストーリー一覧"
  end
end
