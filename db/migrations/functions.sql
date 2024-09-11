CREATE EXTENSION plpython3u;


-- this function will read from the projects table and update the 
-- gh_stars table with the stars information
CREATE OR REPLACE FUNCTION get_gh_stars()
RETURNS VOID AS $$
    import requests
    from datetime import datetime

    # Database connection via plpythonu
    plpy.execute("SELECT project_url FROM projects WHERE project_url LIKE 'https://github.com/%'")
    result = plpy.execute("SELECT project_url FROM projects WHERE project_url LIKE 'https://github.com/%'")

    for row in result:
        project_url = row['project_url']
        api_url = project_url.replace("github.com", "api.github.com/repos")
        # Adding authentication via environment variables (you can use your GitHub credentials or token)
        client_id = "Jayko001"
        # THIS NEEDS TO BE UPDATED
        client_secret = "" 
        
        if client_id and client_secret:
            api_url += f"?client_id={client_id}&client_secret={client_secret}"

        # Fetching data from GitHub API
        response = requests.get(api_url)
        
        if response.status_code == 200:
            data = response.json()
            
            if 'stargazers_count' in data:
                stars_count = data['stargazers_count']
                # Update the gh_stars table with the fetched stars count
                update_query = f"""
                UPDATE gh_stars
                SET gh_stars = {stars_count}, gh_stars_last_updated = NOW()
                WHERE project_url = '{project_url}'
                """
                plpy.execute(update_query)
            else:
                plpy.notice(f"Stargazers count not found for {project_url}")
        else:
            plpy.notice(f"Failed to fetch data from {api_url} with status code {response.status_code}")
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
        
        # Update the user's score in the users table
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
