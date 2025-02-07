module OpenAiApi
  class GetResponse
    include AuthMixin

    def initialize(prompt:, user_input:, temperature: 0.7)
      @prompt = prompt
      @user_input = user_input
      @temperature = temperature
    end

    def call
      begin
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [
              { role: "system", content: @prompt },
              { role: "user", content: @user_input }
            ],
            temperature: @temperature
          }
        )
        
        response.dig("choices", 0, "message", "content")
      rescue OpenAI::Error => e
        save_api_log("essay_correction", e, { prompt: @prompt, user_input: @user_input })
        raise "Erro na comunicação com OpenAI: #{e.message}"
      end
    end
  end
end
