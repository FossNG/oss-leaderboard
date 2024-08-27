# FOSS.NG
This readme has the broad idea about the project and key targets that it needs to accomplish

## Brief Description
This project is going to be a leaderboard for open-source contributions of UC students.

## Targets
1. A student can sign up 
2. The program scrapes their OSS contributions and scores, ranks them
3. Everyone can view the leaderboard with top contributors and their contributions
4. Everyone can also see the projects that they contributed to.

## Other considerations
1. The score assigned to each contribution should be factor in the popularity, usefulness of the project. It should use indicators like stars, fork, # of contributors etc.

## User journey
1. Student sign up using github and their UC email id - triggers an event to scrape their contributions and give them a score
2. Student can view the leaderboard and their contributions
3. They can also view the projects that other students contributed to

## Technical specifications
1. Use Postgres ( Tembo ) as backend database
2. Use django as backend and react as frontend
3. Domain - TBD
4. ˙
