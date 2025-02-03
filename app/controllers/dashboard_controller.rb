class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Aqui você pode adicionar lógica para buscar dados para o dashboard
    @user = current_user
  end

  def profile
    @total_simulados = current_user.exams.count
    @media_por_materia = current_user.media_por_materia_from_exams
    @evolucao_notas = current_user.evolucao_notas_from_exams
    @historico_simulados = current_user.exams
      .includes(:questions)
      .order(created_at: :desc)
      .limit(10)
  end
end