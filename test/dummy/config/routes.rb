Rails.application.routes.draw do
  mount MailboxGem::Engine => "/mailbox_gem"
end
