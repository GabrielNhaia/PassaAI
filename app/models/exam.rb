class Exam < ApplicationRecord
  belongs_to :user
  has_many :exam_questions
  has_many :questions, through: :exam_questions

  enum status: { in_progress: 0, completed: 1 }
  enum category: {
    matematica: 0,
    natureza: 1,
    linguagens: 2,
    humanas: 3,
    linguasestrangeiras: 4,
    redacao: 5
  }

  def generate_questions
    question_count = 45

    case category
    when "linguagens"
      portuguese_questions = Question.where(category: "linguagens").sample(40)
      foreign_language_questions = Question.where(category: "linguasestrangeiras").sample(5)
      
      questions_to_add = portuguese_questions + foreign_language_questions
    else
      questions_to_add = Question.where(category: category).sample(question_count)
    end
    questions_to_add.each do |question|
      self.exam_questions.create(question: question)
    end
  end
end
