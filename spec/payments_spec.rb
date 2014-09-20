require "spec_helper"

describe "Payments from the Yandex.Money wallet" do
  describe "make payment to an account" do
    before :all do
      @api = YandexMoney::Api.new(
        token: "41001565326286.F231B646B62994F492C42942769B28211D996082FB0E553BF7D8783D91D6A2FF8CB9C83EA2E7A6A1DC303369916D25A8B60F63E52F6C19784F3F703B54332655CF59964ADFEF6D188F74E912617D7B0954A7BDEF83A683C09DAB35BC189785C3A1E6D0D7168F980875A67962C6119E87A18442E600F0ADB431DD1BCF33C905D3"
      )
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
        }.to raise_error "Illegal params"
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
        }.to raise_error "Contract not found"
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
        }.to raise_error "Illegal param protection code, attemps available: 2"
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
        }.to raise_error "Illegal param operation id"
      end
    end
  end
end
