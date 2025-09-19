# frozen_string_literal: true

class StoriesQuery
  def initialize(scope = Story.all, params = {})
    @scope = scope
    @params = params || {}
    @join_applied = false
  end

  def call
    @join_applied = false

    result = scope
    result = filter_search(result)
    result = filter_labels(result)
    result = filter_story_type(result)
    result = filter_state(result)
    result = filter_priority(result)
    result = filter_owner(result)
    result = filter_created_range(result)
    result = filter_accepted_range(result)

    result = result.distinct if @join_applied
    result
  end

  private

  attr_reader :scope, :params

  def filter_search(relation)
    term = string_param(:q)
    return relation if term.blank?

    pattern = "%#{sanitize_sql_like(term.downcase)}%"
    relation.where("LOWER(stories.title) LIKE :q OR LOWER(stories.description) LIKE :q", q: pattern)
  end

  def filter_labels(relation)
    labels = array_param(:labels)
    return relation if labels.empty?

    @join_applied = true
    relation.left_joins(:story_labels).where(story_labels: { name: labels })
  end

  def filter_story_type(relation)
    value = string_param(:story_type)
    return relation if value.blank?

    relation.where(story_type: value)
  end

  def filter_state(relation)
    value = string_param(:current_state)
    return relation if value.blank?

    relation.where(current_state: value)
  end

  def filter_priority(relation)
    value = string_param(:priority)
    return relation if value.blank?

    relation.where(priority: value)
  end

  def filter_owner(relation)
    owners = array_param(:owners)
    return relation if owners.empty?

    @join_applied = true
    relation.left_joins(:story_ownerships).where(story_ownerships: { owner_name: owners })
  end

  def filter_created_range(relation)
    from = parse_date(:created_from)&.beginning_of_day
    to = parse_date(:created_to)&.end_of_day

    relation = relation.where(Story.arel_table[:story_created_at].gteq(from)) if from
    relation = relation.where(Story.arel_table[:story_created_at].lteq(to)) if to
    relation
  end

  def filter_accepted_range(relation)
    from = parse_date(:accepted_from)&.beginning_of_day
    to = parse_date(:accepted_to)&.end_of_day

    relation = relation.where(Story.arel_table[:accepted_at].gteq(from)) if from
    relation = relation.where(Story.arel_table[:accepted_at].lteq(to)) if to
    relation
  end

  def parse_date(key)
    value = string_param(key)
    return if value.blank?

    Time.zone.parse(value)
  rescue ArgumentError
    nil
  end

  def string_param(key)
    raw = params[key] || params[key.to_s]
    return if raw.blank?

    raw.to_s.strip.presence
  end

  def array_param(key)
    raw = params[key] || params[key.to_s]
    list = Array(raw).map { |v| v.is_a?(String) ? v.strip : v }.reject(&:blank?)
    list
  end

  def sanitize_sql_like(value)
    ActiveRecord::Base.sanitize_sql_like(value)
  end
end
