# user extensions

## Gnome Shell Packages

- list
    - `gnome-extensions list --enabled`
    - or:  `ls ~/.local/share/gnome-shell/extensions | sort | sed -r "s/(.+)/- \1/g"`

## Librewolf Addon Packages

- list
    - `ls ~/.librewolf/*.default-release/extensions | sort | sed -r "s/(.+)\.xpi/- \1/g"`

## Chromium Addons

- list
    - `profile_dir="$HOME/.config/chromium/Default"; prefs_file="$profile_dir/Preferences"; extensions_dir="$profile_dir/Extensions"; jq -r '[ .extensions.settings | to_entries[] | select((.value.state // -1) == 1) ] | sort_by(.key)[] | "# \(.value.manifest.name // .key) (\(.key))\n- \(.key)"' "$prefs_file" | grep -E -- "($(ls -1 "$extensions_dir" | paste -sd '|'))"`

## libreoffice
