class StoryPullRequest < ApplicationRecord
  belongs_to :story

  validates :url, presence: true
end
