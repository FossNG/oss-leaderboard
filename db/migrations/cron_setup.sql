-- Explore implementing this using pg_timetable
CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE FUNCTION run_all_tasks()
RETURNS void AS $$
BEGIN
    -- Run each function in sequence
    PERFORM get_projects();
    PERFORM get_gh_stars();
    PERFORM link_contributors();
    PERFORM score_users();
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('run_all_tasks', '0 * * * *', $$SELECT run_all_tasks();$$);
