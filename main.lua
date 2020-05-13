if Location == nil then
    -- a wrapper to runing ankulua script in only lua env.
    require("ankulua.lua")
end

WORK_DIR = scriptPath()
package.path = package.path .. ";" .. WORK_DIR .. '?.lua'

-- ========== Initial Settings ================
setDragDropTiming(200, 220)	--downMs: 開始移動前壓住不動幾毫秒	upMs: 最後放開前停住幾毫秒
setDragDropStepCount(35)	--stepCount: 從啟始點到目的地分幾步移動完
setDragDropStepInterval(10)	--intervalMs: 每次移動間停留幾毫秒

screen = getAppUsableScreenSize()
X = screen:getX()
Y = screen:getY()
resolution = 1280
Settings:setCompareDimension(true, resolution)--執行圖形比對時螢度的解析度。根據compareByWidth的值的值設定成寬度或高度
Settings:setScriptDimension(true, X)--用於參考App解析度腳本內座標位置
Settings:set("MinSimilarity", 0.8)
setImagePath(WORK_DIR.."image."..resolution.."/")
logDir = scriptPath().."log/"
DEBUG = true

require("ankulua_wrapper")
require("tools")
require("screen_config")
require("action_parser")
require("logger")
require("common_page")
require("event")
require("multi_host")

-- ========== Dialogs ================

dialogInit()
FUNC=1
LOGINDEX=1

BRIGHTNESS = false IMMERSIVE = true RECORD_LOG = false
addRadioGroup("FUNC", 1)addRadioButton("活動", 1)
addRadioButton("協力(開房)", 2)newRow()
addRadioButton("檢視日誌", 3)newRow()
addRadioButton("清除日誌", 4)newRow()
addCheckBox("BRIGHTNESS", "螢幕亮度最低 ", true)newRow() -- brightness low
--addCheckBox("IMMERSIVE", "Immersive", true)newRow()
addCheckBox("RECORD_LOG", "記錄日誌", true)newRow()
addCheckBox("DEBUG", "Debug ", true)addCheckBox("PRO", "專業版", false)newRow() -- for PRO version

dialogShow("選擇自動化功能")
setImmersiveMode(IMMERSIVE)

if FUNC == 1 then
    event = Event()
    event:looper()
    scriptExit("結束")
elseif FUNC == 2 then
    multiHost = MultiHost()
    multiHost:looper()
    scriptExit("結束")
elseif FUNC == 3 then
    files = scandir(logDir)
    if files[#files] then
        dialogInit()
        for i, file in ipairs(files) do
            addRadioGroup("LOGINDEX", i)addRadioButton(file, i)
        end
        dialogShow("日誌清單")
        dialogInit()
        content = readAll(logDir..files[LOGINDEX])
        addTextView(content)
        dialogShow(files[LOGINDEX])
        scriptExit("結束")
    else
        scriptExit("找不到日誌")
    end
elseif FUNC == 4 then
    os.execute("rm "..logDir.."*")
    scriptExit("清除成功")
end
