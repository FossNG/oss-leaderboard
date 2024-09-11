INSERT INTO projects (project_url, created_at, updated_at)
VALUES 
('https://github.com/tembo-io/prometheus_fdw', NOW(), NOW()),
('https://github.com/tembo-io/clerk_fdw', NOW(), NOW()),
('https://github.com/tembo-io/orb_fdw', NOW(), NOW());

INSERT INTO gh_stars (project_url, created_at, updated_at, total_commits, total_contributors, gh_stars, gh_stars_last_updated)
VALUES 
('https://github.com/tembo-io/prometheus_fdw', NOW(), NOW(), 0, 0, 0, NOW()),
('https://github.com/tembo-io/clerk_fdw', NOW(), NOW(), 0, 0, 0, NOW()),
('https://github.com/tembo-io/orb_fdw', NOW(), NOW(), 0, 0, 0, NOW());

INSERT INTO users (github_id, score, email, created_at, updated_at)
VALUES
('Jayko001', 0, 'kotharjy@mail.uc.edu', NOW(), NOW()),
('ryw', 0, 'ry@tembo.io', NOW(), NOW());
