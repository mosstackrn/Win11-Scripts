# 🎨 win11-theme-scripts

Two small PowerShell scripts that repaint parts of Windows 11 that the Settings app sometimes refuses to touch:

| Script | What it does | Needs admin? |
|---|---|---|
| `Set-AccentColor.ps1` | Paints your taskbar, Start menu and window title bars from **one hex code** | No |
| `Set-LockScreen.ps1` | Forces a lock screen image through the registry | **Yes** |

**Table of contents**
1. [Quick start (60 seconds)](#1-quick-start-60-seconds)
2. [How to run a .ps1 file](#2-how-to-run-a-ps1-file)
3. [How to edit the scripts](#3-how-to-edit-the-scripts)
4. [Script 1: Set-AccentColor.ps1 explained line by line](#4-script-1-set-accentcolorps1-line-by-line)
5. [Script 2: Set-LockScreen.ps1 explained line by line](#5-script-2-set-lockscreenps1-line-by-line)
6. [Script 3: Reset-LockScreen.ps1 explained line by line](#6-script-3-reset-lockscreenps1-line-by-line)
7. [Is this safe? Backups and undo](#7-is-this-safe-backups-and-undo)
8. [Known limitations (the honest part)](#8-known-limitations-the-honest-part)
9. [Content creators: please credit](#9-content-creators-please-credit)
10. [Credits and license](#10-credits-and-license)

---

## 1. Quick start (60 seconds)

**Change the accent colour:**
1. Open `scripts/Set-AccentColor.ps1` in Notepad.
2. Change `$Hex = "474029"` to any colour you like.
3. Save, then in PowerShell run: `powershell -ExecutionPolicy Bypass -File .\scripts\Set-AccentColor.ps1`
4. Windows signs you out. **Save your work first.** It does not ask nicely.
5. Sign back in. Enjoy your new vibe.

**Change the lock screen:**
1. Put an image at `C:\Users\<you>\Pictures\lockscreen.jpg`.
2. Open PowerShell **as Administrator**.
3. Run: `powershell -ExecutionPolicy Bypass -File .\scripts\Set-LockScreen.ps1`
4. Press `Win + L` to look at your masterpiece.

---

## 2. How to run a .ps1 file

A `.ps1` file is a PowerShell script: a text file full of commands that PowerShell runs top to bottom. Windows is a bit paranoid about running them, so here are the ways in.

### Step A: Open PowerShell
- **Normal:** press `Win`, type `PowerShell`, press Enter.
- **Administrator** (needed for the lock screen script): press `Win + X`, then choose **Terminal (Admin)** or **Windows PowerShell (Admin)**. Click **Yes** on the prompt.

How to tell which one you're in: the admin window's title says "Administrator". If you're not sure, the lock screen script checks for you and politely yells in red text.

### Step B: go to the folder
```powershell
cd C:\path\to\win11-theme-scripts
```
Tip: in File Explorer, click the address bar, copy the path, and paste it after `cd `.

### Step C: run the script

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-AccentColor.ps1
```

### Wait, what's "ExecutionPolicy Bypass"?
Windows has a safety setting (the *execution policy*) that blocks scripts by default. `-ExecutionPolicy Bypass` here means "let **this one run** go ahead". It applies only to that single PowerShell process. It does **not** change your system's policy permanently, and it is not a hack. It's the normal way to run a script you downloaded and have read.

### Other ways (pick one)
- **Right-click the `.ps1` file, then "Run with PowerShell".** Easy, but the window may flash and vanish. Also, this does not give admin rights.
- **Paste the code directly** into an open PowerShell window. Works, but you can't easily re-run it.

### "File cannot be loaded because running scripts is disabled"
That is the execution policy. Use the `-ExecutionPolicy Bypass` command above.

### "File is blocked / came from another computer"
Right-click the file, **Properties**, tick **Unblock** at the bottom, then **OK**. Or run `Unblock-File .\scripts\*.ps1`.

---

## 3. How to edit the scripts

Open any `.ps1` file in **Notepad** (or VS Code if you're fancy). Every script has a section like this:

```powershell
# ===== CHANGE ONLY THESE =====
$Hex = "474029"
...
# =============================
```

**You only edit things inside that box.** Everything below it is the engine. Don't poke the engine unless you know what you're poking.

### Set-AccentColor.ps1 settings

| Setting | Values | What it does |
|---|---|---|
| `$Hex` | `"RRGGBB"` (6 characters, no `#`) | Your colour. `"FF0000"` red, `"00FF00"` green, `"0078D7"` Windows default blue |
| `$ApplyTaskbarStart` | `$true` / `$false` | Colour on the taskbar **and** Start menu (they share one switch, sorry) |
| `$ApplyTitleBars` | `$true` / `$false` | Colour on window title bars and borders |
| `$DarkMode` | `$true` / `$false` | Dark or light mode. Taskbar/Start colour only shows in **dark** mode |
| `$Transparency` | `$true` / `$false` | Glassy blur effect. `$false` gives a solid colour that looks closest to your hex |
| `$SignOut` | `$true` / `$false` | Sign out at the end so changes load. Set `$false` if you'd rather sign out yourself |

### How do I find a hex code?
Search "colour picker" in your browser, pick a colour, copy the 6 characters. Or use one of the 48 Windows presets listed at the bottom of `Set-AccentColor.ps1`. Very light colours make taskbar text unreadable. Windows will not save you from yourself.

### Set-LockScreen.ps1 settings
Only one: `$src = "...\lockscreen.jpg"`. Point it at your image. `.jpg` or `.png`. Use a quote-wrapped full path if it's somewhere unusual:
```powershell
$src = "D:\Wallpapers\my cool image.png"
```

### Editing rules that save you pain
- Keep the **quotes** around text values, and don't add spaces inside the hex.
- `$true` and `$false` have a `$`, no quotes, and are spelled exactly that way.
- Save the file before running it. Yes, everyone forgets.

---

## 4. Script 1: Set-AccentColor.ps1, line by line

**What it does in one sentence:** takes one hex colour, builds the shade palette Windows expects, and writes it to the registry so your taskbar, Start menu and title bars match.

**Why not just use Settings?** Sometimes Settings greys out or ignores the choice (this project started because of exactly that). The registry is where Settings stores these values anyway. We just write them ourselves.

**Where it writes:** only under `HKCU` (the current user's own registry area). No admin needed, no system files touched, other user accounts unaffected.

### The settings block
```powershell
$Hex = "474029"
$ApplyTaskbarStart = $true
$ApplyTitleBars = $true
$DarkMode = $true
$Transparency = $false
$SignOut = $true
```
These just create variables (labelled boxes holding values). Nothing happens yet. They're the knobs from section 3.

### Check the colour
```powershell
if ($Hex -notmatch '^[0-9A-Fa-f]{6}$') { Write-Host "Hex must be 6 characters (RRGGBB)." -ForegroundColor Red; return }
```
**Safety check.** If `$Hex` is not exactly 6 hex characters (0-9, A-F), it prints a red error and **stops** before touching anything. `return` means "leave the script now".

### Split the colour into red, green, blue
```powershell
$r = [Convert]::ToInt32($Hex.Substring(0,2),16)
$g = [Convert]::ToInt32($Hex.Substring(2,2),16)
$b = [Convert]::ToInt32($Hex.Substring(4,2),16)
```
A hex colour like `474029` is three pairs: `47` red, `40` green, `29` blue. `Substring` grabs a pair, and `ToInt32(..., 16)` converts it from hex to a normal number (0-255). So `474029` becomes r=71, g=64, b=41.

### The two helper functions
```powershell
function Tint($t){ [byte[]]( [math]::Round($r+(255-$r)*$t), [math]::Round($g+(255-$g)*$t), [math]::Round($b+(255-$b)*$t), 0) }
function Shade($s){ [byte[]]( [math]::Round($r*$s), [math]::Round($g*$s), [math]::Round($b*$s), 0) }
```
- **Tint** mixes your colour toward white. `Tint 0.6` means "60% of the way to white", giving a lighter version.
- **Shade** multiplies your colour toward black. `Shade 0.5` means "half as bright", giving a darker version.
- Each returns four bytes: red, green, blue, and a `0` (a padding byte Windows expects).

They only calculate. They don't change anything on your PC.

### Build the palette
```powershell
$palette = [byte[]]( (Tint 0.6) + (Tint 0.4) + (Tint 0.2) + [byte[]]($r,$g,$b,0) +
                     (Shade 0.85) + (Shade 0.7) + (Shade 0.5) + [byte[]]($r,$g,$b,0) )
```
Windows keeps an **8-colour palette** (32 bytes) for its accent: three light shades, your exact colour, three dark shades, then your colour again. This line glues the 8 pieces together. Those shades are what the taskbar, Start menu and buttons pull from.

### Convert to the formats the registry wants
```powershell
$abgr = [int](0xFF000000 -bor ($b -shl 16) -bor ($g -shl 8) -bor $r)
$argb = [int](0xC4000000 -bor ($r -shl 16) -bor ($g -shl 8) -bor $b)
```
Windows stores colours as one 32-bit number, but different keys use different byte orders:
- `$abgr`: alpha (FF = fully solid), then **B**lue, **G**reen, **R**ed. Used by the `Accent` keys.
- `$argb`: alpha (C4 = slightly see-through), then **R**ed, **G**reen, **B**lue. Used by the DWM key.

`-shl 16` slides a value 16 bits left, and `-bor` stacks the pieces together. If you ever see a negative number when reading these back, that's normal. It's the same bits displayed as signed.

### The registry paths
```powershell
$accent = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
$pers   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$dwm    = 'HKCU:\Software\Microsoft\Windows\DWM'
$desk   = 'HKCU:\Control Panel\Desktop'
```
Just shortcuts for four addresses in your registry. `HKCU` = your user only.

```powershell
New-Item $accent -Force | Out-Null
```
Creates the `Accent` key if it doesn't exist. `-Force` means "no error if it's already there". `Out-Null` hides the boring output.

### Write the settings
```powershell
Set-ItemProperty $desk AutoColorization 0
Set-ItemProperty $accent AutoColorization 0 -ErrorAction SilentlyContinue
```
Turns off "pick an accent colour from my wallpaper automatically", otherwise Windows overrides your colour. The second line is a belt-and-braces copy and is allowed to fail quietly.

```powershell
Set-ItemProperty $accent AccentPalette $palette -Type Binary
Set-ItemProperty $accent AccentColorMenu $abgr
Set-ItemProperty $accent StartColorMenu  $abgr
```
Writes the 8-colour palette, plus the main colour and the Start menu colour.

```powershell
$light = if ($DarkMode) { 0 } else { 1 }
Set-ItemProperty $pers SystemUsesLightTheme $light
Set-ItemProperty $pers AppsUseLightTheme    $light
Set-ItemProperty $pers EnableTransparency   ([int]$Transparency)
Set-ItemProperty $pers ColorPrevalence      ([int]$ApplyTaskbarStart)
```
- `$light`: Windows uses `0` for dark, `1` for light, so this flips your `$true/$false` into that.
- First two lines set dark/light for the system (taskbar) and apps.
- `EnableTransparency`: `[int]` turns `$true/$false` into `1/0`.
- `ColorPrevalence` in `Personalize` is the master switch for "show accent colour on Start and taskbar".

```powershell
Set-ItemProperty $dwm ColorPrevalence ([int]$ApplyTitleBars)
Set-ItemProperty $dwm AccentColor $abgr
Set-ItemProperty $dwm ColorizationColor $argb
```
Same idea for the **Desktop Window Manager** (the thing that draws window frames). `ColorPrevalence` here controls title bars and borders.

### Finish
```powershell
"Applied #$Hex | Taskbar+Start: $ApplyTaskbarStart | Title bars: $ApplyTitleBars"
"Palette: " + ($palette[0..15] -join ',')
if ($SignOut) { Start-Sleep 3; shutdown /l }
```
Prints a summary and the first 16 palette bytes (useful for checking what was written). If `$SignOut` is on, waits 3 seconds, then runs `shutdown /l` (**l = logoff**). It signs you out. It does not shut down or restart your PC.

### The comment block at the bottom
Lines starting with `#` are comments. Windows ignores them. They hold the preset colour list.

---

## 5. Script 2: Set-LockScreen.ps1, line by line

**What it does in one sentence:** copies your image to a folder the system can read, then tells Windows (via the registry) to use it as the lock screen image.

**Where it writes:** `HKLM` (machine-wide), hence **admin required**. Also writes one image file to `C:\Users\Public\Pictures`.

```powershell
$src = "$env:USERPROFILE\Pictures\lockscreen.jpg"
```
The path of **your** image. `$env:USERPROFILE` expands to your user folder, e.g. `C:\Users\Vikranth`.

```powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run PowerShell as Administrator." -ForegroundColor Red; return
}
```
**Admin check.** It asks Windows "is the current user an Administrator?" If not, it prints a red message and stops. Nothing is changed.

```powershell
if (Test-Path $src) {
```
Checks the image actually exists. If it doesn't, the `else` at the bottom prints "Image not found" and nothing is changed.

```powershell
    $dir = "C:\Users\Public\Pictures"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
```
Picks (and creates if needed) a shared folder. **Why?** The lock screen is loaded by the system, and files buried inside a personal profile folder can fail to load. The Public folder is readable by everyone.

```powershell
    $img = Join-Path $dir ("lockscreen" + [IO.Path]::GetExtension($src))
    Copy-Item $src $img -Force
```
Builds the new file name (`lockscreen.jpg` or `.png`, keeping your original extension) and **copies** your image there. Your original is untouched. `-Force` overwrites an older copy.

```powershell
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    New-Item -Path $key -Force | Out-Null
```
Address of the registry key that holds the lock screen override, created if missing. "CSP" is Windows' device-management settings system, which this borrows.

```powershell
    New-ItemProperty -Path $key -Name LockScreenImagePath   -Value $img -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $key -Name LockScreenImageUrl    -Value $img -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $key -Name LockScreenImageStatus -Value 1    -PropertyType DWord  -Force | Out-Null
```
The three values Windows reads:
- `LockScreenImagePath`: where the image file is.
- `LockScreenImageUrl`: same path, the second field the CSP expects.
- `LockScreenImageStatus`: `1` means "the image is set and ready".

```powershell
    "Lock screen set to: $img  (press Win+L to test)"
} else {
    Write-Host "Image not found. Check the path." -ForegroundColor Red
}
```
Success message, or the red "can't find your image" error.

---

## 6. Script 3: Reset-LockScreen.ps1, line by line

**What it does:** deletes the override key so Windows goes back to normal.

```powershell
if (-not (...IsInRole(...Administrator))) { ... return }
```
Same admin check as before.

```powershell
Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Recurse -Force -ErrorAction SilentlyContinue
```
Deletes the `PersonalizationCSP` key and everything inside it. `-Recurse` means "and its contents", `-Force` means "don't ask", and `SilentlyContinue` means "no error if it's already gone".

> ⚠️ This removes **the whole key**. If another program or a work/school policy also stored values in that key, they go too. On a normal personal PC, the key only holds what our script put there.

```powershell
"Lock screen override removed."
```
Confirmation message. Sign out and back in if the old image lingers.

---

## 7. Is this safe? Backups and undo

**Short answer:** it edits your registry, which is a bit like rearranging the furniture in the dark. Safe if you know where the furniture is. Here's the map.

### What the scripts DO
- Write a handful of values in specific registry keys (listed above).
- Copy one image to `C:\Users\Public\Pictures` (lock screen script).
- Sign you out (accent script, if `$SignOut` is on).

### What the scripts DON'T do
- No internet access, no downloads, no uploading anything.
- No installing software, no services, no startup entries.
- No deleting your files (the only delete is the registry key in `Reset-LockScreen.ps1`).
- No touching system files, activation or licensing.

### Read before you run
That's what section 4-6 are for. If a line doesn't make sense, don't run it. Paste the script into an AI chat or ask a friend. This is a good habit for **every** script from the internet, including this one.

### Make a backup first (30 seconds)
Open PowerShell and run:
```powershell
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" "$env:USERPROFILE\Desktop\accent-backup.reg" /y
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "$env:USERPROFILE\Desktop\personalize-backup.reg" /y
reg export "HKCU\Software\Microsoft\Windows\DWM" "$env:USERPROFILE\Desktop\dwm-backup.reg" /y
```
To undo later, **double-click the `.reg` files** and confirm. Done.

For extra paranoia (admin PowerShell): `Checkpoint-Computer -Description "before theme scripts"` creates a restore point. System Protection must be on for this to work.

### Quick undo cheat sheet

| I want to undo... | Do this |
|---|---|
| Accent colour | Set `$Hex = "0078D7"` and rerun, or import your `.reg` backups |
| Lock screen | Run `Reset-LockScreen.ps1` as admin |
| Taskbar vanished | `Ctrl + Shift + Esc`, **File > Run new task**, type `explorer.exe`, Enter |

### Antivirus warnings
Registry-editing scripts sometimes trip antivirus tools because malware also edits the registry. That doesn't make this script malware, and the code is right here to read. But if your antivirus complains, don't just click "allow". Read it first.

---

## 8. Known limitations (the honest part)

- **Not every Windows panel obeys.** Parts of the UI, like some Quick Settings elements, can keep Windows' default blue even after the palette is set. Windows may read the palette only at sign-in, and some controls ignore it.
- **Accent on taskbar/Start only works in dark mode.** Light mode ignores it. Windows decided this, not us.
- **Taskbar and Start share one switch.** They can't be coloured separately via this method.
- **Lock screen method is unofficial for home users.** `PersonalizationCSP` is built for managed/enterprise devices. It is documented for Pro, Enterprise, and Education, and may be ignored on Home. Windows updates can change its behaviour.
- **Tested on:** Windows 11 build 26200. Other builds: your mileage may vary.
- **Windows Spotlight and "slideshow" lock screen modes** may fight the override.

Found a bug or a build where it fails? Open an Issue and include your Windows version (`winver`).

---

## 9. Content creators: please credit

Making a YouTube video, blog post, Reddit tutorial, or short about these scripts? Awesome, genuinely. Go for it. Just do one thing:

**Mention the creator and link back to this repo.** Put it in the description, the pinned comment, or the post itself. Something like:

```
Scripts by Vikranth: https://github.com/YOURUSERNAME/win11-theme-scripts
```

Ground rules:
- Crediting means naming the author **and** linking the original repo.
- You can modify, remix, and re-share under the MIT licence, but **keep the LICENSE file and copyright notice** with any copy of the code.
- Please don't re-upload the scripts as your own work or put them behind a paywall or "join my Discord to get the link" gate. The licence technically allows reuse, but be a decent human.
- Tag the repo or drop a link if you make a video. Creators who credit their sources get good karma points. (The karma is imaginary, but still.)

---

## 10. Credits and license

- **Creator:** moss, GitHub: `@mosstackrn`
- **Built with help from** AI assistants (ChatGPT and Claude) during development and troubleshooting. The scripts were iterated with real Windows 11 testing and error output.
- **Not affiliated with Microsoft.** Windows is a trademark of Microsoft Corporation.
- **License:** [MIT](LICENSE). Use it, change it, share it, keep the notice.

---

*If this saved you a trip through the Settings app, give the repo a ⭐. It costs nothing and feeds the developer's ego.*
