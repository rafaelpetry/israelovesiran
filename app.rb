#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'uri'
require 'cgi'
require 'helpers/application_helper'
require 'helpers/image_helper'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }

  set :flickr_api_key, ENV['FLICKR_API_KEY']
  set :flickr_secret, ENV['FLICKR_SECRET']
  set :flickr_access_token, ENV['FLICKR_ACCESS_TOKEN']
  set :flickr_access_secret, ENV['FLICKR_ACCESS_SECRET']

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

  photo_id = flickr.upload file_name

  redirect "/show/#{photo_id}"
end

get '/show/:photo_id' do
  haml :show, :locals => { :photo_url => flickr.photo_url(params[:photo_id]), :photo_id => params[:photo_id] }
end

get '/share/facebook/:photo_id' do
  redirect facebook.authorization_url(facebook_callback_url(params[:photo_id]))
end

get '/callback/facebook/:photo_id' do
  photo = flickr.photo_url(params[:photo_id])
  callback = facebook_callback_url(params[:photo_id])
  facebook.share_photo(photo, 'Israel Loves Iran', params[:code], callback)
  redirect "/show/#{params[:photo_id]}?shared_facebook=1"
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end
