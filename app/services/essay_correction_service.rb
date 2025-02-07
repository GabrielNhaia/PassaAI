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
      Você é um corretor especializado em redações do ENEM. Analise a redação fornecida com base nas 5 competências:

      1. Domínio da escrita formal da língua portuguesa (0-200 pontos)
      2. Compreensão do tema e desenvolvimento do texto dissertativo-argumentativo (0-200 pontos)
      3. Capacidade de interpretação e organização de argumentos (0-200 pontos)
      4. Domínio dos mecanismos linguísticos de argumentação (0-200 pontos)
      5. Proposta de intervenção respeitando os direitos humanos (0-200 pontos)

      O tema da redação é: #{@theme}

      Retorne um JSON com o seguinte formato:
      {
        "comp1": { "score": 0-200, "feedback": "feedback detalhado" },
        "comp2": { "score": 0-200, "feedback": "feedback detalhado" },
        "comp3": { "score": 0-200, "feedback": "feedback detalhado" },
        "comp4": { "score": 0-200, "feedback": "feedback detalhado" },
        "comp5": { "score": 0-200, "feedback": "feedback detalhado" },
        "total_score": "soma das notas",
        "general_feedback": "feedback geral da redação"
      }
    PROMPT
  end

  def parse_response(response)
    JSON.parse(response)
  rescue JSON::ParserError
    { error: "Erro ao processar a correção da redação" }
  end
end
