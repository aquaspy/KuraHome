class HomeController < ApplicationController
  include CurrentProfile

  def index
    @sites = @profile.sites.ordered
  end

  def stack
    @stack_items = @profile.stack_items.ordered
  end
end
