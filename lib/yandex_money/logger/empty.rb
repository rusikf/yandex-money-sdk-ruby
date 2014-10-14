require "logger"

module YandexMoney
  module Logger
    class Empty < Default
      def info(text)
      end
    end
  end
end
