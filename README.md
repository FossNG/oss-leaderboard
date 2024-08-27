# FOSS.NG
This readme has the broad idea about the project, technical specifications and targets that it needs to accomplish.

## Brief Description
This project is going to be a leaderboard for open-source contributions of UC students. The primary goal is to encourage students to make open-source contributions.

## Key Features
1. **Sign-up:** A student can sign up using their Github Account and UC email
2. **Scoring and Ranking:** Every day at midnight, the program scrapes their OSS contributions and scores, ranks them
3. **Leaderboard:** Everyone can view the leaderboard with top contributors and their contributions
4. **Project Contributions:** Everyone can also see the projects that they contributed to.

## Other considerations
1. The score assigned to each contribution should be factor in the popularity, usefulness of the project. It should use indicators like stars, fork, # of contributors etc.

## Technical specifications
1. **Database:** Postgres ( [Tembo](https://tembo.io/) ) 
2. **Backend & Frontend:**  Django and React. Here is the [django-react-boilerplate](https://github.com/vintasoftware/django-react-boilerplate) template we can use as a starting point
3. **Domain:** TBD
