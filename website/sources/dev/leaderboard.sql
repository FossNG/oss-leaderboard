SELECT
    github_id,
    '/user/' || github_id AS user_link,
    score
FROM users
ORDER BY score DESC
