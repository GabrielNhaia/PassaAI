class StudyEvent < ApplicationRecord
  include ActsAsTaggableOn::Taggable

  belongs_to :user
  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  
  acts_as_taggable_on :subjects
end
