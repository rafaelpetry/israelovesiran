#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'digest/sha1'
require 'uri'
require 'cgi'
require 'image_helper.rb'
require 'facebook_sharing.rb'
require 'flickr_sharing.rb'

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
  redirect facebook.authorization_url(callback_url(params[:photo_id]))
end

get '/facebook_callback/:photo_id' do
  photo = flickr.photo_url(params[:photo_id])
  callback = callback_url(params[:photo_id])
  facebook.share_photo(photo, 'Israel Loves Iran', params[:code], callback)
  redirect "/show/#{params[:photo_id]}?shared_facebook=1"
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

helpers do
  def callback_url(photo_id)
    'http://' + request.host_with_port + '/facebook_callback/' + photo_id
  end

  def logo_in(color_scheme)
    "static/images/logo-#{color_scheme}.png"
  end

  def share_to_tumblr_link(photo_url)
    "http://www.tumblr.com/share/photo?source=#{CGI.escape(photo_url)}" +
      "&caption=#{URI.escape("We Love Iran")}" +
      "&click_thru=#{CGI.escape(request.url)}"
  end

  def facebook
    @facebook_sharing ||= FacebookSharing.new(settings.fb_app_id, settings.fb_app_secret)
  end

  def flickr
    @flickr_sharing ||= FlickrSharing.new(settings.flickr_api_key, settings.flickr_secret, settings.flickr_access_token, settings.flickr_access_secret)
  end
end

