[![Build Status](https://travis-ci.org/yandex-money/yandex-money-sdk-ruby.svg)](https://travis-ci.org/yandex-money/yandex-money-sdk-ruby)
[![Coverage Status](https://img.shields.io/coveralls/yandex-money/yandex-money-sdk-ruby.svg)](https://coveralls.io/r/yandex-money/yandex-money-sdk-ruby)
[![Code Climate](https://codeclimate.com/github/yandex-money/yandex-money-sdk-ruby/badges/gpa.svg)](https://codeclimate.com/github/yandex-money/yandex-money-sdk-ruby)
[![Gem Version](https://badge.fury.io/rb/yandex-money-sdk.svg)](http://badge.fury.io/rb/yandex-money-sdk)
[![Dependency Status](https://gemnasium.com/yandex-money/yandex-money-sdk-ruby.svg)](https://gemnasium.com/yandex-money/yandex-money-sdk-ruby)

# Ruby Yandex.Money API SDK

## Requirements

Supported ruby versions: 1.9.3, 2.0, 2.1, jruby, rbx-2

## Links

1. Yandex.Money API page: [Ru](http://api.yandex.ru/money/),
[En](http://api.yandex.com/money/)

## Getting started

### Installation


Add this line to your Gemfile:

```ruby
gem 'yandex-money-sdk', require: false
```

And then execute:

```
bundle
```

Or install it manually with:

```
gem install yandex-money-sdk
```

Next, require it in application:

```ruby
require 'yandex_money/api'
```


### Payments from the Yandex.Money wallet

Using Yandex.Money API requires following steps

1. Obtain token URL and redirect user's browser to Yandex.Money service.
Note: `client_id`, `redirect_uri`, `client_secret` are constants that you get,
when [register](https://sp-money.yandex.ru/myservices/new.xml) app in Yandex.Money API.

    ```ruby
    api = YandexMoney::Api.new(
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      scope: "account-info operation-history"
    )
    auth_url = api.client_url
    ```

2. After that, user fills Yandex.Money HTML form and user is redirected back to
`REDIRECT_URI?code=CODE`.

3. You should immediately exchange `CODE` with `ACCESS_TOKEN`.

    ```ruby
    api = YandexMoney::Api.new(
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      scope: "account-info operation-history"
    )
    api.code = params[:code] # obtained code
    access_token = api.obtain_token
    # or, if client secret defined:
    # access_token = api.obtain_token(CLIENT_SECRET)
    ```

4. Now you can use Yandex.Money API.

    ```ruby
    api = YandexMoney::Api.new(token: TOKEN) # TOKEN is obtained token
    account_info = api.account_info
    balance = account_info.balance # and so on

    request_options = {
        "pattern_id": "p2p",
        "to": "410011161616877",
        "amount_due": "0.02",
        "comment": "test payment comment from yandex-money-python",
        "message": "test payment message from yandex-money-python",
        "label": "testPayment",
        "test_payment": true,
        "test_result": "success"
    };
    request_result = api.request_payment(request_options)
    # check status

    process_payment = api.process_payment({
        request_id: request_result.request_id,
    })
    # check result
    if process_payment.status == "success"
      # show success page
    else
      # something went wrong
    end
    ```

### Payments from bank cards without authorization

1. Fetch instantce-id(ussually only once for every client. You can store
result in DB).

    ```ruby
    api = YandexMoney::Api.new(client_id: CLIENT_ID)
    response = api.get_instance_id # returns string, contains instance id
    if reponse.status == "success"
      instance_id = response.instance_id
    else
      # throw exception
    end
    ```

2. Make request payment

    ```ruby
    api = YandexMoney::Api.new(
      client_id: CLIENT_ID,
      instance_id: INSTANCE_ID
    )
    response = api.request_external_payment({
      pattern_id: "p2p",
      to: "410011285611534",
      amount_due: "1.00",
      message: "test"
    })
    if response.status == "success"
      request_id = response.request_id
    else
      # throw exception
    end
    ```

3. Process the request with process-payment. 

    ```ruby
    api = YandexMoney::Api.new(instance_id: INSTANCE_ID)
    result = api.process_external_payment({
      request_id: REQUEST_ID,
      ext_auth_success_uri: "http://example.com/success",
      ext_auth_fail_uri: "http://example.com/fail"
    })
    # process result according to docs
    ```


## Running tests

Just run it with `bundle exec rake` command.
