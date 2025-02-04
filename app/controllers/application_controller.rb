class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected

  def configure_permitted_parameters
    # Adicione aqui quaisquer campos adicionais que você queira permitir no devise
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :avatar])
  end

  def after_sign_in_path_for(resource)
    dashboard_path # Redireciona para o dashboard após o login
  end
end
