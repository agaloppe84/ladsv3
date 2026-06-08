class AdminV2::CategoryScopedController < AdminV2::BaseController
  before_action :set_category

  private

  def set_category
    @category = Category.find(params[:category_id])
    track_admin_v2_context(@category)
  end

  def render_category_streams(*streams, level: :success, message:, event_type: :update, status: :ok, metadata: {})
    render turbo_stream: [
      *streams,
      *admin_v2_feedback_streams(
        level,
        message,
        event_type: event_type,
        resource: @category,
        metadata: metadata,
        status_code: Rack::Utils.status_code(status)
      )
    ], status: status
  end

  def render_category_feedback(level:, message:, event_type: :server, status: :ok, metadata: {})
    render turbo_stream: admin_v2_feedback_streams(
      level,
      message,
      event_type: event_type,
      resource: @category,
      metadata: metadata,
      status_code: Rack::Utils.status_code(status)
    ), status: status
  end

  def attach_category_upload(field:, attachment:, success_message:)
    blob = ActiveStorage::Blob.find_signed!(params.require(field))
    validation = AdminV2::UploadPolicy.validate_blob(blob, field)

    unless validation.valid?
      purge_rejected_upload(blob)
      return render_category_upload_error(field, validation.message)
    end

    previous_blob = attached_blob_for(attachment)

    attachment.attach(blob)
    purge_replaced_upload(previous_blob, blob)
    @category.reload

    render_category_streams(
      *Array(yield),
      level: :success,
      message: success_message,
      event_type: :upload,
      metadata: upload_metadata(field)
    )
  rescue ActionController::ParameterMissing
    render_category_upload_error(field, "#{AdminV2::UploadPolicy.label(field)} manquante. Relance l'upload.")
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    render_category_upload_error(field, "#{AdminV2::UploadPolicy.label(field)} invalide. Relance l'upload.")
  rescue ActiveRecord::RecordInvalid, ActiveStorage::IntegrityError => error
    purge_rejected_upload(blob)
    render_category_upload_error(field, "#{AdminV2::UploadPolicy.label(field)} refusée : #{error.message}.")
  rescue StandardError => error
    Rails.logger.error("[AdminV2 category upload] #{error.class}: #{error.message}")
    purge_rejected_upload(blob)
    render_category_upload_error(field, "#{AdminV2::UploadPolicy.label(field)} impossible à attacher. Vérifie le fichier puis réessaie.")
  end

  def category_row_stream
    turbo_stream.replace(
      "admin_v2_category_#{@category.id}",
      partial: "admin_v2/categories/row",
      locals: { category: category_with_count }
    )
  end

  def drawer_summary_stream
    turbo_stream.replace(
      "admin_v2_category_drawer_summary",
      partial: "admin_v2/categories/drawer_summary",
      locals: { category: @category }
    )
  end

  def drawer_header_stream
    turbo_stream.replace(
      "admin_v2_category_drawer_header",
      partial: "admin_v2/categories/drawer_header",
      locals: { category: @category }
    )
  end

  def details_panel_stream
    turbo_stream.replace(
      "admin_v2_category_details",
      partial: "admin_v2/categories/panels/details",
      locals: { category: @category }
    )
  end

  def appearance_panel_stream
    turbo_stream.replace(
      "admin_v2_category_appearance",
      partial: "admin_v2/categories/panels/appearance",
      locals: { category: @category }
    )
  end

  def hero_image_panel_stream
    turbo_stream.replace(
      "admin_v2_category_hero_image",
      partial: "admin_v2/categories/panels/hero_image",
      locals: { category: @category }
    )
  end

  def publication_panel_stream
    turbo_stream.replace(
      "admin_v2_category_publication",
      partial: "admin_v2/categories/panels/publication",
      locals: { category: @category }
    )
  end

  def category_with_count
    Category
      .left_joins(:products)
      .select("categories.*, COUNT(products.id) FILTER (WHERE products.type IS NULL) AS admin_v2_products_count")
      .where(categories: { id: @category.id })
      .group("categories.id")
      .first || @category
  end

  def render_category_upload_error(field, message)
    render_category_feedback(
      level: :error,
      message: message,
      event_type: :error,
      status: :unprocessable_entity,
      metadata: upload_metadata(field)
    )
  end

  def upload_metadata(field)
    { source: "upload", field: field.to_s }
  end

  def purge_rejected_upload(blob)
    return if blob.blank?
    return if blob.attachments.exists?

    blob.purge_later
  end

  def purge_replaced_upload(previous_blob, current_blob)
    return if previous_blob.blank?
    return if previous_blob.id == current_blob.id
    return if previous_blob.attachments.exists?

    previous_blob.purge_later
  end

  def attached_blob_for(attachment)
    return unless attachment.respond_to?(:attached?) && attachment.attached?
    return unless attachment.respond_to?(:blob)

    attachment.blob
  end
end
