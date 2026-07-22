module MailboxGem
  # A Mail delivery method, in the same sense that Mail::SMTP or
  # Mail::TestMailer are: something Mail::Message#deliver! can call
  # #deliver!(self) on. Registered with ActionMailer::Base.add_delivery_method
  # so a host app opts in with one config line, exactly like letter_opener or
  # mailcatcher-rails do - not auto-enabled, since silently intercepting a
  # host app's mail delivery without consent would break setups that already
  # capture mail another way.
  #
  # This intentionally does not send anything, the same way Swoosh's local
  # adapter or Mail::TestMailer don't: capturing dev mail should not depend
  # on network access or a running SMTP relay.
  class DeliveryMethod
    def initialize(settings)
      @settings = settings
    end

    def deliver!(mail)
      Store.add(mail)
    end
  end
end
