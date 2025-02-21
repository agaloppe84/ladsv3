class Admin::OptionsController < AdminController

  def create
    if params[:product_id]
      @product = Product.find(params[:product_id])
    elsif params[:destock_product_id]
      @product = DestockProduct.find(params[:destock_product_id])
    end
    @new_option = @product.options.build

    if @new_option.save
      if params[:product_id]
        redirect_to edit_admin_product_path(@product), notice: "Option ajoutée"
      elsif params[:destock_product_id]
        redirect_to edit_admin_destock_product_path(@product), notice: "Option ajoutée"
      end
    else
      render :edit
    end
  end

  def destroy
    @option = Option.find(params[:id])
    @option.destroy

    puts "TOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOTOT"
    puts @option.inspect

    respond_to do |format|
      # format.turbo_stream do
      #   render turbo_stream: turbo_stream.remove("option_#{@option.id}")
      # end
      format.html { redirect_to edit_admin_product_path(@option.product), notice: "Option supprimée." }
    end
  end
end
