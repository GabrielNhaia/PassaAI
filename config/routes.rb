Rails.application.routes.draw do
  devise_for :users
  
  # Rotas do dashboard e perfil
  get 'dashboard', to: 'dashboard#index'
  get 'profile', to: 'dashboard#profile'

  get 'simulados', to: 'exams#index', as: :simulados
  
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
    end
    collection do
      get :completed
    end
  end
end
