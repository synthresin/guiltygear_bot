class WelcomeController < ApplicationController
  def index
    redis = Redis.new(host: 'localhost', port: 6379)
    @rooms = redis.lrange('guiltygear:rooms', 0, -1)
  end
end
