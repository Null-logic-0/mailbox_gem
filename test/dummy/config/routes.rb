Rails.application.routes.draw do
  mount MailboxGem::Engine => "/mailbox"

  # Manual verification only, not part of the gem's public surface.
  get "/send_test_mail", to: proc { |env|
    name = Rack::Request.new(env).params["name"] || "Lisa"
    UserMailer.welcome(name).deliver_now
    [ 200, {}, [ "sent #{name}" ] ]
  }
end
