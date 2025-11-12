module ApplicationHelper
  def categoria_formatada(category)
    case category
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
      category.titleize
    end
  end

  # Helper para exibir avatar do usuário com fallback
  def user_avatar_tag(user, options = {})
    size = options[:size] || 32
    css_class = options[:class] || "rounded-circle"
    
    if user.avatar.attached? && user.avatar_thumbnail.present?
      image_tag user.avatar_thumbnail, 
                class: css_class, 
                style: "width: #{size}px; height: #{size}px; object-fit: cover;",
                alt: user.nickname
    else
      content_tag :i, '', 
                  class: "bi bi-person-circle #{css_class}", 
                  style: "font-size: #{size}px;"
    end
  end
end
