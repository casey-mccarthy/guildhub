class HomeController < ApplicationController
  skip_before_action :authenticate_user! # Public landing page

  def index
  end
end
