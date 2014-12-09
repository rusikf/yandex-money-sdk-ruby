module YandexMoney
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end

  def self.reset_config
    @config = Config.new
  end

  class Config
    attr_accessor :money_url, :sp_money_url

    def initialize
      @money_url = "https://money.yandex.ru"
      @sp_money_url = "https://sp-money.yandex.ru"
    end
  end
end
