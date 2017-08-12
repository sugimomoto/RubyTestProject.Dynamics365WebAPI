require 'httpclient'
require 'json'
require 'uri'

class AzureAdOauthManager
    attr_accessor :tenantId
    attr_accessor :clientId
    attr_accessor :clientSeacret
    attr_accessor :resourceUrl

    #コンストラクタ
    def initialize(tenantId, clientId, clientSeacret, resourceUrl)
        @tenantId = tenantId
        @clientId = clientId
        @clientSeacret = clientSeacret
        @resourceUrl = resourceUrl
    end

    #Tokenオブジェクトの取得
    def get_token
        
        oauthUrl = "https://login.microsoftonline.com/#{@tenantId}/oauth2/token"
        
        #Client Credentials形式でAzureAdのTokenを取得
        requestBody = URI.escape("grant_type=client_credentials&client_id=#{@clientId}&client_secret=#{@clientSeacret}&resource=#{@resourceUrl}")
        header = {'Content-Type' => 'application/x-www-form-urlencoded'}
        client = HTTPClient.new
        res = client.post(oauthUrl,requestBody,header)

        JSON.parse(res.body)
    end
end

con = AzureAdOauthManager.new('sugi43.onmicrosoft.com','517b7991-bb75-44df-8adf-1cf9c0a65c1a','Z26i0/pCYeV44gqdUYEmbYqztrNTUbLBDARMSR04Wu0=','https://sugi43.crm7.dynamics.com/')

token = con.get_token()

dynamicsUrl = "https://sugi43.api.crm7.dynamics.com/api/data/v8.2/accounts?$select=name&$top=5"
header =[['Accept','application/json'],['OData-MaxVersion','4.0'],['OData-Version','4.0'],['Authorization','Bearer ' + token['access_token']]]

client = HTTPClient.new

res = client.get(dynamicsUrl,nil,header)


p res