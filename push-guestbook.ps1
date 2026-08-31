param (
    [Parameter(Mandatory=$true, HelpMessage="The name of your Azure Container Registry")]
    [string]$AcrName,

    [Parameter(Mandatory=$false, HelpMessage="The source image to import")]
    [string]$SourceImage = "docker.io/nginx:alpine",

    [Parameter(Mandatory=$false, HelpMessage="The target repository and tag in your ACR")]
    [string]$TargetImage = "ks-guestbook-demo:0.2"
)

Write-Host "Importing $SourceImage into ACR '$AcrName' as '$TargetImage'..." -ForegroundColor Cyan

# We use 'az acr import' which avoids needing to run docker pull/tag/push locally
az acr import --name $AcrName --source $SourceImage --image $TargetImage

if ($LASTEXITCODE -eq 0 -or $?) {
    Write-Host "Successfully imported image to ACR!" -ForegroundColor Green
} else {
    Write-Host "Failed to import image to ACR." -ForegroundColor Red
    exit 1
}
