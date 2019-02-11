require 'aws-sdk'

class UsersController < ApplicationController
  include ApplicationHelper

  before_action :logged?, except: [:login]

  def index
    @user = get_user_info(email: @user_email, token: @token)
  end

  def edit
    file_path = params[:avatar][:file].path
    if (File.size(file_path).to_f / 1024000 < 3) && (['.jpg','.png'].include?(File.extname(file_path)))
      avatar_url = save_image_to_s3(image_location: file_path, folder_name: 'uploads')
      update_user(photo_url: avatar_url)
    else
      flash[:upload_error] = "Upload error. File must be less than 3Mb and must have jpg/png extension."
    end
    redirect_to users_path
  end

  def getreport
    email = params[:report]["email"]
    start_date = [params[:report]["start_date(1i)"],params[:report]["start_date(2i)"],params[:report]["start_date(3i)"]].join("-")
    end_date = [params[:report]["end_date(1i)"],params[:report]["end_date(2i)"],params[:report]["end_date(3i)"]].join("-")
    response = get_report(email_to: email, from: start_date, to: end_date, token: @token)
    if response.nil?
      flash[:report_error] = "Something is wrong with API server. Try again later."
      redirect_to users_report_path
    else
      flash[:report_success] = response['message']
      redirect_to users_report_path
    end
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

  def update_user(photo_url: nil)
    get_request(url: "#{api_url}/api/v1/users/#{@user_email}/edit?photo_url=#{photo_url}", token: @token)
  end

  def save_image_to_s3(image_location: '', folder_name: '', user_id: nil)
    # KEY_ID and SECRET_KEY setted through ENV
    s3 = Aws::S3::Resource.new(region: 'us-east-2')
    bucket = 'unavailabl3'
    name = File.basename(image_location)
    obj = s3.bucket(bucket).object(name)
    obj.upload_file(image_location)
    obj.acl.put({ acl: "public-read" })
    obj.public_url.to_s
  end
end
