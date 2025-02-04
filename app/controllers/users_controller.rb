class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(user_params)
      redirect_to dashboard_profile_path, notice: 'Perfil atualizado com sucesso!'
    else
      redirect_to dashboard_profile_path, alert: 'Erro ao atualizar perfil.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :avatar)
  end
end
