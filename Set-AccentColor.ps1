<#
.SYNOPSIS
  Set the Windows 11 accent colour from a single hex value.
.DESCRIPTION
  Writes the accent palette and colour keys under HKCU (no admin needed),
  with toggles for taskbar/Start, title bars, dark mode and transparency.
#>

# ===== CHANGE ONLY THESE =====
$Hex               = "474029"   # RRGGBB, no #  (any 000000-FFFFFF works)
$ApplyTaskbarStart = $true      # accent on taskbar + Start menu
$ApplyTitleBars    = $true      # accent on window title bars + borders
$DarkMode          = $true      # $false = light mode
$Transparency      = $false     # $true = translucent taskbar and Start
$SignOut           = $true      # sign out at the end so everything applies
# =============================

if ($Hex -notmatch '^[0-9A-Fa-f]{6}$') { Write-Host "Hex must be 6 characters (RRGGBB)." -ForegroundColor Red; return }

$r = [Convert]::ToInt32($Hex.Substring(0,2),16)
$g = [Convert]::ToInt32($Hex.Substring(2,2),16)
$b = [Convert]::ToInt32($Hex.Substring(4,2),16)

function Tint($t){ [byte[]](
  [math]::Round($r+(255-$r)*$t), [math]::Round($g+(255-$g)*$t), [math]::Round($b+(255-$b)*$t), 0) }
function Shade($s){ [byte[]](
  [math]::Round($r*$s), [math]::Round($g*$s), [math]::Round($b*$s), 0) }

$palette = [byte[]]( (Tint 0.6) + (Tint 0.4) + (Tint 0.2) + [byte[]]($r,$g,$b,0) +
                     (Shade 0.85) + (Shade 0.7) + (Shade 0.5) + [byte[]]($r,$g,$b,0) )

$abgr = [int](0xFF000000 -bor ($b -shl 16) -bor ($g -shl 8) -bor $r)   # accent keys (ABGR)
$argb = [int](0xC4000000 -bor ($r -shl 16) -bor ($g -shl 8) -bor $b)   # DWM colorization (ARGB)

$accent = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
$pers   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$dwm    = 'HKCU:\Software\Microsoft\Windows\DWM'
$desk   = 'HKCU:\Control Panel\Desktop'
New-Item $accent -Force | Out-Null

Set-ItemProperty $desk AutoColorization 0
Set-ItemProperty $accent AutoColorization 0 -ErrorAction SilentlyContinue
Set-ItemProperty $accent AccentPalette $palette -Type Binary
Set-ItemProperty $accent AccentColorMenu $abgr
Set-ItemProperty $accent StartColorMenu  $abgr

$light = if ($DarkMode) { 0 } else { 1 }
Set-ItemProperty $pers SystemUsesLightTheme $light
Set-ItemProperty $pers AppsUseLightTheme    $light
Set-ItemProperty $pers EnableTransparency   ([int]$Transparency)
Set-ItemProperty $pers ColorPrevalence      ([int]$ApplyTaskbarStart)   # taskbar + Start

Set-ItemProperty $dwm ColorPrevalence ([int]$ApplyTitleBars)            # title bars + borders
Set-ItemProperty $dwm AccentColor $abgr
Set-ItemProperty $dwm ColorizationColor $argb

"Applied #$Hex | Taskbar+Start: $ApplyTaskbarStart | Title bars: $ApplyTitleBars"
"Palette: " + ($palette[0..15] -join ',')
if ($SignOut) { Start-Sleep 3; shutdown /l }

# ===== COLOURS WINDOWS ACCEPTS =====
# Any 24-bit colour (000000-FFFFFF). The 48 presets from Settings > Personalization > Colors:
# Yellows/Oranges: FFB900 F7630C CA5010 DA3B01 EF6950 FF8C00
# Reds/Pinks:      D13438 FF4343 E74856 E81123 EA005E C30052
# Purples:         E3008C BF0077 C239B3 9A0089 8E8CD8 6B69D6 8764B8 744DA9 B146C2 881798
# Blues:           0078D7(default) 0063B1 0099BC 2D7D9A 68768A 515C6B 69797E 4A5459
# Teals/Greens:    00B7C3 038387 00B294 018574 00CC6A 10893E 107C10 498205 567C73 486860 647C64 525E54
# Grays/Browns:    7A7574 5D5A58 767676 4C4A48 847545 7E735F
# Avoid very light colours for taskbar/Start: text becomes unreadable.
