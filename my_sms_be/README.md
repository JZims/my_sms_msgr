# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* MongoDB is used for data storage via the mongoid gem.
* The database name for development is `my_sms_dev`.
* The backend service expects a `MONGODB_URI` environment variable (see docker-compose.yml).
* The mongoid configuration is in `config/mongoid.yml`.
* The Dockerfile ensures this config is present in the container.
