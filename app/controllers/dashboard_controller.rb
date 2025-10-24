class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def index
    @dashboard_data = build_dashboard_overview
    @recent_activity = fetch_recent_activity
    @study_streak = calculate_study_streak
    @achievements = fetch_user_achievements
  end

  def profile
    @profile_statistics = build_profile_statistics
    @performance_data = build_performance_data
    @recent_exams = fetch_recent_exams
    @study_goals = fetch_study_goals

    @total_simulados = @profile_statistics[:total_simulados]
    @media_por_materia = @performance_data[:media_por_materia] || []
    @evolucao_notas = @performance_data[:evolucao_notas] || []
    @historico_simulados = @recent_exams || []
  end

  private

  def set_user
    @user = current_user
  end

  def build_dashboard_overview
    {
      total_exams: calculate_total_exams,
      completed_exams: calculate_completed_exams,
      average_score: calculate_overall_average_score,
      best_score: calculate_best_score,
      study_hours: calculate_total_study_hours,
      current_streak: calculate_study_streak
    }
  end

  def fetch_recent_activity
    activities = []

    recent_exams = @user.exams.completed.order(created_at: :desc).limit(5)
    recent_exams.each do |exam|
      activities << {
        type: 'exam_completed',
        title: format_exam_title(exam),
        score: exam.score || exam.essay_total_score,
        date: exam.finished_at,
        icon: 'clipboard-check'
      }
    end

    recent_studies = @user.study_events.order(created_at: :desc).limit(3)
    recent_studies.each do |study|
      activities << {
        type: 'study_session',
        title: "Sessão de estudos - #{study.title}",
        duration: study.formatted_duration,
        date: study.created_at,
        icon: 'book-open'
      }
    end

    activities.sort_by { |activity| activity[:date] }.reverse.take(8)
  end

  def calculate_study_streak
    return 0 unless @user.study_events.exists?

    current_date = Date.current
    streak = 0

    loop do
      has_study = @user.study_events.where(
        created_at: current_date.beginning_of_day..current_date.end_of_day
      ).exists?

      break unless has_study

      streak += 1
      current_date -= 1.day

      break if streak > 365
    end

    streak
  end

  def fetch_user_achievements
    achievements = []

    if @user.exams.completed.count >= 1
      achievements << {
        title: "Primeiro Simulado",
        description: "Completou seu primeiro simulado",
        icon: "trophy",
        unlocked_at: @user.exams.completed.first.finished_at
      }
    end

    if @user.exams.where('score >= ?', 80).exists?
      achievements << {
        title: "Nota de Ouro",
        description: "Conseguiu nota acima de 80%",
        icon: "star",
        unlocked_at: @user.exams.where('score >= ?', 80).first.finished_at
      }
    end

    if calculate_study_streak >= 7
      achievements << {
        title: "Dedicação",
        description: "Estudou por 7 dias consecutivos",
        icon: "calendar-check",
        unlocked_at: 1.week.ago
      }
    end

    completed_categories = @user.exams.completed.pluck(:category).uniq
    if completed_categories.count >= 3
      achievements << {
        title: "Multidisciplinar",
        description: "Completou simulados em 3+ áreas",
        icon: "puzzle",
        unlocked_at: 2.weeks.ago
      }
    end

    achievements.sort_by { |a| a[:unlocked_at] }.reverse
  end

  def build_profile_statistics
    {
      total_simulados: calculate_total_exams,
      simulados_completos: calculate_completed_exams,
      media_geral: calculate_overall_average_score,
      melhor_nota: calculate_best_score,
      pior_nota: calculate_worst_score,
      tempo_total_estudos: calculate_total_study_hours,
      dias_estudando: calculate_study_days,
      sequencia_atual: calculate_study_streak
    }
  end

  def build_performance_data
    {
      media_por_materia: safe_media_por_materia,
      evolucao_notas: safe_evolucao_notas,
      distribuicao_categorias: calculate_category_distribution,
      progresso_mensal: calculate_monthly_progress
    }
  end

  def fetch_recent_exams
    @user.exams
         .includes(:questions)
         .order(created_at: :desc)
         .limit(10)
         .map do |exam|
      {
        id: exam.id,
        category: format_category_name(exam.category),
        score: exam.score || exam.essay_total_score || 0,
        questions_count: exam.exam_questions&.count || 0,
        duration: calculate_exam_duration(exam),
        completed_at: exam.finished_at,
        status: exam.status,
        created_at: exam.created_at
      }
    end
  end

  def fetch_study_goals
    current_month = Date.current.beginning_of_month..Date.current.end_of_month

    {
      monthly_exams: {
        current: @user.exams.where(created_at: current_month).count,
        target: 10,
        percentage: [@user.exams.where(created_at: current_month).count * 10, 100].min
      },
      study_hours: {
        current: calculate_monthly_study_hours,
        target: 40,
        percentage: [(calculate_monthly_study_hours * 2.5).to_i, 100].min
      },
      average_score: {
        current: calculate_monthly_average_score,
        target: 75,
        percentage: [(calculate_monthly_average_score * 100 / 75).to_i, 100].min
      }
    }
  end

  def calculate_total_exams
    @user.exams.count
  end

  def calculate_completed_exams
    @user.exams.completed.count
  end

  def calculate_overall_average_score
    avg = @user.exams.where.not(score: nil).average(:score)
    essay_avg = @user.exams.where.not(essay_total_score: nil).average(:essay_total_score)

    scores = [avg, essay_avg].compact
    return 0 if scores.empty?

    (scores.sum / scores.count).round(1)
  end

  def calculate_best_score
    regular_best = @user.exams.maximum(:score) || 0
    essay_best = @user.exams.maximum(:essay_total_score) || 0
    [regular_best, essay_best].max
  end

  def calculate_worst_score
    regular_worst = @user.exams.where.not(score: nil).minimum(:score) || 0
    essay_worst = @user.exams.where.not(essay_total_score: nil).minimum(:essay_total_score) || 0

    scores = [regular_worst, essay_worst].reject(&:zero?)
    scores.empty? ? 0 : scores.min
  end

  def calculate_total_study_hours
    total_seconds = @user.study_events.sum(&:duration_in_seconds)
    (total_seconds / 3600.0).round(1)
  end

  def calculate_study_days
    @user.study_events.group("DATE(created_at)").count.keys.count
  end

  def calculate_category_distribution
    @user.exams.completed
         .group(:category)
         .count
         .transform_keys { |key| format_category_name(key) }
  end

  def calculate_monthly_progress
    results = []

    (0..6).each do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month

      exams_in_month = @user.exams.where(created_at: month_start..month_end)

      results << {
        month: month_start.strftime('%b/%y'),
        exams_count: exams_in_month.count,
        average_score: exams_in_month.average(:score)&.round(1) || 0
      }
    end

    results.reverse
  end

  def calculate_monthly_study_hours
    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    monthly_studies = @user.study_events.where(created_at: current_month)

    total_seconds = monthly_studies.sum(&:duration_in_seconds)
    (total_seconds / 3600.0).round(1)
  end

  def calculate_monthly_average_score
    current_month = Date.current.beginning_of_month..Date.current.end_of_month
    @user.exams.where(created_at: current_month).average(:score)&.round(1) || 0
  end

  def format_exam_title(exam)
    category_name = format_category_name(exam.category)
    exam.category == 'redacao' ? 'Redação ENEM' : "Simulado - #{category_name}"
  end

  def format_category_name(category)
    case category&.downcase
    when 'matematica'
      'Matemática e suas Tecnologias'
    when 'natureza'
      'Ciências da Natureza'
    when 'linguagens'
      'Linguagens e suas Tecnologias'
    when 'humanas'
      'Ciências Humanas'
    when 'redacao'
      'Redação'
    else
      category&.titleize || 'Categoria não definida'
    end
  end

  def calculate_exam_duration(exam)
    return nil unless exam.started_at && exam.finished_at

    duration_in_seconds = exam.finished_at - exam.started_at
    Time.at(duration_in_seconds).utc.strftime("%H:%M:%S")
  end

  def safe_media_por_materia
    result = @user.media_por_materia_from_exams
    result.is_a?(Array) ? result : []
  rescue => e
    Rails.logger.error "Erro ao calcular média por matéria: #{e.message}"
    []
  end

  def safe_evolucao_notas
    result = @user.evolucao_notas_from_exams
    result.is_a?(Array) ? result : []
  rescue => e
    Rails.logger.error "Erro ao calcular evolução de notas: #{e.message}"
    []
  end
end