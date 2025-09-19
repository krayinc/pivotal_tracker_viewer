# frozen_string_literal: true

require "test_helper"

class EpicsControllerTest < ActionDispatch::IntegrationTest
  SAMPLE_PATH = Rails.root.join("test/fixtures/files/stories_sample.xlsx")

  setup do
    Imports::StoriesXlsxImporter.new(SAMPLE_PATH).call
  end

  test "index renders epic summary and table" do
    get epics_url
    assert_response :success

    assert_select "h1", I18n.t("epics.index.title")
    assert_select ".epics-summary .summary-card", 3
    assert_select "table.epics-table tbody tr", Epic.count
  end

  test "epic link points to stories filter" do
    epic = Epic.where.not(label: nil).first

    get epics_url
    assert_select "a[href=?]", stories_path(filter: { labels: [epic.label] })
  end
end
