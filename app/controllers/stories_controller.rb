class StoriesController < ApplicationController
  PER_PAGE = 50

  def index
    @filter_params = filtered_params
    @page = params.fetch(:page, 1).to_i
    @page = 1 if @page < 1

    base_scope = Story.ordered_by_import
    filtered_scope = StoriesQuery.new(base_scope, @filter_params).call

    limit = @page * PER_PAGE
    @stories = filtered_scope.includes(:epic, :story_labels, :story_ownerships).limit(limit)
    @next_page = @page + 1 if filtered_scope.offset(limit).exists?

    prepare_filter_options
    @summary = build_summary

    if turbo_frame_request?
      render partial: "stories/list_frame", locals: { stories: @stories, next_page: @next_page, filter_params: @filter_params }, layout: false
    end
  end

  STORY_DETAIL_INCLUDES = [
    :epic,
    :story_labels,
    :story_ownerships,
    :story_tasks,
    :story_blockers,
    :story_pull_requests,
    :story_branches,
    :story_comments
  ].freeze

  def show
    @story = stories_with_details.find(params[:id])

    render_detail_frame if turbo_frame_request?
  end

  def show_by_tracker
    @story = stories_with_details.find_by!(tracker_id: params[:tracker_id])

    if turbo_frame_request?
      render_detail_frame
    else
      redirect_to story_path(@story)
    end
  end

  private
  def render_detail_frame
    render partial: "stories/detail_frame", locals: { story: @story, standalone: false }, layout: false
  end

  def filtered_params
    permitted = params.fetch(:filter, {}).permit(
      :q,
      :story_type,
      :current_state,
      :priority,
      :created_from,
      :created_to,
      :accepted_from,
      :accepted_to,
      labels: [],
      owners: []
    )

    permitted = permitted.to_h.deep_symbolize_keys
    permitted[:labels] = Array(permitted[:labels]).reject(&:blank?)
    permitted[:owners] = Array(permitted[:owners]).reject(&:blank?)
    permitted
  end

  def prepare_filter_options
    @available_story_types = Story.where.not(story_type: nil).distinct.order(:story_type).pluck(:story_type)
    @available_states = Story.where.not(current_state: nil).distinct.order(:current_state).pluck(:current_state)
    @available_priorities = Story.where.not(priority: nil).distinct.order(:priority).pluck(:priority)
    @available_labels = StoryLabel.where.not(name: nil).distinct.order(:name).pluck(:name)
    @available_owners = StoryOwnership.where.not(owner_name: nil).distinct.order(:owner_name).pluck(:owner_name)
  end

  def build_summary
    stories_scope = Story.all

    stories_count = stories_scope.count
    accepted_count = stories_scope.where(current_state: "accepted").count

    {
      stories_count: stories_count,
      labels_count: StoryLabel.distinct.count(:name),
      epics_count: Epic.count,
      accepted_count: accepted_count,
      accepted_ratio: stories_count.positive? ? ((accepted_count.to_f / stories_count) * 100).round : 0,
      owners_count: StoryOwnership.distinct.count(:owner_name),
      last_imported_at: stories_scope.maximum(:updated_at)
    }
  end

  def stories_with_details
    Story.includes(STORY_DETAIL_INCLUDES)
  end
end
