class StoryTask < ApplicationRecord
  belongs_to :story

  validates :description, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
