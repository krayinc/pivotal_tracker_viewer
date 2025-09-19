# frozen_string_literal: true

require "test_helper"

class ImportsControllerTest < ActionDispatch::IntegrationTest
  SAMPLE_PATH = Rails.root.join("test/fixtures/files/stories_sample.xlsx")

  teardown do
    FileUtils.rm_f(Rails.root.join("stories.xlsx"))
  end

  test "new renders summary" do
    get new_import_url
    assert_response :success
    assert_select "h1", "データインポート"
    assert_select "form.upload-form"
  end

  test "create imports uploaded file" do
    Story.delete_all
    Epic.delete_all

    file = fixture_file_upload(SAMPLE_PATH, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

    post import_url, params: { import: { file: file } }

    assert_redirected_to new_import_url
    follow_redirect!

    assert_equal 3, Story.count
    assert_equal 1, Epic.count
    assert_match "インポートが完了", flash[:notice]
  end

  test "create without file shows error" do
    post import_url, params: { import: { file: nil } }, headers: { "HTTP_ACCEPT" => "text/vnd.turbo-stream.html" }

    assert_response :unprocessable_content
    assert_includes @response.body, "インポートするファイルを選択してください"
  end

  test "destroy removes data" do
    Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call

    delete import_url

    assert_redirected_to new_import_url
    follow_redirect!

    assert_equal 0, Story.count
    assert_equal 0, Epic.count
    assert_match "削除", flash[:notice]
  end
end
