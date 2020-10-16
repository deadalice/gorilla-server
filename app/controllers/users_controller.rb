class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :deny_endpoint!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update]

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      format.html { render :edit }
    end
  end

  # TODO: Dashboard
  def dashboard
    if user_signed_in?
      #
    else
      #
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.fetch(:user, {})
  end

end
