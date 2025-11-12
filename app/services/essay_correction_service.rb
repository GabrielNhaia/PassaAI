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
      Você é um corretor automatizado de redações alinhado à matriz de referência do ENEM (Inep). Avalie uma redação dissertativa-argumentativa em língua portuguesa e entregue:

      • Notas separadas para cada Competência (1 a 5), cada uma entre 0 e 200
      • Nota final = soma das 5 competências (0–1000)
      • Feedback curto e acionável: 2–4 pontos fortes, 2–4 pontos a melhorar e 2–3 sugestões práticas
      • Justificativa breve (1–2 frases) para cada competência

      CRITÉRIOS DE AVALIAÇÃO:

      COMPETÊNCIA 1: Domínio da norma padrão (ortografia, morfossintaxe, pontuação)
      - Identifique erros específicos de ortografia, concordância, regência e pontuação
      - Cite trechos exatos com problemas
      - Use incrementos de 10 pontos (ex.: 120, 130, 140...)

      COMPETÊNCIA 2: Compreensão do tema e seleção de informações relevantes
      - Verifique se abordou completamente o tema: #{@theme}
      - Identifique tangenciamentos ou fugas do tema
      - Se houver fuga total ao tema, aplique nota 0 conforme regra do ENEM

      COMPETÊNCIA 3: Organização, coesão e progressão temática
      - Avalie estrutura (introdução, desenvolvimento, conclusão)
      - Analise articulação entre parágrafos e ideias
      - Verifique progressão lógica dos argumentos

      COMPETÊNCIA 4: Argumentação (uso de argumentos, repertório)
      - Avalie qualidade e consistência dos argumentos
      - Verifique uso adequado de repertório sociocultural
      - Analise mecanismos linguísticos de argumentação

      COMPETÊNCIA 5: Proposta de intervenção compatível com direitos humanos
      - Deve conter: agente, ação, meio/modo, finalidade e detalhamento
      - Verificar respeito aos direitos humanos
      - Avaliar articulação com o desenvolvimento do texto

      REGRAS IMPORTANTES:
      - Use incrementos coerentes (múltiplos de 20) ao atribuir pontos
      - Se detectar indícios de plágio ou fraude, marque e explique
      - Seja específico: evite frases como "há deslizes" - diga QUAIS deslizes e ONDE
      - Cite trechos problemáticos do texto original

      Retorne um JSON com o seguinte formato:
      {
        "comp1": {
          "score": 0-200,
          "feedback": "Pontos fortes: [2-3 pontos]. Pontos a melhorar: [2-3 pontos específicos com citações]. Sugestão: [1 dica prática].",
          "justification": "Justificativa breve em 1-2 frases"
        },
        "comp2": {
          "score": 0-200,
          "feedback": "Pontos fortes: [2-3 pontos]. Pontos a melhorar: [2-3 pontos específicos com citações]. Sugestão: [1 dica prática].",
          "justification": "Justificativa breve em 1-2 frases"
        },
        "comp3": {
          "score": 0-200,
          "feedback": "Pontos fortes: [2-3 pontos]. Pontos a melhorar: [2-3 pontos específicos com citações]. Sugestão: [1 dica prática].",
          "justification": "Justificativa breve em 1-2 frases"
        },
        "comp4": {
          "score": 0-200,
          "feedback": "Pontos fortes: [2-3 pontos]. Pontos a melhorar: [2-3 pontos específicos com citações]. Sugestão: [1 dica prática].",
          "justification": "Justificativa breve em 1-2 frases"
        },
        "comp5": {
          "score": 0-200,
          "feedback": "Pontos fortes: [2-3 pontos]. Pontos a melhorar: [2-3 pontos específicos com citações]. Sugestão: [1 dica prática].",
          "justification": "Justificativa breve em 1-2 frases"
        },
        "total_score": "soma das 5 competências",
        "general_feedback": "Resumo geral da redação com as principais conquistas e desafios identificados"
      }
    PROMPT
  end

  def parse_response(response)
    parsed_response = JSON.parse(response)
    validate_response_structure(parsed_response)
  rescue JSON::ParserError
    { error: "Erro ao processar a correção da redação" }
  end

  def validate_response_structure(response)
    required_competencies = %w[comp1 comp2 comp3 comp4 comp5]

    required_competencies.each do |comp|
      comp_data = response[comp]
      unless comp_data.is_a?(Hash) && 
             comp_data["score"].is_a?(Integer) && 
             comp_data["feedback"].is_a?(String) &&
             comp_data["justification"].is_a?(String)

        return { error: "Formato de resposta inválido para #{comp}" }
      end
    end

    response
  end
end
