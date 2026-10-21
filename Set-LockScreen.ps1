<#
.SYNOPSIS
  Set the Windows 11 lock screen image via PersonalizationCSP registry keys.
.NOTES
  Run as Administrator. Officially supported on Pro/Enterprise/Education.
  May be ignored on Home.
#>

# ===== CHANGE ONLY THIS =====
$src = "$env:USERPROFILE\Pictures\lockscreen.jpg"   # your image (jpg/png)
# ============================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run PowerShell as Administrator." -ForegroundColor Red; return
}

if (Test-Path $src) {
    # Copy to a location the system account can always read
    $dir = "C:\Users\Public\Pictures"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $img = Join-Path $dir ("lockscreen" + [IO.Path]::GetExtension($src))
    Copy-Item $src $img -Force

    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    New-Item -Path $key -Force | Out-Null
    New-ItemProperty -Path $key -Name LockScreenImagePath   -Value $img -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $key -Name LockScreenImageUrl    -Value $img -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $key -Name LockScreenImageStatus -Value 1    -PropertyType DWord  -Force | Out-Null
    "Lock screen set to: $img  (press Win+L to test)"
} else {
    Write-Host "Image not found. Check the path." -ForegroundColor Red
}
