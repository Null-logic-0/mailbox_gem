require "test_helper"

module MailboxGem
  class MessageTest < ActiveSupport::TestCase
    test "wraps basic headers" do
      mail = Mail.new do
        from    "sender@example.com"
        to      "recipient@example.com"
        cc      "cc@example.com"
        subject "Hello"
        body    "Plain body"
      end

      message = Message.new(mail)

      assert_kind_of String, message.id
      assert_kind_of Time, message.captured_at
      assert_equal "Hello", message.subject
      assert_equal "sender@example.com", message.from
      assert_equal "recipient@example.com", message.to
      assert_equal "cc@example.com", message.cc
      assert_equal "", message.bcc
    end

    test "text_body for a singlepart plain text message" do
      message = Message.new(Mail.new { body "Just text" })

      assert_equal "Just text", message.text_body
      assert_nil message.html_body
    end

    test "html_body for a singlepart html message" do
      mail = Mail.new do
        content_type "text/html; charset=UTF-8"
        body "<p>Hi</p>"
      end

      message = Message.new(mail)

      assert_equal "<p>Hi</p>", message.html_body
      assert_nil message.text_body
    end

    test "html_body and text_body for a multipart message" do
      mail = Mail.new do
        text_part do
          body "Plain version"
        end

        html_part do
          content_type "text/html; charset=UTF-8"
          body "<p>HTML version</p>"
        end
      end

      message = Message.new(mail)

      assert_equal "Plain version", message.text_body
      assert_equal "<p>HTML version</p>", message.html_body
    end

    test "attachments and source expose the underlying mail" do
      mail = Mail.new do
        body "Body"
        add_file filename: "greeting.txt", content: "Hi there"
      end

      message = Message.new(mail)

      assert_equal 1, message.attachments.size
      assert_equal "greeting.txt", message.attachments.first.filename
      assert_includes message.source, "greeting.txt"
    end

    test "matches? is true for a blank query" do
      message = Message.new(Mail.new { subject "Hello" })

      assert message.matches?(nil)
      assert message.matches?("")
    end

    test "matches? checks subject, from, and to, case-insensitively" do
      mail = Mail.new do
        from    "sender@example.com"
        to      "recipient@example.com"
        subject "Welcome aboard"
      end
      message = Message.new(mail)

      assert message.matches?("WELCOME")
      assert message.matches?("sender")
      assert message.matches?("recipient@example.com")
      assert_not message.matches?("nope")
    end
  end
end
