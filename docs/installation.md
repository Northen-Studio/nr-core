# Installation

Use a current FiveM/FXServer artifact with the standard Lua 5.4 runtime. No
deprecated `lua54` manifest setting is needed. No database is used by nr-core.

1. Place the resource in `resources/[northen]/nr-core`, retaining that folder name.
2. Select one primary framework in `config/shared.lua`, or use `auto`.
3. Start the required resources in order, as shown below.
4. Start Northen Studio dependants after nr-core. Their manifest must declare
   `dependency 'nr-core'`.
5. Check the server console for the successful banner and the client console for
   readiness or configuration errors.

ESX with optional ESX notifications (also start ESX's own dependencies as
instructed by ESX; omit esx_notify to use the native fallback):

```cfg
ensure es_extended
ensure esx_notify
ensure nr-core
```

QBCore, with its optional upstream progress resource:

```cfg
ensure qb-core
ensure progressbar
ensure nr-core
```

Qbox (start its own dependencies according to Qbox documentation):

```cfg
ensure ox_lib
ensure qbx_core
ensure nr-core
```

Standalone with no progress provider:

```cfg
ensure nr-core
```

Standalone with optional ox_lib notifications and progress:

```cfg
ensure ox_lib
ensure nr-core
```

For any framework, start ox_lib before nr-core to use its UI. nr-core calls its
exports directly and does not require `@ox_lib/init.lua`. Install a built ox_lib
release, including its web assets. Qbox always uses native `qbx_core` exports.

## Development example

Copy `examples/nr-example` alongside nr-core; do not start its nested source copy.

```cfg
ensure nr-example
add_ace group.admin command.nrtest allow
```

An authorised player runs `/nrtest`; the console runs `nrtest 12` for connected
player 12. The command never accepts a different target from a player. Remove
the example from production if development commands are unnecessary.

## Restart behaviour

Framework and provider start/stop events invalidate cached framework objects and
re-evaluate selection on the next tick. A stopped explicitly selected framework
makes the API unready; restarting it recovers automatically. An auto selection may
temporarily become standalone. Consumers must handle failed calls during this
transition. Active progress fails if its provider or calling resource stops.
Restart nr-core after changing configuration or adapter files.

The server and each client initialise independently. A successful server banner
describes server-observed availability, not acknowledgement from every client.
