-- this function will read from the projects table and update the 
-- gh_stars table with the stars information
create function get_gh_stars()


-- this function will get the list of projects from the text file in the repo
create function get_projects()


-- this function uses the contributors table to assign a score to each user
-- as v1, we will simply sum the stars of the repo they contributed to
create function score_users()