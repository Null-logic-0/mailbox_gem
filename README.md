# MailboxGem

A development-only email inbox for Rails, inspired by [Phoenix's `/dev/mailbox`](https://hexdocs.pm/swoosh/Swoosh.Adapters.Local.html). Point `ActionMailer` at it in development and every email your app actually sends — through its real mailer code paths, not a hand-written preview — shows up in a live, searchable inbox in your browser.

MailboxGem is a standalone engine. It doesn't modify Rails or Action Mailer; it registers itself as one more delivery method, the same extension point `letter_opener` and `mailcatcher` use.

## Why

Rails already has two ways to look at outgoing mail in development, and both have a gap:

- **`ActionMailer::Preview`** (`/rails/mailers`) renders a mailer against data you construct by hand in a preview class. It never touches your real application code path, so it can drift from what actually gets sent.
- **`ActionMailer::Base.deliveries`** only accumulates anything when `delivery_method` is `:test`, which is what the `test` environment uses — not `development`. In development there's normally nowhere to look at all.

MailboxGem fills that gap: it captures the real `Mail::Message` your app hands to Action Mailer when a user actually triggers an email (signs up, resets a password, checks out), and gives you a live UI to inspect it — HTML, plain text, and raw source, with attachments.

## Features

- **Captures real mail**, not previews — anything delivered through Action Mailer while `mailbox_gem` is the active delivery method.
- **Live-updating inbox** — the message list polls in the background and updates without a page reload.
- **Search-as-you-type** — filters by from/to/subject with no page reload and no query language, debounced so it doesn't hammer the server.
- **HTML / Text / Source tabs** per message, with attachments listed and sized. HTML is rendered in a sandboxed `iframe` — captured mail is untrusted content and never executes scripts against your app's page.
- **Zero-config storage** — in-memory only, no database, no migration to install.

## Requirements

- Ruby >= 3.2
- Rails >= 8.0

## Installation

Add it to your `development` group — this is a dev tool and has no reason to load in `production` or `test`:

```ruby
group :development do
  gem "mailbox_gem"
end
```

```bash
bundle install
```

## Setup

**1. Mount the engine**, guarded to development, wherever you'd like it served from:

```ruby
# config/routes.rb
mount MailboxGem::Engine => "/mailbox" if Rails.env.development?
```

**2. Point Action Mailer at it:**

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :mailbox_gem
```

**3. Visit `/mailbox`** and send some mail from your app. It'll show up without you doing anything else.

Both steps are opt-in on purpose. Mounting is a normal route in your own `config/routes.rb`, and the delivery method only takes effect if you assign it — installing the gem never silently changes how your app already handles mail in development (e.g. if you're already using `letter_opener` or a local SMTP catcher).

## Configuration

MailboxGem keeps the most recent messages and drops older ones once that limit is exceeded:

```ruby
# config/initializers/mailbox_gem.rb
MailboxGem.max_messages = 500 # defaults to 200
```

## Known limitations

- **In-memory only.** The mailbox is wiped on every server restart. This is deliberate — the same tradeoff `ActionMailer::Base.deliveries` makes — not a bug.
- **Single Puma worker only.** Storage is a plain in-process buffer. If your app runs Puma in cluster mode (`WEB_CONCURRENCY > 1`), each worker process gets its own independent mailbox, and the UI will only show whatever mail happened to land on whichever worker served that request. This is fine under Puma's default (`WEB_CONCURRENCY` unset, i.e. one worker); it's a real gap if you deliberately run multiple workers in development.

## Development

```bash
bundle install # installs dependencies for the gem and its dummy test app
bin/rails test # runs the test suite against the dummy app
bin/rubocop    # lints
```

The dummy Rails app used for manual testing lives under `test/dummy`.

### Testing against multiple Rails versions

`mailbox_gem.gemspec` declares `"rails", ">= 8.0"`. CI backs that claim by running the suite against each supported minor via [Appraisal](https://github.com/thoughtbot/appraisal) - see `Appraisals` and the generated `gemfiles/*.gemfile`:

```bash
BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bin/rails test
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bin/rails test
```

After changing `Appraisals` or the gemspec's dependencies, regenerate and commit the gemfiles:

```bash
bundle exec appraisal generate
```

## Contributing

Bug reports and pull requests are welcome. This gem is meant to stay small and dependency-light — before adding a new capability, it's worth asking whether it fits a zero-config, drop-in dev tool, or belongs as configuration a host app opts into instead.

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
