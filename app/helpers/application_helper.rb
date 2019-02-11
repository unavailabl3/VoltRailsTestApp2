require 'net/http'

module ApplicationHelper
  def api_url
    #"http://localhost:3001"
    "https://still-badlands-56815.herokuapp.com"
  end

  def logged?
    if session[:token]
      @token = session[:token]
      @user_email = session[:email]
    else
      render 'users/loginpage'
    end
  end

  def get_token(email: "example@mail.com", password: "example")
    url = URI.parse("#{api_url}/auth/login")
    parameters =  {email: email, password: password}.to_json
    header = { 'CONTENT_TYPE' => 'application/json' }
    http = Net::HTTP.new(url.host, url.port)
    #http.use_ssl = true
    request = Net::HTTP::Post.new(url.request_uri, header)
    request.body = parameters

    response = http.request(request)
    body = JSON.parse(response.body)
    body if body.key?('token')
  end

  def get_report(email_to: nil, from: nil, to: nil, token: nil)
    url = URI.parse("#{api_url}/api/v1/reports/by_author.json")
    parameters =  {'start_date': from, 'end_date': to, 'email': email_to}
    header = { 'Authorization' => "Bearer #{token}" }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.request_uri, header)
    request.body = URI.encode_www_form(parameters)

    response = http.request(request)
    body = JSON.parse(response.body)
    body if body.key?('message')
  end

  def get_request(url: "", token: nil)
    url = URI.parse(url)
    header = { 'Authorization' => "Bearer #{token}" }
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.request_uri, header)
    return http.request(request).body
  end

  def get_posts(token: nil)
    response = get_request(url: "#{api_url}/api/v1/posts.json", token: token)
    posts = []
    JSON.parse(response)['data'].each{ |post|
        posts << post_from_json(post)
     }
     return posts
  end

  def get_post(id: 1, token: nil)
    response = get_request(url: "#{api_url}/api/v1/posts/#{id}.json", token: token)
    post_from_json(JSON.parse(response)['data'])
  end

  def get_user_info(email: "", token: nil)
    response = get_request(url: "#{api_url}/api/v1/users/#{email}", token: token) #CHANGE URL
    JSON.parse(response)
  end

  def post_from_json(post)
    post['attributes']['id'] = post['id']
    post['attributes']
  end
end
