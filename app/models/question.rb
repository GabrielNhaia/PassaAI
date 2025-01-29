class Question < ApplicationRecord
  belongs_to :user
  has_many :exam_questions
  has_many :exams, through: :exam_questions

  validates :content, :answer_a, :answer_b, :answer_c, :answer_d, :answer_e, 
            :correct_answer, :category, :subject, presence: true
  
  enum category: {
    matematica: 'matematica',
    natureza: 'natureza',
    linguagens: 'linguagens',
    humanas: 'humanas',
    redacao: 'redacao'
  }
end
