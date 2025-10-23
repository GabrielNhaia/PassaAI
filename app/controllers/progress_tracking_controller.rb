class ProgressTrackingController < ApplicationController
  def index
    @exams = user_exams
    @statistics = exam_statistics
    @chart_data = build_chart_data
  end

  private

  def user_exams
    @user_exams ||= current_user.exams.order(created_at: :desc)
  end

  def exam_statistics
    {
      total_exams: user_exams.count,
      average_score: calculate_average_score,
      best_score: user_exams.maximum(:score),
      worst_score: user_exams.minimum(:score)
    }
  end

  def calculate_average_score
    score = user_exams.average(:score)
    score&.round(2)
  end

  def build_chart_data
    {
      labels: formatted_exam_dates,
      datasets: chart_datasets
    }
  end

  def formatted_exam_dates
    user_exams.pluck(:created_at).map { |date| date.strftime("%d/%m/%Y") }
  end

  def chart_datasets
    [{
      label: 'Pontuação',
      data: user_exams.pluck(:score),
      borderColor: 'rgba(75, 192, 192, 1)',
      backgroundColor: 'rgba(75, 192, 192, 0.2)',
      fill: false
    }]
  end
end
