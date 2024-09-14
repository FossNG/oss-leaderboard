---
title: User Contributions
parameters:
  - github_id
---

# User Contributions: {params.github_id}

Here you can show details about the contributions for **{params.github_id}**.

```sql results
SELECT
    gh_stars.project_url,
    total_commits,
    total_contributors,
    gh_stars
FROM gh_stars
JOIN contributors ON contributors.project_url = gh_stars.project_url
WHERE contributors.github_id = '${params.github_id}'
```

<DataTable data={results} />
