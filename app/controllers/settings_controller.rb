class SettingsController < ApplicationController
  def index
    # Renderiza a página de configurações
  end

  def save
    current_user.update(settings_params)
    redirect_to settings_path, notice: 'Configurações salvas com sucesso.'
  end

  def edit_password
    # Lógica para editar a senha
  end

  def edit_email
    # Lógica para editar o email
  end

  def delete_account
    # Lógica para excluir a conta
  end

  private

  def settings_params
    params.require(:user).permit(:email_notifications, :sms_notifications, :dark_mode, :language)
  end
end
