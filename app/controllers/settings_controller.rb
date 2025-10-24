class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:index, :save, :edit_password, :edit_email, :update_password, :update_email, :delete_account]

  def index
    @user = current_user
    @notification_settings = build_notification_settings
    @appearance_settings = build_appearance_settings
    @account_settings = build_account_settings
  end

  def save
    if update_user_settings
      redirect_to settings_path, notice: 'Configurações atualizadas com sucesso!'
    else
      handle_update_errors
    end
  end

  def edit_password
    @user = current_user
  end

  def update_password
    if validate_current_password && update_user_password
      bypass_sign_in(@user)
      redirect_to settings_path, notice: 'Senha atualizada com sucesso!'
    else
      handle_password_errors
    end
  end

  def edit_email
    @user = current_user
  end

  def update_email
    if @user.update(email_params)
      redirect_to settings_path, notice: 'Email atualizado com sucesso!'
    else
      flash.now[:alert] = 'Erro ao atualizar email.'
      render :edit_email, status: :unprocessable_entity
    end
  end

  def delete_account
    if confirm_account_deletion?
      perform_account_deletion
    else
      redirect_to settings_path, alert: 'Confirmação necessária para excluir a conta.'
    end
  end

  private

  def set_user
    @user = current_user
  end

  def build_notification_settings
    {
      email_notifications: @user.email_notifications,
      sms_notifications: @user.sms_notifications
    }
  end

  def build_appearance_settings
    {
      dark_mode: @user.dark_mode,
      language: @user.language
    }
  end

  def build_account_settings
    {
      email: @user.email,
      nickname: @user.nickname,
      created_at: @user.created_at
    }
  end

  def update_user_settings
    @user.update(settings_params)
  end

  def handle_update_errors
    flash[:alert] = format_error_messages(@user.errors)
    redirect_to settings_path
  end

  def validate_current_password
    return true if @user.valid_password?(password_params[:current_password])

    @user.errors.add(:current_password, 'é inválida')
    false
  end

  def update_user_password
    @user.update(password: password_params[:password])
  end

  def handle_password_errors
    flash.now[:alert] = format_error_messages(@user.errors)
    render :edit_password, status: :unprocessable_entity
  end

  def confirm_account_deletion?
    params[:confirm_deletion] == 'true'
  end

  def perform_account_deletion
    if @user.destroy
      redirect_to root_path, notice: 'Sua conta foi excluída com sucesso.'
    else
      redirect_to settings_path, alert: 'Erro ao excluir conta.'
    end
  end

  def format_error_messages(errors)
    errors.full_messages.join(', ')
  end

  def settings_params
    params.require(:user).permit(
      :email_notifications,
      :sms_notifications,
      :dark_mode,
      :language,
      :nickname
    )
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def email_params
    params.require(:user).permit(:email)
  end
end
