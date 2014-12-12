require "spec_helper"

describe "YandexMoney config" do
  after :all do
    YandexMoney.reset_config
  end

  let(:default_money_url) { "https://money.yandex.ru" }
  let(:default_sp_money_url) { "https://sp-money.yandex.ru" }

  it "should have methods: config, configure, reset_config" do
    yandex = class_double("YandexMoney")
    expect(yandex).to receive_messages([:config, :configure, :reset_config])
    yandex.config & yandex.configure & yandex.reset_config
  end

  it "should yield block in configure" do
    expect {|b| YandexMoney.configure(&b)}.to yield_control
  end

  it "should return a YandexMoney::Config instance" do
    expect(YandexMoney.config).to be_a_kind_of(YandexMoney::Config)
  end

  it "should reset_config" do
    YandexMoney.configure { |c| c.money_url = "http://example1.com" }
    YandexMoney.reset_config
    expect(YandexMoney.config.money_url).to eq(default_money_url)
  end

  it "should have correct defaults" do
    expect(YandexMoney.config.money_url).to eq(default_money_url)
    expect(YandexMoney.config.sp_money_url).to eq(default_sp_money_url)
  end

  it "can write config url directly" do
    YandexMoney.config.money_url = "http://example3.com"
    expect(YandexMoney.config.money_url).to eq "http://example3.com"
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
