class WelcomeController < ApplicationController
  def index
    @rooms = Room.all
  end
end
