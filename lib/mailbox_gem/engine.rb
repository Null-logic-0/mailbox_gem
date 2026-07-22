module MailboxGem
  class Engine < ::Rails::Engine
    isolate_namespace MailboxGem

    # ActiveSupport.on_load(:action_mailer) defers this until ActionMailer::Base
    # is actually loaded, instead of referencing the constant at boot (which
    # would force-load Action Mailer early and break eager_load ordering).
    # This is the same hook premailer-rails and other mailer-extending gems use.
    initializer "mailbox_gem.delivery_method" do
      ActiveSupport.on_load(:action_mailer) do
        add_delivery_method :mailbox_gem, MailboxGem::DeliveryMethod
      end
    end
  end
end
