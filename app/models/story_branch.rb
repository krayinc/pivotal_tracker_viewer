class StoryBranch < ApplicationRecord
  belongs_to :story

  validates :name, presence: true
  validates :name, uniqueness: { scope: :story_id }
end
