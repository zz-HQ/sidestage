module Deal::StateMachine
  extend ActiveSupport::Concern

  
  included do    
    #There is a better Gem 'state_machine' available, but unfortunatley not maintained anymore
    include AASM
    
    PENDING_STATES = [ :requested, :offered ]
    
    aasm column: 'state', whiny_transitions: false do
      
      state :requested, initial: true
      state :offered
      state :confirmed
      state :accepted
      state :declined
      state :cancelled
      state :rejected
      
      event :offer do
        transitions from: [ :requested ], to: :offered
      end
      
      event :cancel do
        transitions from: [:requested, :offered, :confirmed, :accepted], to: :cancelled
      end

      event :reject do
        transitions from: [:requested, :confirmed, :accepted], to: :rejected, guards: [:current_user_is_artist?]
      end

      event :decline do
        transitions from: [:requested, :offered], to: :declined
      end
      
      event :accept do
        transitions from: [:requested], to: :accepted, guards: [:current_user_is_artist?, :customer_charged?]
      end
      
      event :confirm do
        transitions from: [ :offered ], to: :confirmed, guards: [:current_user_is_customer?, :customer_charged?]
      end
      
    end

  end
  
  def customer_charged?
    return charge_deal_customer(customer, self)
  end
  
  def current_user_is_artist?
    current_user == artist
  end

  def current_user_is_customer?
    current_user == customer
  end
  
end