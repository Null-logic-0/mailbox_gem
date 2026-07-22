MailboxGem::Engine.routes.draw do
  root to: "messages#index"

  resources :messages, only: [ :index, :show ] do
    collection do
      get :table
    end
  end
  delete "messages", to: "messages#clear", as: :clear_messages
end
