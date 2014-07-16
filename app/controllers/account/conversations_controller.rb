class Account::ConversationsController < Account::ResourcesController

  #
  # Settings
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  actions :index, :show

  #
  # Filters
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  before_filter :update_unread_message_counter, only: :show
  
  respond_to :html, :js
  
  #
  # Actions
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  def show
    @message = Message.new
    @message.receiver_id = resource.negotiator_for(current_user).id
    @message.conversation = resource
    show!
  end

  def archive
    resource.archive_by!(current_user)
    respond_to do |format|
      format.html{ redirect_to collection_path }
      format.js{}
    end
  end

  #
  # Protected
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
    
  protected
  

  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  private
  
  def update_unread_message_counter
    unread_msgs = resource.messages.select { |m| m.receiver_id == current_user.id && m.read_at.nil? }.count
    if unread_msgs > 0
      User.update_counters current_user.id, unread_message_counter: -unread_msgs
      resource.messages.unread.where(receiver_id: current_user.id).update_all read_at: Time.now
      current_user.unread_message_counter -= unread_msgs
    end
  end
  
end