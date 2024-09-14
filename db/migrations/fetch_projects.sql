CREATE OR REPLACE FUNCTION get_projects()
RETURNS VOID AS $$
    import requests
    
    # URL for the raw file in the GitHub repo
    repo_url = "https://raw.githubusercontent.com/FossNG/oss-leaderboard/main/projects.txt"
    
    # Fetch the content of the file
    response = requests.get(repo_url)
    
    if response.status_code == 200:
        # Get the text content
        content = response.text
        
        # Split the content by new lines to get individual project URLs
        project_urls = content.splitlines()
        
        for project_url in project_urls:
            # Insert into the projects table if it doesn't already exist
            insert_query = f"""
            INSERT INTO projects (project_url, created_at, updated_at)
            VALUES ('{project_url}', NOW(), NOW())
            ON CONFLICT (project_url) DO NOTHING
            """
            plpy.execute(insert_query)
    else:
        plpy.notice(f"Failed to fetch the project file from {repo_url}. Status code: {response.status_code}")
$$ LANGUAGE plpython3u;
