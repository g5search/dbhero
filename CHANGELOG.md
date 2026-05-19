# CHANGELOG

## 2.0.0

  - **BREAKING**: Removed Google Drive export feature and `google_drive` gem dependency. The `drive` action, `google_client` helper, `:google_api_id` and `:google_api_secret` config keys, and the `Dbhero::GdriveExporter` class are all gone. This unblocks Faraday 2.x compatibility, since `google_drive` transitively required `google-api-client 0.7.x` which hardcoded the removed `faraday/request/multipart` path.
  - **BREAKING**: Minimum Rails bumped from `>= 4.1` to `>= 7.2`.
  - **BREAKING**: Minimum Ruby set to `>= 3.4`.
  - Dropped `codeclimate-test-reporter` (abandoned project).
  - Migrated test stack from `factory_girl_rails` to `factory_bot_rails` and bumped `rspec-rails` from `~> 3.0` to `~> 7.0`.
  - Modernized `spec/dummy` Rails application for Rails 7.2+ defaults.

## 1.3.0

  - Rails 5 Upgrade updates:
    - Use strong parameters for one_time_query params usage
    - Use `text/cvs` instead of `Mime::Type` for CSV send_data type

## 1.2.0.alpha

  - Modified default csv export filename
  - Added class methods for Integrations Overview and Uber reports
  - Adding **Home** link to navigation menu
  - Adding **Docs** link to navigation menu
  - Adding **Change logs** link to navigation menu
  - Removing Admin and Clients from navigation menu