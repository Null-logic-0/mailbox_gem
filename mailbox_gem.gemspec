require_relative "lib/mailbox_gem/version"

Gem::Specification.new do |spec|
  spec.name        = "mailbox_gem"
  spec.version     = MailboxGem::VERSION
  spec.authors     = [ "Luka Tchelidze" ]
  spec.email       = [ "lukachelidze3008@gmail.com" ]
  spec.homepage    = "https://github.com/Null-logic-0/mailbox_gem"
  spec.summary     = "A development-only email inbox for Rails, inspired by Phoenix's /dev/mailbox."
  spec.description = "Captures mail your app actually sends in development - through its real " \
                      "Action Mailer delivery path, not a hand-written preview - and shows it in " \
                      "a live, searchable inbox in the browser."
  spec.license     = "MIT"

  # Matches Rails 8.x's own floor (Rails 8.1.3 declares required_ruby_version
  # ">= 3.2.0") rather than pinning to whatever Ruby happens to be installed
  # here - Ruby 4.0 satisfies this with room to spare, and there's nothing
  # Ruby-4-specific in this codebase that would justify a narrower floor.
  spec.required_ruby_version = ">= 3.2"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Null-logic-0/mailbox_gem"
  spec.metadata["changelog_uri"] = "https://github.com/Null-logic-0/mailbox_gem/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/lukatchelidze/mailbox_gem/issues"
  spec.metadata["rubygems_mfa_required"] = "true"


  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.require_paths = [ "lib" ]


  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "stimulus-rails"
end
