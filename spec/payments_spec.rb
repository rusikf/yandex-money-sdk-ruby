require "spec_helper"

describe "Payments from the Yandex.Money wallet" do
  describe "make payment to an account" do
    before :all do
      @api = YandexMoney::Wallet.new(ACCESS_TOKEN)
    end

    it "success request payment" do
      VCR.use_cassette "success request payment to an account" do
        server_response = @api.request_payment(
          pattern_id: "p2p",
          to: "410011161616877",
          amount: "0.02",
          comment: "test payment comment from yandex-money-ruby",
          message: "test payment message from yandex-money-ruby",
          label: "testPayment",
          test_payment: "true",
          test_result: "success"
        )
        expect(server_response.status).to eq "success"
      end
    end

    it "raise exception without requered params when request payment" do
      VCR.use_cassette "request payment to an account with failure" do
        result = @api.request_payment(
          pattern_id: "p2p",
          to: "410011161616877",
          test_payment: "true",
          test_result: "success"
        )
        expect(result.status).to eq "refused"
      end
    end

    it "success process payment" do
      VCR.use_cassette "success process payment to an account" do
        server_response = @api.process_payment(
          request_id: "test-p2p",
          test_payment: "true",
          test_result: "success"
        )
        expect(server_response.status).to eq "success"
      end
    end

    it "raise exception without requered params when process payment" do
      VCR.use_cassette "process payment to an account with failure" do
        result = @api.process_payment(
            test_payment: "true",
            test_result: "success"
        )
        expect(result.status).to eq "refused"
      end
    end

    it "accept incoming transfer with protection code" do
      VCR.use_cassette "accept incoming transfer with protection code" do
        expect(
          @api.incoming_transfer_accept("463937708331015004", "0208").status
        ).to eq "success"
      end
    end

    it "can reject payment" do
      VCR.use_cassette "reject payment" do
        expect(
          @api.incoming_transfer_reject("463947376678019004").status
        ).to eq "success"
      end
    end

    it "raise exception when reject wrong payment" do
      VCR.use_cassette "reject payment fail" do
        expect(@api.incoming_transfer_reject("").status).to eq "refused"
      end
    end
  end
end
