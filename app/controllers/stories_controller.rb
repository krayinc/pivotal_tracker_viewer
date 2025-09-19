class StoriesController < ApplicationController
  PER_PAGE = 50

  def index
    @page = params.fetch(:page, 1).to_i
    @page = 1 if @page < 1

    stories_scope = Story.ordered_by_import.includes(:epic)
    offset = (@page - 1) * PER_PAGE
    @stories = stories_scope.offset(offset).limit(PER_PAGE)
    @next_page = @page + 1 if stories_scope.offset(offset + PER_PAGE).exists?

    if turbo_frame_request?
      render partial: "stories/list", locals: { stories: @stories, next_page: @next_page }, layout: false
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
end
