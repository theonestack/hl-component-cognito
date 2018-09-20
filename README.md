![build-status](https://travis-ci.com/theonestack/hl-component-cognito.svg?branch=master)

### Cfhighlander cognito component

Uses [cloudformation-custom-resources-js](https://github.com/base2Services/cloudformation-custom-resources-nodejs) 
as a custom resource code for creating cognito clients and custom domain names.  

```bash

# install highlander gem
$ gem install cfhighlander

# build and validate standalone component
$ cfcompile --validate cognito

```
### Usage

Creates Cognito UserPools. Allows adding User pool clients and custom domain name. Note that
this functionality is not supported natively via CloudFormation, and is implemented through 
custom resources. Consume component with `Component 'cognito'` in your cfhiglhander template for default behaviour.
Read more on [cfhighlander page](https://github.com/theonestack/cfhighlander) on consuming, extending and inlining components.  

### Configuration options

Look at `cognito.config.yaml` for format of configuration file

- `pool_name` - Explicit Cognito UserPool name
- `user_schema` - Defines user attributes. 
- `groups` - Create UserGroups alongside with the pool. Allows defining name and description
- `clients` - Cognito OAuth clients to authorize against the pool. Look at `default_client` section
of the config file for required structure
- `domain_name` - Custom domain name for authentication over the web on `https://${domain_name}.auth.${aws_region}.amazoncognito.com` url
- `ccr` - Required for custom resources to be rendered. Do **NOT** alter this configuration value

### Parameters

NONE

### Outputs

`UserPoolId` - PoolId

`UserPoolArn` - Pool Amazon Resource Name (ARN) 

`UserPoolProviderURL` - Provider URL

`UserPoolProviderName` - Provider Name

`PoolDomainUrl` - *(Optional)* if custom domain name is set, this will render the full url

`PoolDomainName`- *(Optional)* if custom domain name is set, this will render the domain name

`PoolClient${clietNname}Id` - *(Optional)* client id for every defined client

`PoolClient${clietNname}Secret` - *(Optional)* if client secret is configured on defined client