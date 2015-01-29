module YandexMoney
  # Payments without auth
  class ExternalPayment
    def initialize(instance_id)
      @instance_id = instance_id
    end

    # Registers instance of application
    #
    # - {http://api.yandex.com/money/doc/dg/reference/instance-id.xml}
    # - {https://tech.yandex.ru/money/doc/dg/reference/instance-id-docpage/}
    #
    # @param client_id [String] An identifier of application
    # @return [RecursiveOpenStruct] A status of operation
    def self.get_instance_id(client_id)
      request = send_external_payment_request("/api/instance-id", client_id: client_id)
      RecursiveOpenStruct.new request.parsed_response
    end

    # Requests a external payment
    #
    # - {http://api.yandex.com/money/doc/dg/reference/request-external-payment.xml}
    # - {https://tech.yandex.ru/money/doc/dg/reference/request-external-payment-docpage/}
    #
    # @param payment_options [Hash] Method's parameters. Check out docs for more information.
    # @return [RecursiveOpenStruct] A struct, containing `payment_id` and additional information about a recipient and payer
    def request_external_payment(payment_options)
      payment_options[:instance_id] = @instance_id
      request = self.class.send_external_payment_request("/api/request-external-payment", payment_options)
      RecursiveOpenStruct.new request.parsed_response
    end

    # Confirms a payment that was created using the request-extenral-payment method
    #
    # - {http://api.yandex.com/money/doc/dg/reference/process-external-payment.xml}
    # - {https://tech.yandex.ru/money/doc/dg/reference/process-external-payment-docpage/}
    #
    # @param payment_options [Hash] Method's parameters. Check out docs for more information.
    # @return [RecursiveOpenStruct] A status of payment and additional steps for authorization (if needed)
    def process_external_payment(payment_options)
      payment_options[:instance_id] = @instance_id
      request = self.class.send_external_payment_request("/api/process-external-payment", payment_options)
      RecursiveOpenStruct.new request.parsed_response
    end

    private

    def self.send_external_payment_request(uri, options)
      request = HTTParty.post(uri, base_uri: YandexMoney.config.money_url, headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options)
      case request.response.code
      when "400" then raise YandexMoney::InvalidRequestError.new request.response
      when "401" then raise YandexMoney::UnauthorizedError.new request.response
      when "403" then raise YandexMoney::InsufficientScopeError request.response
      when "500" then raise YandexMoney::ServerError
      else
        request
      end
    end

  end
end
