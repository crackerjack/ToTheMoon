require 'rubygems'
require 'sinatra'
require 'haml'
require 'builder'

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
  builder :who
end

get '/who' do
  haml :whoelse
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

@@who
builder do |xml|
	xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
	xml.node do
		xml.subnode "Seriously? Internet Explorer 7? Upgrade and come back."
	end
end

@@whoelse
%h2 You seem to be using something other than IE7 to browse the web...