require "test_helper"

module MailboxGem
  class DeliveryMethodTest < ActiveSupport::TestCase
    test "deliver! adds the mail to the Store" do
      mail = Mail.new do
        from    "sender@example.com"
        to      "recipient@example.com"
        subject "Hi"
        body    "Body"
      end

      DeliveryMethod.new({}).deliver!(mail)

      assert_equal 1, Store.all.size
      assert_equal "Hi", Store.all.first.subject
    end

    test "a real mailer message can be delivered through it" do
      mail = UserMailer.welcome("Ada").message

      DeliveryMethod.new({}).deliver!(mail)

      assert_equal "Welcome, Ada!", Store.all.first.subject
    end
  end
end
