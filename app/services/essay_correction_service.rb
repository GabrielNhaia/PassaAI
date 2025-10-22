class EssayCorrectionService
  def initialize(essay_text, theme)
    @essay_text = essay_text
    @theme = theme
  end

  def correct
    response = OpenAiApi::GetResponse.new(
      prompt: correction_prompt,
      user_input: @essay_text
    ).call

    parse_response(response)
  rescue StandardError => e
    { error: e.message }
  end

  private

  def correction_prompt
    <<~PROMPT
      Você é um corretor especializado em redações do ENEM. Analise a redação fornecida com base nas 5 competências lembrando que cada competência vale até 200 
      pontos e os corretores retiram 20 pontos para cada erro grave identificado. Considere os seguintes critérios:

      COMPETÊNCIA 1 - Domínio da escrita formal da língua portuguesa (0-200 pontos):
      - Identifique ESPECIFICAMENTE os erros: ortografia, acentuação, concordância, regência, pontuação
      - Cite trechos exatos onde ocorrem os problemas
      - Sugira correções pontuais
      - Avalie registro de linguagem e adequação à norma culta

      COMPETÊNCIA 2 - Compreensão do tema e desenvolvimento do texto dissertativo-argumentativo (0-200 pontos):
      - Verifique se abordou o tema proposto completamente
      - Analise se manteve o tipo textual dissertativo-argumentativo
      - Identifique tangenciamentos ou fugas do tema
      - Comente sobre a progressão temática

      COMPETÊNCIA 3 - Capacidade de interpretação e organização de argumentos (0-200 pontos):
      - Avalie a estrutura: introdução, desenvolvimento, conclusão
      - Analise a consistência e relevância dos argumentos
      - Verifique o uso de repertório sociocultural
      - Comente sobre a articulação entre as ideias

      COMPETÊNCIA 4 - Domínio dos mecanismos linguísticos de argumentação (0-200 pontos):
      - Identifique ESPECIFICAMENTE quais conectivos foram mal utilizados ou ausentes
      - Cite trechos onde falta coesão entre períodos ou parágrafos
      - Aponte problemas de coerência textual
      - Sugira conectivos adequados para melhorar a fluidez

      COMPETÊNCIA 5 - Proposta de intervenção respeitando os direitos humanos (0-200 pontos):
      - Verifique se apresentou proposta clara e viável
      - Analise se contempla: agente, ação, meio, finalidade, detalhamento
      - Confirme se respeita os direitos humanos
      - Avalie a articulação com o restante do texto

      INSTRUÇÕES PARA FEEDBACK ESPECÍFICO:
      - Para cada competência, seja ESPECÍFICO: cite trechos, palavras ou frases problemáticas
      - Em vez de "há deslizes que comprometem a fluidez", diga QUAIS deslizes e ONDE estão
      - Para problemas de coesão, indique EXATAMENTE onde faltam conectivos e quais usar
      - Para erros gramaticais, cite o erro e a correção
      - Use exemplos do próprio texto do candidato

      O tema da redação é: #{@theme}

      Retorne um JSON com o seguinte formato:
      {
        "comp1": { "score": 0-200, "feedback": "feedback detalhado com citações específicas do texto" },
        "comp2": { "score": 0-200, "feedback": "feedback detalhado com citações específicas do texto" },
        "comp3": { "score": 0-200, "feedback": "feedback detalhado com citações específicas do texto" },
        "comp4": { "score": 0-200, "feedback": "feedback detalhado com citações específicas do texto" },
        "comp5": { "score": 0-200, "feedback": "feedback detalhado com citações específicas do texto" },
        "total_score": "soma das notas",
        "general_feedback": "feedback geral da redação com sugestões de melhoria específicas"
      }
    PROMPT
  end

  def parse_response(response)
    parsed_response = JSON.parse(response)
    validate_and_enhance_feedback(parsed_response)
  rescue JSON::ParserError
    { error: "Erro ao processar a correção da redação" }
  end

  def validate_and_enhance_feedback(response)
    required_competencies = %w[comp1 comp2 comp3 comp4 comp5]
    
    required_competencies.each do |comp|
      unless response[comp]&.dig("feedback")&.length&.> 50
        response[comp]["feedback"] = enhance_generic_feedback(response[comp]["feedback"], comp)
      end
    end

    response
  end

  def enhance_generic_feedback(feedback, competency)
    return feedback if feedback.nil? || feedback.empty?

    generic_phrases = [
      "há deslizes", "alguns problemas", "precisa melhorar",
      "comprometem a fluidez", "apresenta dificuldades"
    ]

    if generic_phrases.any? { |phrase| feedback.downcase.include?(phrase) }
      case competency
      when "comp1"
        feedback + " Sugestão: Revise especificamente concordância verbal e nominal, uso de vírgulas em orações subordinadas e acentuação de palavras proparoxítonas."
      when "comp4"
        feedback + " Sugestão: Use conectivos como 'ademais', 'por conseguinte', 'dessa forma' para melhorar a articulação entre ideias. Evite repetir 'e' e 'mas' em excesso."
      else
        feedback + " Revise os critérios específicos desta competência para identificar pontos de melhoria."
      end
    else
      feedback
    end
  end
end
