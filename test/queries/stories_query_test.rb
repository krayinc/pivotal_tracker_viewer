# frozen_string_literal: true

require "test_helper"

class StoriesQueryTest < ActiveSupport::TestCase
  def setup
    Imports::StoriesXlsxImporter.new(Rails.root.join("test/fixtures/files/stories_sample.xlsx")).call
  end

  def query(params = {})
    StoriesQuery.new(Story.all, params).call
  end

  test "no filters returns all stories" do
    assert_equal Story.count, query.count
  end

  test "filters by keyword" do
    result = query(q: "ログインできる")
    assert_equal [ 61531244 ], result.pluck(:tracker_id)
  end

  test "filters by label" do
    result = query(labels: [ "backend" ])
    assert_equal [ 185533815 ], result.pluck(:tracker_id)
  end

  test "filters by owner" do
    result = query(owners: [ "Edward" ])
    assert_equal [ 185533815 ], result.pluck(:tracker_id)
  end

  test "filters by story type" do
    result = query(story_type: "feature")
    assert_equal %w[feature feature feature], result.pluck(:story_type)
  end

  test "filters by state" do
    result = query(current_state: "accepted")
    assert_equal Story.count, result.count
  end

  test "filters by created date range" do
    result = query(created_from: "2017-01-01", created_to: "2018-01-01")
    assert_equal [ 150290098 ], result.pluck(:tracker_id)
  end

  test "filters by accepted date range" do
    result = query(accepted_from: "2023-01-01", accepted_to: "2023-12-31")
    assert_equal [ 185533815 ], result.pluck(:tracker_id)
  end

  test "combined filters intersect" do
    params = {
      q: "ログイン",
      story_type: "feature",
      current_state: "accepted",
      owners: [ "Charlie" ],
      created_to: "2014-01-01"
    }

    result = query(params)
    assert_equal [ 61531244 ], result.pluck(:tracker_id)
  end

  test "invalid date values are ignored" do
    result = query(created_from: "invalid")
    assert_equal Story.count, result.count
  end

  test "distinct results when joining labels" do
    result = query(labels: [ "backend", "保守" ])
    assert_equal [ 185533815 ], result.pluck(:tracker_id)
  end
end
