module Payment
  extend ActiveSupport::Concern
  
  included do
  end
  
  def credit_last4
    credit_card["last4"]
  end
  
  def credit_type
    credit_card["type"]
  end
  
  def credit_exp_month
    I18n.t("date.abbr_month_names")[credit_card["exp_month"].to_i]
  end
  
  def credit_exp_year
    credit_card["exp_year"]
  end
  
  def credit_card
    @card ||= retrieve_credit_card
    @card.first
  end
  
  def retrieve_credit_card
    begin
       Stripe::Customer.retrieve(stripe_customer_id).cards
    rescue Stripe::StripeError => e
      User.where(id: id).update_all(stripe_log: e.json_body.inspect)
      Rails.logger.info "###########################"
      Rails.logger.info e.inspect
      Rails.logger.info "###########################"
      return [{}]
    end
  end
  
  def create_stripe_customer(user, desc=nil)
    begin
      Stripe::Customer.create(card: user.stripe_token, description: desc || user.email)
    rescue Stripe::StripeError => e
      # TODO: Stripe Customer Create Error
      user.errors.add :stripe_customer_id, e.json_body[:error][:message]
      User.where(id: user.id).update_all(stripe_log: e.json_body.inspect)
      Rails.logger.info "###########################"
      Rails.logger.info e.inspect
      Rails.logger.info "###########################"
    end
  end

  def charge_deal_customer(customer, deal)
    return true if deal.stripe_charge_id.present?
    return false if customer.stripe_customer_id.nil?
    begin
      charge = Stripe::Charge.create(
        :amount => deal.price_with_surcharge_in_cents,
        :currency => deal.currency,
        :customer => customer.stripe_customer_id,
        :description => "Deal #{customer.name}"
      )
      deal.charged_price = deal.price_with_surcharge_in_cents
      deal.stripe_charge_id = charge.id
      Deal.where(id: deal.id).update_all(charged_price: deal.charged_price, stripe_charge_id: deal.stripe_charge_id)
      return true
    rescue Stripe::StripeError => e
      # TODO: Stripe Charge CardError
      deal.errors.add :stripe_charge_id, e.json_body[:error][:message] 
      User.where(id: customer.id).update_all(stripe_log: e.json_body.inspect) 
      Rails.logger.info "##########################"
      Rails.logger.info e.inspect
      Rails.logger.info "##########################"
    end
    return false
    
  end
  
end

