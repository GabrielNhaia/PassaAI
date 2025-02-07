module OpenAiApi
  module AuthMixin
    def client
      @client ||= OpenAI::Client.new(access_token: api_key)
    end

    private

    def api_key
      Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY']
    end

    def save_api_log(action, e, request_body)
      ApiLog.create!(
        kind: :openai,
        action_name: action,
        code: e.response.dig(:status),
        request_body: request_body,
        metadata: e.response.dig(:body),
        environment: Rails.env
      )
    end
  end
end