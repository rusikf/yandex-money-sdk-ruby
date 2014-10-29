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
          to: "410011285611534",
          amount: "1.0",
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
        expect {
          @api.request_payment(
            pattern_id: "p2p",
            to: "410011285611534",
            test_payment: "true",
            test_result: "success"
          )
        }.to raise_error YandexMoney::ApiError
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
        expect {
          @api.process_payment(
            test_payment: "true",
            test_result: "success"
          )
        }.to raise_error YandexMoney::ApiError
      end
    end

    it "accept incoming transfer with protection code" do
      VCR.use_cassette "accept incoming transfer with protection code" do
        expect(@api.incoming_transfer_accept("463937708331015004", "0208")).to be true
      end
    end

    it "raise exception with wrong protection code while accepting incoming transfer" do
      VCR.use_cassette "accept incoming transfer with protection code with wrong code" do
        expect {
          @api.incoming_transfer_accept("463937921796020004", "6377")
        }.to raise_error YandexMoney::AcceptTransferError
      end
    end

    it "can reject payment" do
      VCR.use_cassette "reject payment" do
        expect(@api.incoming_transfer_reject("463947376678019004")).to be true
      end
    end

    it "raise exception when reject wrong payment" do
      VCR.use_cassette "reject payment fail" do
        expect {
          @api.incoming_transfer_reject("")
        }.to raise_error YandexMoney::ApiError
      end
    end
  end
end
