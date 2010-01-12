require 'rubygems'
require 'sinatra'
require 'haml'
require 'builder'

# Datamapper demo (http://blog.zerosum.org/2008/7/2/clone-pastie-with-sinatra-datamapper-redux) requires
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
# require 'syntaxi'
require 'coderay'

# Setup the sqlite3db
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/toopaste.sqlite3")

# Define the model
class Snippet
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text,    :required => true# cannot be null
  property :created_at, DateTime
  property :updated_at, DateTime

  # validates_present :body
  # validates_length :body, :minimum => 1

  #Syntaxi.line_number_method = 'inline'
  #Syntaxi.wrap_at_column = 80

  def formatted_body
    #replacer = Time.now.strftime('[code-%d]')
    #html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]', replacer)}[/code]").process
    #"<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, '[/code]')}</div>"
    
		tokens = CodeRay.scan self.body, :ruby
		tokens.html :line_numbers => :inline, :wrap => :div

  end
end

DataMapper.auto_upgrade!

get '/' do
  haml :index
end

# This one shows how you can use refer to
# variables in your Haml views.
# This method uses member variables.
get '/hello/:name' do|name|
  @name = name
  haml :hello
end

# This method shows you how to inject
# local variables
get '/goodbye/:name' do|name|
  haml :goodbye, :locals => { :name => name }
end

get '/who', :agent => /MSIE/ do
  builder :who
end

get '/who' do
  haml :whoelse
end

get '/env' do
	haml :env
end


#Snippets stuff below

# new
get '/snip' do
  haml :new
end

# create
post '/snip' do
  @snippet = Snippet.new(:body => params[:snippet_body])
  if @snippet.save
    redirect "/snip/#{@snippet.id}"
  else
    redirect '/snip'
  end
end

# show
get '/snip/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    haml :show
  else
    redirect '/snip'
  end
end

__END__
@@ hello
%h1= "Hello #{@name}!"

@@ goodbye
%h1= "Goodbye #{name}!"

@@env
%h2 Some environmental settings
%ul
  %li= "Environment: #{options.environment}"
  %li= "PWD: #{Dir.pwd}"
  %li= "Root: #{options.root}"

@@who
builder do |xml|
	xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
	xml.node do
		xml.subnode "Seriously? Internet Explorer? Install a real browser and come back."
	end
end

@@whoelse
%h2 You seem to be using something other than IE to browse the web... Congratulations!

@@new
.snippet
  %form(action="/snip" method="POST")
    %textarea(name="snippet_body" id="snippet_body" rows="20")
    %br
    %input(type="submit" value="Save")

@@show
= @snippet.formatted_body
.sdate
	Created on 
	= @snippet.created_at.strftime("%B %d, %Y at %I:%M %p")
%br/
%a(href="/snip")
	New Paste!
