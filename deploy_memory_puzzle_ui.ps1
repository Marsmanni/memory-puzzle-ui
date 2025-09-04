flutter clean

flutter build web


function Encrypt-Text {
    param (
        [string]$PlainText,
        [string]$Key
    )
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($Key.PadRight(32).Substring(0,32))
    $aes.IV = [byte[]](1..16)
    $encryptor = $aes.CreateEncryptor()
    $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
    [Convert]::ToBase64String($encryptedBytes)
}

# Set your encryption key (must be 32 chars for AES-256)
$encryptionKey = "ThisIsMySuperSecretKeyLOL123"

# Set your FTP credentials and paths
$ftpHost = "ftp.tectrics.de"
$ftpUser = "298260-ftp"
$ftpPass = $env:FTP_PASS
$localFolder = "C:\Sources\Flutter\MemoryPuzzleUI\build\web"
$remoteFolder = "/webseiten/domains/_rotblaugelb/_rotrotrot/memory/"

# Path to WinSCP.com (update if installed elsewhere)
$winscpExe = "C:\Program Files (x86)\WinSCP\WinSCP.com"

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$version = "1.2.3" # Set your version here, or read from a file
$gitCommit = git log -1 --pretty=format:"%h %ad %s" --date=format:"%H:%M %d.%m.%Y"

# Ensure the 'assets' directory exists
$assetsPath = Join-Path $localFolder "assets/assets"
New-Item -Path $assetsPath -ItemType Directory -Force | Out-Null

# Create the deployment.txt file with version, deploymentTime, and gitCommit
$deploymentInfo = @"
version: $version
deploymentTime: $timestamp
gitCommit: $gitCommit
"@

$encryptedInfo = Encrypt-Text -PlainText $deploymentInfo -Key $encryptionKey

Set-Content -Path (Join-Path $assetsPath "deployment.txt") -Value $encryptedInfo
# ----------------------------------------

# Create a temporary WinSCP script file
#$scriptPath = "$env:TEMP\winscp_ftp_script.txt"
$scriptPath = "C:\Sources\Flutter\MemoryPuzzleUI\winscp_ftp_script.txt"

@"
open ftp://${ftpUser}:$ftpPass@$ftpHost
cd $remoteFolder
put -filemask="|index.html" $localFolder\*
exit
"@ | Set-Content $scriptPath

# Run WinSCP with the script
& "$winscpExe" /script="$scriptPath"

# Remove the temporary script file
Remove-Item $scriptPath

