# Argon40 NixOS Module

This flake provides NixOS modules for [Argon40](https://argon40.com/) Raspberry Pi cases. It packages the functionality from the [Argon40 install script](https://download.argon40.com/argon1.sh) for declarative NixOS configuration.

Supported cases:
- **Argon ONE** (including M.2 variant) - CPU fan control, power button, OLED display, IR remote
- **Argon EON** - All Argon ONE features plus HDD fan control and RTC (Real-Time Clock)

## Installation

### With flakes

Add the following to your `flake.nix`:

```nix
{
  inputs.argon40-nix.url = "github:guusvanmeerveld/argon40-nix";
}
```

Then import the module in your NixOS configuration:

```nix
{ inputs, ... }: {
  imports = [ inputs.argon40-nix.nixosModules.default ];
}
```

## Module Structure

The module uses a clean, hierarchical structure:

| Option | Description |
|--------|-------------|
| `programs.argon.enable` | Enables the main service (CPU fan, OLED, power button, IR) |
| `programs.argon.settings.*` | Configuration for fan speeds, OLED screens, IR remote |
| `programs.argon.eon.enable` | Enables the EON RTC service |
| `programs.argon.eon.settings.*` | EON-specific settings (HDD fan control) |

## Configuration Examples

### Argon ONE Case

Basic configuration for the Argon ONE or Argon ONE M.2 case:

```nix
{ inputs, ... }: {
  imports = [ inputs.argon40-nix.nixosModules.default ];

  programs.argon = {
    enable = true;

    settings = {
      # Temperature unit: "celsius" (default) or "fahrenheit"
      displayUnits = "celsius";

      # CPU fan speed curve
      fanspeed = [
        { temperature = 55; speed = 30; }   # 30% fan at 55°C
        { temperature = 60; speed = 55; }   # 55% fan at 60°C
        { temperature = 65; speed = 100; }  # 100% fan at 65°C
      ];
    };
  };
}
```

### Argon EON Case

The Argon EON is a NAS case with HDD bays and an RTC module. It uses the same base service as the Argon ONE for CPU fan control and OLED display:

```nix
{ inputs, ... }: {
  imports = [ inputs.argon40-nix.nixosModules.default ];

  programs.argon = {
    enable = true;  # Base service for CPU fan, OLED, power button

    settings = {
      # CPU fan speed curve
      fanspeed = [
        { temperature = 55; speed = 30; }
        { temperature = 60; speed = 55; }
        { temperature = 65; speed = 100; }
      ];

      # OLED display configuration
      oled = {
        screenList = [ "clock" "cpu" "storage" "raid" "ram" "temp" "ip" ];
        switchDuration = 30;  # seconds between screen changes
      };
    };

    # EON-specific features
    eon = {
      enable = true;  # Enable RTC service

      settings = {
        # HDD fan speed curve (uses SMART temperature data)
        # mdadm is automatically added to PATH for RAID setups
        hddFanspeed = [
          { temperature = 35; speed = 30; }
          { temperature = 45; speed = 55; }
          { temperature = 50; speed = 100; }
        ];
      };
    };
  };
}
```

### IR Remote Configuration

Enable support for the Argon IR remote:

```nix
programs.argon = {
  enable = true;

  settings.ir = {
    enable = true;

    # GPIO pin for IR receiver (default: 23)
    gpio = {
      enable = true;
      pin = 23;
    };

    # Custom key mappings (defaults shown)
    keymap = {
      "POWER" = "00ff39c6";
      "UP" = "00ff53ac";
      "DOWN" = "00ff4bb4";
      "LEFT" = "00ff9966";
      "RIGHT" = "00ff837c";
      "VOLUMEUP" = "00ff01fe";
      "VOLUMEDOWN" = "00ff817e";
      "OK" = "00ff738c";
      "HOME" = "00ffd32c";
      "MENU" = "00ffb946";
      "BACK" = "00ff09f6";
    };
  };
};
```

## Services

This module manages two systemd services:

- **`argon.service`** - Main service for fan control, OLED display, and power button handling. Enabled by `programs.argon.enable`.
- **`argon-eon.service`** - EON RTC service. Enabled by `programs.argon.eon.enable`.

## Thanks

- [Argon40](https://argon40.com/) for providing such an awesome case, continuously providing updates and [open sourcing](https://github.com/Argon40Tech) their projects.
- [okunze's repo](https://github.com/okunze/Argon40-ArgonOne-Script) containing an up to date version of the argon40 install script.
