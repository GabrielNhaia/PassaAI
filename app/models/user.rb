class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :exams
  has_many :questions
  has_many :exam_questions, through: :exams
  has_many :study_events, dependent: :destroy

  # Adicionar os novos atributos
  attribute :email_notifications, :boolean, default: true
  attribute :sms_notifications, :boolean, default: false
  attribute :dark_mode, :boolean, default: false
  attribute :language, :string, default: 'pt-BR'

  has_one_attached :avatar

  validates :nickname, presence: true, uniqueness: true

  def media_por_materia_from_exams
    exam_averages = exams
      .joins(:questions)
      .group('questions.category')
      .select('questions.category, AVG(exams.score) as average_score')

    exam_averages.map { |result| {
      materia: categoria_formatada(result.category),
      media: result.average_score.to_i
    }}
  end

  def evolucao_notas_from_exams
    if ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')
      # Versão SQLite
      exams
        .select("strftime('%Y-%m', created_at) as month, AVG(score) as average_score")
        .group('month')
        .order('month')
        .last(6)
        .map { |result| {
          mes: Date.parse(result.month + '-01').strftime('%b'),
          media: result.average_score.to_i
        }}
    else
      # Versão PostgreSQL
      exams
        .select("DATE_TRUNC('month', created_at) as month, AVG(score) as average_score")
        .group('month')
        .order('month')
        .last(6)
        .map { |result| {
          mes: result.month.strftime('%b'),
          media: result.average_score.to_i
        }}
    end
  end

  def avatar_thumbnail
    return unless avatar.attached?
    
    avatar.variant(resize_to_fill: [100, 100]).processed
  rescue StandardError => e
    Rails.logger.error("Erro ao processar thumbnail: #{e.message}")
    nil
  end

  private

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
