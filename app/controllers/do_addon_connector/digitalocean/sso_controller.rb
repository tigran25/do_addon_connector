class DoAddonConnector::Digitalocean::SsoController < DoAddonConnector::ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    
    @customer = DoAddonConnector::Customer.find_by(key: params[:resource_uuid])
    if @customer.present? && resource_token == params[:token] 
      @sso_event = DoAddonConnector::SsoEvent.create!(
        resource_uuid: params[:resource_uuid],
        # resource_token: params[:token],
        # timestamp: params[:timestamp],
        email: params[:email]
      )
      
      sign_in_action if @sso_event.present?
    else
      # do not auth
      logger.info("********* Failed Login ********")
      logger.info("System Salt: #{ENV['DO_SSOSALT']}")
      logger.info("Presented Params: #{params}")
      logger.info("Presented Token: #{params[:token]}")
      logger.info("Expected Token: #{resource_token}")
      render nothing: true, status: '401'
    end
  end

  private 
  
  def resource_token
    Digest::SHA256.hexdigest("#{params[:timestamp]}:#{ENV['DO_SSOSALT']}:#{params[:resource_uuid]}")
  end

  def current_protocol
    if Rails.env == "production"
      "https"
    else
      "http"
    end
  end

end
