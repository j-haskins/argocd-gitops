param (
    [Parameter(Mandatory=$true, HelpMessage="The name of your Azure Container Registry")]
    [string]$AcrName,

    [Parameter(Mandatory=$false, HelpMessage="The source image to import")]
    [string]$SourceImage = "docker.io/nginx:alpine",

    [Parameter(Mandatory=$false, HelpMessage="The target repository and tag in your ACR")]
    [string]$TargetImage = "ks-guestbook-demo:0.2"
)

Write-Host "Importing $SourceImage into ACR '$AcrName' as '$TargetImage'..." -ForegroundColor Cyan

# We use local docker commands because 'az acr import' often fails with 401 Unauthorized from Docker Hub due to rate limits
az acr login --name $AcrName
docker pull $SourceImage
docker tag $SourceImage "$AcrName.azurecr.io/$TargetImage"
docker push "$AcrName.azurecr.io/$TargetImage"

if ($LASTEXITCODE -eq 0 -or $?) {
    Write-Host "Successfully imported image to ACR!" -ForegroundColor Green
} else {
    Write-Host "Failed to import image to ACR." -ForegroundColor Red
    exit 1
}
