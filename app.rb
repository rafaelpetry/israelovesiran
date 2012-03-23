#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'aws/s3'
require 'digest/sha1'
require 'fb_graph'
require 'RMagick'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }

  set :s3_bucket, ENV['S3_BUCKET']
  set :s3_key, ENV['S3_KEY']
  set :s3_secret, ENV['S3_SECRET']
  set :s3_website, ENV['S3_WEBSITE']

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

  image = add_logo(tempfile.path)
  AWS::S3::Base.establish_connection!(:access_key_id => settings.s3_key, :secret_access_key => settings.s3_secret)
  AWS::S3::S3Object.store(unique_filename + '.jpg', image.to_blob, settings.s3_bucket, :access => :public_read)

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

helpers do
  def callback_url(image_file)
    'http://' + request.host_with_port + '/facebook_callback/' + image_file
  end

  def image_url(image_file)
    settings.s3_website + image_file + '.jpg'
  end

  def add_logo(image_path)
    original_image = Magick::Image::read(image_path)[0]
    user_img = original_image.resize_to_fit(500, 500)

    weloveiran_img = Magick::Image::read('static/images/iran-love-israel-01.png')[0]

    weloveiran_img = resize(user_img, weloveiran_img)

    images = Magick::ImageList.new
    images << user_img
    images << weloveiran_img

    max_height = images[0].rows + images[1].rows
    posy = max_height < 500 ? (images[0].rows - images[1].rows) : (500-images[1].rows)

    images[1].page = Magick::Rectangle.new(images[1].columns, images[1].rows, 0, posy)

    images.flatten_images
  end

  def resize(image, banner)
    banner.resize!(image.columns * 0.33, image.rows * 0.33)
  end

  def unique_filename
    "#{Digest::SHA1.hexdigest("#{Time.now}#{Time.now.usec}")}.jpg"
  end
end

