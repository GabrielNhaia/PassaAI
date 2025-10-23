Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    root to: 'devise/sessions#new'
  end

  authenticate :user do
    get 'dashboard', to: 'dashboard#index'
    get 'profile', to: 'dashboard#profile'

    get 'simulados', to: 'exams#index', as: :simulados
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

    get 'progress_tracking', to: 'progress_tracking#index'

    scope 'settings', controller: :settings do
      get '/', action: :index, as: :settings
      post 'save', action: :save, as: :save_settings

      get 'password', action: :edit_password, as: :edit_password
      patch 'password', action: :update_password, as: :update_password

      get 'email', action: :edit_email, as: :edit_email
      patch 'email', action: :update_email, as: :update_email

      delete 'account', action: :delete_account, as: :delete_account
    end

    resources :study_events

    resources :users, only: [:update]
  end
end
