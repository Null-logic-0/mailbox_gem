# Generates gemfiles/*.gemfile (+ matching .lock files) - one per Rails
# version we claim support for in mailbox_gem.gemspec ("rails", ">= 8.0").
# Regenerate after changing this file or the gemspec's dependencies - `install`
# rather than `generate`, so the committed .lock files are re-resolved too
# (CI installs in frozen mode and fails on a stale lockfile):
#
#   bundle exec appraisal install
#
# Version bumps go through bin/bump, which re-locks these as well.

appraise "rails-8.0" do
  gem "rails", "~> 8.0.0"
end

appraise "rails-8.1" do
  gem "rails", "~> 8.1.0"
end
