class PackagesController < ApplicationController
  # We allowing anonymous access
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_package, except: [:index, :new, :create]
  before_action :limit_edit, only: [:edit, :update, :delete]

  # GET /packages
  # GET /packages.json
  def index
    @packages = Package.allowed_for(current_user)
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
  end

  # GET /packages/new
  def new
    @package = Package.new
  end

  # GET /packages/1/edit
  def edit
  end

  # POST /packages
  # POST /packages.json
  def create
    @package = Package.new(package_params)
    @package.user = current_user
    respond_to do |format|
      if @package.save
        @package.reload
        format.html { redirect_to @package, notice: 'Package was successfully created.' }
        format.json { render :show, status: :created, location: @package }
      else
        format.html { render :new }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packages/1
  # PATCH/PUT /packages/1.json
  def update
    if package_params[:attachment] == 'purge'
      # We can't purge files, just because some of the customers can be in a middle of update
      @package.parts.purge_later
      head :no_content
    elsif package_params[:attachment] == 'store'
      # TODO: Move to files to keep all versions for this package
      JoinPartsToFileJob.perform_later(@package, package_params[:checksum])
      head :no_content
    elsif package_params[:part].present?
      @package.parts.attach(package_params[:part])
      head :no_content
    else
      respond_to do |format|
        if @package.update(package_params)
          format.html { redirect_to @package, notice: 'Package was successfully updated.' }
          format.json { render :show, status: :ok, location: @package }
        else
          format.html { render :edit }
          format.json { render json: @package.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.json
  def destroy
    respond_to do |format|
      if @package.discard
        format.html { redirect_to packages_url, notice: 'Package was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_package
    @package = Package.find_by_alias(current_user, package_params[:id])
  end

  def limit_edit
    head :forbidden if (current_user.endpoint.present? || (@package.user != current_user))
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # TODO: require(:package)
  # <input type="text" name="client[name]" value="Acme" />
  def package_params
    params.permit(:id, :name, :text, :version, :attachment, :part, :checksum)
  end

end
