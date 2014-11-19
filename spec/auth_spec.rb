require "spec_helper"

describe "Application authorization flow" do
  # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
  it "should properly initialize without client_secret" do
    VCR.use_cassette "init without client secret" do
      url = YandexMoney::Wallet.build_obtain_token_url(
        CLIENT_ID,
        REDIRECT_URI,
        "account-info operation-history"
      )
      expect(url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
  it "should get token from code" do
    VCR.use_cassette "get token from authorization code" do
      expect {
        YandexMoney::Wallet.get_access_token(
          CLIENT_ID,
          "SOME CODE",
          REDIRECT_URI
        )
      }.to raise_error YandexMoney::ApiError
    end
  end

  it "could be initialized with token" do
    VCR.use_cassette "initialize with token" do
      api = YandexMoney::Wallet.new(ACCESS_TOKEN)
      expect(api.account_info.account).to eq WALLET_NUMBER
    end
  end

  # https://tech.yandex.ru/money/doc/dg/reference/obtain-token-aux-docpage/
  it "should get auxiliary token" do
    VCR.use_cassette "initialize with token and get aux_token" do
      api = YandexMoney::Wallet.new(ACCESS_TOKEN)
      # it assumes, that you have account-info scope when obtaining access_token
      expect(api.get_aux_token("account-info")).to start_with("aux.")
    end
  end
end
