require 'activity_notification/apis/subscription_api'

module ActivityNotification
  module ORM
    module ActiveRecord
      # Subscription model implementation generated by ActivityNotification.
      class Subscription < ::ActiveRecord::Base
        include SubscriptionApi
        self.table_name = ActivityNotification.config.subscription_table_name

        # Belongs to target instance of this subscription as polymorphic association.
        # @scope instance
        # @return [Object] Target instance of this subscription
        belongs_to :target,               polymorphic: true

        # Serialize parameters Hash
        serialize  :optional_targets, type: Hash

        validates  :target,               presence: true
        validates  :key,                  presence: true, uniqueness: { scope: :target }
        validates_inclusion_of :subscribing,          in: [true, false]
        validates_inclusion_of :subscribing_to_email, in: [true, false]
        validate   :subscribing_to_email_cannot_be_true_when_subscribing_is_false
        validates  :subscribed_at,            presence: true, if:     :subscribing
        validates  :unsubscribed_at,          presence: true, unless: :subscribing
        validates  :subscribed_to_email_at,   presence: true, if:     :subscribing_to_email
        validates  :unsubscribed_to_email_at, presence: true, unless: :subscribing_to_email
        validate   :subscribing_to_optional_target_cannot_be_true_when_subscribing_is_false

        # Selects filtered subscriptions by target instance.
        #   ActivityNotification::Subscription.filtered_by_target(@user)
        # is the same as
        #   @user.subscriptions
        # @scope class
        # @param [Object] target Target instance for filter
        # @return [ActiveRecord_AssociationRelation<Subscription>] Database query of filtered subscriptions
        scope :filtered_by_target,  ->(target) { where(target: target) }

        # Includes target instance with query for subscriptions.
        # @return [ActiveRecord_AssociationRelation<Subscription>] Database query of subscriptions with target
        scope :with_target,               -> { includes(:target) }

        # Selects unique keys from query for subscriptions.
        # @return [Array<String>] Array of subscription unique keys
        def self.uniq_keys
          # select method cannot be chained with order by other columns like created_at
          # select(:key).distinct.pluck(:key)
          pluck(:key).uniq
        end

      end
    end
  end
end
