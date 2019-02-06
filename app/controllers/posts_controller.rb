class PostsController < ApplicationController
  include ApplicationHelper

  before_action :logged?

  def index
    @posts = get_posts(token: @token)
  end

  def show
    @post = get_post(id: params[:id], token: @token)
  end

end
