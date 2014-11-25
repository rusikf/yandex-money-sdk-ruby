require "spec_helper"

describe "Exceptions for Yandex.Money" do
  describe "exceptions for wallet" do

    it "should raise invalid request error" do
      VCR.use_cassette "invalid request error" do
        @api = YandexMoney::Wallet.new("WRONG TOKEN")
        expect {
          @api.request_payment(nil)
        }.to raise_error YandexMoney::InvalidRequestError
      end
    end

    it "should raise unauthorized error" do
      VCR.use_cassette "unauthorized error" do
        @api = YandexMoney::Wallet.new("41001565326286.AEF04DD8614B6C66AF082793D71FF624C92989E7F98D1EE377C3707BC54DE72E0DDC8EAB79470803254178F40F4712F6EBD8C5E1FDA01D041A5C4A110C8E1940DE0928FF45F4E49500EA79D8F21D2D5C7A79CCCA142AE216C69D7B6DC6378FE9CB87769E9EB37DAC22A67BD8A33CADB6F18C4C2C22D28434914970575109FDB3")
        expect {
          @api.request_payment(nil)
        }.to raise_error YandexMoney::UnauthorizedError
      end
    end

    it "should raise insufficient scope error" do
      VCR.use_cassette "insufficient scope error" do
        @api = YandexMoney::Wallet.new(ACCESS_TOKEN)
        expect {
          @api.request_payment(
            pattern_id: "p2p",
            to: "example@example.com",
            amount: 5
          )
        }.to raise_error YandexMoney::InsufficientScopeError
      end
    end

  end

  describe "exceptions for external payment" do
    # it "should raise invalid request error" do
    #   VCR.use_cassette "invalid request error external payment" do
    #   end
    # end

    # it "should raise unauthorized error" do
    #   VCR.use_cassette "unauthorized error external payment" do
    #   end
    # end

    # it "should raise insufficient scope error" do
    #   VCR.use_cassette "insufficient scope error external payment" do
    #   end
    # end
  end
end
