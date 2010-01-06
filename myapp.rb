require 'rubygems'
require 'sinatra'
require 'haml'

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

get '/who', :agent => /MSIE 7/ do
  "Seriously? Internet Explorer 7? Upgrade and come back."
end

get '/env' do
	haml :env
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
