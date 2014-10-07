require "yandex_money/api/version"
require "yandex_money/exceptions"
require "yandex_money/logger/default"
require "httparty"
require "uri"
require "ostruct"

module YandexMoney
  class Api
    include HTTParty

    base_uri "https://sp-money.yandex.ru"
    default_timeout 30

    attr_accessor :client_url, :code, :token, :instance_id

    # Returns url to get token
    def initialize(options)
      # TOKEN provided
      @logger = options[:logger] || YandexMoney::Logger::Default.new(STDOUT)
      if options.length == 1 && options[:token] != nil
        @token = options[:token]
      else
        @client_id = options[:client_id]
        @redirect_uri = options[:redirect_uri]
        @instance_id = options[:instance_id]
        if options[:scope] != nil
          @client_url = send_authorize_request(
            client_id: @client_id,
            response_type: "code",
            redirect_uri: @redirect_uri,
            scope: options[:scope]
          )
        end
      end
      @logger.info "test TEST"
    end

    # obtains and saves token from code
    def obtain_token(client_secret = nil)
      raise YandexMoney::FieldNotSetError.new(:code) if @code == nil
      uri = "/oauth/token"
      options = {
        code: @code,
        client_id: @client_id,
        grant_type: "authorization_code",
        redirect_uri: @redirect_url
      }
      options[:client_secret] = client_secret if client_secret
      @token = self.class.post(uri, body: options)
                         .parsed_response["access_token"]
    end

    # obtains account info
    def account_info
      check_token
      OpenStruct.new send_request("/api/account-info").parsed_response
    end

    # obtains operation history
    def operation_history(options=nil)
      check_token
      OpenStruct.new send_request("/api/operation-history", options).parsed_response
    end

    # obtains operation details
    def operation_details(operation_id)
      check_token
      request = send_request("/api/operation-details", operation_id: operation_id)
      details = OpenStruct.new request.parsed_response
      if details.error
        raise YandexMoney::ApiError.new details.error
      else
        details
      end
    end

    # basic request payment method
    def request_payment(options)
      send_payment_request("/api/request-payment", options)
    end

    # basic process payment method
    def process_payment(options)
      send_payment_request("/api/process-payment", options)
    end

    def get_instance_id
      request = send_request("/api/instance-id", client_id: @client_id)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      else
        request["instance_id"]
      end
    end

    def incoming_transfer_accept(operation_id, protection_code = nil)
      uri = "/api/incoming-transfer-accept"
      if protection_code
        request_body = {
          operation_id: operation_id,
          protection_code: protection_code
        }
      else
        request_body = { operation_id: operation_id }
      end
      request = send_request("/api/incoming-transfer-accept", request_body)

      if request["status"] == "refused"
        raise YandexMoney::AcceptTransferError.new request["error"], request["protection_code_attempts_available"]
      else
        true
      end
    end

    def incoming_transfer_reject(operation_id)
      request = send_request("/api/incoming-transfer-reject", operation_id: operation_id)

      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      else
        true
      end
    end

    def request_external_payment(payment_options)
      payment_options[:instance_id] ||= @instance_id
      request = send_request("/api/request-external-payment", payment_options)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      else
        OpenStruct.new request.parsed_response
      end
    end

    def process_external_payment(payment_options)
      payment_options[:instance_id] ||= @instance_id
      request = send_request("/api/process-external-payment", payment_options)
      if request["status"] == "refused"
        raise YandexMoney::ApiError.new request["error"]
      elsif request["status"] == "in_progress"
        raise YandexMoney::ExternalPaymentProgressError.new request["error"], request["next_retry"]
      else
        OpenStruct.new request.parsed_response
      end
    end

    private

    def send_request(uri, options = nil)
      request = self.class.post(uri, base_uri: "https://money.yandex.ru", headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options)

      case request.response.code
      when "403" then raise YandexMoney::InsufficientScopeError
      when "401" then raise YandexMoney::UnauthorizedError.new request["www-authenticate"]
      else request
      end
    end

    def send_payment_request(uri, options)
      check_token
      request = send_request(uri, options)
      response = OpenStruct.new request.parsed_response
      if response.error
        raise YandexMoney::ApiError.new response.error
      else
        response
      end
    end

    def check_token
      raise YandexMoney::FieldNotSetError.new(:token) unless @token
    end

    def send_authorize_request(options)
      uri = "/oauth/authorize"
      self.class.post(uri, body: options).request.path.to_s
    end
  end
end
