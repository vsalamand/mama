class ListChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_for "list_#{params[:list_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
