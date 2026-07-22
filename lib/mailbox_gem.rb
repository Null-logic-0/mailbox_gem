require "active_support/core_ext/module/attribute_accessors"

# Bundler.require only requires gems listed directly in the host app's
# Gemfile, not our own gemspec's runtime dependencies - so stimulus-rails'
# Stimulus::Engine would never be defined, and Rails would never load its
# vendored stimulus.min.js asset, unless we require it ourselves here.
require "stimulus-rails"

require "mailbox_gem/version"
require "mailbox_gem/message"
require "mailbox_gem/store"
require "mailbox_gem/delivery_method"
require "mailbox_gem/engine"

module MailboxGem
  # Maximum number of captured messages to retain. Oldest are dropped once
  # this is exceeded - see Store#add. Override in an initializer:
  #   MailboxGem.max_messages = 500
  mattr_accessor :max_messages, default: 200
end
