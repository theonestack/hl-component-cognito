CloudFormation do


  Cognito_UserPool :UserPool do
    UserPoolName pool_name
    AliasAttributes alias_attributes
    schema = user_schema.collect do |key, val|
      { Name: key,
          AttributeDataType: val['type'],
          Mutable: val['mutable'],
          Required: val['required'] }
    end

    Schema schema

  end

  if defined? domain_name and (not domain_name.nil?)
    CloudFormation_CustomResource('PoolDomainName') do
      ServiceToken FnGetAtt('ccrCognitoDN', 'Arn')
      Property 'UserPoolId', Ref(:UserPool)
      Property 'Domain', domain_name
      Property 'GenerateRandomIfNotAvailable', 'true'
    end

    Output('PoolDomainUrl') do
      Value(FnGetAtt('PoolDomainName', 'DomainFull'))
    end
    Output('PoolDomainName') do
      Value(FnGetAtt('PoolDomainName', 'Domain'))
    end
  end


  def user_pool_client(name, config)

    CloudFormation_CustomResource("PoolClient#{name}") do

      ServiceToken FnGetAtt('ccrCognitoUPC', 'Arn')

      Property 'UserPoolId', Ref(:UserPool)
      Property 'ClientName', config['name']

      if config.key? 'generate_secret'
        Property 'GenerateSecret', config['generate_secret']
      end

      if config.key? 'explicit_auth_flows'
        Property 'ExplicitAuthFlows', config['explicit_auth_flows']
      end

      if config.key? 'callback_urls'
        Property 'CallbackURLs', config['callback_urls']
      end

      if config.key? 'logout_urls'
        Property 'LogoutURLs', config['logout_urls']
      end

      if config.key? 'default_redirect_uri'
        Property 'DefaultRedirectURI', config['default_redirect_uri']
      end

      if config.key? 'read_attributes'
        Property 'ReadAttributes', config['read_attributes']
      end

      if config.key? 'write_attributes'
        Property 'WriteAttributes', config['write_attributes']
      end

      if config.key? 'refresh_token_validity'
        Property 'RefreshTokenValidity', config['refresh_token_validity']
      end

      if config.key? 'allowed_oauth_flows_userpool_client'
        Property 'AllowedOAuthFlowsUserPoolClient', config['allowed_oauth_flows_userpool_client']
      end

      if config.key? 'allowed_oauth_flows'
        Property 'AllowedOAuthFlows', config['allowed_oauth_flows']
      end

      if config.key? 'allowed_oauth_scopes'
        Property 'AllowedOAuthScopes', config['allowed_oauth_scopes']
      end

      if config.key? 'supported_identity_providers'
        Property 'SupportedIdentityProviders', config['supported_identity_providers']
      elsif config.key? 'allow_cognito_idp' and config['allow_cognito_idp']
        Property 'SupportedIdentityProviders', ['COGNITO']
      end

      if config.key? 'skip_update'
        Property 'SkipUpdate', config['skip_update']
      end

    end

    Output("PoolClient#{name}Id") do
      Value(FnGetAtt("PoolClient#{name}", 'UserPoolClient.ClientId'))
    end

    if (config.key? 'generate_secret') and (config['generate_secret'])
      if config.key? 'output_secret' and config['output_secret']
        Output("PoolClient#{name}Secret") do
          Value(FnGetAtt("PoolClient#{name}", 'UserPoolClient.ClientSecret'))
        end
      end
    end

  end

  def user_pool_group(name, config)
    Cognito_UserPoolGroup("UserGroup#{name}") do

      GroupName config['name']
      Description config['description']
      Precedence config['precedence'] if config.key? 'precedence'
      UserPoolId Ref(:UserPool)
    end
  end


  if defined? clients and (not clients.nil?)
    clients.each do |key, config|
      user_pool_client(key, config)
    end
  else
    user_pool_client(:defaultPoolClient, default_client)
  end


  if defined? groups and (not groups.nil?)
    groups.each do |key, config|
      user_pool_group(key, config)
    end
  else
    user_pool_group(:defaultUserGroup, default_user_group)
  end


  Output(:UserPoolId) do
    Value(Ref(:UserPool))
  end

  Output(:UserPoolArn) do
    Value(FnGetAtt(:UserPool, 'Arn'))
  end

  Output(:UserPoolProviderURL) do
    Value(FnGetAtt(:UserPool, 'ProviderURL'))
  end

  Output(:UserPoolProviderName) do
    Value(FnGetAtt(:UserPool, 'ProviderName'))
  end

end