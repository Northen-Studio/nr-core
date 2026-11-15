# Testing and release verification

## Automated checks

The development runner uses Wasmoon, a WebAssembly build of Lua 5.4. Node.js is
needed only to run these checks; FXServer needs no Node/npm dependencies.

From this resource directory:

```sh
npm install --prefix .test-tools --no-audit --no-fund wasmoon@1.16.0
node tests/run.cjs
```

The ignored `.test-tools` directory must not be included in a release archive.
On a system using a managed certificate authority, Node may need the supported
`--use-system-ca` option. Never disable TLS verification to install test tooling.

The runner compiles every project Lua file, executes the real manifest to check
script paths/order and loads both actual runtime script lists into separate
mock environments. It exercises detection, conflicts, restarts, validation,
fallback, exact adapter argument mapping, export separation, targeted network
delivery, progress callbacks/overlap/timeouts/shutdown, player field whitelisting
and startup banner/licence behaviour.

The simulator stubs upstream framework exports, natives and scheduling. It
checks nr-core's behaviour; it does not execute upstream frameworks, NUI or a
real network. See [verification results](verification.md) for checks actually run.

## Required live FXServer checks before publishing

Use a development server with a current artifact. Record artifact, framework and
provider versions for each run. Test one primary framework at a time.

1. Start standalone, ESX Legacy, QBCore and Qbox configurations. Confirm both
   client and server GetFramework results, banner values and no runtime errors.
2. Start Qbox with only its virtual QB bridge; confirm qbox. Then start two real
   framework resources, confirm auto failure and explicit-selection recovery.
3. Stop/restart each framework and provider with nr-core running. Confirm
   unready or fallback behaviour and recovery, with no stale objects.
4. Display all four notification types for every installed provider, title-only,
   description-only and both. Confirm their actual visual capabilities. On
   ox_lib, check info versus inform against the installed version.
5. Try invalid payloads/durations, a missing provider with fallback enabled and
   disabled, and one targeted server notification. Confirm a second connected
   client never receives it. Confirm no duplicate UI after adapter errors.
6. Run progress to completion and cancel it. Test overlap with nr-core and with
   another resource. Stop the provider, nr-core and the calling resource during
   progress. Confirm no stuck UI, controls or busy state. Test a missing callback
   using a temporary custom adapter; confirm duration + grace expires.
7. Load/unload/switch characters, change jobs/duty, and disconnect. Check player
   snapshots, absent fields and false duty values on both runtimes. Confirm no
   privileged decision relies on client data.
8. Confirm `/nrtest` is denied without command.nrtest ACE, allowed with it, and
   console target validation rejects IDs 0/-1/disconnected players.
9. Check server and txAdmin live consoles: aligned banner once per successful
   resource startup, correct version/framework/provider/licence metadata and no
   success message after invalid config or a missing required framework.
10. Observe resmon/profiler idle and active behaviour. No performance figures
    are claimed by this release; record measurements before making such claims.

## Release packaging

Include source, docs, examples, tests, manifest, licence and changelog. Exclude
.test-tools, node_modules, editor files and archives. Retain the `nr-core` folder
name on extraction. On Windows, `./tools/package.ps1` creates a sibling
`nr-core-1.0.0.zip` with that root folder, including hidden project metadata and
excluding development dependencies. It refuses to overwrite an existing archive;
use `-Destination` to choose another output. Run automated and live checks before publishing a GitHub
release tagged v1.0.0. No remote repository or release is created by the tests.
