# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
	require 'googleauth'
	
	def create
		id_token = params[:idToken]
		
		client_id = Rails.application.credentials.google[:client_id]
		Rails.logger.info("client id: #{client_id}")
		begin
			payload = Google::Auth::IDTokens.verify_oidc(id_token, aud: client_id)
			# Successfully verified, use the payload to identify the user
			Rails.logger.info("Google Sign-In Payload: #{payload}")
			user = User.find_or_create_by(email: payload['email'])
			Rails.logger.info("User ID: #{user.id}, email: #{user.email}")
			render json: { success: true, user_id: user.id }
		rescue Google::Auth::IDTokens::VerificationError => e
			Rails.logger.info("Google Sign-In Error: #{e.message}")
			render json: { success: false, error: 'Invalid ID Token' }, status: :unauthorized
		end
	end
end
