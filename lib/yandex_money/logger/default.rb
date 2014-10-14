require "logger"

module YandexMoney
  module Logger
    class Default < ::Logger
      # if token exists, then extract first 8 symbols
      # and last 8 symbols, and join it with ".."
      def mask_token(token)
        if token
          token.match(/\A(.?{8}).*?(.?{8})\z/)[1,2].join("..")
        else
          nil
        end
      end
    end
  end
end
