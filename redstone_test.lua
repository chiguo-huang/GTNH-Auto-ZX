component = require("component")
sides = require("sides")
os = require("os")

-- 红石输出测试工具（独立于主脚本）
-- 用法：redstone_test <up|down|east|west|north|south> [时长秒(默认5)] [信号强度(默认15)]
-- 例：redstone_test east 5 15   在东面输出强度15信号5秒，结束后归零

local dir_map = {
    up = sides.up, down = sides.down,
    east = sides.east, west = sides.west,
    north = sides.north, south = sides.south,
}

local args = {...}
local dir = args[1] and args[1]:lower()
local side = dir and dir_map[dir]
if not side then
    print("用法：redstone_test <up|down|east|west|north|south> [时长秒(默认5)] [信号强度(默认15)]")
    if dir then print(string.format("无效方向：%s", args[1])) end
    return
end
local duration = tonumber(args[2]) or 5
if duration <= 0 then duration = 5 end
local strength = tonumber(args[3]) or 15
if strength < 0 or strength > 15 then strength = 15 end

local rs, count = nil, 0
for addr in component.list("redstone") do
    count = count + 1
    if not rs then rs = component.proxy(addr) end
end
if not rs then
    print("未找到redstone组件（红石卡未插入电脑或未接入网络）")
    return
end
print(string.format("使用redstone组件：%s", rs.address))
if count > 1 then
    print(string.format("警告：检测到%d个redstone组件（红石卡/红石I/O方块混用），仅使用第一个！", count))
end

print(string.format("开始：在 %s 面输出信号强度 %d，持续 %d 秒（观察该面的灯/红石粉是否亮起）", dir, strength, duration))
rs.setOutput(side, strength)
for i = duration, 1, -1 do
    print(string.format("  剩余 %d 秒", i))
    os.sleep(1)
end
rs.setOutput(side, 0)
print("信号已归零，测试结束")
