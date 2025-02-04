Rails.application.routes.draw do
  devise_for :users
  
  # Rotas do dashboard e perfil
  get 'dashboard', to: 'dashboard#index'
  get 'profile', to: 'dashboard#profile'

  get 'simulados', to: 'exams#index', as: :simulados

  get 'settings', to: 'settings#index'
  post 'save_settings', to: 'settings#save'
  get 'edit_password', to: 'settings#edit_password'
  get 'edit_email', to: 'settings#edit_email'
  delete 'delete_account', to: 'settings#delete_account'
  
  get 'study_materials', to: 'study_materials#index'
  get 'progress_tracking', to: 'progress_tracking#index'
  
  # Rota raiz dentro do devise_scope
  devise_scope :user do
    root to: 'devise/sessions#new'
  end
  
  # Rotas protegidas que requerem autenticação
  authenticate :user do
    # Adicione aqui outras rotas que precisam de autenticação
  end

  resources :exams do
    member do
      get :start
      post :answer
      get :result
      get :writing
      patch :submit_writing
    end
    collection do
      get :completed
    end
  end

  resources :users, only: [:update]
end
