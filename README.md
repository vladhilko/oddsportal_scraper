# OddsportalScraper

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/oddsportal_scraper`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oddsportal_scraper.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
