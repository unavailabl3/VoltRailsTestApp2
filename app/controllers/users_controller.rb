class UsersController < ApplicationController
  include ApplicationHelper

  before_action :logged?, except: [:login]

  def index
    @user = get_user_info(email: @user_email, token: @token)
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
      session[:token] = token['token']
      session[:email] = token['email']
      redirect_to root_path
    end
  end

  def logout
    reset_session
    redirect_to root_path
  end

  private

  def save_screenshot_to_s3(image_location, folder_name,user_id)
    service = AWS::S3.new(:access_key_id => 'AKIAJQ43XLA5AUMWDVCA',
                          :secret_access_key => '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')
    bucket_name = "unavailabl3"
    if(service.buckets.include?(bucket_name))
      bucket = service.buckets[bucket_name]
    else
      bucket = service.buckets.create(bucket_name)
    end
    bucket.acl = :public_read
    key = folder_name.to_s + "/" + File.basename(image_location)
    s3_file = service.buckets[bucket_name].objects[key].write(:file => image_location)
    s3_file.acl = :public_read
    user = User.where(id: user_id).first
    user.image = s3_file.public_url.to_s
    user.save
  end
end
