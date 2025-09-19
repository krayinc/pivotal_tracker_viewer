class StoriesController < ApplicationController
  PER_PAGE = 50

  def index
    @filter_params = filtered_params
    @page = params.fetch(:page, 1).to_i
    @page = 1 if @page < 1

    base_scope = Story.ordered_by_import
    filtered_scope = StoriesQuery.new(base_scope, @filter_params).call

    offset = (@page - 1) * PER_PAGE
    @stories = filtered_scope.includes(:epic).offset(offset).limit(PER_PAGE)
    @next_page = @page + 1 if filtered_scope.offset(offset + PER_PAGE).exists?

    prepare_filter_options

    if turbo_frame_request?
      render partial: "stories/list", locals: { stories: @stories, next_page: @next_page, filter_params: @filter_params }, layout: false
    end
  end

  def show
    @story = Story
      .includes(
        :epic,
        :story_labels,
        :story_ownerships,
        :story_tasks,
        :story_blockers,
        :story_pull_requests,
        :story_branches,
        :story_comments
      )
      .find(params[:id])

    if turbo_frame_request?
      render partial: "stories/detail_frame", locals: { story: @story, standalone: false }, layout: false
    end
  end

  private

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
end
