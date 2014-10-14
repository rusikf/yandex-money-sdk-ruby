require "spec_helper"

describe "logger" do
  it "should log to provided logger" do
    @logger = double
    expect(@logger).to receive(:info).at_least(:once)

    VCR.use_cassette "obtain token for get account info" do
      @api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "account-info operation-history operation-details",
        logger: @logger
      )
      @api.code = "39041180F6631E2B56DD0058F75A34C7504226178A45D624313495ECD417DCC3AA6CBF1B010E65BB09F3F9EB5AE63452129BAE2B732B7457C33BE6B2039B7B60A8058D2A387729A601DC817BBFB27CB0CC2D65E3C70997D981AC0E31F18CF32C0675DFD461E2F5C5639B75AC0E5074CE64FCF4546447BBDC566E3459FB1B3C3B"
      @api.obtain_token
    end
  end
end
