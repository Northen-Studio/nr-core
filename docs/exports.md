# Public exports

Call from Lua in the correct runtime. All operations return a useful first value
or a documented failure plus a string reason. A success has no second result.
No export returns raw framework player objects.

## Readiness and GetFramework (client and server)

```lua
local framework, reason = exports['nr-core']:GetFramework()
```

Returns `esx`, `qbcore`, `qbox`, `custom` or `standalone`; returns `nil,
'not_ready'` before successful initialisation or during dependency failure.
Exports register while scripts load; initialisation runs on the startup event's
next tick. Dependency ordering alone is not a readiness acknowledgement. A
dependant may listen to the local `nr-core:ready` event (one framework string)
and also query GetFramework when its own resource starts. Never use that event
as permission evidence. It may fire again after dependency changes.

## Notify (client only)

```lua
local ok, reason = exports['nr-core']:Notify({
    title = 'Northen Studio', description = 'Operation completed.',
    type = 'success', duration = 5000, position = 'top-right'
})
```

Returns `true` after successful adapter invocation; `false, reason` otherwise.
The input must be a table with at least one non-blank string `title` or
`description`. Title is limited to 256 bytes, description to 1000 bytes. Strings
have control characters removed. `type` is `success`, `error`, `warning` or
`info` (default). Duration is an integer from 1–60000 ms; position uses the
configuration's allowed values. Missing duration/position use configured defaults.
Unsupported extra fields, including styling, are ignored rather than forwarded.

Failures: `not_ready`, `invalid_data`, `empty_message`, `invalid_duration`,
`invalid_type`, `invalid_position`, `provider_unavailable`, `provider_error`.
Native feed output is shortened and strips GTA formatting markers. The feed
cannot honour position/duration/type; other providers have their own limits.

## NotifyPlayer (server only)

```lua
local queued, reason = exports['nr-core']:NotifyPlayer(source, {
    description = 'Welcome!', type = 'info'
})
```

`source` must be a numeric positive integer belonging to a connected player.
Strings, console ID 0, broadcast ID -1, fractions and disconnected IDs are
rejected as `invalid_source`. Data and validation failures match Notify.
Returns `true` when queued, not a client display acknowledgement. A client can
disconnect after validation. Its provider may also differ or be unavailable.
No broadcast export and no client-to-server notification event exist. If a
trusted server resource explicitly wishes to broadcast, it must enumerate and
validate individual recipients itself. Authorise gameplay actions server-side.

## Progress (client only)

```lua
local completed, reason = exports['nr-core']:Progress({
    label = 'Repairing vehicle...', duration = 5000, canCancel = true
})
```

Must run in a yieldable FiveM coroutine (for example a command/event callback or
CreateThread). Accepts non-blank string `label` (up to 256 bytes), required integer
`duration` from 1–3600000 ms and optional boolean `canCancel` (default true,
subject to configuration). Unknown fields are ignored. No animations, props,
dead-player option or control-disable contract is exposed in v1.

Returns `true` only on completion; `false, reason` on cancellation/failure.
Reasons: `not_ready`, `invalid_data`, `invalid_label`, `invalid_duration`,
`invalid_cancel`, `busy`, `provider_unavailable`, `provider_error`, `cancelled`,
`timeout`, `provider_stopped`, `resource_stopped`. Checks both nr-core's own active
operation and the provider's busy state. Never falls back after an operation
starts. Duplicate/late callbacks are ignored. Cleanup delegates to the provider.

## GetPlayerData (client and server)

```lua
local clientPlayer, reason = exports['nr-core']:GetPlayerData()

local serverPlayer, serverReason = exports['nr-core']:GetPlayerData(source)
```

Returns a fresh snapshot with `identifier`, `name` and `job = { name, label,
grade, onDuty }`. Unavailable fields are nil (therefore absent from Lua tables);
job is always a table. Grade is an integer when provided, duty a boolean
including false. ESX identifiers and QB citizen IDs are different identifier
domains, not interchangeable account IDs. No money, permissions, tokens or
framework methods are returned. Do not publish identifiers to other players.

Client reads only the local character. Server requires the same validated
numeric source as NotifyPlayer. Returns `nil, 'player_unloaded'` for an unloaded
character, `nil, 'invalid_source'` for invalid/disconnected server sources,
`nil, 'not_ready'` during failure, or `nil, 'provider_error'` on adapter errors.
Standalone returns the connected player's display name only, with an empty job
table. Custom behaviour follows the same whitelist. Client data is informational;
perform every privileged job/permission check server-side.

## Network boundary

`nr-core:client:notify` is the only nr-core network event. It accepts only
server-originated client deliveries (`source == 65535`) and revalidates the
payload. It never triggers server execution. There are no server network handlers.
