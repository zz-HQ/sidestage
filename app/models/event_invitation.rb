class EventInvitation < ActiveRecord::Base
  
  include Tokenable
  
  #
  #
  # Validations
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #  

  validates :event_id, :inviter_id, :email, presence: true
  validates :email, uniqueness: { scope: :event_id }
  
  #
  #
  # Associations
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #  
  
  belongs_to :inviter, class_name: 'User', foreign_key: :inviter_id
  belongs_to :event, counter_cache: true

  
  #
  #
  # Callbacks
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #  
  
  after_create :mail_invitation

  #
  #
  # Instance Methods
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #  
  
  def visited!
    update_column :visited, true
  end

  
  #
  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #  
  
  private
  
  def mail_invitation
    EmailWorker.perform_async(:event_invitation_mail, id)
  end
    
  
end
