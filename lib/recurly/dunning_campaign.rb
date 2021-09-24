module Recurly
  # Recurly Documentation: https://developers.recurly.com/api-v2/latest/index.html#tag/dunning-campaigns
  class DunningCampaign < Resource
    # @return [[DunningCycle], []]
    has_many :dunning_cycles

    define_attribute_methods %w(
      name
      code
      description
      default
      dunning_cycles
      created_at
      updated_at
      deleted_at
    )

    def bulk_update(plan_codes)
      reload API.put("#{uri}/bulk_update", plan_codes)
      true
    end
  end
end
