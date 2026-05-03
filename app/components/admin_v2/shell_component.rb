# frozen_string_literal: true

class AdminV2::ShellComponent < ViewComponent::Base
  def initialize(current_user:, active: :products, drawer: nil, show_boot_panel: false)
    @current_user = current_user
    @active = active
    @drawer = drawer
    @show_boot_panel = show_boot_panel
  end

  private

  attr_reader :current_user, :active, :drawer, :show_boot_panel

  def active?(key)
    active.to_sym == key.to_sym
  end
end
