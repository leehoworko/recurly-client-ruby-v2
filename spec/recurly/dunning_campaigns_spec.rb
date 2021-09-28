require "spec_helper"

describe DunningCampaign do
  let(:campaign) { Recurly::DunningCampaign.find("abcdef1234567890") }

  before do
    stub_api_request :get, "dunning_campaigns/abcdef1234567890", "dunning_campaigns/show-200"
  end

  describe ".find" do
    it "returns a campaign when available" do
      campaign.must_be_instance_of(DunningCampaign)
    end
  end

  describe "plan bulk update" do
    let(:plan1) {
      Plan.new(
        :plan_code                 => "gold",
        :name                      => "The Gold Plan",
        :unit_amount_in_cents      => 79_00,
        :description               => "The Gold Plan is for folks who love gold.",
        :accounting_code           => "gold_plan_acc_code",
        :setup_fee_accounting_code => "setup_fee_ac",
        :setup_fee_in_cents        => 60_00,
        :plan_interval_length      => 1,
        :plan_interval_unit        => 'months',
        :tax_exempt                => false,
        :revenue_schedule_type     => 'evenly',
        :avalara_transaction_type  => 600,
        :avalara_service_type      => 3,
      )
    }
    let(:plan2) {
      Plan.new(
        :plan_code                 => "silver",
        :name                      => "The Silver Plan",
        :unit_amount_in_cents      => 79_00,
        :description               => "The Silver Plan is for folks who love silver.",
        :accounting_code           => "silver_plan_acc_code",
        :setup_fee_accounting_code => "setup_fee_ac",
        :setup_fee_in_cents        => 60_00,
        :plan_interval_length      => 1,
        :plan_interval_unit        => 'months',
        :tax_exempt                => false,
        :revenue_schedule_type     => 'evenly',
        :avalara_transaction_type  => 600,
        :avalara_service_type      => 3,
      )
    }

    before do
      stub_api_request :put, "dunning_campaigns/abcdef1234567890/bulk_update", "dunning_campaigns/update-200"
    end

    it "should assign the dunning campaign to multiple plans" do
      plans = campaign.bulk_update([plan1.plan_code, plan2.plan_code])

      plans.each do |plan|
        plan.dunning_campaign_id.must_equal(campaign.id)
      end
    end
  end
end
