module MailboxGem
  class MessagesController < ApplicationController
    def index
      @query = params[:q].presence
      @messages = filtered_messages
    end

    # Polled by the auto-refresh Stimulus controller - same data as #index,
    # rendered without the surrounding page so it can replace just the table.
    # Takes the same q param so a poll mid-search stays scoped to it instead
    # of silently reverting to the unfiltered list.
    def table
      @query = params[:q].presence
      render partial: "table", locals: { messages: filtered_messages, query: @query }
    end

    def show
      @message = Store.find(params[:id])
      return head :not_found unless @message

      @view = params[:view].presence || (@message.html_body ? "html" : "text")
    end

    def clear
      Store.clear
      redirect_to messages_path
    end

    private

    def filtered_messages
      Store.all
           .select { |message| message.matches?(@query) }
           .sort_by { |message| message.captured_at }
           .reverse
    end
  end
end
