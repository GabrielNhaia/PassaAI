class ExamQuestion < ApplicationRecord
  belongs_to :exam
  belongs_to :question

  before_save :check_answer

  def check_answer
    self.correct = (selected_answer == question.correct_answer)
  end
end