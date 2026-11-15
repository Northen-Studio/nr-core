# Configuration

All settings live in `config/shared.lua` and are visible to clients. Store no
secrets there. Invalid configuration blocks readiness and prints an actionable
error; it never prints a success banner. Restart nr-core after editing settings.

- `Debug`: boolean, default `false`; enables DEBUG diagnostics.
- `Framework`: `auto` (default), `esx`, `qbcore`, `qbox`, `custom` or `standalone`.
  Explicit selection overrides ambiguity, but requires its adapter to initialise.
- `CustomResources`: array of resource-name strings, default `{}`. Start/stop
  events for these custom dependencies trigger adapter invalidation and recovery.
- `Notify.provider`: `auto` (default), `esx`, `qbcore`, `qbox`, `ox_lib`, `custom`
  or `native`. Auto chooses ox_lib, then the selected framework's provider, then
  native. It does not discover custom integrations automatically.
- `Notify.defaultDuration`: integer milliseconds, 1–60000, default `5000`.
- `Notify.defaultPosition`: default `top-right`; one of `top`, `top-right`,
  `top-left`, `bottom`, `bottom-right`, `bottom-left`, `center-right`, `center-left`.
- `Notify.oxInfoType`: `info` (default, current upstream ox_lib source) or `inform`
  (older releases). Set this to the value accepted by your installed ox_lib UI.
  This also applies to native Qbox Notify, which forwards types to ox_lib unchanged.
- `Notify.allowFallback`: boolean, default `true`. For an unavailable explicit
  provider, select the configured fallback **before** invoking a UI adapter.
  Auto mode always uses its documented preference chain.
- `Notify.fallback`: any notification provider except `auto`, default `native`.
  Only one fallback is attempted; no cycles. After invoking a provider, errors do
  not trigger retries because UI may already have appeared.
- `Progress.provider`: `auto` (default), `ox_lib`, `qbcore` or `custom`. Auto
  chooses ox_lib then upstream `progressbar`. The `qbcore` label refers to that
  specific progress resource and does not require the QBCore framework.
- `Progress.allowCancel`: boolean, default `true`; false disables user
  cancellation even if requested by a caller. Safety timeout and shutdown
  cancellation remain active.
- `Progress.timeoutGrace`: integer milliseconds, 1000–30000, default `5000`.
  A single watchdog expires after requested duration plus this grace period.
- `Licence.id`: non-blank string, displayed up to 80 bytes; default
  `NS-CORE-0001`. Informational, not proof of authenticity or activation.
- `Licence.type`: non-blank string, displayed up to 80 bytes; default `MIT`.
  Changing this label does not change the legal terms in LICENSE.

Example: ESX character data with ox_lib UI:

```lua
Config.Framework = 'esx'
Config.Notify.provider = 'ox_lib'
Config.Progress.provider = 'ox_lib'
```

Missing optional providers are warnings. Their operations return
`provider_unavailable` when no usable notification fallback exists or no progress
provider exists. No framework-dependent functionality is fabricated.
