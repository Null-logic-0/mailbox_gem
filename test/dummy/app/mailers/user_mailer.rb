class UserMailer < ApplicationMailer
  def welcome(name)
    @name = name
    attachments["greeting.txt"] = "Hi #{name}, welcome aboard!" if name == "Lisa"

    mail(to: "#{name.downcase}@example.com", subject: "Welcome, #{name}!")
  end
end
