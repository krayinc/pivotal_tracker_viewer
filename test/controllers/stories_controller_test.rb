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
    assert_select "h1", I18n.t("stories.index.title")
    assert_select "form.filter-card"
    assert_select "turbo-frame#stories_list" do
      assert_select ".story-card", minimum: 1
    end
    assert_select "a", text: "ID/PWでログインできる"
    assert_select "turbo-frame#story_detail" do
      assert_select "div.detail-placeholder p", text: I18n.t("stories.index.placeholder_detail")
    end
  end

  test "show displays story details" do
    story = Story.find_by!(tracker_id: 61531244)

    get story_url(story)
    assert_response :success
    assert_select "turbo-frame#story_detail" do
      assert_select "h1", story.title
      assert_select "div.markdown"
    end
  end

  test "filters stories by keyword and state" do
    get stories_url(filter: { q: "ログインできる", current_state: "accepted" })

    assert_response :success
    assert_select ".story-card", 1
    assert_select "a", text: "ID/PWでログインできる"
  end

  test "filters stories by label and owner" do
    get stories_url(filter: { labels: ["backend"], owners: ["Edward"] })

    assert_response :success
    assert_select ".story-card", 1
    assert_select "a", text: "データの展開を unzip で行うようにする"
  end

  test "filters stories by multiple labels using AND" do
    base_position = Story.maximum(:import_position).to_i + 1

    matching_story = Story.create!(
      tracker_id: 9_100_001,
      title: "複数ラベルのストーリー",
      story_type: "feature",
      import_position: base_position
    )
    %w[label_a label_b].each { |name| matching_story.story_labels.create!(name: name) }

    non_matching_story = Story.create!(
      tracker_id: 9_100_002,
      title: "単一ラベルのストーリー",
      story_type: "feature",
      import_position: base_position + 1
    )
    non_matching_story.story_labels.create!(name: "label_a")

    get stories_url(filter: { labels: %w[label_a label_b] })

    assert_response :success
    assert_select ".story-card", 1
    assert_select "a", text: matching_story.title
    assert_select "a", text: non_matching_story.title, count: 0
  end

  test "filters by created date range" do
    get stories_url(filter: { created_from: "2017-01-01", created_to: "2018-01-01" })

    assert_response :success
    assert_select ".story-card", 1
    assert_select "a", text: "アプリケーションをメンテナンス中にできる"
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
    assert_select "turbo-frame#stories_list"
    assert_select "a", text: "ID/PWでログインできる"
  end

  test "filtered pagination keeps query params" do
    per_page = StoriesController::PER_PAGE
    base_position = Story.maximum(:import_position) || 0

    (per_page * 2).times do |i|
      story = Story.create!(
        tracker_id: 8_000_000 + i,
        title: "backend story #{i}",
        story_type: "feature",
        import_position: base_position + i + 10
      )
      story.story_labels.create!(name: "backend")
    end

    get stories_url(filter: { labels: ["backend"] }, page: 2), headers: { "Turbo-Frame" => "stories_list" }

    assert_response :success
    assert_includes response.body, "backend story #{per_page}"
    assert_includes response.body, "filter%5Blabels%5D%5B%5D=backend"
  end

  test "show responds with detail frame for turbo requests" do
    story = Story.find_by!(tracker_id: 61531244)

    get story_url(story), headers: { "Turbo-Frame" => "story_detail" }
    assert_response :success
    assert_includes response.body, '<turbo-frame id="story_detail"'
    assert_includes response.body, story.title
    refute_includes response.body, "<html"
  end

  test "root redirects to stories index" do
    get root_url
    assert_response :success
    assert_select "h1", I18n.t("stories.index.title")
  end
end
