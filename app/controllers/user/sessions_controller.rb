# frozen_string_literal: true

class User::SessionsController < ApplicationController
  before_action :authenticate_user!, only: %i[destroy]
  before_action :require_guest_access!, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = ::User.authenticate_by(user_params)

    respond_to do |format|
      if @user
        format.html do
          sign_in(@user)

          redirect_to task_list_items_path(Current.task_list_id), notice: "You have successfully signed in!"
        end
        format.json { render "user/shared/user_token", status: :ok }
      else
        format.html do
          flash.now[:alert] = "Invalid email or password. Please try again."

          @user = User.new(email: user_params[:email])

          render :new, status: :unprocessable_entity
        end
        format.json do
          render("errors/unauthorized", status: :unauthorized, locals: {
            message: "Invalid email or password. Please try again."
          })
        end
      end
    end
  end

  def destroy
    sign_out

    redirect_to new_user_session_path, notice: "You have successfully signed out."
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
