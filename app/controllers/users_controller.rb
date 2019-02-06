class UsersController < ApplicationController
  include ApplicationHelper

  before_action :logged?, except: [:login]

  def index
  end

  def show
  end

  def edit
  end

  def login
    token = get_token(email: params[:user][:address], password: params[:password])
    if token.nil?
      render plain: "Login Failed"
    else
      session[:token] = token
      redirect_to root_path
    end
  end

  def logout
    reset_session
    redirect_to root_path
  end
end
