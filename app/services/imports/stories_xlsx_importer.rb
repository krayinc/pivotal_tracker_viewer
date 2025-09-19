# frozen_string_literal: true

require "pathname"

module Imports
  class StoriesXlsxImporter
    Error = Class.new(StandardError)
    Result = Struct.new(:epics_count, :stories_count, keyword_init: true)

    ID_COL = 0
    TITLE_COL = 1
    LABELS_COL = 2
    TYPE_COL = 6
    ESTIMATE_COL = 7
    PRIORITY_COL = 8
    CURRENT_STATE_COL = 9
    CREATED_AT_COL = 10
    ACCEPTED_AT_COL = 11
    REQUESTED_BY_COL = 13
    DESCRIPTION_COL = 14
    URL_COL = 15

    OWNED_BY_RANGE = (16..18).freeze
    BLOCKER_RANGE = (19..50).freeze
    COMMENTS_RANGE = (51..79).freeze
    TASKS_RANGE = (80..105).freeze
    PULL_REQUEST_RANGE = (106..113).freeze
    BRANCH_RANGE = (114..117).freeze

    COMMENT_FOOTER_REGEX = /(.*?)(?:\s*\(([^()]+?) - ([^)]+)\)\s*)?\z/m.freeze

    def initialize(file_path = default_file_path)
      @file_path = Pathname(file_path)
    end

    def call
      raise Error, "stories.xlsx not found at #{@file_path}" unless @file_path.exist?

      spreadsheet = Roo::Spreadsheet.open(@file_path.to_s)
      sheet = spreadsheet.sheet(0)

      ActiveRecord::Base.transaction do
        purge_existing_records

        epics_index = import_epics(sheet)
        stories_count = import_stories(sheet, epics_index)

        Result.new(epics_count: epics_index[:by_tracker_id].size, stories_count: stories_count)
      end
    end

    private

    def default_file_path
      Rails.root.join("stories.xlsx")
    end

    def purge_existing_records
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

    def import_epics(sheet)
      by_label = {}
      by_tracker_id = {}

      each_data_row(sheet) do |row|
        next unless row[TYPE_COL].to_s.strip.casecmp?("epic")

        epic = Epic.create!(
          tracker_id: integer_value(row[ID_COL]),
          name: string_value(row[TITLE_COL]) || "",
          label: string_value(row[LABELS_COL]),
          state: string_value(row[CURRENT_STATE_COL]),
          url: string_value(row[URL_COL])
        )

        if (normalized_label = normalize_label(epic.label))
          by_label[normalized_label] = epic
        end

        by_tracker_id[epic.tracker_id] = epic
      end

      { by_label: by_label, by_tracker_id: by_tracker_id }
    end

    def import_stories(sheet, epics_index)
      import_position = 0
      stories_count = 0

      each_data_row(sheet) do |row|
        next if row[TYPE_COL].to_s.strip.casecmp?("epic")
        next if row[ID_COL].blank? && row[TITLE_COL].blank?

        labels = parse_labels(row[LABELS_COL])
        epic = labels.lazy.map { |label| epics_index[:by_label][normalize_label(label)] }.compact.first

        story = Story.create!(
          tracker_id: integer_value(row[ID_COL]),
          title: string_value(row[TITLE_COL]) || "(no title)",
          story_type: string_value(row[TYPE_COL]),
          estimate: integer_value(row[ESTIMATE_COL]),
          priority: string_value(row[PRIORITY_COL]),
          current_state: string_value(row[CURRENT_STATE_COL]),
          story_created_at: time_value(row[CREATED_AT_COL]),
          accepted_at: time_value(row[ACCEPTED_AT_COL]),
          requested_by: string_value(row[REQUESTED_BY_COL]),
          description: row[DESCRIPTION_COL].presence,
          url: string_value(row[URL_COL]),
          import_position: import_position,
          epic: epic
        )

        import_labels!(story, labels)
        import_owned_bys!(story, row)
        import_comments!(story, row)
        import_tasks!(story, row)
        import_blockers!(story, row)
        import_pull_requests!(story, row)
        import_branches!(story, row)

        import_position += 1
        stories_count += 1
      end

      stories_count
    end

    def each_data_row(sheet)
      return enum_for(:each_data_row, sheet) unless block_given?

      first_data_row = 2
      last_row = sheet.last_row.to_i
      return if last_row < first_data_row

      (first_data_row..last_row).each do |row_index|
        yield sheet.row(row_index)
      end
    end

    def import_labels!(story, labels)
      labels.each do |label_name|
        story.story_labels.create!(name: label_name)
      end
    end

    def import_owned_bys!(story, row)
      row[OWNED_BY_RANGE].to_a.each_with_index do |value, index|
        name = string_value(value)
        next if name.blank?

        story.story_ownerships.create!(owner_name: name, position: index)
      end
    end

    def import_comments!(story, row)
      row[COMMENTS_RANGE].to_a.each_with_index do |raw_comment, index|
        next if raw_comment.blank?

        parsed = parse_comment(raw_comment)
        next if parsed[:body].blank?

        story.story_comments.create!(
          body: parsed[:body],
          author_name: parsed[:author_name],
          commented_at: parsed[:commented_at],
          position: index
        )
      end
    end

    def import_tasks!(story, row)
      row[TASKS_RANGE].to_a.each_slice(2).with_index do |(description, status), index|
        desc = string_value(description)
        next if desc.blank?

        story.story_tasks.create!(
          description: desc,
          status: string_value(status),
          position: index
        )
      end
    end

    def import_blockers!(story, row)
      row[BLOCKER_RANGE].to_a.each_slice(2) do |description, status|
        desc = string_value(description)
        next if desc.blank?

        story.story_blockers.create!(
          description: desc,
          status: string_value(status)
        )
      end
    end

    def import_pull_requests!(story, row)
      row[PULL_REQUEST_RANGE].to_a.each do |value|
        url = string_value(value)
        next if url.blank?

        story.story_pull_requests.create!(url: url)
      end
    end

    def import_branches!(story, row)
      row[BRANCH_RANGE].to_a.each do |value|
        name = string_value(value)
        next if name.blank?

        story.story_branches.create!(name: name)
      end
    end

    def parse_labels(value)
      return [] if value.blank?

      value.to_s.split(",").map { |part| string_value(part) }.compact_blank.uniq
    end

    def parse_comment(raw_comment)
      match = COMMENT_FOOTER_REGEX.match(raw_comment.to_s)
      body = match[1]&.rstrip || ""
      author = match[2]&.strip
      commented_at = parse_comment_timestamp(match[3]) if match[3]

      { body: body, author_name: author, commented_at: commented_at }
    end

    def parse_comment_timestamp(value)
      return if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def integer_value(value)
      return nil if value.blank?

      numeric = value.to_s.strip

      case value
      when Integer
        value
      when Float
        value.to_i
      else
        Integer(numeric)
      end
    rescue ArgumentError, TypeError
      begin
        Float(numeric).to_i
      rescue ArgumentError, TypeError
        nil
      end
    end

    def time_value(value)
      return if value.blank?

      if value.respond_to?(:to_time)
        value.to_time.in_time_zone
      else
        Time.zone.parse(value.to_s)
      end
    rescue ArgumentError
      nil
    end

    def string_value(value)
      return if value.blank?

      value.to_s.strip.presence
    end

    def normalize_label(label)
      string_value(label)&.downcase
    end
  end
end
