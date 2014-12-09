module YandexMoney
  # Payments without auth
  class ExternalPayment
    def initialize(instance_id)
      @instance_id = instance_id
    end

    def self.get_instance_id(client_id)
      request = send_external_payment_request("/api/instance-id", client_id: client_id)
      RecursiveOpenStruct.new request.parsed_response
    end

    def request_external_payment(payment_options)
      payment_options[:instance_id] = @instance_id
      request = self.class.send_external_payment_request("/api/request-external-payment", payment_options)
      RecursiveOpenStruct.new request.parsed_response
    end

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
