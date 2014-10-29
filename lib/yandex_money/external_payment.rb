module YandexMoney
  # Payments without auth
  class ExternalPayment
    def initialize(instance_id)
      @instance_id = instance_id
    end

    def self.get_instance_id(client_id)
      request = send_external_payment_request("/api/instance-id", client_id: client_id)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      else
        request["instance_id"]
      end
    end

    def request_external_payment(payment_options)
      payment_options[:instance_id] = @instance_id
      request = self.class.send_external_payment_request("/api/request-external-payment", payment_options)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      else
        OpenStruct.new request.parsed_response
      end
    end

    def process_external_payment(payment_options)
      payment_options[:instance_id] = @instance_id
      request = self.class.send_external_payment_request("/api/process-external-payment", payment_options)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      elsif request["status"] == "in_progress"
        raise YandexMoney::ExternalPaymentProgressError.new request["error"], request["next_retry"]
      else
        OpenStruct.new request.parsed_response
      end
    end

    private

    def self.send_external_payment_request(uri, options)
      request = HTTParty.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options)
      case request.response.code
      when "403" then raise YandexMoney::InsufficientScopeError
      when "401" then raise YandexMoney::UnauthorizedError.new request["www-authenticate"]
      else request
      end
    end

  end
end
