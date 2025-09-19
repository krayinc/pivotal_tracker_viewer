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
    assert_select "turbo-frame#stories_list" do
      assert_select "table tbody tr", minimum: 1
    end
    assert_select "a", text: "ID/PWでログインできる"
  end

  test "show displays story details" do
    story = Story.find_by!(tracker_id: 61531244)

    get story_url(story)
    assert_response :success
    assert_select "h1", story.title
    assert_select "section", text: /コメント/
  end

  test "infinite scroll fetches next page via turbo frame" do
    per_page = StoriesController::PER_PAGE
    base_position = Story.maximum(:import_position) || 0

    (per_page + 5).times do |i|
      Story.create!(
        tracker_id: 9_000_000 + i,
        title: "追加ストーリー#{i}",
        story_type: "chore",
        import_position: base_position + i + 1
      )
    end

    get stories_url(page: 2), headers: { "Turbo-Frame" => "stories_list" }
    assert_response :success
    assert_includes response.body, "追加ストーリー#{per_page}"
  end

  test "root redirects to stories index" do
    get root_url
    assert_response :success
    assert_select "h1", "ストーリー一覧"
  end
end
