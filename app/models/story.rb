class Story < ApplicationRecord
  belongs_to :epic, optional: true

  has_many :story_ownerships, -> { order(:position, :id) }, dependent: :destroy
  has_many :story_labels, dependent: :destroy
  has_many :story_comments, -> { order(:position, :id) }, dependent: :destroy
  has_many :story_tasks, -> { order(:position, :id) }, dependent: :destroy
  has_many :story_blockers, -> { order(reported_at: :asc, id: :asc) }, dependent: :destroy
  has_many :story_pull_requests, -> { order(submitted_at: :desc, id: :asc) }, dependent: :destroy
  has_many :story_branches, -> { order(:name, :id) }, dependent: :destroy

  scope :ordered_by_import, -> { order(import_position: :asc, tracker_id: :asc) }

  validates :tracker_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :import_position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :estimate, numericality: { only_integer: true }, allow_nil: true
end
