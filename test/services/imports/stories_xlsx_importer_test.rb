# frozen_string_literal: true

require "test_helper"

module Imports
  class StoriesXlsxImporterTest < ActiveSupport::TestCase
    SAMPLE_PATH = Rails.root.join("test/fixtures/files/stories_sample.xlsx")

    test "replaces existing data and reports counts" do
      preexisting_epic = Epic.create!(tracker_id: 999_999, name: "Legacy", label: "legacy")
      Story.create!(
        tracker_id: 888_888,
        title: "Stale Story",
        story_type: "feature",
        import_position: 0,
        epic: preexisting_epic
      )

      result = Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call

      assert_equal 1, result.epics_count
      assert_equal 3, result.stories_count

      assert_equal [ 5181486 ], Epic.pluck(:tracker_id)
      assert_not Story.exists?(tracker_id: 888_888)
      assert_equal [ 61531244, 150290098, 185533815 ], Story.order(:import_position).pluck(:tracker_id)
    end

    test "imports labels, owners, tasks, and comments" do
      Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call

      story = Story.find_by!(tracker_id: 61531244)

      assert_equal "feature", story.story_type
      assert_equal 3, story.estimate
      assert_equal "p3 - Low", story.priority
      assert_equal Date.new(2013, 11, 27), story.story_created_at&.to_date
      assert_equal Date.new(2013, 12, 16), story.accepted_at&.to_date

      assert_equal [ "初回設定" ], story.story_labels.order(:name).pluck(:name)
      assert_equal [ "Charlie" ], story.story_ownerships.order(:position).pluck(:owner_name)

      tasks = story.story_tasks.order(:position).pluck(:description, :status)
      assert_equal [
        [ "ログイン成功したらセッションに保存", "not completed" ],
        [ "deviseなどを使うほどでもないかもしれない", "not completed" ]
      ], tasks

      comments = story.story_comments.order(:position).map do |comment|
        {
          body: comment.body.strip,
          author: comment.author_name,
          date: comment.commented_at&.to_date
        }
      end

      assert_equal [
        { body: "@", author: "Alice", date: Date.new(2013, 12, 5) },
        {
          body: "ログインして、ユーザー名が表示されるのを確認しました。",
          author: "Alice",
          date: Date.new(2013, 12, 16)
        }
      ], comments
    end

    test "imports blockers, pull requests, and branches" do
      Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call

      blockers_story = Story.find_by!(tracker_id: 150290098)
      assert_equal [ [ "#150290063", "resolved" ] ], blockers_story.story_blockers.pluck(:description, :status)

      pr_story = Story.find_by!(tracker_id: 185533815)
      assert_equal [ "backend", "保守" ], pr_story.story_labels.order(:name).pluck(:name)
      assert_equal [ "https://github.com/krayinc/dummy-repo/pull/2544" ], pr_story.story_pull_requests.pluck(:url)
      assert_equal [ "extract-by-unzip-command" ], pr_story.story_branches.pluck(:name)
      assert_equal 5, pr_story.story_comments.count
    end
  end
end
