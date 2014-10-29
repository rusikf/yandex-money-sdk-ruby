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
  it "should get token with usage of client_secret" do
    VCR.use_cassette "token with client secret" do
      token = YandexMoney::Wallet.get_access_token(
        "2CB2BBF0788E79A1537437CFD37B15A3E21DAAEE5CD0AE8981118C1CFC6F376A",
        "94D93C28E1B27B02A36D495B01BB410EB415EF0152FA30837DEAF307773EDB9734B46954292458D3E5B0E8ABD70C1AF1EE71D64648FB65E7DA8ADAC961970709C3BEBA1AF949F73BAEA2134D386D2ED31CA3F001A45EA05A614432A196A6BEA7B042A0ABDA6E62BA108F864FC400286F388A41454DD961A4A782BF32A80F3816",
        REDIRECT_URI,
        "6FAFA896BD2C77E21E240081CDFF3B007451876AB9C186DE2AD2EDDCE29CE3E1BCC1A2789B53583F3398ACD8127A61851357C5D3F444D58F8B5F0AA4F78F088D"
      )
      expect(token).to start_with("410011285611534")
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
  it "should get token from code" do
    VCR.use_cassette "get token from authorization code" do
      token = YandexMoney::Wallet.get_access_token(
        CLIENT_ID,
        "736557BEBF03A1867FFF179F8FADF0F33841471B31BD9ECF2AC59480D0F123475E6261300B1FED6CDB7C067EF4C5E9CC860A31839D52FA5950B5CAFD18C29FE0A31D2F53618D000BAA7C733B2A143C148C4631EFDEAB29151A5EA92B6B099AAEE31A82BF9F7C13EC2E8EAFF44F62D1326EDEBDA4668631ACC367967DDA57F875",
        REDIRECT_URI,
      )
      expect(token).to start_with("41001565326286.D206A82773387134BB25CF89A85256EA")
    end
  end

  it "could be initialized with token" do
    VCR.use_cassette "initialize with token" do
      api = YandexMoney::Wallet.new(ACCESS_TOKEN)
      expect(api.account_info.account).to eq WALLET_NUMBER
    end
  end
end
