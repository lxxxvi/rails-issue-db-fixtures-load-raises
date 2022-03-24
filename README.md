# Rails Issue `db:fixtures:load` raises

This repository contains the minimal setup to reproduce an error that appears in Rails when invoking `db:fixtures:load`.

* https://github.com/rails/rails/pull/44760

## Reproduce error locally

1. Clone this repo
2. Run `bin/setup` (this also creates `other` schema and the two tables)
3. Run `bin/rails db:fixtures:load`

## Error

The error appears in an edgecase with Postgres, when there are objects in another schema (other than `public`) having foreign key constraints.

```
# bin/rails dbconsole
\dt (other|public).*
               List of relations
 Schema |         Name         | Type  | Owner
--------+----------------------+-------+-------
 other  | authors              | table | mario
 other  | books                | table | mario
 public | ar_internal_metadata | table | mario
 public | cats                 | table | mario
 public | schema_migrations    | table | mario
```

Table `other.books` contains a foreign key to `other.authors`.

In that case `bin/rails db:fixtures:load` raises this error:

```
Foreign key violations found in your fixture data. Ensure you aren't referring to labels that don't exist on associations.
```

Under the hood we see this problem:

```
ERROR:  relation "books" does not exist (PG::UndefinedTable)
CONTEXT:  SQL statement "UPDATE pg_constraint SET convalidated=false WHERE conname = 'fk_authors'; ALTER TABLE books VALIDATE CONSTRAINT fk_authors;"
```

As indicated above, the table `books` lives in schema `other` but the schema is not prefixed in the the `ALTER TABLE` statement.

## Meta

* Postgres `14.2`

```
bin/rails about
About your application's environment
Rails version             7.0.2.3
Ruby version              ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [arm64-darwin21]
RubyGems version          3.3.5
Rack version              2.2.3
Middleware                ActionDispatch::HostAuthorization, Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActionDispatch::ServerTiming, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::ActionableExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, ActionDispatch::ContentSecurityPolicy::Middleware, ActionDispatch::PermissionsPolicy::Middleware, Rack::Head, Rack::ConditionalGet, Rack::ETag, Rack::TempfileReaper
Application root          /Users/mario/Projects/lxxxvi/rails-issue-db-fixtures-load-raises
Environment               development
Database adapter          postgresql
Database schema version   20220324064857
```
