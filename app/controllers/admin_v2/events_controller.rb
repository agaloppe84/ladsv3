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
    @events, @pagination = paginate_admin_v2(@events)

    respond_to do |format|
      format.html do
        if events_results_frame_request?
          render partial: "admin_v2/events/results_frame", locals: { events: @events, pagination: @pagination }, layout: false
        else
          render
        end
      end
      format.turbo_stream { render turbo_stream: events_index_stream }
    end
  end

  def show
    @event = Event.find(params[:id])
    track_admin_v2_context(@event)
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
          events, pagination = paginate_admin_v2(Event.order(start_date: :desc, updated_at: :desc))

          render turbo_stream: [
            turbo_stream.replace(
              "admin_v2_main",
              partial: "admin_v2/events/index_frame",
              locals: { events: events, total_events: Event.count, pagination: pagination }
            ),
            turbo_stream.replace(
              "admin_v2_drawer",
              partial: "admin_v2/events/drawer_frame",
              locals: { event: @event }
            ),
            store_nav_stream(:events),
            *admin_v2_feedback_streams(:success, "Event##{@event.id} created", event_type: :create, resource: @event, status_code: 200)
          ]
        end
        format.html { redirect_to admin_v2_events_path, notice: "Event créé" }
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
    track_admin_v2_context(@event)

    respond_to do |format|
      format.html do
        @drawer_only = turbo_frame_request?

        if @drawer_only
          render :edit, layout: false
        else
          @total_events = Event.count
          @events, @pagination = paginate_admin_v2(Event.order(start_date: :desc, updated_at: :desc))
          render
        end
      end
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "admin_v2_drawer",
            partial: "admin_v2/events/drawer_edit_frame",
            locals: { event: @event }
          ),
          store_nav_stream(:events)
        ]
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :content, :start_date, :end_date)
  end

  def events_results_frame_request?
    request.headers["Turbo-Frame"] == "admin_v2_events_results"
  end

  def events_index_stream
    return events_results_stream if events_results_frame_request?

    [
      store_nav_stream(:events),
      turbo_stream.replace(
        "admin_v2_main",
        partial: "admin_v2/events/index_frame",
        locals: { events: @events, total_events: @total_events, pagination: @pagination }
      )
    ]
  end

  def events_results_stream
    turbo_stream.replace(
      "admin_v2_events_results",
      partial: "admin_v2/events/results_frame",
      locals: { events: @events, pagination: @pagination }
    )
  end
end
