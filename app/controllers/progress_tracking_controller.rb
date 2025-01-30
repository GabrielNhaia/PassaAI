class ProgressTrackingController < ApplicationController
  def index
    @total_exams = current_user.exams.count
    @average_score = current_user.exams.average(:score)
    @best_score = current_user.exams.maximum(:score)
    @worst_score = current_user.exams.minimum(:score)
    @exams = current_user.exams.order(created_at: :desc)
    @chart_data = {
      labels: @exams.pluck(:created_at).map { |date| date.strftime("%d/%m/%Y") },
      datasets: [{
        label: 'Pontuação',
        data: @exams.pluck(:score),
        borderColor: 'rgba(75, 192, 192, 1)',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        fill: false
      }]
    }
  end
end
