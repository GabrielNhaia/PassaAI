module DashboardHelper
  # Formatação de pontuação com cores
  def format_score_with_color(score)
    return content_tag(:span, "N/A", class: "text-muted") unless score
    
    color_class = case score
                  when 0..59   then "text-danger"
                  when 60..74  then "text-warning" 
                  when 75..89  then "text-info"
                  when 90..100 then "text-success"
                  else "text-muted"
                  end
    
    content_tag(:span, "#{number_with_precision(score, precision: 1)}%", class: "#{color_class} fw-bold")
  end

  # Ícone baseado no tipo de atividade
  def activity_icon(type)
    icons = {
      'exam_completed' => 'clipboard-check',
      'study_session' => 'book-open',
      'achievement' => 'trophy',
      'goal_completed' => 'target'
    }
    icons[type] || 'circle'
  end

  # Cor baseada na categoria do exame
  def category_color(category)
    colors = {
      'matematica' => 'primary',
      'natureza' => 'success', 
      'linguagens' => 'warning',
      'humanas' => 'danger',
      'redacao' => 'purple'
    }
    colors[category&.downcase] || 'secondary'
  end

  # Badge de nível baseado na sequência de estudos
  def streak_badge(streak_days)
    case streak_days
    when 0
      content_tag(:span, "Iniciante", class: "badge bg-light text-dark")
    when 1..6
      content_tag(:span, "Começando", class: "badge bg-info")
    when 7..13
      content_tag(:span, "Dedicado", class: "badge bg-primary") 
    when 14..29
      content_tag(:span, "Consistente", class: "badge bg-warning")
    when 30..59
      content_tag(:span, "Disciplinado", class: "badge bg-success")
    else
      content_tag(:span, "Mestre", class: "badge bg-dark")
    end
  end

  # Progresso visual da meta
  def progress_bar(current, target, options = {})
    percentage = target > 0 ? [(current.to_f / target * 100).round, 100].min : 0
    color = options[:color] || progress_color(percentage)
    
    content_tag(:div, class: "progress", style: "height: 8px;") do
      content_tag(:div, "", 
        class: "progress-bar bg-#{color}",
        style: "width: #{percentage}%",
        role: "progressbar",
        'aria-valuenow': current,
        'aria-valuemin': 0,
        'aria-valuemax': target
      )
    end
  end

  # Cor da barra de progresso baseada na porcentagem
  def progress_color(percentage)
    case percentage
    when 0..24   then 'danger'
    when 25..49  then 'warning'
    when 50..74  then 'info' 
    when 75..89  then 'primary'
    else 'success'
    end
  end

  # Formatação de tempo relativo
  def format_time_ago(date)
    return "Nunca" unless date
    
    if date > 1.day.ago
      time_ago_in_words(date) + " atrás"
    else
      date.strftime("%d/%m/%Y")
    end
  end

  # Saudação baseada no horário
  def time_based_greeting
    hour = Time.current.hour
    
    case hour
    when 5..11
      "Bom dia"
    when 12..17
      "Boa tarde"
    when 18..23, 0..4
      "Boa noite"
    end
  end

  # Emoji motivacional baseado no desempenho
  def motivational_emoji(score)
    case score
    when 0..59   then "😔"
    when 60..74  then "😐"
    when 75..89  then "😊"
    when 90..100 then "🎉"
    else "📚"
    end
  end

  # Status de meta (atingida, próxima, longe)
  def goal_status(current, target)
    percentage = target > 0 ? (current.to_f / target * 100).round : 0
    
    case percentage
    when 0..24
      { status: 'danger', text: 'Precisa se esforçar mais', icon: 'exclamation-triangle' }
    when 25..49
      { status: 'warning', text: 'No caminho certo', icon: 'arrow-up' }
    when 50..74
      { status: 'info', text: 'Progresso bom', icon: 'graph-up' }
    when 75..99
      { status: 'primary', text: 'Quase lá!', icon: 'target' }
    else
      { status: 'success', text: 'Meta atingida!', icon: 'check-circle' }
    end
  end

  # Formatação de duração em texto amigável
  def format_study_duration(hours)
    return "0h" if hours.zero?
    
    if hours < 1
      minutes = (hours * 60).round
      "#{minutes}min"
    elsif hours < 24
      "#{hours.round(1)}h"
    else
      days = (hours / 24).round(1)
      "#{days}d"
    end
  end

  # Gera dados para gráficos (Chart.js)
  def chart_data_for_scores(exams)
    {
      labels: exams.map { |e| e.created_at.strftime("%d/%m") },
      datasets: [{
        label: 'Pontuação',
        data: exams.map { |e| e.score || e.essay_total_score || 0 },
        borderColor: '#007bff',
        backgroundColor: 'rgba(0, 123, 255, 0.1)',
        tension: 0.4,
        fill: true
      }]
    }.to_json.html_safe
  end
end