const fs = require('node:fs');
const path = require('node:path');
const { LuaFactory } = require('../.test-tools/node_modules/wasmoon');
const root = path.resolve(__dirname, '..');
function files(directory) {
    return fs.readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
        if (entry.name.startsWith('.') || entry.name === 'node_modules') return [];
        const target = path.join(directory, entry.name);
        return entry.isDirectory() ? files(target) : [target];
    });
}
function literal(value) {
    let eq = '';
    while (value.includes(`]${eq}]`)) eq += '=';
    return `[${eq}[${value}]${eq}]`;
}
(async () => {
    const lua = await new LuaFactory().createEngine();
    try {
        lua.global.set('readSource', name => fs.readFileSync(path.join(root, name), 'utf8'));
        const sources = files(root).filter(name => name.endsWith('.lua'));
        for (const file of sources) {
            await lua.doString(`assert(load(${literal(fs.readFileSync(file, 'utf8'))}, ${literal(file)}))`);
        }
        console.log(`Syntax: ${sources.length} Lua files compiled with Lua 5.4`);
        await lua.doString(fs.readFileSync(path.join(__dirname, 'spec.lua'), 'utf8'));
    } finally {
        lua.global.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
