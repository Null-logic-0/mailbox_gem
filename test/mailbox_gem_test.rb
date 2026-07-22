require "test_helper"

class MailboxGemTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert MailboxGem::VERSION
  end

  test "max_messages defaults to 200" do
    assert_equal 200, MailboxGem.max_messages
  end

  test "registers itself as an Action Mailer delivery method" do
    assert_equal MailboxGem::DeliveryMethod, ActionMailer::Base.delivery_methods[:mailbox_gem]
  end
end
