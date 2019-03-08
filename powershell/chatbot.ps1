
param(
    [string]
    $subscriptionId = "c91ab2b2-524e-4b8c-9feb-2ad11e7d2aba",

    [string]
    $resourceGroupName = "GlobantChatbot",

    [string]
    $resourceGroupLocation = "westus",

    [string]
    $deploymentName = "chatbot",

    [string]
    $qnaServicesTemplate = "https://raw.githubusercontent.com/juliananto/Chatbot_Assignment/master/templates/qnamaker_template.json",

    [string]
    $chatBotTemplate = "https://raw.githubusercontent.com/juliananto/Chatbot_Assignment/master/templates/bot_template.json",

    [Parameter(Mandatory=$true)]
    [string]
    $qna_maker_name,

    [Parameter(Mandatory=$true)]
    [string]
    $bot_name,

   [Parameter(Mandatory=$true)]
    [string]
    $app_Id ,

   [Parameter(Mandatory=$true, Position=0, HelpMessage="Password?")]
    [SecureString]
    $app_Pass 

    )

Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
#Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.compute", "microsoft.network");
if ($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach ($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if (!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else {
    Write-Host "Using existing resource group '$resourceGroupName'";
}


# $appInfo = New-AzureADApplication -DisplayName $bot_name -Oauth2Permissions []  #-IdentifierUris "https://sampleglobant1234.azurewebsites.net"

# $appInfo

# $appsecret1 = New-AzureADApplicationPasswordCredential -ObjectId $appInfo.ObjectId

# #$Secure_String_Pwd = ConvertTo-SecureString $appsecret1.Value -AsPlainText -Force
# $appsecret1


# Start the deployment
Write-Host "Deploying QNA Services";
$qnaparameters = @{
    qna    = $qna_maker_name
    appName = $qna_maker_name
}
$qnaoutput = New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $qnaServicesTemplate -TemplateParameterObject $qnaparameters -Verbose;


Start-Sleep -s 60

Write-Host "Create Knowledgebase";
[string]$key = $qnaoutput.Outputs.item("cognitivekey1").value

$uri = 'https://westus.api.cognitive.microsoft.com/qnamaker/v4.0/knowledgebases/create'
$headers = @{
    'Content-Type'              = 'application/json'
    'Ocp-Apim-Subscription-Key' = $key
}
$body = '{"name": "GlobantQnA","qnaList":[],"urls":[], "files": [{"fileName": "GlobantFAQ.docx","fileUri": "https://github.com/AashiqJ/Chatbot_Assignment/blob/master/GlobantFAQ.docx?raw=true"}]}'
$createKbResult = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

$createKbResult

Start-Sleep -s 15

Write-Host "Get Operation Details";
[string]$operationId = $createKbResult.operationId
[string]$operationState = "NotSucceeded"
$uri2 = -join ("https://westus.api.cognitive.microsoft.com/qnamaker/v4.0/operations/", $operationId);
$headers2 = @{
    'Ocp-Apim-Subscription-Key' = $key
}

do {
    $operationDetails = Invoke-RestMethod -Method Get -Uri $uri2 -Headers $headers2
    $operationDetails
    [string]$operationState = $operationDetails.operationState;
    Start-Sleep -s 15
}while ($operationState -ne "Succeeded")

$operationDetails

Write-Host "Publish Knowledgebase";

$uri3 = -join ("https://westus.api.cognitive.microsoft.com/qnamaker/v4.0", $operationDetails.resourceLocation);
$uri3
$headers3 = @{
    'Ocp-Apim-Subscription-Key' = $key
}
$body2 = ""
$publishKb = Invoke-RestMethod -Uri $uri3 -Method Post -Headers $headers3 -Body $body2
$publishKb

Write-Host "Get Endpoint Keys";

$uri4 = "https://westus.api.cognitive.microsoft.com/qnamaker/v4.0/endpointkeys";

$headers4 = @{
    'Ocp-Apim-Subscription-Key' = $key
}

$EndpointKeys = Invoke-RestMethod -Uri $uri4 -Method Get -Headers $headers4
$EndpointKeys

Write-Host "Get Knowledgebase Details";

$uri5 = -join ("https://westus.api.cognitive.microsoft.com/qnamaker/v4.0", $operationDetails.resourceLocation);

$headers5 = @{
    'Ocp-Apim-Subscription-Key' = $key
}

$KBDetails = Invoke-RestMethod -Uri $uri5 -Method Get -Headers $headers5
$KBDetails

[string]$storagename = -join ($bot_name,"sto")
[string]$serviceplan = -join ($bot_name,"sp")

$botparameters = @{
    botId    = $bot_name
    siteName = $bot_name
    storageAccountName = $storagename
    appId = $app_Id
    appSecret    = $app_Pass
    serverFarmId = $serviceplan
    QnAKnowledgebaseId    = $KBDetails.id
    QnAAuthKey = $EndpointKeys.primaryEndpointKey
    QnAEndpointHostName    = -join ('https://',$qna_maker_name,'.azurewebsites.net/qnamaker')
}
$chatbotoutput = New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $chatBotTemplate -TemplateParameterObject $botparameters -Verbose;

$chatbotoutput
