# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OddsportalScraper::Scrapers::Seasons do
  describe '.by_sport_and_country_and_league' do
    subject { described_class.by_sport_and_country_and_league(sport_name, country, league) }

    context 'when choosen sport is `soccer`, country is `England` and league is `Premier League`',
            vcr: 'oddsportal/soccer/england/premier-league/seasons' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Premier League' }

      it 'returns all seasons available for this sport, country and league' do
        expect(subject).to contain_exactly(
          '2022/2023',
          '2021/2022',
          '2020/2021',
          '2019/2020',
          '2018/2019',
          '2017/2018',
          '2016/2017',
          '2015/2016',
          '2014/2015',
          '2013/2014',
          '2012/2013',
          '2011/2012',
          '2010/2011',
          '2009/2010',
          '2008/2009',
          '2007/2008',
          '2006/2007',
          '2005/2006',
          '2004/2005',
          '2003/2004',
          '2002/2003',
          '2001/2002',
          '2000/2001',
          '1999/2000',
          '1998/1999'
        )
      end
    end

    context 'when choosen sport is `soccer`, country is `England` and league is `Championship`',
            vcr: 'oddsportal/soccer/england/championship/seasons' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Championship' }

      it 'returns all seasons available for this sport, country and league' do
        expect(subject).to contain_exactly(
          '2022/2023',
          '2021/2022',
          '2020/2021',
          '2019/2020',
          '2018/2019',
          '2017/2018',
          '2016/2017',
          '2015/2016',
          '2014/2015',
          '2013/2014',
          '2012/2013',
          '2011/2012',
          '2010/2011',
          '2009/2010',
          '2008/2009',
          '2007/2008',
          '2006/2007',
          '2005/2006',
          '2004/2005',
          '2003/2004',
          '2002/2003',
          '2001/2002',
          '2000/2001',
          '1999/2000',
          '1998/1999'
        )
      end
    end

    context 'when choosen country is invalid', vcr: 'oddsportal/soccer/england/invalid/seasons' do
      let(:sport_name) { 'soccer' }
      let(:country) { 'England' }
      let(:league) { 'Invalid' }

      it { is_expected.to be_empty }
    end
  end
end
