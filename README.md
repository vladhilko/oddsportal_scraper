# OddsportalScraper

Ruby gem for reading football countries, leagues, seasons, and matches from
[OddsPortal](https://www.oddsportal.com/).

The gem uses Ruby's standard HTTP client and Nokogiri to parse the current
OddsPortal application. The normal path does not require Chrome, Selenium, or
browser automation.

## Preparation

For the optional browser fallback on macOS, install Chrome:

```rb
brew install --cask google-chrome
```

The default specs use local HTML and archive fixtures. The optional browser
specs are kept separate because they require a working Chrome installation and
are subject to live-site changes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add oddsportal_scraper

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install oddsportal_scraper

For local development from this repository:

```bash
bundle install
bundle exec rspec spec --tag ~@browser_fallback
bundle exec rubocop
```

Run the optional browser fallback specs separately:

```bash
ODDSPORTAL_SCRAPER_BROWSER_FALLBACK=1 bundle exec rake browser_spec
```

The browser fallback is only for match imports that cannot be read over HTTP.
Leave `ODDSPORTAL_SCRAPER_BROWSER_FALLBACK` unset for normal tasks; the HTTP
adapter does not launch Chrome.

Run the full default task with:

```bash
bundle exec rake
```

## Usage

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

The `soccer` argument is translated to OddsPortal's current `football` route.
The same API also accepts current basketball and hockey routes.

Historical seasons are read from OddsPortal's archive endpoint. Odds are
returned as strings with two decimal places; a match can contain `nil` odds
when the site does not publish all three outcomes. Applications with required
odds columns should skip those rows at their persistence boundary. If
OddsPortal explicitly reports that a season has no available odds, the
matches API returns `[]`. The adapter retries a fresh season page when an
archive token transiently returns that empty response; this handles occasional
current-season archive responses without enabling a browser.

### Browser fallback

If the HTTP endpoint changes or a site response needs JavaScript rendering, set
the fallback flag explicitly:

```bash
ODDSPORTAL_SCRAPER_BROWSER_FALLBACK=1 bundle exec ruby -Ilib -e \
  "require 'oddsportal_scraper'; p OddsportalScraper.matches(sport: 'soccer', country: 'England', league: 'Premier League', season: '2019/2020')"
```

When the flag is unset, Selenium is never loaded and Chrome is not required.
Transport failures and malformed successful responses raise
`OddsportalScraper::TransportError` or `OddsportalScraper::ProtocolError` so a
scheduled import cannot silently succeed with an empty result.
