#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'flickraw'
require 'digest/sha1'
require 'fb_graph'
require 'RMagick'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }

  FlickRaw.api_key = ENV['FLICKR_API_KEY']
  FlickRaw.shared_secret = ENV['FLICKR_SECRET']
  flickr.access_token = ENV['FLICKR_ACCESS_TOKEN']
  flickr.access_secret = ENV['FLICKR_ACCESS_SECRET']

  set :fb_app_id, ENV['FB_APP_ID']
  set :fb_app_secret, ENV['FB_APP_SECRET']
end

get '/' do
  haml :index
end

post '/upload' do
  unless params['photo'] && (tempfile = params['photo'][:tempfile])
    redirect '/'
  end

  file_name = tempfile.path
  photo = resize_to_fit!(file_name, 500)

  photo_id = flickr.upload_photo file_name, :is_public => false

  redirect "/show/#{photo_id}"
end

get '/show/:photo_id' do
  haml :show, :locals => { :photo_url => photo_url(params[:photo_id]), :photo_id => params[:photo_id] }
end

get '/share/:photo_id' do
  client = FbGraph::Auth.new(settings.fb_app_id, settings.fb_app_secret).client
  client.redirect_uri = callback_url(params[:photo_id])
  redirect client.authorization_uri(:scope => [:publish_stream, :publish_actions])
end

get '/facebook_callback/:photo_id' do
  client = FbGraph::Auth.new(settings.fb_app_id, settings.fb_app_secret).client
  client.redirect_uri = callback_url(params[:photo_id])
  client.authorization_code = params[:code]
  token = client.access_token! :client_auth_body

  user = FbGraph::User.me(token)
  user.photo!(:url => photo_url(params[:photo_id]), :message => 'Israel Loves Iran')

  redirect "/show/#{params[:photo_id]}?shared=1"
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

helpers do
  def callback_url(photo_id)
    'http://' + request.host_with_port + '/facebook_callback/' + photo_id
  end

  def photo_url(photo_id)
    info = flickr.photos.getInfo(:photo_id => photo_id)
    FlickRaw.url_b(info)
  end

  def resize_to_fit!(image_path, maximum_size)
    original_image = Magick::Image::read(image_path)[0]
    original_image.resize_to_fit!(maximum_size, maximum_size)
    original_image.write(image_path)
  end

  def unique_filename
    Digest::SHA1.hexdigest("#{Time.now}#{Time.now.usec}")
  end
end

