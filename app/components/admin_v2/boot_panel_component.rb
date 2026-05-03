# frozen_string_literal: true

class AdminV2::BootPanelComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  private

  attr_reader :current_user

  def lines
    [
      { level: "system", message: "auth session restored" },
      { level: "server", message: "env available" },
      { level: "success", message: "status: OK" },
      { level: "info", message: "turbo live-interface mounted" },
      { level: "server", message: "context drawer online" },
      { level: "success", message: "store console ready" }
    ]
  end
end
