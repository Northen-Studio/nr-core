# Upstream API references

Reviewed on 15 November 2026 against official documentation and upstream source.
These links target moving upstream branches, not a promise that every historical
release exposes the same API. Use the live checklist against installed versions.
nr-core contains independent adapter code, not copied framework implementations.

- [FiveM manifest specification](https://docs.fivem.net/docs/scripting-reference/resource-manifest/):
  cerulean, script lists, metadata and the standard Lua 5.4 runtime.
- [FiveM event security](https://docs.fivem.net/docs/developers/server-security/):
  client events check server-origin source; privileged decisions remain server-side.
- [FiveM Lua function references](https://github.com/citizenfx/fivem/blob/master/data/shared/citizen/scripting/lua/scheduler.lua):
  exported functions can be transported as callable tables. Framework capability
  checks accept these references as well as ordinary Lua functions.
- [QBCore client functions](https://github.com/qbcore-framework/qb-core/blob/main/client/functions.lua):
  GetPlayerData, Notify(text, texttype, length, icon), and the Progressbar wrapper
  mapping to upstream progressbar's Progress callback.
- [QBCore server functions](https://github.com/qbcore-framework/qb-core/blob/main/server/functions.lua):
  GetPlayer(source) returns a player whose PlayerData contains character fields.
- [Upstream progressbar](https://github.com/qbcore-framework/progressbar/blob/main/client.lua):
  Progress(action, finish), isDoingSomething and progressbar:client:cancel.
- [Qbox client functions](https://github.com/Qbox-project/qbx_core/blob/main/client/functions.lua):
  native GetPlayerData and Notify(text, notifyType, duration, subTitle, position).
- [Qbox server functions](https://github.com/Qbox-project/qbx_core/blob/main/server/functions.lua):
  GetPlayer(source), GetCoreVersion(resourceName).
- [Qbox playerdata module](https://github.com/Qbox-project/qbx_core/blob/main/modules/playerdata.lua):
  demonstrates native GetPlayerData and character lifecycle handling.
- [Qbox server export documentation](https://docs.qbox.re/resources/qbx_core/exports/server).
- [ESX shared object](https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/shared/main.lua):
  getSharedObject export.
- [ESX client player data](https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/modules/player/data.lua):
  GetPlayerData and IsPlayerLoaded.
- [ESX player interface](https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/server/classes/player.lua):
  getIdentifier, getName, getJob and optional job.onDuty.
- [ESX documentation](https://docs.esx-framework.org/): optional notification
  dependencies differ between releases; verify the installed ShowNotification UI.
- [ESX notification functions](https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/modules/ui/notifications.lua):
  ShowNotification(message, notifyType, length, title, position) delegates to
  optional esx_notify. nr-core checks that dependency before selecting it.
- [ox_lib notification implementation](https://github.com/overextended/ox_lib/blob/master/resource/interface/client/notify.lua):
  normalised data table, notification types and position enumeration.
- [ox_lib progress implementation](https://github.com/overextended/ox_lib/blob/master/resource/interface/client/progress.lua):
  progressBar, progressActive, cancelProgress and cleanup.
- [ox_lib export registration](https://github.com/overextended/ox_lib/blob/master/resource/init.lua):
  resource interface functions are registered as exports. nr-core therefore does
  not load the optional @ox_lib/init.lua script.

Current upstream ox_lib source advertises `info`; older ox_lib documentation and
Qbox installations use `inform`. This is explicitly configurable for both the
ox_lib and Qbox adapters, and is a live compatibility check.

The verification workflow uses the official stable
[checkout v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1) and
[setup-node v7.1.0](https://github.com/actions/setup-node/releases/tag/v7.1.0)
actions, checked against their published release pages.
