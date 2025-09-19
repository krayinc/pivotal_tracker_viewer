class EpicsController < ApplicationController
  def index
    @epics = Epic
      .left_joins(:stories)
      .select(
        "epics.*",
        "COUNT(stories.id) AS stories_count",
        "SUM(CASE WHEN stories.current_state = 'accepted' THEN 1 ELSE 0 END) AS accepted_count",
        "SUM(stories.estimate) AS total_points",
        "SUM(CASE WHEN stories.current_state = 'accepted' THEN stories.estimate ELSE 0 END) AS accepted_points"
      )
      .group("epics.id")
      .order(:name)
  end
end
