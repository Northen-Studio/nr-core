# Verification results

Performed on 15 November 2026 in the supplied Windows workspace.

## Executed

- Compiled **37 Lua files** using Wasmoon's Lua **5.4** runtime, including both
  manifests, all runtime modules, custom adapters, example scripts and tests.
- Ran **103 behaviour tests**, all passing. The runner executes the actual
  manifest and its shared/client/server lists; all referenced files loaded in
  order without missing paths.
- Tested both client and server exports independently. Verified no server
  network handler is registered and no client-only export is exposed server-side.
- Tested framework selection, ambiguity, broken/missing required APIs, reference
  invalidation, restart recovery and coalesced lifecycle changes.
- Tested all notification types, invalid payloads, missing fields, UTF-8 limits,
  independent providers, fallback, no retry after side effects and targeted
  server delivery with invalid/broadcast IDs rejected.
- Tested native Qbox Notify and configurable ox_lib info/inform translation;
  verified optional esx_notify availability and restart behaviour.
- Tested progress completion/cancellation for ox_lib and upstream progressbar,
  busy checks, overlapping requests, timeouts, late callbacks, exceptions and
  provider/caller/core stops.
- Tested loaded/unloaded/disconnected players, character reloads, missing job
  fields, false duty values, field whitelisting and detached snapshots.
- Tested banner frequency, metadata, failed startup and the working custom
  examples. Executed both nr-example scripts against the real public exports in
  the simulator; confirmed the server command registers with ACE restriction.
- Reviewed upstream signatures and recorded authoritative links in references.md.
- Inspected manifest load order, resource structure, documentation, export names
  and network registrations. No framework/NUI/database dependency was added.

## Not executed

No FXServer or GTA client was available. This is **Lua syntax and simulated
behaviour verification**, not live framework certification. The repository's
Actions tab records remote workflow results separately. These local checks do
not create a tagged GitHub release.

The simulator does not run upstream resource implementations. Live notification
appearance, progress cleanup/controls, ACE enforcement, network origin behaviour,
txAdmin display, character lifecycle and restart timing must be verified with
the installed versions using testing.md. No resmon or performance numbers are
claimed. The server banner reports server-observed provider availability, which
does not prove every client has initialised successfully.

## Compatibility details

- Current ESX notification delegation requires esx_notify. Replaced ESX notifier
  implementations can use the custom adapter contract.
- Set Notify.oxInfoType to info or inform as accepted by the installed ox_lib UI;
  the setting is used by both ox_lib and Qbox notification adapters.
- The progressbar adapter supports the upstream qbcore-framework resource API,
  not arbitrary forks with a similar resource name.
- Native feed notifications cannot honour semantic styling, position or requested
  duration and limit the message to one safe 99-byte component.
- Optional integrations can be unavailable while the core remains ready. The
  corresponding public operation then fails safely or uses notification fallback.

The local archive is a release candidate pending the documented live checks.
