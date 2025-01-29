class Exam < ApplicationRecord
  belongs_to :user
  has_many :exam_questions
  has_many :questions, through: :exam_questions

  enum status: { in_progress: 0, completed: 1 }
  enum category: {
    matematica: 'matematica',
    natureza: 'natureza',
    linguagens: 'linguagens',
    humanas: 'humanas',
    redacao: 'redacao'
  }

  def generate_questions
    # Pega todas as questões que ainda não foram usadas neste usuário
    available_questions = Question.where(category: self.category)
                                .where.not(id: user.exam_questions.pluck(:question_id))
                                .distinct
                                .order("RANDOM()")
                                .limit(45)
    
    # Se não houver questões suficientes, reinicia usando todas as questões
    if available_questions.count < 45
      available_questions = Question.where(category: self.category)
                                  .distinct
                                  .order("RANDOM()")
                                  .limit(45)
    end
    
    available_questions.each do |question|
      exam_questions.create(question: question)
    end
  end
end
