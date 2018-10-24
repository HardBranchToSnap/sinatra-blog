#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sqlite3'
#require 'sinatra/reloader'

def init_db
  @db = SQLite3::Database.new 'blog-sinatra.db'
  @db.results_as_hash = true
end  

before do
  init_db 
end  

configure do
  init_db

  @db.execute 'CREATE TABLE IF NOT EXISTS `Posts` (
    `id`  INTEGER PRIMARY KEY AUTOINCREMENT,
    `created_date`  DATE,
    `content` TEXT
  )'

  @db.execute 'CREATE TABLE IF NOT EXISTS `Comments` (
    `id`  INTEGER PRIMARY KEY AUTOINCREMENT,
    `created_date`  DATE,
    `comment` TEXT,
    `post_id` INTEGER
  )'
end

#GET'S 

get '/' do
  @title = 'Блог'
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
  @title = 'Создание поста'
  erb :new
end

get '/posts' do
  @title = 'Посты'
  @show_posts = @db.execute 'select * from Posts ORDER BY id DESC' 
  erb :posts
end

get '/p/:post_id' do
  post_id = params[:post_id].to_i

  results = @db.execute 'select * from Posts where id = ?', [post_id]
  @row = results[0]

  @show_comments = @db.execute 'select * from Comments where post_id = ? ORDER BY id DESC', [post_id]
  erb :show_post
end

get '/signup' do
  erb :signup
end

# POST'S

post '/new' do
  post_title = params['post_title']
  content = params['post_text']
  @post_title, @content = params['post_title'], params['post_text']
  @error = 'Слишком короткий пост!'; return erb :new if post_title.length < 2 || @content.length < 2
  @db.execute 'INSERT into Posts (post_title, content, created_date) values (?, ?, datetime())',[post_title, content]
  redirect '/posts'
  #"#{post_title} - тема \n #{content} - контент"
end

post '/p/:post_id' do
  post_id = params[:post_id].to_i
  comment = params[:comment]
  @db.execute 'INSERT into Comments (comment, post_id, created_date) values (?, ?, datetime())',[comment, post_id]
  redirect "/p/#{post_id}"
end

post '/signup/register' do
  login = params['login']
  password = params['password']
  @db.execute 'INSERT into Users (login, password) values (?, ?)',[login, password]
  #session[:identity] = login

  #where_user_came_from = session[:previous_url] || '/'
  redirect to '/'
end