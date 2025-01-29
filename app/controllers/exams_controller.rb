class ExamsController < ApplicationController
  before_action :authenticate_user!

  def index
    @exam_categories = [
      {
        name: "Matemática e suas Tecnologias",
        questions: 45,
        icon: "calculator"
      },
      {
        name: "Ciências da Natureza",
        questions: 45,
        subjects: ["Biologia", "Química", "Física"],
        icon: "flask"
      },
      {
        name: "Linguagens e suas Tecnologias",
        questions: 45,
        subjects: ["Português (40 questões)", "Língua Estrangeira (5 questões)"],
        icon: "book"
      },
      {
        name: "Ciências Humanas",
        questions: 45,
        subjects: ["História", "Geografia", "Filosofia", "Sociologia", "Artes"],
        icon: "globe"
      },
      {
        name: "Redação",
        icon: "pencil"
      }
    ]
  end

  def create
    @exam = current_user.exams.build(exam_params)
    
    if @exam.save
      @exam.generate_questions
      redirect_to start_exam_path(@exam)
    else
      redirect_to simulados_path, alert: 'Erro ao criar simulado'
    end
  end

  def start
    @exam = current_user.exams.find(params[:id])
    @exam.update(started_at: Time.current) if @exam.started_at.nil?
    @current_question = @exam.exam_questions.where(selected_answer: nil).first
  end

  def answer
    @exam = current_user.exams.find(params[:id])
    @exam_question = @exam.exam_questions.find(params[:exam_question_id])
    
    if @exam_question.update(answer_params)
      @exam_question.check_answer
      @next_question = @exam.exam_questions.where(selected_answer: nil).first
      
      if @next_question
        redirect_to start_exam_path(@exam)
      else
        @exam.update(status: :completed, finished_at: Time.current)
        redirect_to result_exam_path(@exam)
      end
    else
      redirect_to start_exam_path(@exam), alert: 'Erro ao salvar resposta'
    end
  end

  def result
    @exam = current_user.exams.find(params[:id])
    @total_questions = @exam.exam_questions.count
    @correct_answers = @exam.exam_questions.where(correct: true).count
    @score = (@correct_answers.to_f / @total_questions * 100).round(2)
  end

  def completed
    @completed_exams = current_user.exams.completed
  end

  private

  def exam_params
    params.require(:exam).permit(:category)
  end

  def answer_params
    params.require(:exam_question).permit(:selected_answer)
  end
end