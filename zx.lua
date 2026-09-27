component = require("component")
sides = require("sides")
event = require("event")
os = require("os")
computer = require("computer")
 
local redstone
local transposer
local oredrills = {}
local mode
local side_item_in
local side_item_out
local side_trash
local side_orb
local side_ritual
local side_miners
local side_done_miners
local side_done_drills
local itemData = { --使用“item.name:item.damage”的形式辨认物品
    -- A类原料-无矿石
    ["minecraft:melon_block:0"] = { type = 1, lp = 123456 },                                         --西瓜
    ["minecraft:tnt:0"] = { type = 1, lp = 775000 },                                                 --TNT
    ["minecraft:soul_sand:0"]  = { type = 1, lp = 5000000 },                                         --灵魂沙
    ["etfuturum:amethyst_cluster_2:6"]  = { type = 1, lp = 234567 },                               --紫水晶簇
    ["etfuturum:blue_ice:0"]  = { type = 1, lp = 275000 },                                           --蓝冰
    ["etfuturum:honeycomb:0"]  = { type = 1, lp = 800050 },                                          --蜜脾
    ["etfuturum:netherite_scrap:0"]  = { type = 1, lp = 9876543 },                                   --下界合金碎片
    ["MagicBees:item.frenziedFrame:0"]  = { type = 1, lp = 500666 },                                 --狂热框架
    ["GalacticraftMars:item.itemBasicAsteroids:0"]  = { type = 1, lp = 1000000 },                  --重型装甲板
    ["universalsingularities:universal.extraUtilities.singularity:0"]  = { type = 1, lp = 5000200 }, --不稳定金属奇点
    ["dreamcraft:item.HeavyDutyPlateTier4:0"]  = { type = 1, lp = 7500000 },                         --重型合金锭 T4
    ["dreamcraft:item.HeavyDutyPlateTier5:0"]  = { type = 1, lp = 10000000 },                        --重型合金锭 T5
    ["dreamcraft:item.HeavyDutyPlateTier6:0"]  = { type = 1, lp = 15000000 },                        --重型合金锭 T6
    ["dreamcraft:item.HeavyDutyPlateTier7:0"]  = { type = 1, lp = 30000000 },                        --重型合金锭 T7
    ["dreamcraft:item.HeavyDutyPlateTier8:0"]  = { type = 1, lp = 50000000 },                        --重型合金锭 T8
    ["Botania:alfheimPortal:0"]  = { type = 1, lp = 50000000 },                                      --精灵门核心
    ["Botania:laputaShard:0"]  = { type = 1, lp = 1000000001},                                     --拉普达碎片I
    ["gregtech:gt.metaitem.01:32462"]  = { type = 1, lp = 500000 },                                --重型合金锭 T1
    ["gregtech:gt.metaitem.01:32463"]  = { type = 1, lp = 750000 },                                --重型合金锭 T2
    ["gregtech:gt.blockcasings4:7"]  = { type = 1, lp = 6669666 },                                 --聚变线圈方块
    ["BiomesOPlenty:mud:1"]  = { type = 1, lp = 700000 },                                          --流沙
    -- B类原料-混合类型
    ["minecraft:end_stone:0"] = { type = 2, lp = 500000 },                                           --末地石
    ["appliedenergistics2:tile.BlockSkyChest:1"] = { type = 2, lp = 600002 },                      --陨石块箱子
    ["harvestcraft:cheeseItem:0"] = { type = 2, lp = 650000 },                                       --芝士
    ["Thaumcraft:ItemSanitySoap:0"] = { type = 2, lp = 800000 },                                     --祛邪肥皂
    ["minecraft:fish:3"] = { type = 2, lp = 6666666},                                              --河豚
    ["gregtech:gt.metaitem.01:32680"] = { type = 2, lp = 300000 },                                 --发射器(LV)
    ["gregtech:gt.metaitem.01:32690"] = { type = 2, lp = 300000 },                                 --传感器(LV)
    ["gregtech:gt.metaitem.02:30500"] = { type = 2, lp = 420000 },                                 --精致的钻石
    ["gregtech:gt.metaitem.01:24347"] = { type = 2, lp = 500000 },                                 --火石透镜
    ["gregtech:gt.metaitem.01:32464"] = { type = 2, lp = 1000000 },                                --重型合金锭 T3
    ["gregtech:gt.metaitem.01:32672"] = { type = 2, lp = 1000000 },                                --力场发生器(HV)
    ["gregtech:gt.metaitem.01:32674"] = { type = 2, lp = 1500000 },                                --力场发生器(IV)
    ["gregtech:gt.blockmachines:1182"] = { type = 2, lp = 3250000 },                               --进阶电路组装机 II
    ["gregtech:gt.blockmachines:10990"] = { type = 2, lp = 44000000 },                             --精英回收机
    ["ForbiddenMagic:FMResource:3"] = { type = 2, lp = 700700 },                                   --腐血碎片
    ["Botania:starfield:0"] = { type = 2, lp = 800800 },                                             --星空制造器
    -- C类原料-纯矿石
    ["minecraft:nether_star:0"] = { type = 3, lp = 750000 },                                         --下界之星
    ["GalacticraftAmunRa:tile.machines2:1"] = { type = 3, lp = 1000000001 },                       --离子推进器喷口
    ["kubatech:defc.casing:8"] = { type = 3, lp = 90000000},                                       --血腥灵宝聚合机械方块
    ["gregtech:gt.metaitem.01:32692"] = { type = 3, lp = 500000 },                                 --传感器(HV)
    ["gregtech:gt.metaitem.01:32682"] = { type = 3, lp = 2000000 },                                --发射器(HV)
    ["gregtech:gt.metaitem.01:32670"] = { type = 3, lp = 600000 },                                 --力场发生器(LV)
    ["gregtech:gt.blockmachines:482"] = { type = 3, lp = 1200000 },                                --进阶复制机
    ["gregtech:gt.blockmachines:214"] = { type = 3, lp = 2000000 },                                --进阶组装机 III
    ["gregtech:gt.blockmachines:463"] = { type = 3, lp = 6000000 },                                --进阶质量发生器 II
    ["gregtech:gt.blockmachines:465"] = { type = 3, lp = 2500000 },                                --进阶质量发生器 IV
    ["gregtech:gt.blockmachines:10951"] = { type = 3, lp = 100000000 },                            --精英质量发生器 II
    ["gregtech:gt.blockmachines:406"] = { type = 3, lp = 10000000 },                               --精英打包机 I
    ["gregtech:gt.blockmachines:345"] = { type = 3, lp = 12500000 },                               --进阶扫描仪 IV
    ["gregtech:gt.blockmachines:1186"] = { type = 3, lp = 80000000 },                              --进阶电路组装机 VI
    ["gregtech:gt.blockmachines:28050"] = { type = 3, lp = 125000000 },                            --终极作物合成器
    ["gregtech:gt.blockmachines:14009"] = { type = 3, lp = 1000000001 },                           --太空采矿模块MK-III
    ["gregtech:gt.metaitem.03:32091"] = { type = 3, lp = 25000000 },                               --晶体主机
    ["gregtech:gt.metaitem.03:32094"] = { type = 3, lp = 50000000 }                                --湿件超级计算机
}
local function set_oredrills(state) for _, p in ipairs(oredrills) do p.setWorkAllowed(state) end end
 
local function get_direction(prompt, default)
    local valid_dirs = { n = sides.north, s = sides.south, e = sides.east, w = sides.west, u = sides.up, d = sides.down }
    while true do
        io.write(string.format("%s 可用方向：(n->north/s->south/e->east/w->west/u->up/d->down) 默认：[%s]: ", prompt, default))
        local input = io.read():lower()
        if input == "" then return valid_dirs[default]
        elseif valid_dirs[input] then return valid_dirs[input]
        else print("无效方向，请重新输入") end
    end
end
 
local function wait_for_signal(side, expected_sig, timeout, reason) --只支持红石事件
    if redstone.getInput(side) == expected_sig then --先查当前电平，防止等待前信号已到位（或事件被os.sleep吞掉）
        print(string.format("[%s] 信号当前已为%d，直接通过", reason, expected_sig))
        return true
    end
    local start = computer.uptime()
    while computer.uptime() - start < timeout do
        local remaining = timeout - (computer.uptime()- start)
        local wait = math.min(5, math.max(0.1, remaining))  -- 单次循环最多等5秒，但不超过剩余时间
        local _, _, event_side, _, new_sig = event.pull(wait, "redstone_changed")
        if event_side == side and new_sig == expected_sig then
            print(string.format("[%s] 收到信号，耗时%.0f秒", reason, computer.uptime() - start))
            return true
        end
        print(string.format("[%s] 等待信号中，已等%.0f/%d秒", reason, computer.uptime() - start, timeout))
    end
    print(string.format("[%s] 等待超时（%d秒）", reason, timeout))
    return false
end
 
local function get_type(item)
    if item.name and item.damage ~= nil then
        local combined = item.name .. ":" .. tostring(item.damage)
        local info = itemData[combined]
        if info then return info end
    else return itemData[item.name] end
end
 
local function ore_drill()
    print("采矿场开采中")
    while true do
        set_oredrills(true)
        os.sleep(1)
        if wait_for_signal(side_done_drills, 15, 300, "采矿场完成") then break end
        print("超时，真正重启采矿场：先停机再启动")
        set_oredrills(false)
        os.sleep(2)
    end
    print("采矿场开采完成")
end

local function ore_miner()
    print("清理非矿石中")
    redstone.setOutput(side_miners, 15)
    os.sleep(2)
    while true do
        if wait_for_signal(side_done_miners, 15, 300, "清理机完成") then break end
        print("超时，真正重启清理机：断电后重新上电")
        redstone.setOutput(side_miners, 0)
        os.sleep(2)
        redstone.setOutput(side_miners, 15)
        os.sleep(2)
    end
    redstone.setOutput(side_miners, 0)
    print("清理完毕")
end
 
local function initialize()
    os.execute("cls")
    print("奥术钻探机模式接受所有祭品（除了无序的催化剂），填充机模式会排除无矿石祭品，纯矿石模式只接受纯矿石祭品。")
    io.write("输入对应数字选择模式（默认模式3）【1->奥术钻探机模式 | 2->填充机模式 | 3->纯矿石模式】：")
    local input = tonumber(io.read())
    if (input == 1 or input == 2 or input == 3) then mode = input
    else mode = 3 end
    side_ritual = get_direction("控制仪式启动的方向", "e")
    if mode == 1 then
        side_miners = get_direction("控制奥术钻探机启动的方向", "w")
        side_done_miners = get_direction("接受奥术钻探机开采完成信号的方向", "n")
    end
    if mode == 2 then
        side_miners = get_direction("控制填充机启动的方向", "w")
        side_done_miners = get_direction("接受填充机清理完成信号的方向", "n")
    end
    side_done_drills = get_direction("接受采矿场采矿完成信号的方向", "s")
    for addr in component.list() do
        local type = component.proxy(addr).type
        if type == "redstone" then redstone = component.proxy(addr)
        elseif type == "transposer" then transposer = component.proxy(addr)
        elseif type == "gt_machine" then
            local oredrill = component.proxy(addr)
            local name = oredrill.getName()
            if string.find(name, "multimachine.oredrill") then table.insert(oredrills, oredrill) end
        end
    end
    if not redstone then
        print("未连接任何红石端口，已退出")
        os.exit(0)
    elseif #oredrills == 0 then
        print("未连接任何采矿机，已退出")
        os.exit(0)
    elseif not transposer then
        print("未连接任何转运器，已退出")
        os.exit(0)
    end
    for side = 0, 5 do
        local name = transposer.getInventoryName(side)
        if name == "tile.fullDrawers1" then side_item_in = side
        elseif name == "tile.enderchest" then side_item_out = side
        elseif name == "tile.chest" then side_trash = side
        elseif name == "tile.extrautils:chestMini" then side_orb = side end
    end
    if not (side_item_in and side_item_out and side_trash and side_orb) then
        print("转运器检测到缺少抽屉、高级末影箱子、迷你箱或箱子，已退出")
        os.exit(0)
    end
    print(string.format("共%d台采矿场", #oredrills))
    if mode ~= 3 then redstone.setOutput(side_miners, 0) end
    os.sleep(3)
    print("清理场地中")
    ore_drill()
    if mode ~= 3 then ore_miner() end
end
 
local function main()
    initialize()
    print("初始化完成，进入主循环")
    os.sleep(2)
    ::select::
    os.execute("cls")
    local item = transposer.getStackInSlot(side_item_in, 2)
    while not item do
        print("无祭品，已待机，每10秒检测一次")
        os.sleep(10)
        goto select
    end
    print(string.format("当前祭品：item.label = %s | item.name = %s", item.label, item.name))
    local item_info = get_type(item)
    if (not item_info) or (mode == 3 and item_info.type ~= 3) or (mode == 2 and item_info.type == 1) then
        print("非白名单物品，转运至垃圾箱")
        transposer.transferItem(side_item_in, side_trash, transposer.getSlotStackSize(side_item_in, 2), 2)
        os.sleep(2)
        goto select
    end
    local orb
    local orb_wait = 0
    while true do
        orb = transposer.getStackInSlot(side_orb, 1)
        if not orb then
            os.execute("cls")
            print(string.format("未检测到宝珠，待机等待（已等%d秒）", orb_wait))
            os.sleep(5)
            orb_wait = orb_wait + 5
        else break end
    end
    local lp = 0
    local lp_wait = 0
    local lp_len = 0 --LP信息单行刷新：上一条已打印内容的字节长度
    while true do
        orb = transposer.getStackInSlot(side_orb, 1)
        lp = orb.networkEssence
        if item_info.lp <= lp + 100 then break end
        local msg = string.format("LP不足（需要%d，当前%d，还差%d，已等%d秒）", item_info.lp, lp, item_info.lp - lp, lp_wait)
        --首次换新行，之后\r回到行首原地刷新；按字节差补空格擦除残留（可变部分均为数字，字节差=显示宽度差）
        io.write((lp_len == 0 and "\n" or "\r") .. msg .. string.rep(" ", math.max(0, lp_len - #msg)))
        lp_len = #msg
        os.sleep(10)
        lp_wait = lp_wait + 10
    end
    if lp_len > 0 then io.write("\n") end --LP等待结束，补换行让后续输出另起一行
    print("当前网络lp量：", lp)
    print("祭品lp消耗量：", item_info.lp)
    transposer.transferItem(side_item_in, side_item_out, 1, 2, 1)
    redstone.setOutput(side_ritual, 15)
    print("等待陨星落地")
    os.sleep(11)
    redstone.setOutput(side_ritual, 0)
    os.execute("cls")
    if item_info.type == 1 then
        print("==清理场地==")
        ore_miner()
    elseif item_info.type == 2 then
        print("==混杂矿石==")
        ore_drill()
        ore_miner()
    elseif item_info.type == 3 then
        ore_drill()
    end
    goto select
end
 
main()