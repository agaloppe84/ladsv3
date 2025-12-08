class Admin::RalsController < AdminController

  def index
    @rals = Ral.all
  end

  def show
    @ral = Ral.find(params[:id])
  end

  def edit
    @ral = Ral.find(params[:id])
  end

  def new
    @ral = Ral.new
  end

  def create
    @ral = Ral.new(ral_params)
    if @ral.save
      redirect_to admin_rals_path, notice: 'Ral ajouté'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @ral = Ral.find(params[:id])
    if @ral.update(ral_params)
      redirect_to admin_rals_path, notice: 'Ral modifié'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ral_params
    params.require(:ral).permit(:name, :name_en, :ref, :rgb, :hex, :collection)
  end
end