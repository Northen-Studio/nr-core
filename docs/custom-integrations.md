# Custom integrations

Adapters are trusted resource code. Configure integrations by editing the
dedicated files under `bridges`, never by evaluating configuration strings.
Restart nr-core after editing them. No external framework is supported merely
because Config.Framework is set to custom.

## Framework contract

`bridges/frameworks/custom/client.lua` and `server.lua` each assign
`NR.frameworks.custom` with these functions:

```lua
NR.frameworks.custom = {
    init = function()

        return GetResourceState('my-framework') == 'started'
    end,
    reset = function()

    end,
    player = function(source)

        local data = exports['my-framework']:GetPublicCharacter(source)
        if not data then return nil, 'player_unloaded' end
        return {
            identifier = data.characterId,
            name = data.displayName,
            job = { name = data.jobName, label = data.jobLabel,
                grade = data.jobGrade, onDuty = data.onDuty }
        }
    end
}
```

The `my-framework` calls above illustrate the contract and must be replaced
with your actual documented API. The shipped client/server examples are fully
functional minimal adapters: they return real display names and no fabricated
character fields. Client and server files must implement their own appropriate
APIs. `init` must complete without yielding; return `false, reason` on failure.
`player` returns a table or `nil, reason`. Exceptions are logged and converted to
provider_error. The manager always whitelists the returned fields.

Add actual dependency names in `config/shared.lua`:

```lua
Config.CustomResources = { 'my-framework' }
```

This makes start/stop events trigger reference invalidation and recovery. Never
put secrets in this shared file. Reset must be quick, non-yielding and safe even
if the dependency has already stopped.

## Notification contract

Replace `bridges/notify/custom.lua` with `NR.notifications.custom`:

- `available() -> boolean`: quick capability check; must not show UI or yield.
- `send(normalisedData) -> true | false, reason`: invoke exactly one UI action.
  Receives whitelisted title/description/type/duration/position fields.

Set `Config.Notify.provider = 'custom'`. The shipped example delegates to the
native GTA feed. A real external provider must declare its own availability and
map types/capabilities honestly. `available` also runs on the server to display
server-observed availability, so use `NR.server` to avoid client-only API calls
there. `send` only runs client-side. Register dependencies in NR.watched.

Returning false or throwing after invocation does not trigger fallback: UI could
already have appeared. Missing providers are resolved to the configured fallback
before invocation. Do not schedule duplicate notifications inside an adapter.

## Progress contract

Replace `bridges/progress/custom.lua` with `NR.progressProviders.custom`:

- `resource`: exact dependency resource name, used for stop cancellation.
- `available() -> boolean`: fast, non-yielding capability check, both runtimes.
- `busy() -> boolean`: client-side external progress ownership check.
- `start(normalisedData, done)`: begin a client operation and return promptly.
  For an awaiting provider API, create a thread and call done when it finishes.
- `cancel()`: synchronously request cleanup of only the current nr-core operation.
  Must be safe if start failed midway and must not yield or start a new action.

Call `done(true)` only after genuine completion, or `done(false, 'cancelled')`
on user cancellation. Other failure reasons may be returned as strings. The
manager ignores duplicate/late callbacks and has its own deadline. Adapters
must still release their own controls, props, animation and busy flags; a timeout
cannot forcibly fix an arbitrary proprietary resource. Never implement progress
by always returning true after a timer.

The shipped example delegates to the verified upstream progressbar adapter and
therefore works when that resource is installed. It demonstrates the complete
contract without pretending an unknown progress resource is supported.

## Future modules

Framework, notification and progress registries are deliberately separate.
Inventory, target, text UI, menus, callbacks and localisation should each add a
dedicated registry, validated contract, runtime-specific exports, tests and
documentation. V1 exports no unfinished future features. Privileged mutations
must validate players and permissions server-side, without accepting authority
from client snapshots or generic execution events.
