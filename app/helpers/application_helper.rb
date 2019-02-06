require 'net/http'

module ApplicationHelper
  def logged?
    if session[:token]
      @token = session[:token]
    else
      render 'users/loginpage'
    end
  end

  def get_token(email: "example@mail.com", password: "example")
    url = URI.parse("https://still-badlands-56815.herokuapp.com/auth/login")
    parameters =  {email: email, password: password}.to_json
    header = { 'CONTENT_TYPE' => 'application/json' }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.request_uri, header)
    request.body = parameters

    response = http.request(request)
    body = JSON.parse(response.body)
    body['token'] if body.key?('token')
  end

  def get_posts(token: nil)
    url = URI.parse("https://still-badlands-56815.herokuapp.com/api/v1/posts.json")
    header = { 'Authorization' => "Bearer #{token}" }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.request_uri, header)
    response = http.request(request)

    posts = []
    JSON.parse(response.body)['data'].each{ |post|
        posts << post_from_json(post)
     }
     return posts
  end

  def get_post(id: 1, token: nil)
    url = URI.parse("https://still-badlands-56815.herokuapp.com/api/v1/posts/#{id}.json")
    header = { 'Authorization' => "Bearer #{token}" }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.request_uri, header)
    response = http.request(request)

    post_from_json(JSON.parse(response.body)['data'])
  end

  def post_from_json(post)
    post['attributes']['id'] = post['id']
    post['attributes']
  end
end
