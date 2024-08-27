# FOSS.NG
This readme has the broad idea about the project, technical specifications and targets that it needs to accomplish.

## Brief Description
This project is going to be a leaderboard for open-source contributions of UC students. The primary goal is to encourage students to make open-source contributions.

## Key Features
1. **Sign-up:** A student can sign up using their Github Account and UC email
2. **Scoring and Ranking:** Every day at midnight, the program scrapes their OSS contributions and scores, ranks them
3. **Leaderboard:** Everyone can view the leaderboard with top contributors and their contributions
4. **User Profile:** A page with detailed information on the contributor, the projects they contributed to, proficient languages, interests etc.

## Other considerations
1. **Scoring Algorithm:** The score assigned to each contribution should be factor in the popularity, usefulness of the project. It should use indicators like stars, fork, # of contributors, age of commit, issues, PR reviews etc.

## Technical specifications
1. **Database:** Postgres ( [Tembo](https://tembo.io/) ) 
2. **Backend & Frontend:**  Django and React. Here is the [django-react-boilerplate](https://github.com/vintasoftware/django-react-boilerplate) template we can use as a starting point
3. **Domain:** TBD
4. **Hosting and Deployment:** TBD. Potential options [Heroku](https://www.heroku.com/), [Modal](https://modal.com/)

## Schema Overview
- Users: These will be the UC students and contributors we will be tracking. Stores information like their email, github username, major, year, score
- Projects: Projects that students contributed to. This should be automatically scraped. It stores information like stars, contributors, forks etc
- Contributions: Links the users to project commits
- Leaderboard history: Optional. 

## Future Enhancements
1. Track contributions across other VCS, research publications etc.
2. Expand to other universities
3. Screener for employers to find the student who is the right fit for the role