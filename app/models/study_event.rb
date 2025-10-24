class StudyEvent < ApplicationRecord
  include ActsAsTaggableOn::Taggable

  belongs_to :user
  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  acts_as_taggable_on :subjects

  def duration_in_seconds
    return 0 unless start_time && end_time
    end_time - start_time
  end

  def duration_in_minutes
    (duration_in_seconds / 60.0).round(2)
  end

  def duration_in_hours
    (duration_in_seconds / 3600.0).round(2)
  end

  def formatted_duration
    return "0h 0m" unless start_time && end_time

    seconds = duration_in_seconds
    hours = (seconds / 3600).to_i
    minutes = ((seconds % 3600) / 60).to_i

    "#{hours}h #{minutes}m"
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end
end
