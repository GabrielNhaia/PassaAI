class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def save
    respond_to do |format|
      if current_user.update(settings_params)
        format.html { 
          flash[:notice] = 'Configurações atualizadas com sucesso!'
          redirect_to settings_path
        }
      else
        format.html { 
          flash[:alert] = 'Erro ao atualizar configurações.'
          redirect_to settings_path
        }
      end
    end
  end

  def edit_password
    # Lógica para editar a senha
  end

  def edit_email
    # Lógica para editar o email
  end

  def delete_account
    if current_user.destroy
      redirect_to root_path, notice: 'Sua conta foi excluída com sucesso.'
    else
      redirect_to settings_path, alert: 'Erro ao excluir conta.'
    end
  end

  private

  def settings_params
    params.require(:user).permit(:email_notifications, :dark_mode)
  end
end
