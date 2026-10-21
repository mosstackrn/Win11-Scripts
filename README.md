# win11-theme-scripts

Two small PowerShell scripts that customise Windows 11 through the registry:

- **Set-AccentColor.ps1**: set one hex colour and apply it to the taskbar, Start menu and window title bars.
- **Set-LockScreen.ps1**: set the lock screen image via the `PersonalizationCSP` registry keys, useful when the Settings page won't change it.

Edit the variables at the top of each script, run it, done.

## Requirements

- Windows 11 (built and tried on build 26200)
- PowerShell 5.1 (built in)
- Accent script: normal user, no admin needed
- Lock screen script: **Administrator**. Officially supported on Pro, Enterprise and Education; may be ignored on Home

## Usage

### Accent colour

Open `scripts/Set-AccentColor.ps1`, edit the top block:

| Variable | Meaning |
|---|---|
| `$Hex` | Colour as `RRGGBB`, no `#`. Any `000000`-`FFFFFF` works |
| `$ApplyTaskbarStart` | Accent on taskbar + Start menu |
| `$ApplyTitleBars` | Accent on title bars and window borders |
| `$DarkMode` | `$true` dark, `$false` light |
| `$Transparency` | Translucent taskbar/Start |
| `$SignOut` | Sign out at the end so the palette loads |

Then run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-AccentColor.ps1
```

Notes:
- Windows 11 has a single switch for taskbar and Start together, so they can't be toggled separately.
- Accent on taskbar/Start only shows in **dark mode**.
- Very light colours make taskbar text unreadable.
- To restore the default, set `$Hex = "0078D7"` and rerun. Or turn on "Accent color: Automatic" in Settings > Personalization > Colors.
- A list of the 48 preset colours is at the bottom of the script.

### Lock screen

1. Put your image at `%USERPROFILE%\Pictures\lockscreen.jpg` (or edit `$src`).
2. Open PowerShell **as Administrator** and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-LockScreen.ps1
```

3. Press `Win + L` to test. If the old image shows, sign out and back in.

The script copies your image to `C:\Users\Public\Pictures` first, because the lock screen is loaded by the system and files inside a user profile can fail to load.

**Undo:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Reset-LockScreen.ps1
```

## How it works

| What | Registry location |
|---|---|
| Accent palette and colours | `HKCU\...\Explorer\Accent` (`AccentPalette`, `AccentColorMenu`, `StartColorMenu`) |
| Dark mode, transparency, taskbar/Start accent | `HKCU\...\Themes\Personalize` |
| Title bar accent, colorization | `HKCU\...\DWM` |
| Lock screen image | `HKLM\...\PersonalizationCSP` (`LockScreenImagePath`, `LockScreenImageUrl`, `LockScreenImageStatus`) |

`Accent*` keys use ABGR byte order. `DWM ColorizationColor` uses ARGB. The script builds an 8-shade `AccentPalette` from your hex (3 tints, the base colour, 3 shades, base again).

## Known limitations

- Some Windows 11 UI (e.g. parts of Quick Settings) may keep default colours. Windows can read the palette only at sign-in, and some controls ignore it.
- `PersonalizationCSP` is designed for device management (MDM). Behaviour can change between Windows updates, and it may do nothing on Home.
- These scripts edit the registry. Try them on your own PC and read the code first.

## Disclaimer

Provided as is, with no warranty. Use at your own risk. Not affiliated with Microsoft.

## License

MIT
