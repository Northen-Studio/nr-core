local passed = 0
local function equal(actual, expected, message)
    assert(actual == expected, (message or 'Mismatch') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function test(name, callback)
    local ok, reason = pcall(callback)
    if not ok then error('FAIL ' .. name .. ': ' .. tostring(reason), 0) end
    passed = passed + 1
    print('PASS ' .. name)
end

local Harness = {}
Harness.__index = Harness
function Harness.new(server, states, configure)
    local h = setmetatable({ server = server, states = states or {}, exported = {},
        events = {}, network = {}, timers = {}, now = 0, logs = {}, sent = {},
        shown = {}, loaded = true, connected = true, busy = false, cleanup = 0,
        manifest = {}, source = 65535 }, Harness)
    h.data = { citizenid = 'char-1', identifier = 'esx-char-1', name = 'Test Character',
        charinfo = { firstname = 'Test', lastname = 'Character' },
        job = { name = 'police', label = 'Police', grade = { level = 2 }, onduty = false },
        money = { bank = 123 }, metadata = { secret = true } }
    local e = setmetatable({}, { __index = _G })
    h.env = e
    e.IsDuplicityVersion = function() return server end
    e.GetResourceState = function(name) return h.states[name] and 'started' or 'missing' end
    e.GetCurrentResourceName = function() return 'nr-core' end
    e.GetResourceMetadata = function(_, key) return key == 'version' and '1.0.0' or nil end
    e.GetInvokingResource = function() return 'consumer' end
    e.GetPlayerName = function(id) if (id == 1 and h.connected) or (id == 0 and not server) then return 'Display Name' end end
    e.PlayerId = function() return 0 end
    e.LocalPlayer = { state = { isLoggedIn = true } }
    e.print = function(...) h.logs[#h.logs + 1] = table.concat({...}, ' ') end
    e.AddEventHandler = function(name, callback)
        h.events[name] = h.events[name] or {}
        table.insert(h.events[name], callback)
    end
    e.RegisterNetEvent = function(name, callback)
        h.network[name] = true
        e.AddEventHandler(name, callback)
    end
    e.TriggerEvent = function(name, ...)
        if name == 'progressbar:client:cancel' then
            h.cleanup = h.cleanup + 1; h.busy = false
            if h.done then h.done(true) end
        end
        h:emit(name, ...)
    end
    e.TriggerClientEvent = function(name, target, payload)
        h.sent[#h.sent + 1] = { name = name, target = target, payload = payload }
    end
    e.SetTimeout = function(delay, callback)
        h.timers[#h.timers + 1] = { at = h.now + delay, callback = callback }
    end
    e.CreateThread = function(callback) e.SetTimeout(0, function() h:run(callback) end) end
    e.promise = { new = function()
        local p = { waiters = {} }
        function p:resolve(value)
            if self.resolved then return end
            self.resolved, self.value = true, value
            for _, co in ipairs(self.waiters) do
                local ok, reason = coroutine.resume(co, value)
                assert(ok, reason)
            end
        end
        return p
    end }
    e.Citizen = { Await = function(p)
        if p.resolved then return p.value end
        p.waiters[#p.waiters + 1] = coroutine.running()
        return coroutine.yield()
    end }
    local function record(provider, ...)
        h.shown[#h.shown + 1] = { provider = provider, args = {...} }
    end
    h.esx = {
        IsPlayerLoaded = function() return h.loaded end,
        GetPlayerData = function() return h.data end,
        ShowNotification = function(...) record('esx', ...) end,
        GetPlayerFromId = function()
            if not h.loaded then return nil end
            return { getIdentifier = function() return h.data.identifier end,
                getName = function() return h.data.name end,
                getJob = function() return h.data.job end }
        end
    }
    h.qb = { Functions = {
        GetPlayerData = function() return h.data end,
        GetPlayer = function() if h.loaded then return { PlayerData = h.data } end end,
        Notify = function(...) record('qbcore', ...) end
    } }
    local resources = {
        es_extended = { getSharedObject = function() return h.esx end },
        ['qb-core'] = { GetCoreObject = function() return h.qb end },
        qbx_core = {
            GetPlayerData = function() return h.data end,
            GetCoreVersion = function() return '1.0.0' end,
            GetPlayer = function() if h.loaded then return { PlayerData = h.data } end end,
            Notify = function(_, ...) record('qbox', ...) end
        },
        ox_lib = {
            hasLoaded = function() return true end,
            notify = function(_, data) record('ox_lib', data) end,
            progressActive = function() return h.busy end,
            progressBar = function(_, data)
                h.busy = true
                local pending = e.promise.new()
                h.oxPending = pending
                return e.Citizen.Await(pending)
            end,
            cancelProgress = function()
                h.cleanup = h.cleanup + 1; h.busy = false
                if h.oxPending then h.oxPending:resolve(false) end
            end
        },
        progressbar = {
            isDoingSomething = function() return h.busy end,
            Progress = function(_, data, callback) h.busy = true; h.done = callback; h.progressData = data end
        }
    }
    h.resources = resources
    e.exports = setmetatable(resources, { __call = function(_, name, callback) h.exported[name] = callback end })
    e.BeginTextCommandThefeedPost = function() end
    e.AddTextComponentSubstringPlayerName = function(text) record('native', text) end
    e.EndTextCommandThefeedPostTicker = function() end
    for _, key in ipairs({'fx_version', 'game', 'author', 'description', 'version'}) do e[key] = function() end end
    for _, key in ipairs({'shared_scripts', 'client_scripts', 'server_scripts'}) do
        e[key] = function(list) h.manifest[key] = list end
    end
    h:load('fxmanifest.lua')
    for _, name in ipairs(h.manifest.shared_scripts) do h:load(name) end
    for _, name in ipairs(h.manifest[server and 'server_scripts' or 'client_scripts']) do h:load(name) end
    if configure then configure(e.Config, h) end
    e.NR.initialise()
    return h
end
function Harness:load(name)
    assert(load(readSource(name), '@' .. name, 't', self.env))()
end
function Harness:emit(name, ...)
    for _, callback in ipairs(self.events[name] or {}) do callback(...) end
end
function Harness:pump(untilTime)
    untilTime = untilTime or self.now
    local count = 0
    while true do
        local nextIndex, nextTimer
        for i, timer in ipairs(self.timers) do
            if timer.at <= untilTime and (not nextTimer or timer.at < nextTimer.at) then nextIndex, nextTimer = i, timer end
        end
        if not nextTimer then break end
        table.remove(self.timers, nextIndex)
        self.now = nextTimer.at
        nextTimer.callback()
        count = count + 1
        assert(count < 1000, 'Unexpected timer loop')
    end
    self.now = untilTime
end
function Harness:run(callback)
    local result = {}
    local co = coroutine.create(function() result.values = table.pack(callback()) end)
    local ok, reason = coroutine.resume(co)
    assert(ok, reason)
    return result
end
function Harness:progress()
    return self:run(function() return self.exported.Progress({label = 'Testing', duration = 1000}) end)
end
function Harness:complete(success)
    self.busy = false
    if self.oxPending then self.oxPending:resolve(success) else self.done(not success) end
end

test('Lua runtime is 5.4', function() equal(_VERSION, 'Lua 5.4') end)
for name, resource in pairs({ esx = 'es_extended', qbcore = 'qb-core', qbox = 'qbx_core' }) do
    for _, server in ipairs({ false, true }) do
        test('Detection ' .. name .. ' ' .. tostring(server), function()
            local h = Harness.new(server, { [resource] = true })
            equal(h.exported.GetFramework(), name)
        end)
    end
end
test('Standalone auto detection', function() equal(Harness.new(false).exported.GetFramework(), 'standalone') end)
test('Qbox QB virtual export is not a second resource', function()
    local h = Harness.new(false, { qbx_core = true })
    equal(h.exported.GetFramework(), 'qbox')
end)
test('Ambiguous frameworks block readiness', function()
    local h = Harness.new(true, { qbx_core = true, ['qb-core'] = true })
    local value, reason = h.exported.GetFramework()
    equal(value, nil); equal(reason, 'not_ready')
    assert(not table.concat(h.logs):find('%[SUCCESS%]'))
end)
test('ESX is detected independently from Qbox', function()
    equal(Harness.new(false, { qbx_core = true, es_extended = true }).env.NR.ready, false)
end)
test('Manual framework resolves ambiguity', function()
    local h = Harness.new(true, { qbx_core = true, es_extended = true }, function(c) c.Framework = 'esx' end)
    equal(h.exported.GetFramework(), 'esx')
end)
test('Missing manual framework fails safely', function()
    local h = Harness.new(false, {}, function(c) c.Framework = 'qbcore' end)
    equal(h.env.NR.ready, false)
end)
test('Broken framework API fails safely', function()
    local h = Harness.new(false, { ['qb-core'] = true }, function(_, t) t.qb.Functions.GetPlayerData = nil end)
    equal(h.env.NR.ready, false)
end)
test('Framework stop invalidates object and restart obtains replacement', function()
    local h = Harness.new(false, { ['qb-core'] = true }, function(c) c.Framework = 'qbcore' end)
    local old = h.env.NR.frameworks.qbcore.object()
    h.states['qb-core'] = nil; h:emit('onClientResourceStop', 'qb-core'); h:pump()
    equal(h.env.NR.ready, false)
    h.qb = { Functions = { GetPlayerData = function() return {} end } }
    h.states['qb-core'] = true; h:emit('onClientResourceStart', 'qb-core'); h:pump()
    equal(h.env.NR.ready, true); assert(h.env.NR.frameworks.qbcore.object() ~= old)
end)
test('Auto mode recovers from conflict after resource stop', function()
    local h = Harness.new(true, { es_extended = true, qbx_core = true })
    h.states.es_extended = nil; h:emit('onResourceStop', 'es_extended'); h:pump()
    equal(h.exported.GetFramework(), 'qbox')
end)
test('Invalid configuration never prints success', function()
    local h = Harness.new(true, {}, function(c) c.Notify.defaultDuration = -1 end)
    equal(h.env.NR.ready, false); assert(not table.concat(h.logs):find('%[SUCCESS%]'))
end)
test('Banner once per successful startup with real metadata', function()
    local h = Harness.new(true, {}, function(c) c.Licence.id = 'TEST-LICENCE' end)
    h.env.NR.initialise()
    local output = table.concat(h.logs, '\n')
    local _, count = output:gsub('%[SUCCESS%]', '')
    equal(count, 1); assert(output:find('TEST%-LICENCE')); assert(output:find('standalone'))
    assert(output:find('1%.0%.0')); assert(output:find('Static metadata; no online validation', 1, true))
end)
test('Server and client export separation', function()
    local client, server = Harness.new(false), Harness.new(true)
    equal(client.exported.NotifyPlayer, nil); equal(server.exported.Notify, nil)
    equal(server.exported.Progress, nil)
    for _, name in ipairs({'GetFramework', 'Notify', 'Progress', 'GetPlayerData'}) do assert(client.exported[name]) end
    for _, name in ipairs({'GetFramework', 'NotifyPlayer', 'GetPlayerData'}) do assert(server.exported[name]) end
end)

for _, kind in ipairs({'success', 'error', 'warning', 'info'}) do
    test('Notification normalisation ' .. kind, function()
        local h = Harness.new(false, { ox_lib = true })
        local ok, reason = h.exported.Notify({ description = 'Test', type = kind })
        equal(ok, true); equal(reason, nil)
        equal(h.shown[1].args[1].type, kind); equal(h.shown[1].args[1].duration, 5000)
    end)
end
test('Missing description accepted with title', function()
    local h = Harness.new(false); equal(h.exported.Notify({title = 'Title'}), true)
end)
test('Missing title accepted with description', function()
    local h = Harness.new(false); equal(h.exported.Notify({description = 'Description'}), true)
end)
for _, case in ipairs({
    { {}, 'empty_message' }, { {title = 'T', duration = -1}, 'invalid_duration' },
    { {title = 'T', duration = '1000'}, 'invalid_duration' },
    { {title = 'T', duration = 0/0}, 'invalid_duration' },
    { {title = 'T', type = 'admin'}, 'invalid_type' },
    { {title = 'T', position = 'unknown'}, 'invalid_position' }
}) do
    test('Reject notification ' .. case[2] .. ' ' .. tostring(case[1].duration), function()
        local h = Harness.new(false)
        local ok, reason = h.exported.Notify(case[1]); equal(ok, false); equal(reason, case[2]); equal(#h.shown, 0)
    end)
end
test('Invalid notification table rejected', function()
    local ok, reason = Harness.new(false).exported.Notify('text'); equal(ok, false); equal(reason, 'invalid_data')
end)
test('Notification provider independent of framework', function()
    local h = Harness.new(false, { es_extended = true, ox_lib = true }, function(c) c.Notify.provider = 'ox_lib' end)
    h.exported.Notify({title = 'T'}); equal(h.shown[1].provider, 'ox_lib')
end)
test('Unavailable notification falls back once', function()
    local h = Harness.new(false, {}, function(c) c.Notify.provider = 'ox_lib' end)
    equal(h.exported.Notify({title = 'T'}), true); equal(#h.shown, 1); equal(h.shown[1].provider, 'native')
end)
test('Unavailable provider without fallback fails', function()
    local h = Harness.new(false, {}, function(c) c.Notify.provider = 'ox_lib'; c.Notify.allowFallback = false end)
    local ok, reason = h.exported.Notify({title = 'T'}); equal(ok, false); equal(reason, 'provider_unavailable')
end)
test('Throwing notification provider never duplicates UI', function()
    local h = Harness.new(false, { ox_lib = true })
    h.resources.ox_lib.notify = function() h.shown[#h.shown + 1] = {}; error('after display') end
    local ok, reason = h.exported.Notify({title = 'T'}); equal(ok, false); equal(reason, 'provider_error'); equal(#h.shown, 1)
end)
test('QBCore warning maps to primary and title/caption', function()
    local h = Harness.new(false, { ['qb-core'] = true })
    h.exported.Notify({title = 'T', description = 'D', type = 'warning'})
    equal(h.shown[1].args[1].text, 'T'); equal(h.shown[1].args[2], 'primary')
end)
test('Qbox uses native Notify export and configured ox_lib type', function()
    local h = Harness.new(false, { qbx_core = true })
    h.exported.Notify({title = 'T', description = 'D'})
    equal(h.shown[1].provider, 'qbox'); equal(h.shown[1].args[2], 'info'); equal(h.shown[1].args[4], 'D')
end)
test('ESX notification signature', function()
    local h = Harness.new(false, { es_extended = true, esx_notify = true })
    h.exported.Notify({title = 'T', description = 'D', type = 'error', duration = 1234})
    equal(h.shown[1].args[1], 'T: D'); equal(h.shown[1].args[2], 'error'); equal(h.shown[1].args[3], 1234)
end)
test('Legacy ox_lib info type configurable', function()
    local h = Harness.new(false, { ox_lib = true }, function(c) c.Notify.oxInfoType = 'inform' end)
    h.exported.Notify({title = 'T'}); equal(h.shown[1].args[1].type, 'inform')
end)
test('Targeted server notification validates and queues exactly one recipient', function()
    local h = Harness.new(true)
    equal(h.exported.NotifyPlayer(1, {title = 'T'}), true); equal(#h.sent, 1); equal(h.sent[1].target, 1)
    local client = Harness.new(false)
    client.env.source = 65535; client:emit(h.sent[1].name, h.sent[1].payload); equal(#client.shown, 1)
end)
for _, source in ipairs({-1, 0, 1.5, '1', 999, math.huge}) do
    test('Reject unsafe notification source ' .. tostring(source), function()
        local h = Harness.new(true)
        local ok, reason = h.exported.NotifyPlayer(source, {title = 'T'})
        equal(ok, false); equal(reason, 'invalid_source'); equal(#h.sent, 0)
    end)
end
test('Client event rejects local origin and invalid payload', function()
    local h = Harness.new(false)
    h.env.source = 0; h:emit('nr-core:client:notify', {title = 'T'}); equal(#h.shown, 0)
    h.env.source = 65535; h:emit('nr-core:client:notify', 'bad'); equal(#h.shown, 0)
end)
test('No server network events registered', function() equal(next(Harness.new(true).network), nil) end)
test('Provider start and stop re-resolve notification selection', function()
    local h = Harness.new(false)
    h.states.ox_lib = true; h:emit('onClientResourceStart', 'ox_lib'); h:pump()
    equal(h.env.NR.notificationProvider, 'ox_lib')
    h.states.ox_lib = nil; h:emit('onClientResourceStop', 'ox_lib'); h:pump()
    equal(h.env.NR.notificationProvider, 'native')
end)

for _, provider in ipairs({'ox_lib', 'progressbar'}) do
    test(provider .. ' progress successful completion', function()
        local h = Harness.new(false, { [provider] = true })
        local r = h:progress(); h:pump(); equal(r.values, nil); h:complete(true)
        equal(r.values[1], true); equal(r.values[2], nil)
    end)
    test(provider .. ' progress cancellation', function()
        local h = Harness.new(false, { [provider] = true })
        local r = h:progress(); h:pump(); h:complete(false)
        equal(r.values[1], false); equal(r.values[2], 'cancelled')
    end)
    test(provider .. ' progress watchdog and cleanup', function()
        local h = Harness.new(false, { [provider] = true })
        local r = h:progress(); h:pump(6000)
        equal(r.values[1], false); equal(r.values[2], 'timeout'); equal(h.cleanup, 1); equal(h.busy, false)
    end)
    test(provider .. ' progress rejects overlapping operations', function()
        local h = Harness.new(false, { [provider] = true })
        local first = h:progress(); h:pump(); local second = h:progress()
        equal(second.values[1], false); equal(second.values[2], 'busy'); h:complete(true); equal(first.values[1], true)
    end)
    test(provider .. ' progress provider stop', function()
        local h = Harness.new(false, { [provider] = true })
        local r = h:progress(); h:pump(); h.states[provider] = nil; h:emit('onClientResourceStop', provider)
        equal(r.values[1], false); equal(r.values[2], 'provider_stopped')
    end)
end
test('No progress provider fails clearly', function()
    local r = Harness.new(false):progress(); equal(r.values[1], false); equal(r.values[2], 'provider_unavailable')
end)
test('Invalid progress duration and label rejected', function()
    local h = Harness.new(false)
    local ok, reason = h.exported.Progress({label = 'T', duration = 0}); equal(ok, false); equal(reason, 'invalid_duration')
    ok, reason = h.exported.Progress({label = '', duration = 1}); equal(ok, false); equal(reason, 'invalid_label')
end)
test('Provider already busy rejects without cleanup', function()
    local h = Harness.new(false, { progressbar = true }); h.busy = true
    local r = h:progress(); equal(r.values[2], 'busy'); equal(h.cleanup, 0)
end)
test('Progress callback duplicate and stale timeout cannot affect next operation', function()
    local h = Harness.new(false, { progressbar = true })
    local first = h:progress(); local old = h.done; h:complete(true)
    old(true); equal(first.values[1], true)
    h.now = 5000; local second = h:progress(); h:pump(6000)
    equal(second.values, nil); h:complete(true); equal(second.values[1], true)
end)
test('Calling resource stop cleans up its operation', function()
    local h = Harness.new(false, { progressbar = true })
    local r = h:progress(); h:emit('onClientResourceStop', 'consumer')
    equal(r.values[2], 'resource_stopped'); equal(h.cleanup, 1)
end)
test('Throwing progress start cleans up and releases lock', function()
    local h = Harness.new(false, { progressbar = true })
    h.resources.progressbar.Progress = function() error('failed') end
    local r = h:progress(); equal(r.values[2], 'provider_error'); equal(h.cleanup, 1)
end)
test('Configured cancellation limit forwarded', function()
    local h = Harness.new(false, { progressbar = true }, function(c) c.Progress.allowCancel = false end)
    h:progress(); equal(h.progressData.canCancel, false); h:complete(true)
end)
test('Custom progress example is functional', function()
    local h = Harness.new(false, { progressbar = true }, function(c) c.Progress.provider = 'custom' end)
    local r = h:progress(); h:complete(true); equal(r.values[1], true)
end)

for name, resource in pairs({esx = 'es_extended', qbcore = 'qb-core', qbox = 'qbx_core'}) do
    for _, server in ipairs({false, true}) do
        test(name .. ' player snapshot ' .. tostring(server), function()
            local h = Harness.new(server, { [resource] = true })
            local player = h.exported.GetPlayerData(server and 1 or nil)
            assert(player); equal(player.name, 'Test Character'); equal(player.job.name, 'police')
            equal(player.job.grade, 2); equal(player.money, nil); equal(player.metadata, nil)
            if name ~= 'esx' then equal(player.job.onDuty, false) end
            player.job.name = 'edited'; equal(h.data.job.name, 'police')
        end)
        test(name .. ' unloaded player ' .. tostring(server), function()
            local h = Harness.new(server, { [resource] = true })
            h.loaded = false; h.env.LocalPlayer.state.isLoggedIn = false
            local value, reason = h.exported.GetPlayerData(server and 1 or nil)
            equal(value, nil); equal(reason, 'player_unloaded')
        end)
    end
end
test('Missing job and unsupported fields remain absent', function()
    local h = Harness.new(false, { qbx_core = true }); h.data.job = nil
    local player = h.exported.GetPlayerData(); equal(next(player.job), nil); equal(player.permissions, nil)
end)
test('Disconnected server player rejected', function()
    local h = Harness.new(true, { qbx_core = true }); h.connected = false
    local player, reason = h.exported.GetPlayerData(1); equal(player, nil); equal(reason, 'invalid_source')
end)
test('Standalone player provides name only', function()
    local player = Harness.new(true).exported.GetPlayerData(1)
    equal(player.name, 'Display Name'); equal(player.identifier, nil); equal(next(player.job), nil)
end)
test('Custom framework minimal example initialises', function()
    local h = Harness.new(false, {}, function(c) c.Framework = 'custom' end)
    equal(h.exported.GetFramework(), 'custom'); equal(h.exported.GetPlayerData().name, 'Display Name')
end)
test('Missing optional ESX notifier uses native fallback', function()
    local h = Harness.new(false, { es_extended = true })
    equal(h.exported.Notify({title = 'T'}), true); equal(h.shown[1].provider, 'native')
end)
test('ESX notifier restart updates provider resolution', function()
    local h = Harness.new(false, { es_extended = true })
    h.states.esx_notify = true; h:emit('onClientResourceStart', 'esx_notify'); h:pump()
    equal(h.env.NR.notificationProvider, 'esx')
    h.states.esx_notify = nil; h:emit('onClientResourceStop', 'esx_notify'); h:pump()
    equal(h.env.NR.notificationProvider, 'native')
end)
test('Burst dependency starts coalesce to one refresh', function()
    local h = Harness.new(false)
    local before = #h.logs
    h:emit('onClientResourceStart', 'ox_lib'); h:emit('onClientResourceStart', 'progressbar'); h:pump()
    equal(#h.logs - before, 3)
end)
test('UTF-8 truncation preserves complete characters', function()
    local h = Harness.new(false)
    equal(h.env.NR.text(string.rep('ą', 130), 255), string.rep('ą', 127))
    equal(h.exported.Notify({description = string.rep('ą', 600)}), true)
    assert(utf8.len(h.shown[1].args[1]))
end)
test('Invalid UTF-8 cannot break native notifier', function()
    local h = Harness.new(false)
    local ok, reason = h.exported.Notify({title = string.char(255)})
    equal(ok, false); equal(reason, 'empty_message')
end)
test('Config provider/duration/type errors block readiness', function()
    for _, edit in ipairs({
        function(c) c.Framework = 'unknown' end,
        function(c) c.Notify.fallback = 'auto' end,
        function(c) c.Progress.timeoutGrace = 0 end,
        function(c) c.Licence = nil end,
        function(c) c.Notify.oxInfoType = 'unknown' end
    }) do equal(Harness.new(true, {}, edit).env.NR.ready, false) end
end)
test('Progress invalid cancellation argument rejected', function()
    local h = Harness.new(false)
    local ok, reason = h.exported.Progress({label = 'T', duration = 1, canCancel = 'yes'})
    equal(ok, false); equal(reason, 'invalid_cancel')
end)
test('Progress availability exception cannot start UI', function()
    local h = Harness.new(false, { progressbar = true })
    h.resources.progressbar.isDoingSomething = function() error('missing export') end
    local result = h:progress(); equal(result.values[2], 'provider_error'); equal(h.done, nil)
end)
test('Explicit custom notification adapter works', function()
    local h = Harness.new(false, {}, function(c) c.Notify.provider = 'custom' end)
    equal(h.exported.Notify({title = 'T'}), true); equal(h.shown[1].provider, 'native')
end)
test('Explicit fallback provider selected without duplicates', function()
    local h = Harness.new(false, { ox_lib = true }, function(c)
        c.Notify.provider = 'qbox'; c.Notify.fallback = 'ox_lib'
    end)
    equal(h.exported.Notify({title = 'T'}), true); equal(#h.shown, 1); equal(h.shown[1].provider, 'ox_lib')
end)
test('ESX false duty is retained', function()
    local h = Harness.new(true, { es_extended = true }); h.data.job.onDuty = false
    equal(h.exported.GetPlayerData(1).job.onDuty, false)
end)
test('Character reload reads current data, never old snapshot', function()
    local h = Harness.new(false, { ['qb-core'] = true })
    equal(h.exported.GetPlayerData().identifier, 'char-1')
    h.env.LocalPlayer.state.isLoggedIn = false; equal(h.exported.GetPlayerData(), nil)
    h.data.citizenid = 'char-2'; h.data.job.name = 'ambulance'; h.env.LocalPlayer.state.isLoggedIn = true
    equal(h.exported.GetPlayerData().identifier, 'char-2'); equal(h.exported.GetPlayerData().job.name, 'ambulance')
end)
test('Own resource stop cancels progress and clears readiness', function()
    local h = Harness.new(false, { progressbar = true })
    local result = h:progress(); h:emit('onClientResourceStop', 'nr-core')
    equal(result.values[2], 'resource_stopped'); equal(h.cleanup, 1); equal(h.env.NR.ready, false)
end)
test('Example server command uses real exports and is ACE restricted', function()
    local h = Harness.new(true)
    h.resources['nr-core'] = {
        GetPlayerData = function(_, ...) return h.exported.GetPlayerData(...) end,
        NotifyPlayer = function(_, ...) return h.exported.NotifyPlayer(...) end
    }
    local command
    h.env.RegisterCommand = function(name, callback, restricted)
        equal(name, 'nrtest'); equal(restricted, true); command = callback
    end
    h:load('examples/nr-example/server.lua')
    command(1, {'999'}); equal(h.sent[1].target, 1); equal(h.sent[2].target, 1)
    command(0, {'-1'}); equal(#h.sent, 2)
    command(0, {'1'}); equal(#h.sent, 4)
end)
test('Client example exercises all client exports', function()
    local h = Harness.new(false, { progressbar = true })
    h.resources['nr-core'] = {}
    for _, name in ipairs({'GetFramework', 'Notify', 'Progress', 'GetPlayerData'}) do
        h.resources['nr-core'][name] = function(_, ...) return h.exported[name](...) end
    end
    h:load('examples/nr-example/client.lua')
    h.env.source = 65535
    h:run(function() h:emit('nr-example:run') end)
    equal(#h.shown, 1); assert(h.done); h:complete(true)
    assert(table.concat(h.logs):find('Player: Display Name'))
end)
test('Qbox supports inform with older ox_lib installations', function()
    local h = Harness.new(false, { qbx_core = true }, function(c) c.Notify.oxInfoType = 'inform' end)
    h.exported.Notify({title = 'T'}); equal(h.shown[1].args[2], 'inform')
end)
test('Timeout returns only after provider cleanup, ignoring synchronous cancel callback', function()
    local h = Harness.new(false, { progressbar = true })
    local cleaned
    local result = h:run(function()
        local completed, reason = h.exported.Progress({label = 'T', duration = 1})
        cleaned = h.cleanup
        return completed, reason
    end)
    h:pump(5001)
    equal(cleaned, 1); equal(result.values[1], false); equal(result.values[2], 'timeout')
end)
test('Custom dependencies are configurable without manager changes', function()
    local h = Harness.new(false, {}, function(c) c.CustomResources = {'my-framework'} end)
    h:load('bridges/frameworks/custom/shared.lua')
    equal(h.env.NR.watched['my-framework'], true)
end)
test('Invalid custom dependency list blocks readiness', function()
    local h = Harness.new(true, {}, function(c) c.CustomResources = {false} end)
    equal(h.env.NR.ready, false)
end)
print(('RESULT: %d behaviour tests passed'):format(passed))
