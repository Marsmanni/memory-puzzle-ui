function Encrypt-Text {
    param (
        [string]$PlainText,
        [string]$Key
    )
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($Key.PadRight(32).Substring(0,32))
    $aes.IV = [byte[]](1..16)
    $encryptor = $aes.CreateEncryptor()

    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.FeedbackSize = 128
    $aes.KeySize = 256
    $aes.BlockSize = 128

    $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
    [Convert]::ToBase64String($encryptedBytes)
}

function Decrypt-Text {
    param (
        [string]$EncryptedBase64,
        [string]$Key
    )
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($Key.PadRight(32).Substring(0,32))
    $aes.IV = [byte[]](1..16)
    $decryptor = $aes.CreateDecryptor()
    $encryptedBytes = [Convert]::FromBase64String($EncryptedBase64)
    $plainBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    [System.Text.Encoding]::UTF8.GetString($plainBytes)
}

Write-Host "========== Starting deployment =========="

Write-Host "Running flutter clean..."
flutter clean

Write-Host "Building Flutter web app..."
flutter build web

# Set your encryption key (must be 32 chars for AES-256)
$encryptionKey = "ThisIsMySuperSecretKeyLOL1234567"

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



Write-Host "Ensuring assets directory exists..."
$assetsPath = Join-Path $localFolder "assets/assets"
New-Item -Path $assetsPath -ItemType Directory -Force | Out-Null

Write-Host "Creating deployment info string..."
$deploymentInfo = @"
version: $version
deploymentTime: $timestamp
gitCommit: $gitCommit
"@


Write-Host "Deployment info:`n$deploymentInfo"

Write-Host "Encrypting deployment info..."
$encryptedInfo = Encrypt-Text -PlainText $deploymentInfo -Key $encryptionKey
Write-Host "Encrypted info (base64, length $($encryptedInfo.Length)): $encryptedInfo"

Write-Host "Decrypting to verify encryption..."
$deploymentInfoNew = Decrypt-Text -EncryptedBase64 $encryptedInfo -Key $encryptionKey
Write-Host "Decrypted info:`n$deploymentInfoNew"

if ($deploymentInfo.Trim() -ne $deploymentInfoNew.Trim()) { 
    Write-Error "Encryption/Decryption mismatch! Aborting deployment."
    break
} else {
    Write-Host "Encryption/Decryption check passed."
}
$path = Join-Path $assetsPath "deployment.txt"
Write-Host "Saving encrypted deployment info to assets, path: $path..."
Set-Content -Path $path -Value $encryptedInfo -Encoding ascii


Write-Host "Preparing WinSCP FTP script..."
$scriptPath = "C:\Sources\Flutter\MemoryPuzzleUI\winscp_ftp_script.txt"
@"
open ftp://${ftpUser}:$ftpPass@$ftpHost
cd $remoteFolder
put -filemask="|index.html" $localFolder\*
exit
"@ | Set-Content $scriptPath

Write-Host "Uploading files via WinSCP..."
& "$winscpExe" /script="$scriptPath"

Write-Host "Cleaning up temporary WinSCP script..."
Remove-Item $scriptPath

Write-Host "========== Deployment completed =========="
