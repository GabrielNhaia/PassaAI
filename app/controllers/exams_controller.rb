class ExamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exam, only: [:start, :answer, :result, :writing, :submit_writing]
  before_action :set_exam_question, only: [:answer]

  def index
    @exam_categories = build_exam_categories
  end

  def create
    @exam = current_user.exams.build(exam_params)

    if @exam.save
      handle_exam_creation
    else
      redirect_to simulados_path, alert: 'Erro ao criar simulado'
    end
  end

  def start
    initialize_exam_session
    @current_question = find_next_unanswered_question
  end

  def answer
    if process_exam_answer
      handle_answer_success
    else
      redirect_to start_exam_path(@exam), alert: 'Erro ao salvar resposta'
    end
  end

  def result
    @exam_statistics = calculate_exam_statistics
  end

  def completed
    @completed_exams = current_user.exams.completed.includes(:exam_questions)
  end

  def writing
    @themes = essay_themes
  end

  def submit_writing
    if @exam.update(writing_params)
      process_essay_correction
    else
      redirect_to writing_exam_path(@exam), alert: 'Erro ao salvar redação'
    end
  end

  private

  def set_exam
    @exam = current_user.exams.find(params[:id])
  end

  def set_exam_question
    @exam_question = @exam.exam_questions.find(params[:exam_question_id])
  end

  def build_exam_categories
    [
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

  def handle_exam_creation
    if @exam.redacao?
      redirect_to writing_exam_path(@exam)
    else
      @exam.generate_questions
      redirect_to start_exam_path(@exam)
    end
  end

  def initialize_exam_session
    return unless @exam.started_at.nil?

    @exam.update(started_at: Time.current)
  end

  def find_next_unanswered_question
    @exam.exam_questions.where(selected_answer: nil).first
  end

  def process_exam_answer
    return false unless @exam_question.update(answer_params)

    @exam_question.check_answer
    true
  end

  def handle_answer_success
    @next_question = find_next_unanswered_question

    if @next_question.present?
      redirect_to start_exam_path(@exam)
    else
      complete_exam
      redirect_to result_exam_path(@exam)
    end
  end

  def complete_exam
    @exam.update(
      status: :completed, 
      finished_at: Time.current
    )
  end

  def calculate_exam_statistics
    total_questions = @exam.exam_questions.count
    correct_answers = @exam.exam_questions.where(correct: true).count
    {
      total_questions: total_questions,
      correct_answers: correct_answers,
      incorrect_answers: total_questions - correct_answers,
      score: calculate_percentage_score(correct_answers, total_questions),
      duration: calculate_exam_duration
    }
  end

  def calculate_percentage_score(correct, total)
    return 0 if total.zero?

    (correct.to_f / total * 100).round(2)
  end

  def calculate_exam_duration
    return nil unless @exam.started_at && @exam.finished_at

    duration_in_seconds = @exam.finished_at - @exam.started_at
    Time.at(duration_in_seconds).utc.strftime("%H:%M:%S")
  end

  def essay_themes
    [
      "Os desafios da inteligência artificial na sociedade contemporânea",
      "Manipulação do comportamento do usuário pelo controle de dados na internet",
      "O impacto das mudanças climáticas e a urgência de ações sustentáveis no Brasil",
      "Saúde mental na era digital: O adoecimento da juventude e os caminhos para o bem-estar",
      "A educação financeira como ferramenta para a autonomia e o combate à desigualdade social",
      "A desinformação e as 'fake news' como ameaças à democracia e à cidadania no Brasil",
      "O crescimento do trabalho informal e a precarização das relações trabalhistas no país",
      "A inclusão de pessoas com deficiência no mercado de trabalho e na sociedade",
      "A segurança alimentar e o combate à fome no Brasil: Estratégias para garantir o acesso a alimentos de qualidade",
      "O papel das redes sociais na formação da identidade e no comportamento dos jovens",
      "A importância da valorização da cultura popular brasileira e do patrimônio imaterial",
      "Os desafios da mobilidade urbana nas grandes cidades brasileiras: Soluções sustentáveis para o transporte público e privado",
      "A importância da representatividade e do combate ao preconceito nas diversas esferas sociais",
      "O uso consciente da tecnologia na educação e os novos modelos de ensino-aprendizagem",
      "O desmatamento na Amazônia e a urgência da conservação ambiental no contexto brasileiro",
      "A invisibilidade de populações marginalizadas e o acesso a direitos básicos no Brasil"
    ]
  end

  def process_essay_correction
    correction_result = perform_essay_correction

    if correction_result[:error].present?
      redirect_to writing_exam_path(@exam), alert: correction_result[:error]
      return
    end

    update_essay_scores(correction_result)
    redirect_to result_exam_path(@exam)
  end

  def perform_essay_correction
    correction_service = EssayCorrectionService.new(@exam.essay_text, @exam.selected_theme)
    correction_service.correct
  end

  def update_essay_scores(correction_result)
    essay_attributes = build_essay_attributes(correction_result)
    @exam.update!(essay_attributes)
  end

  def build_essay_attributes(correction_result)
    {
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
      comp1_justification: correction_result["comp1"]["justification"],
      comp2_justification: correction_result["comp2"]["justification"],
      comp3_justification: correction_result["comp3"]["justification"],
      comp4_justification: correction_result["comp4"]["justification"],
      comp5_justification: correction_result["comp5"]["justification"],
      essay_total_score: correction_result["total_score"],
      essay_general_feedback: correction_result["general_feedback"],
      status: :completed,
      finished_at: Time.current
    }
  end

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