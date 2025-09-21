# frozen_string_literal: true

require "application_system_test_case"

class StoriesFlowsTest < ApplicationSystemTestCase
  SAMPLE_PATH = Rails.root.join("test/fixtures/files/stories_sample.xlsx")

  setup do
    clear_data!
  end

  test "ユーザーがストーリーを絞り込み詳細を確認できる" do
    Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call

    visit stories_path

    assert_selector ".story-card", minimum: 1

    fill_in "キーワード", with: "ログイン"
    find("label.label-token", text: "初回設定").click
    click_button "絞り込む"

    assert_selector ".story-card", count: 1

    within "turbo-frame#story_detail" do
      assert_selector "div.detail-placeholder", text: I18n.t("stories.index.placeholder_detail")
    end

    click_link "ID/PWでログインできる"

    within "turbo-frame#story_detail" do
      assert_text "ID/PWでログインできる"
      assert_text "ログインして、ユーザー名が表示されるのを確認しました"
    end

    if page.has_selector?(".story-card__tags button", wait: 1)
      label_button = first(".story-card__tags button")
      label = label_button.text
      label_button.click
      checkbox = find("input[name='filter[labels][]'][value='#{label}']", visible: :all)
      assert checkbox.checked?
    end
  end

  test "stories.xlsx を UI からインポートできる" do
    visit new_import_path

    attach_file "import_file", SAMPLE_PATH
    click_button "インポート実行"

    assert_text "インポートが完了しました", wait: 5

    visit current_path

    within "turbo-frame#import_summary" do
      assert_selector ".summary-card", minimum: 1
      assert_text "3"
    end

    click_link I18n.t("common.back_to_stories")
    assert_current_path stories_path
    assert_selector ".story-card", minimum: 1
  end

  private

  def clear_data!
    StoryBranch.delete_all
    StoryPullRequest.delete_all
    StoryBlocker.delete_all
    StoryTask.delete_all
    StoryComment.delete_all
    StoryOwnership.delete_all
    StoryLabel.delete_all
    Story.delete_all
    Epic.delete_all
  end
end
