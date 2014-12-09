require "spec_helper"

describe YandexMoney do
  after :all do
    YandexMoney.reset_config
  end
  it "should has correct defaults" do
    expect(YandexMoney.config.money_url).to eq "https://money.yandex.ru"
    expect(YandexMoney.config.sp_money_url).to eq "https://sp-money.yandex.ru"
  end

  it "should correct configure hosts addresses" do
    YandexMoney.configure do |config|
      config.money_url = "http://example1.com"
      config.sp_money_url = "http://example2.com"
    end
    expect(YandexMoney.config.money_url).to eq "http://example1.com"
    expect(YandexMoney.config.sp_money_url).to eq "http://example2.com"
  end
end
