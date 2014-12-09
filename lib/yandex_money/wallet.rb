require "httparty"
require "recursive-open-struct"

module YandexMoney
  # Payments from YandexMoney wallet
  class Wallet
    include HTTParty
    base_uri YandexMoney.config.money_url
    default_timeout 30

    attr_accessor :token

    def initialize(token)
      @token = token
    end

    # obtains account info
    def account_info
      RecursiveOpenStruct.new send_request("/api/account-info", recurse_over_arrays: true).parsed_response
    end

    # obtains operation history
    def operation_history(options=nil)
      history = RecursiveOpenStruct.new(
        send_request("/api/operation-history", options).parsed_response
      )
      history.operations = history.operations.map do |operation|
        RecursiveOpenStruct.new operation
      end
      history
    end

    # obtains operation details
    def operation_details(operation_id)
      request = send_request("/api/operation-details", operation_id: operation_id)
      RecursiveOpenStruct.new request.parsed_response
    end

    # basic request payment method
    def request_payment(options)
      send_payment_request("/api/request-payment", options)
    end

    # basic process payment method
    def process_payment(options)
      send_payment_request("/api/process-payment", options)
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
      RecursiveOpenStruct.new send_request("/api/incoming-transfer-accept", request_body)
    end

    def incoming_transfer_reject(operation_id)
      RecursiveOpenStruct.new send_request("/api/incoming-transfer-reject", operation_id: operation_id)
    end

    def self.build_obtain_token_url(client_id, redirect_uri, scope)
      uri = "#{YandexMoney.config.sp_money_url}/oauth/authorize"
      options = {
        client_id: client_id,
        response_type: "code",
        redirect_uri: redirect_uri,
        scope: scope
      }
      HTTParty.post(uri, body: options).request.path.to_s
    end

    def self.get_access_token(client_id, code, redirect_uri, client_secret=nil)
      uri = "#{YandexMoney.config.sp_money_url}/oauth/token"
      options = {
        code: code,
        client_id: client_id,
        grant_type: "authorization_code",
        redirect_uri: redirect_uri
      }
      options[:client_secret] = client_secret if client_secret
      response = HTTParty.post(uri, body: options).parsed_response
      response["access_token"]
    end

    protected

    def send_request(uri, options = nil)
      request = self.class.post(uri, headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/x-www-form-urlencoded"
      }, body: options)
      case request.response.code
      when "400" then raise YandexMoney::InvalidRequestError.new request.response
      when "401" then raise YandexMoney::UnauthorizedError.new request.response
      when "403" then raise YandexMoney::InsufficientScopeError.new request.response
      when "500" then raise YandexMoney::ServerError
      else
        request
      end
    end

    def send_payment_request(uri, options)
      request = send_request(uri, options)
      response = RecursiveOpenStruct.new request.parsed_response
      response
    end
  end
end
