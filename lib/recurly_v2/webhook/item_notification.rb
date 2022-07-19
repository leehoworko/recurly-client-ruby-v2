module RecurlyV2
  module Webhook
    class ItemNotification < Notification
      has_one :item
    end
  end
end
