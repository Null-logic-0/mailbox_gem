require "test_helper"

module MailboxGem
  class MessagesControllerTest < ActionDispatch::IntegrationTest
    test "index shows an empty state with no captured mail" do
      get mailbox_gem.messages_path

      assert_response :success
      assert_select ".empty-state"
    end

    test "index lists captured mail" do
      Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.messages_path

      assert_response :success
      assert_select "td", text: "Welcome, Ada!"
    end

    test "table renders just the fragment, without the surrounding layout" do
      Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.table_messages_path

      assert_response :success
      assert_select "table.messages"
      # assert_select always parses through a full-document parser, which
      # wraps any fragment in an implicit <html><body> - so absence of a
      # literal <html> tag isn't something it can check. DOCTYPE only ever
      # appears in the layout, so its absence is what actually proves the
      # layout was skipped.
      assert_not response.body.include?("<!DOCTYPE html>")
    end

    test "show renders a captured message" do
      message = Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.message_path(message.id)

      assert_response :success
      assert_select "h1", text: "Welcome, Ada!"
    end

    test "show defaults to the html tab when an html body is present" do
      message = Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.message_path(message.id)

      assert_select "iframe.body-frame"
    end

    test "show respects the view param" do
      message = Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.message_path(message.id), params: { view: "text" }

      assert_select "pre.body-text"
      assert_select "iframe", false
    end

    test "show returns 404 for an unknown id" do
      get mailbox_gem.message_path("nonexistent")

      assert_response :not_found
    end

    test "index filters by q" do
      Store.add(UserMailer.welcome("Ada").message)
      Store.add(UserMailer.welcome("Grace").message)

      get mailbox_gem.messages_path, params: { q: "Ada" }

      assert_select "td", text: "Welcome, Ada!"
      assert_select "td", text: "Welcome, Grace!", count: 0
    end

    test "index shows a search-specific empty state when q matches nothing" do
      Store.add(UserMailer.welcome("Ada").message)

      get mailbox_gem.messages_path, params: { q: "nonexistent" }

      assert_select ".empty-state", text: /No mail matches/
    end

    test "table respects q so a poll mid-search stays scoped to it" do
      Store.add(UserMailer.welcome("Ada").message)
      Store.add(UserMailer.welcome("Grace").message)

      get mailbox_gem.table_messages_path, params: { q: "Grace" }

      assert_select "td", text: "Welcome, Grace!"
      assert_select "td", text: "Welcome, Ada!", count: 0
    end

    test "clear empties the store and redirects to index" do
      Store.add(UserMailer.welcome("Ada").message)

      delete mailbox_gem.clear_messages_path

      assert_redirected_to mailbox_gem.messages_path
      assert_empty Store.all
    end
  end
end
