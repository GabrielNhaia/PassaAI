class ExamsController < ApplicationController
  before_action :authenticate_user!

  def index
    @exam_categories = [
      {
        name: "Matemática e suas Tecnologias",
        questions: 45,
        subjects: ["Matemática Básica", "Geometria", "Operações Básicas", "Potenciação e Radiciação", "Conversões de Unidades"],
        icon: "calculator"
      },
      {
        name: "Ciências da Natureza",
        questions: 45,
        subjects: ["Biologia", "Química", "Física"],
        icon: "clipboard-data-fill"
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
      if @exam.redacao?
        redirect_to writing_exam_path(@exam)
      else
        @exam.generate_questions
        redirect_to start_exam_path(@exam)
      end
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

  def writing
    @exam = current_user.exams.find(params[:id])
    @themes = [
      "Novas Tecnologias",
      "Racismo e Discriminação Social",
      "Desigualdade Social no Brasil",
      "Preconceito Linguístico",
      "Violência Escolar"
    ]
  end

  def submit_writing
    @exam = current_user.exams.find(params[:id])
    
    if @exam.update(writing_params)
      correction_service = EssayCorrectionService.new(@exam.essay_text, @exam.selected_theme)
      correction_result = correction_service.correct

      @exam.update(
        comp1_score: correction_result["comp1"]["score"],
        comp2_score: correction_result["comp2"]["score"],
        comp3_score: correction_result["comp3"]["score"],
        comp4_score: correction_result["comp4"]["score"],
        comp5_score: correction_result["comp5"]["score"],
        comp1_feedback: correction_result["comp1"]["feedback"],
        comp2_feedback: correction_result["comp2"]["feedback"],
        comp3_feedback: correction_result["comp3"]["feedback"],
        comp4_feedback: correction_result["comp4"]["feedback"],
        comp5_feedback: correction_result["comp5"]["feedback"],
        essay_total_score: correction_result["total_score"],
        essay_general_feedback: correction_result["general_feedback"],
        status: :completed,
        finished_at: Time.current
      )

      redirect_to result_exam_path(@exam)
    else
      redirect_to writing_exam_path(@exam), alert: 'Erro ao salvar redação'
    end
  end

  private

  def exam_params
    params.require(:exam).permit(:category)
  end

  def answer_params
    params.require(:exam_question).permit(:selected_answer)
  end

  def writing_params
    params.require(:exam).permit(:selected_theme, :essay_text)
  end
end