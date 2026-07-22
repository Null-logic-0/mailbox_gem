module MailboxGem
  # In-memory, thread-safe capture buffer.
  #
  # Deliberately not ActiveRecord-backed: this is a dev-only tool, and
  # requiring a migration to install it would violate the "drop the gem in
  # and go" experience we're after. The tradeoff, same one ActionMailer::Base
  # .deliveries makes, is that the mailbox is wiped on process restart -
  # acceptable for a tool whose job is to show you what *this* dev session
  # sent.
  #
  # Puma's default dev config runs multiple threads, and Mail::Message#deliver!
  # can be called concurrently across requests, so writes are Mutex-guarded.
  #
  # This only protects against races between threads in one process. It does
  # NOT work across Puma worker processes (WEB_CONCURRENCY > 1) - each worker
  # forks its own heap, so each gets its own independent Store, and the
  # mailbox UI would silently show only whatever a given worker happened to
  # capture. Unsupported for now: WEB_CONCURRENCY defaults to 1 (no cluster
  # mode) in a standard Rails dev setup, and going cross-process-safe would
  # mean file or DB-backed storage, a real cost for what's meant to stay a
  # zero-config dev tool.
  class Store
    class << self
      def add(mail)
        message = Message.new(mail)

        mutex.synchronize do
          messages.unshift(message)
          messages.pop while messages.size > MailboxGem.max_messages
        end

        message
      end

      def all
        mutex.synchronize { messages.dup }
      end

      def find(id)
        mutex.synchronize { messages.find { |message| message.id == id } }
      end

      def clear
        mutex.synchronize { messages.clear }
      end

      private

      def messages
        @messages ||= []
      end

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
