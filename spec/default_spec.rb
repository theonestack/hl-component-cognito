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
      expect(properties["AutoVerifiedAttributes"]).to include("email")
      expect(properties["MfaConfiguration"]).to eq("ON")
    end

    it 'has password policy' do
      policy = properties["Policies"]["PasswordPolicy"]
      expect(policy["MinimumLength"]).to eq(8)
      expect(policy["RequireLowercase"]).to be true
      expect(policy["RequireNumbers"]).to be true
      expect(policy["RequireSymbols"]).to be true
      expect(policy["RequireUppercase"]).to be true
    end

    it 'has schema attributes' do
      schema = properties["Schema"]
      expect(schema).to include(
        {
          "Name" => "email",
          "Required" => true,
          "Mutable" => true,
          "StringAttributeConstraints" => {
            "MinLength" => "0",
            "MaxLength" => "2048"
          }
        }
      )
    end
  end

  context 'Resource IdentityPool' do
    let(:properties) { template["Resources"]["IdentityPool"]["Properties"] }

    it 'has basic properties' do
      expect(properties["IdentityPoolName"]).to eq({"Fn::Sub"=>"${EnvironmentName}-test-identity-pool"})
      expect(properties["AllowUnauthenticatedIdentities"]).to be false
    end

    it 'has cognito identity providers' do
      providers = properties["CognitoIdentityProviders"]
      expect(providers).to include(
        {
          "ClientId" => "test-client",
          "ProviderName" => "test-provider",
          "ServerSideTokenCheck" => true
        }
      )
    end
  end

  context 'Outputs' do
    let(:outputs) { template["Outputs"] }

    it 'has user pool id' do
      expect(outputs["UserPoolId"]).to include(
        "Value" => {"Ref"=>"UserPool"}
      )
    end

    it 'has identity pool id' do
      expect(outputs["IdentityPoolId"]).to include(
        "Value" => {"Ref"=>"IdentityPool"}
      )
    end
  end
end
