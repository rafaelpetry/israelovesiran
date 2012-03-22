#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
end

get '/' do
  haml :index
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end