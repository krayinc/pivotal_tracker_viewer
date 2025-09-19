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

    @summary = build_summary(@epics)
  end

  private

  def build_summary(epics)
    epics.each_with_object({ stories: 0, accepted: 0, total_points: 0, accepted_points: 0 }) do |epic, acc|
      acc[:stories] += epic.stories_count.to_i
      acc[:accepted] += epic.accepted_count.to_i
      acc[:total_points] += epic.total_points.to_i
      acc[:accepted_points] += epic.accepted_points.to_i
    end
  end
end
