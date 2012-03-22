#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'aws/s3'
require 'digest/sha1'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }

  set :s3_bucket, ENV['S3_BUCKET']
  set :s3_key, ENV['S3_KEY']
  set :s3_secret, ENV['S3_SECRET']
  set :s3_website, ENV['S3_WEBSITE']
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
  haml :show, :locals => { :image_url => settings.s3_website + params[:image_file] + '.jpg' }
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end