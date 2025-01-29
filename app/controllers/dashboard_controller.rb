class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Aqui você pode adicionar lógica para buscar dados para o dashboard
    @user = current_user
  end

  def profile
    @user = current_user
    # Aqui você pode adicionar lógica para buscar:
    # - Histórico de simulados
    # - Médias por matéria
    # - Estatísticas do usuário
    
    # Exemplo de como estruturar os dados (substitua com dados reais do seu banco):
    @simulados = [] # Substituir com consulta real
    @medias_por_materia = {
      matematica: 85,
      linguagens: 90,
      ciencias_humanas: 88
    }
    
    @evolucao_notas = {
      labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
      dados: [65, 70, 75, 80, 85, 88]
    }
  end
end