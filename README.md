# OddsportalScraper


Site https://www.oddsportal.com/

## Preparation

For Mac users:

```rb
brew install chromedriver
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add oddsportal_scraper

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install oddsportal_scraper

## Usage

Based on `wombat` gem https://github.com/felipecsl/wombat and `kimurai` gem.

```rb
OddsportalScraper.sport_names

# [
#  "Soccer",
#  "Basketball",
#  "Baseball",
#  "Hockey",
#  "Tennis",
#  ...
# ]

OddsportalScraper.countries(sport: 'soccer')

# [
#   "Africa",
#   "Albania",
#   "Andorra",
#   "Argentina",
#   "Armenia",
#   "Australia",
#   "Austria",
#   ...
# ]

OddsportalScraper.leagues(sport: 'soccer', country: 'England')

# [
#   "Premier League",
#   "Championship",
#   "League One",
#   "League Two",
#   "National League",
#   ...
# ]

OddsportalScraper.seasons(sport: 'soccer', country: 'England', league: 'Premier League')

# [
#   "2022/2023",
#   "2021/2022",
#   "2020/2021",
#   "2019/2020",
#   "2018/2019",
#   "2017/2018",
#   ...
# ]

OddsportalScraper.matches(sport: 'soccer', country: 'England', league: 'Premier League', season: '2021/2022')

# [
#   {
#     "match_date": "04 Aug 2020",
#     "match_time": "19:45",
#     "participants": "Brentford - Fulham",
#     "score": "1:2 ET",
#     "odds": {
#       "home_win": "2.13",
#       "draw": "3.16",
#       "away_win": "3.82"
#     }
#   },
#   {
#     "match_date": "30 Jul 2020",
#     "match_time": "19:45",
#     "participants": "Fulham - Cardiff",
#     "score": "1:2",
#     "odds": {
#       "home_win": "2.04",
#       "draw": "3.48",
#       "away_win": "3.70"
#     }
#   },
#   ...
# ]

```
