class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :exams
  has_many :questions
  has_many :exam_questions, through: :exams

  # Adicionar os novos atributos
  attribute :email_notifications, :boolean, default: false
  attribute :sms_notifications, :boolean, default: false
  attribute :dark_mode, :boolean, default: false
  attribute :language, :string, default: 'pt-BR'
end
