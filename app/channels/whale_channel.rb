class WhaleChannel < ApplicationCable::Channel
  def subscribed
    stream_from "whale"
  end

  def swim
    puts 'Queue a job to make the whale swim!'
    SwimJob.perform_later
  end

  def fly
    puts 'Queue a job to make the whale fly!'
    FlyJob.perform_later
  end
end
