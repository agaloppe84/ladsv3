class Admin::ProductConfiguratorsController < AdminController
  before_action :set_product, except: [:index]
  before_action :set_part, only: [:update_part, :destroy_part, :create_item, :update_item, :destroy_item]
  before_action :set_item, only: [:update_item, :destroy_item]

  def index
    @categories = Category.all

    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @categories = [@category] + @categories.reject { |category| category.id == @category.id }
      @products = Product.where(category: @category, type: nil).order(updated_at: :desc)
    else
      @products = Product.where(type: nil).order(updated_at: :desc)
    end
  end

  def show
    load_configurator_collections
  end

  def create_part
    attrs = part_params.to_h.symbolize_keys
    palette_name = attrs.delete(:palette_name)

    ActiveRecord::Base.transaction do
      palette = ColorPalette.create!(name: resolve_palette_name(palette_name, attrs[:label]))
      @product.product_color_parts.create!(attrs.merge(color_palette: palette))
    end

    render_configurator_success("Part ajoutée.")
  rescue ActiveRecord::RecordInvalid => e
    render_configurator_error(e.record.errors.full_messages.to_sentence)
  end

  def update_part
    attrs = part_params.to_h.symbolize_keys
    palette_name = attrs.delete(:palette_name)

    ActiveRecord::Base.transaction do
      @part.update!(attrs)
      @part.color_palette.update!(name: palette_name) if palette_name.present?
    end

    render_configurator_success("Part mise à jour.")
  rescue ActiveRecord::RecordInvalid => e
    render_configurator_error(e.record.errors.full_messages.to_sentence)
  end

  def destroy_part
    palette = @part.color_palette

    ActiveRecord::Base.transaction do
      @part.destroy!
      palette.destroy! if palette.product_color_parts.reload.empty?
    end

    render_configurator_success("Part supprimée.")
  rescue ActiveRecord::RecordNotDestroyed => e
    render_configurator_error(e.record.errors.full_messages.to_sentence.presence || "Impossible de supprimer cette part.")
  end

  def create_item
    @part.color_palette.color_palette_items.create!(create_item_params)
    render_configurator_success("Couleur ajoutée à la palette.")
  rescue ActiveRecord::RecordInvalid => e
    render_configurator_error(e.record.errors.full_messages.to_sentence)
  end

  def update_item
    @item.update!(update_item_params)
    render_configurator_success("Couleur mise à jour.")
  rescue ActiveRecord::RecordInvalid => e
    render_configurator_error(e.record.errors.full_messages.to_sentence)
  end

  def destroy_item
    @item.destroy!
    render_configurator_success("Couleur supprimée de la palette.")
  rescue ActiveRecord::RecordNotDestroyed => e
    render_configurator_error(e.record.errors.full_messages.to_sentence.presence || "Impossible de supprimer cette couleur.")
  end

  def create_finish
    finish = Finish.create!(finish_params)
    render_configurator_success("Finition ajoutée: #{finish.label}.")
  rescue ActiveRecord::RecordInvalid => e
    render_configurator_error(e.record.errors.full_messages.to_sentence)
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_part
    @part = @product.product_color_parts.includes(:color_palette).find(params[:part_id])
  end

  def set_item
    @item = @part.color_palette.color_palette_items.find(params[:item_id])
  end

  def load_configurator_collections
    @product_color_parts = @product.product_color_parts
                                 .includes(color_palette: { color_palette_items: [:ral, :finish] })
                                 .order(:created_at)
    @rals = Ral.order(:collection, :ref)
    @finishes = Finish.order(:label)
  end

  def render_configurator_success(message)
    load_configurator_collections
    render_configurator(message: message)
  end

  def render_configurator_error(message)
    load_configurator_collections
    render_configurator(message: message, error: true, status: :unprocessable_entity)
  end

  def render_configurator(message:, error: false, status: :ok)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "product-configurator-notice",
            partial: "admin/product_configurators/notice",
            locals: { message: message, error: error }
          ),
          turbo_stream.replace(
            "product_configurator_content",
            partial: "admin/product_configurators/configurator",
            locals: {
              product: @product,
              product_color_parts: @product_color_parts,
              rals: @rals,
              finishes: @finishes
            }
          )
        ], status: status
      end
      format.html do
        redirect_to admin_product_configurator_path(@product), notice: message
      end
    end
  end

  def resolve_palette_name(palette_name, part_label)
    return palette_name if palette_name.present?

    base_label = part_label.presence || "Part"
    "#{@product.name} - #{base_label}"
  end

  def part_params
    params.require(:product_color_part).permit(:code, :label, :palette_name)
  end

  def create_item_params
    attrs = params.require(:color_palette_item).permit(:ral_id, :finish_id, :paid_option).to_h.symbolize_keys
    attrs[:finish_id] = attrs[:finish_id].presence
    attrs[:paid_option] = ActiveModel::Type::Boolean.new.cast(attrs[:paid_option])
    attrs
  end

  def update_item_params
    attrs = params.require(:color_palette_item).permit(:paid_option).to_h.symbolize_keys
    attrs[:paid_option] = ActiveModel::Type::Boolean.new.cast(attrs[:paid_option])
    attrs
  end

  def finish_params
    params.require(:finish).permit(:code, :label)
  end
end
