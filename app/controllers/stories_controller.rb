class StoriesController < ApplicationController
  def index
    @stories = Story.ordered_by_import.includes(:epic).limit(100)
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
  end
end
