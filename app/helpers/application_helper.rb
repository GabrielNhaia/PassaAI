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
end
