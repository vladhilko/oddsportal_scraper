# OddsportalScraper

Ruby gem for reading football countries, leagues, seasons, and matches from
[OddsPortal](https://www.oddsportal.com/).

The upgrade branch uses Ruby 4.0.6, Kimurai 2.2, and the newest Wombat
release compatible with Kimurai (3.0.0). Wombat 3.2 requires a newer
Mechanize major than Kimurai 2.2 currently permits.

## Preparation

For macOS browser-based match tests, install ChromeDriver:

```rb
brew install chromedriver
```

The non-browser specs use VCR fixtures and do not require ChromeDriver. The
default test task intentionally excludes live browser specs because OddsPortal
can change historical bookmaker availability.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add oddsportal_scraper

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install oddsportal_scraper

For local development from this repository:

```bash
bundle install
bundle exec rspec spec --tag ~@with_chromedriver
bundle exec rubocop
```

Run the live Chrome/Kimurai integration specs separately:

```bash
bundle exec rake browser_spec
```

Run the full default task with:

```bash
bundle exec rake
```

## Usage

Based on `wombat` gem https://github.com/felipecsl/wombat and `kimurai` gem.

```rb
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
