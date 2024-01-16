class RunsController < ApplicationController
	require 'jwt'
	require 'openssl'

	before_action :authorize_access_token
	before_action :authenticate_api_key
	before_action :set_run, only: [:show, :update, :destroy]
  
	# GET /runs
	def index
		@runs = Run.all
		render json: @runs
	end

	# GET /runs/1
	def show
		render json: @run
	end

	# POST /runs
	def create
		@run = Run.new(run_params)

		if @run.save
			render json: @run, status: :created, location: @run
		else
			render json: @task.errors, status: :unprocessable_entity
		end
	end

	#PATCH/PUT /runs/1
	def update
		if @run.update(run_params)
			render json: @run
		else
			render json: @run.errors, status: :unprocessable_entity
		end
	end

	#DELETE /runs/1
	def destroy
		@run.destroy
	end

	private

	def authorize_access_token
		access_token = request.headers['Authorization']
		unless valid_access_token?(access_token.split(' ').last)
			render json: { error: 'Unauthorized' }, status: :unauthorized
		end	
	end

	def authenticate_api_key
		api_key = request.headers['Api-Key']
		unless valid_api_key?(api_key)
			render json: { error: 'Invalid API key' }, status: :unauthorized
		end
	end

	def valid_access_token?(token)
		file_path = Rails.root.join('app', 'controllers', 'dev-aofo20pf12qkj6io.pem')
		x509_certificate = OpenSSL::X509::Certificate.new(File.read(file_path))
		public_key = x509_certificate.public_key		
		begin
			decode_token = JWT.decode(token, public_key, true, { iss: Rails.application.credentials.iss, verify_iss: true, aud: Rails.application.credentials.aud, verify_aud: true, algorithm: 'RS256' })
			#If no rescue blocks are hit, return true
			return true
		rescue JWT::ExpiredSignature
			render json: { error: 'Expired Access Token' }, status: :unauthorized
		rescue JWT::InvalidIssuerError
			render json: { error: 'Invalid Issuer' }, status: :unauthorized
		rescue JWT::InvalidAudError
			render json: { error: 'Invalid Audience' }, status: :unauthorized
		rescue StandardError => e
			logger.error("Error: #{e.message}")
		end
	end

	def valid_api_key?(api_key)
		stored_api_key = Rails.application.credentials.api_key
		api_key == stored_api_key
	end
		
	def set_run
		@run = Run.find(params[:id])
	end

	def run_params
		params.require(:run).permit(:runNumber, :duration, :distance, :calories, :averagePace, :averageHR)
	end
end
