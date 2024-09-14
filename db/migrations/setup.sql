-- Users table stores basic user information
CREATE TABLE users (
    github_id VARCHAR PRIMARY KEY,
    score INT DEFAULT 0, -- Defaulting score to 0 to avoid NULL
    email VARCHAR NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Projects table to store project details
CREATE TABLE projects (
    project_url VARCHAR PRIMARY KEY,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- GitHub Stars table storing stats about projects
CREATE TABLE gh_stars (
    project_id SERIAL PRIMARY KEY,
    project_url VARCHAR UNIQUE REFERENCES projects(project_url) ON DELETE CASCADE, -- Foreign key reference to projects
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    total_commits INT,
    total_contributors INT,
    gh_stars INT,
    gh_stars_last_updated TIMESTAMP DEFAULT NOW()
);

-- Contributors table to track who contributed to what projects
CREATE TABLE contributors (
    github_id VARCHAR,
    project_url VARCHAR,
    FOREIGN KEY (github_id) REFERENCES users(github_id) ON DELETE CASCADE, -- Ensuring that users and projects are properly related
    FOREIGN KEY (project_url) REFERENCES projects(project_url) ON DELETE CASCADE,
    PRIMARY KEY (github_id, project_url)
);
