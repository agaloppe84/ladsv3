class AdminV2::EventsController < AdminV2::BaseController
  def index
    base_scope = Event.all

    @total_events = base_scope.count
    @events = base_scope.order(start_date: :desc, updated_at: :desc)

    query = params[:query].to_s.strip
    if query.present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)
      @events = @events.where("events.title ILIKE :query OR events.content ILIKE :query", query: "%#{sanitized_query}%")
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          store_nav_stream(:events),
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/events/index_frame",
            locals: { events: @events, total_events: @total_events }
          )
        ]
      end
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new(
      start_date: Time.current.change(sec: 0),
      end_date: 2.days.from_now.change(sec: 0)
    )
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "admin_v2_main",
              partial: "admin_v2/events/edit_frame",
              locals: { event: @event }
            ),
            turbo_stream.replace(
              "admin_v2_drawer",
              partial: "admin_v2/events/drawer_frame",
              locals: { event: @event }
            ),
            store_nav_stream(:events),
            turbo_stream_flash(:success, "Event##{@event.id} created")
          ]
        end
        format.html { redirect_to edit_admin_v2_event_path(@event), notice: "Event créé" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @event = Event.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/events/edit_frame",
            locals: { event: @event }
          ),
          turbo_stream.replace(
            "admin_v2_drawer",
            partial: "admin_v2/events/drawer_frame",
            locals: { event: @event }
          ),
          store_nav_stream(:events)
        ]
      end
      format.html
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :content, :start_date, :end_date)
  end
end
