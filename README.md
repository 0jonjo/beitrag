# BEITRAG

It is an application for study purposes that allows users to: create and rate blog posts, and list posts by best rating and users by IP address. The German word 'Beitrag', meaning 'contribution', 'post', or 'article', captures the essence of the application.

Beitrag is built using Ruby on Rails and Postgres. It follows a Test-Driven Development (TDD) and Continuous Integration/Continuous Deployment (CI/CD) approach using GitHub Actions

## Installation

Clone the repository:

```shell
git clone git@github.com:0jonjo/beitrag.git
cd beitrag
```

Install dependencies:

```shell
bundle install
```

To development and tests, set username and password in `database.yml` as 'postgres'. After, start the database in container running:

```shell
docker run -d --name postgres-beitrag -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -p 5432:5432 postgres:latest
```

Create, migrate, and seed the database:

```shell
rails db:prepare
```

Serve the application:

```shell
rails server
```

Run tests:

```shell
rspec
```

To test a massive population of the database, run:

```shell
bash script/populate_db.sh
```
