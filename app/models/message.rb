class Message < ActiveRecord::Base

  #
  # Attributes
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  validates :sender_id, :receiver_id, :subject, :body, presence: true
  validate :validate_receiver

  #
  # Associations
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
  belongs_to :receiver, foreign_key: :receiver_id, class_name: 'User'  
  belongs_to :thread, class_name: 'Message'  
  belongs_to :replies, class_name: 'Message', foreign_key: :thread_id  
  belongs_to :conversation
  
  #
  # Scopes
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  scope :by_user, ->(user_id) { where("sender_id = :user_id OR receiver_id = :user_id" , user_id: user_id) }
  scope :root, -> { where(thread_id: nil) }
  scope :latest, -> { order("ID DESC") }
  scope :grouped_by_thread, -> { group(:thread_id) }

  #
  # Callbacks
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  before_create :attach_to_conversation
  after_create :update_conversation_order
  
  
  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  private
  
  def validate_receiver
    errors.add :receiver_id unless receiver.present?
  end
  
  def attach_to_conversation
    self.conversation ||= self.sender.conversations.where('receiver_id = :id OR sender_id = :id', id: self.receiver_id).first || create_conversation
  end
  
  def create_conversation
    conversation = Conversation.new
    conversation.sender_id = self.sender_id
    conversation.receiver_id = self.receiver_id
    conversation.subject = self.subject
    conversation.body = self.body
    conversation.last_message_at = Time.now    
    conversation.save
    conversation
  end
  
  def update_conversation_order
    conversation.last_message_at = self.created_at
    conversation.save
  end
  
end
