module OauthTrust
  extend ActiveSupport::Concern

  def client
    @client ||= Doorkeeper::Application.where(uid: params[:client_id]).first
  end

  def allowed_scopes
    allowed = Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(params[:scope], client.scopes)
    head :unprocessable_entity unless allowed
  end

  def default_scopes
    params[:scope] ||= client.default_scope.join(' ')
  end
end