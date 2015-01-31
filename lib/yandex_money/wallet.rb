require "httparty"
require "recursive-open-struct"

module YandexMoney
  # Payments from the Yandex.Money wallet
  class Wallet
    include HTTParty

    base_uri YandexMoney.config.money_url
    default_timeout 30

    attr_accessor :token

    def initialize(token)
      @token = token
    end

    # Getting information about the status of the user account.
    #
    # @see http://api.yandex.com/money/doc/dg/reference/account-info.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/account-info-docpage
    #
    # @return [RecursiveOpenStruct] Account information
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def account_info
      RecursiveOpenStruct.new send_request("/api/account-info", recurse_over_arrays: true).parsed_response
    end

    # Returns operation history of a user's wallet
    #
    # @see http://api.yandex.com/money/doc/dg/reference/operation-history.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/operation-history-docpage/
    # 
    # @param options [Hash] A hash with filter parameters according to documetation
    # @return [Array<RecursiveOpenStruct>] An array containing user's wallet operations.
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def operation_history(options=nil)
      history = RecursiveOpenStruct.new(
        send_request("/api/operation-history", options).parsed_response
      )
      history.operations = history.operations.map do |operation|
        RecursiveOpenStruct.new operation
      end
      history
    end

    # Returns details of operation specified by operation_id
    #
    # @see http://api.yandex.com/money/doc/dg/reference/operation-details.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/operation-details-docpage/
    #
    # @param operation_id [String] A operation identifier
    # @return [RecursiveOpenStruct] All details of requested operation.
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def operation_details(operation_id)
      request = send_request("/api/operation-details", operation_id: operation_id)
      RecursiveOpenStruct.new request.parsed_response
    end

    # Requests a payment
    #
    # @see http://api.yandex.com/money/doc/dg/reference/request-payment.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/request-payment-docpage/
    #
    # @param options [Hash] A method's parameters. Check out docs for more information
    # @return [RecursiveOpenStruct] `payment_id` and additional information about a recipient and payer.
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def request_payment(options)
      send_payment_request("/api/request-payment", options)
    end

    # Confirms a payment that was created using the request-payment method.
    #
    # @see http://api.yandex.com/money/doc/dg/reference/process-payment.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/process-payment-docpage/
    #
    # @param options [Hash] A method's parameters. Check out docs for more information
    # @return [RecursiveOpenStruct] A status of payment and additional steps for authorization (if needed)
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def process_payment(options)
      send_payment_request("/api/process-payment", options)
    end

    # Accepts incoming transfer with a protection code or deferred transfer
    #
    # @see http://api.yandex.com/money/doc/dg/reference/incoming-transfer-accept.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/incoming-transfer-accept-docpage/
    #
    # @param operation_id [String] A operation identifier
    # @param protection_code [String] Secret code of four decimal digits. Specified for an incoming transfer proteced by a secret code. Omitted for deferred transfers
    # @return [RecursiveOpenStruct] An information about operation result.
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
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

    # Rejects incoming transfer with a protection code or deferred transfer
    #
    # @see http://api.yandex.com/money/doc/dg/reference/incoming-transfer-reject.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/incoming-transfer-reject-docpage/
    #
    # @param operation_id [String] A operation identifier
    # @return [RecursiveOpenStruct] An information about operation result.
    #
    # @raise [YandexMoney::InvalidRequestError] HTTP request does not conform to protocol format. Unable to parse HTTP request, or the Authorization header is missing or has an invalid value.
    # @raise [YandexMoney::UnauthorizedError] Nonexistent, expired, or revoked token specified.
    # @raise [YandexMoney::InsufficientScopeError] The token does not have permissions for the requested operation.
    # @raise [YandexMoney::ServerError] A technical error occurs (the server responds with the HTTP code 500 Internal Server Error). The application should repeat the request with the same parameters later.
    def incoming_transfer_reject(operation_id)
      RecursiveOpenStruct.new send_request("/api/incoming-transfer-reject", operation_id: operation_id)
    end

    # Request a authorization URL
    #
    # @note For the authorization request, the user is redirected to the Yandex.Money authorization page. The user enters his login and password, reviews the list of requested permissions and payment limits, and either approves or rejects the application's authorization request.
    # @note The authorization result is returned as an HTTP 302 Redirect. The application must process the HTTP Redirect response.
    # @note Attention! If a user repeats the application authorization with the same value for the client_id parameter, the previous authorization is canceled.
    #
    # @param client_id [String] The client_id that was assigned to the application during registration
    # @param redirect_uri [String] URI that the OAuth server sends the authorization result to. Must have a string value that exactly matches the redirect_uri parameter specified in the application registration data. Any additional parameters required for the application can be added at the end of the string.
    # @param scope [String] A list of requested permissions. Items in the list are separated by a space. List items are case-sensitive.
    #
    # @return [String] Url to user must be redirected
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

    # Access token request
    #
    # @see http://api.yandex.com/money/doc/dg/reference/obtain-access-token.xml
    # @see https://tech.yandex.ru/money/doc/dg/reference/obtain-access-token-docpage
    #
    # @note If authorization was completed successfully, the application should immediately exchange the temporary authorization code for an access token. To do this, a request containing the temporary authorization code must be sent to the Yandex.Money OAuth server.
    #
    # @param client_id [String] The client_id that was assigned to the application during registration
    # @param code [String] Temporary token (authorization code)
    # @param redirect_uri [String] URI that the OAuth server sends the authorization result to. The value of this parameter must exactly match the redirect_uri value from the previous "authorize" call
    # @param client_secret [String] A secret word for verifying the application's authenticity. Specified if the service is registered with the option to verify authenticity
    # @return [String] Access token
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
      RecursiveOpenStruct.new request.parsed_response
    end
  end
end
