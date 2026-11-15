# Frameworks and providers

## Selection

Resource states are checked once during initialisation and on relevant lifecycle
events, with no permanent polling. Qbox is examined first, QBCore second, ESX
independently. Only genuinely `started` resources count. Qbox's virtual
`qb-core` compatibility export alone does not count as an installed QBCore.

Auto mode with zero candidates uses standalone and warns. With one candidate,
the relevant API is invoked and validated. With several candidates, initialisation
fails: stop unintended frameworks or set Config.Framework explicitly. An explicit
choice never silently becomes another framework when missing or broken.

## ESX Legacy

Uses `exports.es_extended:getSharedObject()`. Client player data comes from
`ESX.GetPlayerData()` only while `ESX.IsPlayerLoaded()`. Server uses
`ESX.GetPlayerFromId(source)` and xPlayer's getIdentifier/getName/getJob.
Names may be absent on client ESX installations that do not supply a name field.
Job grade is normalised; unspecified duty remains nil.

Notifications call `ESX.ShowNotification(message, type, duration)`. Title and
description are combined into one message. Position is not forwarded; the
installed ESX notification implementation determines placement and style.
The adapter requires the current upstream optional `esx_notify` resource to be
started; without it, provider resolution uses the configured fallback. If you
replaced ESX's notifier with another resource, use a custom notification adapter.

## QBCore

Uses `exports['qb-core']:GetCoreObject()` only for a real started resource.
Client reads `Functions.GetPlayerData()` while LocalPlayer.state.isLoggedIn is
true. Server uses `Functions.GetPlayer(source).PlayerData`. Character names use
charinfo first/last name, identifiers use citizenid, grades use grade.level and
duty uses job.onduty. Framework getters are read for each request, avoiding a
second stale player cache through character changes.

Notifications use `Functions.Notify(text, type, duration)`. When both title and
description are present the API receives text/caption. Info and warning map to
primary; success/error retain their names. Position is unsupported.

## Qbox

Uses native `qbx_core` exports, never a QBCore core object. Client startup verifies
GetPlayerData; server startup verifies GetCoreVersion. Client player reads use
GetPlayerData while logged in; server reads GetPlayer(source).PlayerData. The
normalised character fields match QBCore's data shape. The official playerdata
module itself uses the same native GetPlayerData export.

Notifications use native `Notify(text, type, duration, subTitle, position)`.
Info maps to Config.Notify.oxInfoType because native Qbox forwards the type to
ox_lib unchanged. Current upstream ox_lib uses `info`; older Qbox/ox_lib
installations may require `inform`. Test the installed combination and set the
configuration accordingly. Both variants still use the native Qbox Notify API.

## Standalone and custom

Standalone has no roleplay identifier or job. It returns a connected player's
display name only. Native notifications work; progress requires a provider.
The custom framework example deliberately offers the same minimal information
until replaced with real calls. See [custom contracts](custom-integrations.md).

## Progress providers

ox_lib uses exported progressBar, progressActive and cancelProgress. Only built
releases with loaded web assets are accepted client-side. Upstream
`qbcore-framework/progressbar` uses Progress(data, callback(cancelled)),
isDoingSomething and progressbar:client:cancel. A differently named or API-
incompatible fork is not automatically supported. The custom progress example
delegates to that verified upstream provider; it is not a fake timed success.

Other resources can own provider UI. nr-core rejects a busy provider and cancels
only the operation it owns. It relies on provider cleanup for controls, busy
flags and UI. Visual and shutdown behaviour must be checked on the installed
versions. No version-independent runtime compatibility claim is made.
