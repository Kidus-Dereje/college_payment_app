class Api::ServicesController < ApplicationController
  before_action :authenticate_user!

  def index
    services = Service.where(is_active: true)
    render json: services
  end
end 