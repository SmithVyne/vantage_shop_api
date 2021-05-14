Rails.application.routes.draw do
  post '/' => 'responses#create'
end
