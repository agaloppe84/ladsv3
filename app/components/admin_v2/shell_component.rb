# frozen_string_literal: true

class AdminV2::ShellComponent < ViewComponent::Base
  def initialize(current_user:, active: :products, drawer: nil)
    @current_user = current_user
    @active = active
    @drawer = drawer
  end

  private

  attr_reader :current_user, :active, :drawer

  def active?(key)
    active.to_sym == key.to_sym
  end
end
