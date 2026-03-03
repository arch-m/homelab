# Homelab (demo)

This directory source of truth for local infrastructure automation.

This submodule no longer carries site-specific inventory or `group_vars`.
Pass the inventory path explicitly, for example:

`make INVENTORY=/abs/path/to/hosts.ini deploy-server`

Static compose validation uses `files/server/.env.example` and
`files/rpi/.env.example`.
