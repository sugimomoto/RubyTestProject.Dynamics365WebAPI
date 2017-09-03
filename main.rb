require 'httpclient'
require 'json'
require 'uri'

## Azure Ad から OAuthを用いてTokenの取得を行うためのClass
class AzureAdOauthManager
    attr_accessor :tenantId
    attr_accessor :clientId
    attr_accessor :clientSeacret
    attr_accessor :resourceUrl

    # コンストラクタ
    # Tenant ID：***.onmicrosoft.com
    # Client ID：XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX
    # Client Seacret： 
    # Resource URL https://XXX.crmX.dynamics.com/
    def initialize(tenantId, clientId, clientSeacret, resourceUrl)
        @tenantId = tenantId
        @clientId = clientId
        @clientSeacret = clientSeacret
        @resourceUrl = resourceUrl
    end

    # Tokenオブジェクトの取得
    def get_token()
        
        oauthUrl = "https://login.microsoftonline.com/#{@tenantId}/oauth2/token"
        
        #Client Credentials形式でAzureAdのTokenを取得
        requestBody = URI.escape("grant_type=client_credentials&client_id=#{@clientId}&client_secret=#{@clientSeacret}&resource=#{@resourceUrl}")
        header = {'Content-Type' => 'application/x-www-form-urlencoded'}
        client = HTTPClient.new
        res = client.post(oauthUrl,requestBody,header)

        JSON.parse(res.body)
    end
end

def Main()

    con = AzureAdOauthManager.new(
        'XXXX.onmicrosoft.com',
        'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX',
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        'https://XXXX.crmX.dynamics.com/')

    ## Tokenを取得
    token = con.get_token()

    ## HTTP Client を生成
    client = HTTPClient.new
    
    ## Request URL
    ## 取引先企業（Accounts）レコードを取得 上位5件 対象フィールドは名前（name）
    dynamicsUrl = "https://XXXX.api.crmX.dynamics.com/api/data/v8.2/accounts?$select=name&$top=5"

    #＃ Header Authorizationに取得したTokenを付与
    header =[
        ['Accept','application/json'],
        ['OData-MaxVersion','4.0'],
        ['OData-Version','4.0'],
        ['Authorization','Bearer ' + token['access_token']]
    ]

    
    res = client.get(dynamicsUrl,nil,header)

    ## 取引先企業レコード一覧を取得
    accounts = JSON.parse(res.body)['value']

    ## For で取引先企業を取得して、コンソールに企業名を出力
    for value in accounts do
        puts value['name']
    end
end