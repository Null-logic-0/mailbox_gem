require "test_helper"

module MailboxGem
  class StoreTest < ActiveSupport::TestCase
    def build_mail(subject: "Test")
      Mail.new do
        from    "sender@example.com"
        to      "recipient@example.com"
        subject subject
        body    "Hello"
      end
    end

    test "add wraps the mail and returns a Message" do
      message = Store.add(build_mail)

      assert_instance_of Message, message
      assert_equal 1, Store.all.size
    end

    test "all returns newest first" do
      first = Store.add(build_mail(subject: "First"))
      second = Store.add(build_mail(subject: "Second"))

      assert_equal [ second, first ], Store.all
    end

    test "all returns a snapshot, not the live internal array" do
      Store.add(build_mail)
      snapshot = Store.all
      snapshot.clear

      assert_equal 1, Store.all.size
    end

    test "find looks up by id" do
      message = Store.add(build_mail)

      assert_equal message, Store.find(message.id)
      assert_nil Store.find("nonexistent")
    end

    test "clear empties the store" do
      Store.add(build_mail)
      Store.clear

      assert_empty Store.all
    end

    test "drops the oldest messages once max_messages is exceeded" do
      original_max = MailboxGem.max_messages
      MailboxGem.max_messages = 2

      first = Store.add(build_mail(subject: "First"))
      Store.add(build_mail(subject: "Second"))
      third = Store.add(build_mail(subject: "Third"))

      assert_equal third.id, Store.all.first.id
      assert_equal 2, Store.all.size
      assert_not_includes Store.all.map(&:id), first.id
    ensure
      MailboxGem.max_messages = original_max
    end

    test "add is safe under concurrent access" do
      threads = 20.times.map do |i|
        Thread.new { Store.add(build_mail(subject: "Concurrent #{i}")) }
      end
      threads.each(&:join)

      assert_equal 20, Store.all.size
    end
  end
end
