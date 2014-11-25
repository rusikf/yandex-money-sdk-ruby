require "spec_helper"

describe "get account info" do
  before :all do
    VCR.use_cassette "obtain token for get account info" do
      @api = YandexMoney::Wallet.new(ACCESS_TOKEN)
    end
  end

  it "should return recursive open struct" do
    VCR.use_cassette "get account info" do
      info = @api.account_info
      expect(info.avatar.url).to start_with "https://avatars.yandex.net/"
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/account-info.xml
  it "should return account info" do
    VCR.use_cassette "get account info" do
      info = @api.account_info
      expect(info.account).to eq WALLET_NUMBER
    end
  end

  # http://api.yandex.com/money/doc/dg/reference/operation-history.xml
  it "should return operation history" do
    VCR.use_cassette "get operation history" do
      history = @api.operation_history
      expect(history.operations.count).to be_between(1, 30).inclusive
    end
  end

  it "should return operation history with params" do
    VCR.use_cassette "get operation history with params" do
      history = @api.operation_history(records: 1)
      expect(history.operations.count).to eq 1
    end
  end

  # http://api.yandex.com/money/doc/dg/reference/operation-details.xml
  describe "operation details" do
    it "should return valid operation details" do
      VCR.use_cassette "get operation details" do
        history = @api.operation_history
        operation_id = history.operations.first.operation_id
        details = @api.operation_details operation_id
        expect(details.status).to eq "success"
      end
    end

    it "raise unauthorized exception when wrong token" do
      VCR.use_cassette "unauthorized exception" do
        @api = YandexMoney::Wallet.new("wrong_token")
        expect { @api.operation_details "462449992116028008" }.to raise_error YandexMoney::UnauthorizedError
      end
    end

    it "should raise exception if operation_id is wrong" do
      VCR.use_cassette "get wrong operation details" do
        expect(@api.operation_details("unknown").error).to eq "illegal_param_operation_id"
      end
    end
  end
end
