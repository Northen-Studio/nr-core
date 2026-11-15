# Northen Studio Core (`nr-core`)

A lightweight compatibility layer connecting Northen Studio resources with ESX
Legacy, QBCore, Qbox, custom adapters and standalone FiveM servers.
Developed by Northen Studio, an independent Polish studio producing free,
open-source FiveM resources. Version **1.0.0**, licensed under MIT.

## Features

- Event-driven framework detection, explicit selection and conflict reporting.
- Independent notification providers: ESX, QBCore, native Qbox, ox_lib, custom
  adapters and the GTA feed fallback.
- Cancellable progress through ox_lib or upstream `qbcore-framework/progressbar`,
  with overlap protection, bounded waits and replaceable custom adapters.
- Small, whitelisted player snapshots on the client and server.
- Provider restart recovery, validated arguments and targeted server delivery.
- Server startup banner with configurable, informational licence metadata.
- No mandatory framework, NUI, database or external licence service.

## Installation

Copy this folder to `resources/[northen]/nr-core`. Use its exact name. Start your
chosen framework and optional providers first, then `nr-core`, then dependants.
For example, on Qbox:

```cfg
ensure ox_lib
ensure qbx_core
ensure nr-core
```

Standalone installations can simply `ensure nr-core`; native notifications work,
but progress requires an installed provider. See [installation](docs/installation.md).

## Configuration

Edit `config/shared.lua`. It contains public settings only.

```lua
Config.Framework = 'auto'
Config.Notify.provider = 'ox_lib'
Config.Notify.allowFallback = true
Config.Notify.fallback = 'native'
Config.Progress.provider = 'auto'
Config.Licence.id = 'NS-CORE-0001'
```

See [every configuration option](docs/configuration.md).

## Developer API

Declare `dependency 'nr-core'` in your manifest. Client:

```lua
local framework, reason = exports['nr-core']:GetFramework()
local shown, notifyError = exports['nr-core']:Notify({
    title = 'Northen Studio', description = 'Vehicle unlocked.', type = 'success'
})
local completed, progressError = exports['nr-core']:Progress({
    label = 'Repairing vehicle...', duration = 5000, canCancel = true
})
local player, playerError = exports['nr-core']:GetPlayerData()
```

Server:

```lua
local framework, reason = exports['nr-core']:GetFramework()
local player, playerError = exports['nr-core']:GetPlayerData(source)
local queued, notifyError = exports['nr-core']:NotifyPlayer(source, {
    description = 'Welcome to the server!', type = 'info'
})
```

[Exact export contracts](docs/exports.md) include failure behaviour and readiness.
[The development example](examples/nr-example) uses an ACE-restricted command.

## Compatibility and limitations

Auto mode rejects multiple genuinely started frameworks. Qbox's virtual QB bridge
does not count as `qb-core`; a real simultaneously started `qb-core` does.
Missing manually selected frameworks leave the API unready until recovery.
Optional UI integrations may be unavailable without preventing startup.

Provider capabilities differ: native feed notifications cannot honour duration,
position or semantic colours; QBCore warning maps to primary. Progress v1 accepts
only label, duration and canCancel; animation, props and control options are not
part of the public contract. See [frameworks](docs/frameworks.md) and
[upstream references](docs/references.md). Live FXServer compatibility and visual
checks remain necessary; mock tests do not establish live compatibility.

## Documentation

- [Installation](docs/installation.md)
- [Configuration](docs/configuration.md)
- [Exports](docs/exports.md)
- [Framework behaviour](docs/frameworks.md)
- [Custom integration contracts](docs/custom-integrations.md)
- [Testing and release checks](docs/testing.md)
- [Changelog](CHANGELOG.md)

## Contributing

Submit focused changes with reproduction steps, framework/provider versions and
relevant test results. Preserve the documented exports and client/server trust
boundary. Never include credentials or raw player records in reports. See
[CONTRIBUTING.md](CONTRIBUTING.md). This project uses the [MIT licence](LICENSE).
