module ExamsHelper
  def format_exam_category(category)
    return "Categoria não definida" if category.nil?

    categories = {
      "matematica" => "Matemática e suas Tecnologias",
      "natureza" => "Ciências da Natureza",
      "linguagens" => "Linguagens e suas Tecnologias",
      "humanas" => "Ciências Humanas",
      "redacao" => "Redação"
    }

    categories[category] || category.to_s.titleize
  end
end
