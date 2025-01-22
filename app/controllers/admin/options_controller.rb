class Admin::OptionsController < AdminController

  def create
    @product = Product.find(params[:product_id])
    @new_option = @product.options.build
    puts "INTO OPTION CREATE VIA TURBO"
    if @new_option.save
      redirect_to edit_admin_product_path(@product), notice: "Option ajoutée"
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
