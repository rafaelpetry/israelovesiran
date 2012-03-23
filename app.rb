#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'aws/s3'
require 'digest/sha1'
require 'fb_graph'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }

  set :s3_bucket, ENV['S3_BUCKET']
  set :s3_key, ENV['S3_KEY']
  set :s3_secret, ENV['S3_SECRET']
  set :s3_website, ENV['S3_WEBSITE']

  set :fb_app_id, ENV['FB_APP_ID']
  set :fb_app_secret, ENV['FB_APP_SECRET']
end

helpers do
  def callback_url(image_file)
    'http://' + request.host_with_port + '/facebook_callback/' + image_file
  end

  def image_url(image_file)
    settings.s3_website + image_file + '.jpg'
  end
end

get '/' do
  haml :index
end

post '/upload' do
  unless params['photo'] && (tempfile = params['photo'][:tempfile])
    redirect '/'
  end

  file_name = Digest::SHA1.hexdigest("#{tempfile.path}#{Time.now}#{Time.now.usec}")
  AWS::S3::Base.establish_connection!(:access_key_id => settings.s3_key, :secret_access_key => settings.s3_secret)
  AWS::S3::S3Object.store(file_name + '.jpg', open(tempfile.path), settings.s3_bucket, :access => :public_read)

  redirect "/show/#{file_name}"
end

get '/show/:image_file' do
  haml :show, :locals => { :image_url => image_url(params[:image_file]), :image_file => params[:image_file] }
end

get '/share/:image_file' do
  client = FbGraph::Auth.new(settings.fb_app_id, settings.fb_app_secret).client
  client.redirect_uri = callback_url(params[:image_file])
  redirect client.authorization_uri(:scope => [:publish_stream, :publish_actions])
end

get '/facebook_callback/:image_file' do
  client = FbGraph::Auth.new(settings.fb_app_id, settings.fb_app_secret).client
  client.redirect_uri = callback_url(params[:image_file])
  client.authorization_code = params[:code]
  token = client.access_token! :client_auth_body

  user = FbGraph::User.me(token)
  user.photo!(:url => image_url(params[:image_file]), :message => 'Israel Loves Iran')

  redirect "/show/#{params[:image_file]}?shared=1"
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end
