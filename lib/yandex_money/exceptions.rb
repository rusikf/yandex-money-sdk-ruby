module YandexMoney
  class Error < StandardError; end

  class InsufficientScopeError < Error; end

  class UnauthorizedError < Error
    def initialize(error)
      @err = error
    end

    def message
      @err
    end
  end

  class FieldNotSetError < Error
    def initialize(field)
      @field = field
    end

    def message
      "Field '#{@field}' not set!"
    end
  end

  class ApiError < Error
    def initialize(msg)
      @msg = msg
    end

    def message
      @msg.gsub(/_/, " ").capitalize
    end
  end

  class AcceptTransferError < ApiError
    def initialize(msg, attemps = nil)
      @msg = msg
      @attemps = attemps
    end

    def message
      if @attemps
        super + ", attemps available: #{@attemps}"
      else
        super
      end
    end
  end

  class ExternalPaymentProgressError < ApiError
    def initialize(msg, next_retry)
      @msg = msg
      @next_retry = next_retry
    end

    def message
      super + ", next_retry: #{@next_retry}"
    end
  end
end
