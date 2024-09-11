create table users (
    github_id varchar primary key,
    score int,
    email varchar not null,
    created_at timestamp,
    updated_at timestamp default NOW(),
);

create table projects (
    project_url varchar primary key,
);

create table gh_stars (
    project_id serial,
    url varchar,
    created_at timestamp,
    updated_at timestamp,
    total_commits int,
    total_contributors int,
    gh_stars int,
    gh_stars_last_updated timestamp,
);

create table contributors (
    github_id varchar
    project_url varchar
    foreign key github_id references users github_id
    foreign key project_url references projects project_url
);