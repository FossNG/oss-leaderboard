CREATE EXTENSION plpython3u;


-- this function will read from the projects table and update the 
-- gh_stars table with the stars information
CREATE OR REPLACE FUNCTION get_gh_stars()
RETURNS VOID AS $$
    import requests
    from datetime import datetime
    from urllib.parse import urlparse
    import os

    # Securely fetch GitHub credentials from environment variables
    GITHUB_TOKEN = "" # Add token here 

    headers = {}
    if GITHUB_TOKEN:
        headers['Authorization'] = f'token {GITHUB_TOKEN}'
    else:
        plpy.notice("GITHUB_TOKEN is not set. Proceeding with unauthenticated requests, which may be rate limited.")

    # Fetch all GitHub project URLs from the projects table
    result = plpy.execute("SELECT project_url FROM projects WHERE project_url LIKE 'https://github.com/%'")

    for row in result:
        project_url = row['project_url']
        
        # Parse the URL to extract owner and repo
        try:
            parsed_url = urlparse(project_url)
            path_parts = parsed_url.path.strip('/').split('/')
            if len(path_parts) >= 2:
                owner, repo = path_parts[0], path_parts[1]
            else:
                plpy.notice(f"Invalid project URL format: {project_url}")
                continue
        except Exception as e:
            plpy.notice(f"Error parsing URL {project_url}: {e}")
            continue

        base_api_url = f"https://api.github.com/repos/{owner}/{repo}"

        # Fetch the general project data (stars, forks, etc.)
        response = requests.get(base_api_url, headers=headers)

        if response.status_code == 200:
            data = response.json()

            # Initialize variables to hold the stats
            stars_count = data.get('stargazers_count', 0)
            total_contributors = 0
            total_commits = 0

            # Fetch total contributors and commits with pagination
            contributors_url = f"{base_api_url}/contributors"
            page = 1
            per_page = 100  # Max per GitHub API

            while True:
                paged_url = f"{contributors_url}?per_page={per_page}&page={page}"
                contributors_response = requests.get(paged_url, headers=headers)

                if contributors_response.status_code == 200:
                    contributors_data = contributors_response.json()

                    if not contributors_data:
                        break  # No more contributors

                    if isinstance(contributors_data, list):
                        total_contributors += len(contributors_data)
                        total_commits += sum(c.get('contributions', 0) for c in contributors_data if isinstance(c, dict))
                    else:
                        plpy.notice(f"Unexpected contributors data format for {project_url}")
                        break
                else:
                    plpy.notice(f"Failed to fetch contributors data for {project_url} with status code {contributors_response.status_code}")
                    break

                page += 1  # Move to next page

            # Update the gh_stars table with the fetched stars, total commits, and contributors count
            upsert_query = f"""
                INSERT INTO gh_stars (project_url, gh_stars, total_contributors, total_commits, gh_stars_last_updated)
                VALUES ('{project_url}', {stars_count}, {total_contributors}, {total_commits}, NOW())
                ON CONFLICT (project_url) DO UPDATE
                SET gh_stars = EXCLUDED.gh_stars,
                    total_contributors = EXCLUDED.total_contributors,
                    total_commits = EXCLUDED.total_commits,
                    gh_stars_last_updated = NOW();
            """
            plpy.execute(upsert_query)
        else:
            plpy.notice(f"Failed to fetch data from {base_api_url} with status code {response.status_code}")
$$ LANGUAGE plpython3u;

-- this function uses the contributors table to assign a score to each user
-- as v1, we will simply sum the stars of the repo they contributed to
CREATE OR REPLACE FUNCTION score_users()
RETURNS VOID AS $$
    # Fetch all users from the contributors table
    users_result = plpy.execute("SELECT DISTINCT github_id FROM contributors")
    
    for user_row in users_result:
        github_id = user_row['github_id']
        
        # Sum the stars from the projects the user has contributed to
        query = f"""
        SELECT COALESCE(SUM(gs.gh_stars), 0) as total_stars
        FROM contributors c
        JOIN gh_stars gs ON c.project_url = gs.project_url
        WHERE c.github_id = '{github_id}'
        """
        result = plpy.execute(query)
        total_stars = result[0]['total_stars']
        
        # Update the users score in the users table
        update_query = f"""
        UPDATE users
        SET score = {total_stars}, updated_at = NOW()
        WHERE github_id = '{github_id}'
        """
        plpy.execute(update_query)

$$ LANGUAGE plpython3u;


-- this function will link the contributors to the projects
CREATE OR REPLACE FUNCTION link_contributors()
RETURNS VOID AS $$
    import requests
    from datetime import datetime

    # Fetch all project URLs from the projects table
    result = plpy.execute("SELECT project_url FROM projects WHERE project_url LIKE 'https://github.com/%'")
    
    for row in result:
        project_url = row['project_url']
        api_url = project_url.replace("github.com", "api.github.com/repos") + "/contributors"
        
        # Adding authentication via environment variables (GitHub credentials)
        client_id = "Jayko001"
        # THIS NEEDS TO BE UPDATED
        client_secret = "" 
        headers = {}

        if client_id and client_secret:
            api_url += f"?client_id={client_id}&client_secret={client_secret}"

        # Fetching contributors from GitHub API
        response = requests.get(api_url, headers=headers)
        
        if response.status_code == 200:
            contributors_data = response.json()
            
            for contributor in contributors_data:
                github_id = contributor['login']
                
                # Check if the user exists in the users table
                existing_user = plpy.execute(f"SELECT 1 FROM users WHERE github_id = '{github_id}'")
                
                if existing_user:
                    # If the user exists, link the contributor to the project in the contributors table
                    insert_contributor_query = f"""
                    INSERT INTO contributors (github_id, project_url)
                    VALUES ('{github_id}', '{project_url}')
                    ON CONFLICT DO NOTHING -- Avoid duplicate entries
                    """
                    plpy.execute(insert_contributor_query)
                else:
                    plpy.notice(f"Skipping user {github_id} as they are not in the users table.")
        else:
            plpy.notice(f"Failed to fetch contributors for {project_url}. Status code: {response.status_code}")
$$ LANGUAGE plpython3u;
