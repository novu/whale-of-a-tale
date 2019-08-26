class FlyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActionCable.server.broadcast("whale", "fly")
  end
end
