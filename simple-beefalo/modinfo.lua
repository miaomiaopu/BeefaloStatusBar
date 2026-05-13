name = "Simple Beefalo Status Bar"
version = "2026.05.13.0"
author = "miaomiaopu"
description = [[
骑乘皮弗娄牛时显示状态栏

当骑乘皮弗娄牛时显示：
健康、驯化、顺从、骑乘计时器、鞍具使用次数、饥饿

基于 MNK 的 Beefalo Status Bar 修改
喂食计时器重置修复来自 莲华可爱捏·ω·
AI 辅助制作

Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3725322029
]]

forumthread = ""
server_filter_tags = {"Beefalo Status Bar", "Beefalo UI"}

dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

api_version = 10

all_clients_require_mod = true
client_only_mod = false

icon_atlas = "icon.xml"
icon = "icon.tex"


-- 可选按键列表
local KEYS = {
    "RAlt"
}

-- 可选颜色列表
local COLORS = {
    {name = "ORANGE", description = "橙色"},
    {name = "ORANGE_ALT", description = "橙色代替"},
    {name = "BLUE", description = "蓝色"},
    {name = "BLUE_ALT", description = "蓝色代替"},
    {name = "PURPLE", description = "紫色"},
    {name = "PURPLE_ALT", description = "紫色代替"},
    {name = "RED", description = "红色"},
    {name = "RED_ALT", description = "红色代替"},
    {name = "GREEN", description = "绿色"},
    {name = "GREEN_ALT", description = "绿色代替"},
    {name = "WHITE", description = "白色"},
    {name = "YELLOW", description = "黄色"}
}

local function InsertOption(options, new_option, default)
    if new_option.data == default then new_option.hover = "默认" end
    options[#options + 1] = new_option
end

-- 数值选项生成器
local function GenerateNumericOptions(start, total, step, default, config)
    local config = config or {}
    local prefix = config.prefix or ""
    local suffix = config.suffix or ""

    local options = {}

    if config.first then InsertOption(options, config.first, default) end

    for i = start, total, step do
        local value = (not config.divide and not config.multiply) and i or (config.divide and i / config.divide or i * config.multiply)
        options[#options + 1] = {data = value, description = prefix .. value .. suffix, hover = value == default and "默认" or nil}
    end

    if config.last then InsertOption(options, config.last, default) end

    return options
end

-- 颜色选项生成器
local function GenerateColorOptions(default)
    local colorOptions = {}
    for i = 1, #COLORS do
        colorOptions[i] = {data = COLORS[i].name, description = COLORS[i].description}
        if default == COLORS[i].name then colorOptions[i].hover = "默认" end
    end
    return colorOptions
end

-- 快捷键选项生成器
local function GenerateKeyboardOptions(default)
    local options = {{description = "禁用", data = false, hover = "切换将被禁用"}}

    for i = 1, #KEYS do
        local key = "KEY_" .. KEYS[i]:upper()
        options[i + 1] = {description = KEYS[i], data = key, hover = key == default and "默认" or nil}
    end

    return options
end

-- ===== 配置项定义 =====
configuration_options =
{
    {
        name = "SEPARATOR_GENERAL",
        label = "常规",
        options = {{description = "", data = 1}},
        default = 1
    },
    {
        name = "ShowByDefault",
        label = "自动显示",
        hover = "当骑乘皮弗娄牛时自动显示状态栏",
        options = {
            {description = "启用", data = true, hover = "默认"},
            {description = "禁用", data = false}
        },
        default = true
    },
    {
        name = "ToggleKey",
        label = "切换按键",
        hover = "按下此按键（在骑乘状态下）切换状态栏\n切换将覆盖\"自动显示\"选项",
        options = GenerateKeyboardOptions("KEY_RALT"),
        default = "KEY_RALT"
    },
    {
        name = "EnableSounds",
        label = "音效",
        hover = "显示或隐藏状态栏时播放音效",
        options = {
            {description = "禁用", data = false, hover = "默认"},
            {description = "启用", data = true}
        },
        default = false
    },
    {
        name = "ClientConfig",
        label = "首选客户端配置",
        hover = "启用后将忽略服务器配置\n此屏幕上的配置将应用于加入或托管的每个服务器",
        options = {
            {description = "禁用", data = false, hover = "默认"},
            {description = "启用", data = true}
        },
        default = false,
        client = true
    },
    {
        name = "SEPARATOR_BADGE_SETTINGS",
        label = "徽章设置",
        options = {{description = "", data = 1}},
        default = 1
    },
    {
        name = "Theme",
        label = "主题",
        hover = "更改徽章的主题",
        options = {
            {description = "默认主题", data = "Default", hover = "默认"},
            {description = "熔炉", data = "TheForge", hover = "使用熔炉主题风格"}
        },
        default = "Default"
    },
    {
        name = "Scale",
        label = "比例",
        hover = "控制徽章的比例（大小）",
        options = GenerateNumericOptions(50, 200, 5, 1, {divide = 100}),
        default = 1
    },
    {
        name = "HungerThreshold",
        label = "饥饿徽章阈值",
        hover = "设定牛饥饿度需要达到阈值才激活显示徽章\n此徽章也可以通过设置为\"从不显示\"来禁用",
        options = GenerateNumericOptions(5, 375, 5, 10, {first = {data = false, description = "从不显示"}}),
        default = 10
    },
    {
        name = "HEALTH_BADGE_CLEAR_BG",
        label = "健康徽章背景",
        hover = "独特：使用独特的背景、亮度和不透明度不适用\n标准：使用标准背景、亮度和不透明度适用",
        options = {
            {description = "独特", data = false, hover = "默认"},
            {description = "标准", data = true}
        },
        default = false
    },
    {
        name = "BADGE_BG_BRIGHTNESS",
        label = "背景亮度",
        hover = "控制徽章的背景亮度",
        options = GenerateNumericOptions(0, 100, 5, 60, {suffix = "%"}),
        default = 60
    },
    {
        name = "BADGE_BG_OPACITY",
        label = "背景透明度",
        hover = "控制徽章的背景不透明度（透明度）\n100% - 不透明、0% - 完全透明",
        options = GenerateNumericOptions(0, 100, 5, 100, {suffix = "%"}),
        default = 100
    },
    {
        name = "GapModifier",
        label = "间隙调整",
        hover = "控制徽章之间的空白间隙\n负值 - 更少的间隙、正值 - 更多的间隙",
        options = GenerateNumericOptions(-15, 30, 1, 0),
        default = 0
    },
    {
        name = "SEPARATOR_BADGE_COLORS",
        label = "徽章颜色",
        options = {{description = "", data = 1}},
        default = 1
    },
    {
        name = "COLOR_DOMESTICATION_ORNERY",
        label = "驯化（战牛）",
        hover = "战牛的驯化徽章颜色",
        options = GenerateColorOptions("ORANGE"),
        default = "ORANGE"
    },
    {
        name = "COLOR_DOMESTICATION_RIDER",
        label = "驯化（行牛）",
        hover = "行牛的驯化徽章颜色",
        options = GenerateColorOptions("BLUE"),
        default = "BLUE"
    },
    {
        name = "COLOR_DOMESTICATION_PUDGY",
        label = "驯化（肥牛）",
        hover = "肥胖牛的驯化徽章颜色",
        options = GenerateColorOptions("PURPLE"),
        default = "PURPLE"
    },
    {
        name = "COLOR_DOMESTICATION_DEFAULT",
        label = "驯化（默认）",
        hover = "默认牛的驯化徽章颜色",
        options = GenerateColorOptions("WHITE"),
        default = "WHITE"
    },
    {
        name = "COLOR_OBEDIENCE",
        label = "顺从",
        hover = "顺从徽章颜色",
        options = GenerateColorOptions("RED"),
        default = "RED"
    },
    {
        name = "COLOR_TIMER",
        label = "骑乘计时器",
        hover = "骑乘计时器徽章颜色",
        options = GenerateColorOptions("GREEN"),
        default = "GREEN"
    },
    {
        name = "SEPARATOR_POSITIONING",
        label = "位置偏移",
        options = {{description = "", data = 1}},
        default = 1
    },
    {
        name = "OffsetX",
        label = "水平偏移",
        hover = "调整水平位置\n负值 - 向左移动、正值 - 向右移动",
        options = GenerateNumericOptions(-500, 500, 10, 0),
        default = 0
    },
    {
        name = "OffsetY",
        label = "垂直偏移",
        hover = "调整垂直位置\n负值 - 向下移动、正值 - 向上移动",
        options = GenerateNumericOptions(-500, 500, 5, 0),
        default = 0
    }
}
