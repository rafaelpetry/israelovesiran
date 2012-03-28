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
  logo = logo_in(params[:color_scheme])

  photo = add_logo(file_name, logo)
  photo.write(file_name)
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

  def add_logo(image_path, logo)
    original_image = Magick::Image::read(image_path)[0]
    user_img = original_image.resize_to_fit(500, 500)

    weloveiran_img = Magick::Image::read(logo)[0]

    weloveiran_img = resize(user_img, weloveiran_img)

    images = Magick::ImageList.new
    images << user_img
    images << weloveiran_img

    max_height = images[0].rows + images[1].rows
    posy = max_height < 500 ? (images[0].rows - images[1].rows) : (500-images[1].rows)

    images[1].page = Magick::Rectangle.new(images[1].columns, images[1].rows, 0, posy)

    images.flatten_images
  end

  def logo_in(color_scheme)
    "static/images/logo-#{color_scheme}.png"
  end

  def resize(image, banner)
    banner.resize_to_fit!(image.columns)
  end

  def unique_filename
    Digest::SHA1.hexdigest("#{Time.now}#{Time.now.usec}")
  end
end

