
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # lógica do dashboard
  end
end