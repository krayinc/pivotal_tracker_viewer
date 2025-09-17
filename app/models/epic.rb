class Epic < ApplicationRecord
  has_many :stories, dependent: :nullify

  validates :tracker_id, presence: true, uniqueness: true
  validates :name, presence: true
end
