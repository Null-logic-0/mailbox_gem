require "securerandom"

module MailboxGem
  # Wraps a Mail::Message captured off the delivery path.
  #
  # We wrap rather than expose Mail::Message directly so the controller/views
  # depend on a small, stable interface instead of the mail gem's API -
  # html_part/text_part branching on multipart? lives here, once, not in ERB.
  class Message
    attr_reader :id, :captured_at, :mail

    def initialize(mail)
      @id = SecureRandom.uuid
      # Time.now, not Time.current: Time.current follows the host app's
      # Time.zone (UTC by default in Rails), which has nothing to do with
      # what a developer watching their own dev server actually wants here -
      # their own machine's clock. Time.now always reads the OS's local zone.
      @captured_at = Time.now
      @mail = mail
    end

    def subject
      mail.subject
    end

    def from
      Array(mail.from).join(", ")
    end

    def to
      Array(mail.to).join(", ")
    end

    def cc
      Array(mail.cc).join(", ")
    end

    def bcc
      Array(mail.bcc).join(", ")
    end

    def html_body
      if mail.multipart?
        mail.html_part&.decoded
      elsif mail.mime_type == "text/html"
        mail.body.decoded
      end
    end

    def text_body
      if mail.multipart?
        mail.text_part&.decoded
      elsif mail.mime_type.nil? || mail.mime_type == "text/plain"
        mail.body.decoded
      end
    end

    def attachments
      mail.attachments
    end

    def source
      mail.to_s
    end

    # Plain substring match, not a query language - the fields searched are
    # exactly the ones shown in the index table, so results stay predictable.
    def matches?(query)
      return true if query.blank?

      [ subject, from, to ].any? { |field| field.to_s.downcase.include?(query.downcase) }
    end
  end
end
