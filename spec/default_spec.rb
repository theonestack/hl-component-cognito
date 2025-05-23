require 'yaml'

describe 'default cognito configuration' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/cognito.compiled.yaml") }
  
  context 'Resource UserPool' do
    let(:properties) { template["Resources"]["UserPool"]["Properties"] }

    it 'has basic properties' do
      expect(properties["UserPoolName"]).to eq({"Fn::Sub"=>"${EnvironmentName}-test-user-pool"})
      expect(properties["AliasAttributes"]).to include("email")
    end

    it 'has schema attributes' do
      schema = properties["Schema"]
      expect(schema).to include(
        {
          "Name" => "email",
          "AttributeDataType" => "String",
          "Required" => true,
          "Mutable" => true
        }
      )
      expect(schema).to include(
        {
          "Name" => "name",
          "AttributeDataType" => "String",
          "Required" => true,
          "Mutable" => true
        }
      )
    end
  end

  context 'Resource UserPoolClient' do
    let(:properties) { template["Resources"]["UserPoolClient"]["Properties"] }

    it 'has basic properties' do
      expect(properties["ClientName"]).to eq({"Fn::Sub"=>"${EnvironmentName}-test-client"})
      expect(properties["GenerateSecret"]).to be true
      expect(properties["UserPoolId"]).to eq({"Ref"=>"UserPool"})
    end

    it 'has oauth configuration' do
      expect(properties["AllowedOAuthScopes"]).to include("openid", "profile")
      expect(properties["CallbackURLs"]).to include("http://localhost:3000")
      expect(properties["LogoutURLs"]).to include("http://localhost:3000/logout")
      expect(properties["DefaultRedirectURI"]).to eq("http://localhost:3000/")
      expect(properties["AllowedOAuthFlows"]).to include("client_credentials")
      expect(properties["AllowedOAuthFlowsUserPoolClient"]).to be true
    end
  end

  context 'Resource UserGroup' do
    let(:properties) { template["Resources"]["UserGroupDefault"]["Properties"] }

    it 'has basic properties' do
      expect(properties["GroupName"]).to eq("default_group")
      expect(properties["Description"]).to eq("Default user group")
      expect(properties["Precedence"]).to eq(10)
      expect(properties["UserPoolId"]).to eq({"Ref"=>"UserPool"})
    end
  end

  context 'Outputs' do
    let(:outputs) { template["Outputs"] }

    it 'has user pool id' do
      expect(outputs["UserPoolId"]).to include(
        "Value" => {"Ref"=>"UserPool"}
      )
    end

    it 'has user pool client id' do
      expect(outputs["UserPoolClientId"]).to include(
        "Value" => {"Ref"=>"UserPoolClient"}
      )
    end
  end
end
