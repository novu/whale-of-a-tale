class SwimJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActionCable.server.broadcast("whale", "swim")
  end
end
