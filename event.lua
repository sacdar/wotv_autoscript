Event = {}
Event.__index = Event

setmetatable(Event, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function Event.new()
    local self = setmetatable({}, Event)
    self.errorCount = 0
    self.debug = false
    self.eventType = 1
    self.eventIndex = 1
    self.levelIndex = 1
    self.buyShardFromWhimsyShop =false
    self.looperCountMax = 0
    self.restoreNrg = false
    self.restoreNrgCount = 0
    self.restoreNrgCountMax = 0
    self.recordLog = true

    self.state = "InEmbarkPage"
    self.States = {
        "InEmbarkPage",
        "InChooseCompanionPage",
        "InBattle",
        "InResult",
        "Clear",
        "ToBattle",
        "InWhimsyShopPage"
    }
    self.nrgRestoreType = 1
    self.NrgRestoreType = {
        "大",
        "中",
        "小",
        "大到小",
        "小到大"
    }

    self.shardPngList = {
        ["奧爾蘭多"] = "Orlandeau",
        ["美迪愛娜"] = "Mediena",
        ["恩格爾伯特"] = "Engelbert",
        ["彩花(X)"] = "Ayaka",
        ["弗蕾德麗卡(X)"] = "Frederika",
        ["桑克瑞德(X)"] = "Thancred",
        ["斯特恩(X)"] = "Sterne",
        ["吉爾伽美什(X)"] = "Gilgamesh",
        ["奧爾德(X)"] = "Oelde",
        ["羅布"] = "Robb",
        ["希紮"] = "Xiza",
        ["耶爾瑪"] = "Yerma",
        ["拉姆薩(X)"] = "Ramza",
        ["瑪雪莉"] = "Macherie",
        ["艾琳(X)"] = "Aileen",
        ["基頓"] = "Kitone",
        ["耳語"] = "Whisper"
    }
    self.buyShardList = {}

    self.switch = {}

    self:init()
    if self.buyShardFromWhimsyShop then
        self:buyShardSetting()
    end
    if BRIGHTNESS then
        proSetBrightness(0)
    end
    return self
end

function Event:init()
    dialogInit()
    RECORD_LOG = true
    addCheckBox("RECORD_LOG", "記錄日誌", true)newRow()
    EVENT_TYPE = 1
    addTextView("刷活動(X)")addRadioGroup("EVENT_TYPE", 1)addRadioButton("期間限定", 1)addRadioButton("每週 育成", 2)newRow()
    EVENT_INDEX = 1
    LEVEL_INDEX = 1
    addTextView("活動列(X)")addEditNumber("EVENT_INDEX", 1)addTextView("關卡列")addEditNumber("LEVEL_INDEX", 1)newRow()
    BUY_SHARD_FROM_WHIMSY_SHOP = false
    addCheckBox("BUY_SHARD_FROM_WHIMSY_SHOP", "自動流動商店買碎片", false)newRow()
    LOOPER_COUNT_MAX = 0
    addTextView("執行次數:(0 = 無限次數)")addEditNumber("LOOPER_COUNT_MAX", 0)newRow()
    CHOOSE_COMPANION = false
    addCheckBox("CHOOSE_COMPANION", "選擇同行者", false)newRow()
    SCAN_INTERVAL = 4
    addTextView("掃描頻率:")addEditNumber("SCAN_INTERVAL", SCAN_INTERVAL)newRow()
    RESTORE_NRG = false
    RESTORE_NRG_COUNT_MAX = 0
    RESTORE_NRG_TYPE = 1
    addCheckBox("RESTORE_NRG", "使用道具", false)addSpinnerIndex("RESTORE_NRG_TYPE", self.NrgRestoreType, 1)addTextView("回復體力(0 = 無限次數) ")addEditNumber("RESTORE_NRG_COUNT_MAX", 0)addTextView(" 回")newRow()

    if DEBUG then
        HIGHLIGHT_TIME = 1.0
        addTextView("Highlight time")addEditNumber("HIGHLIGHT_TIME", 1.0)newRow()
    end
    dialogShow("活動 ".." - "..X.." × "..Y)

    LOG_FILENAME = logDir..os.date("%Y%m%d%H%M%S").."_log.txt"
    self.looperCountMax = LOOPER_COUNT_MAX
    self.recordLog = RECORD_LOG
    self.eventType = EVENT_TYPE
    self.eventIndex = EVENT_INDEX
    self.levelIndex = LEVEL_INDEX
    self.buyShardFromWhimsyShop = BUY_SHARD_FROM_WHIMSY_SHOP
    self.chooseCompanion = CHOOSE_COMPANION
    self.scanInterval = SCAN_INTERVAL
    proSetScanInterval(SCAN_INTERVAL)
    self.restoreNrg = RESTORE_NRG
    self.restoreNrgCountMax = RESTORE_NRG_COUNT_MAX
    self.nrgRestoreType = RESTORE_NRG_TYPE
    --self.autoBattleToggled = false

    self.debug = DEBUG
    if DEBUG then
        self.highlightTime = HIGHLIGHT_TIME
    end
end

function Event:buyShardSetting()
    dialogInit()
    listIndex = 1
    buyIndex = 1
    for key, value in pairs(self.shardPngList) do
        addCheckBox("CB_"..value, key, false)
        if listIndex % 3 == 0 then
            newRow()
        end
        listIndex = listIndex + 1
    end
    dialogShow("於流動商店買碎片")
    for key, value in pairs(self.shardPngList) do
        if (_G["CB_"..value]) then
            self.buyShardList[buyIndex] = value
            buyIndex = buyIndex + 1;
        end
    end
    if #self.buyShardList == 0 then
        self.buyShardFromWhimsyShop = false
    end
end

function Event:looper()

    self.switch = {
        ["InEmbarkPage"] = function()
            --if DEBUG then NRGRESTOREDOK_REGION:highlight(self.highlightTime) end
            if checkRegion(INEMBARKPAGE_REGION, "InEmbarkPage.png") then
                if self.chooseCompanion then
                    clickLocation(GOCHOOSECOMPANION_X, GOCHOOSECOMPANION_Y)
                    return "InChooseCompanionPage"
                else
                    --if DEBUG then AUTOBATTLE_REGION:highlight(self.highlightTime) end
                    --if not self.autoBattleToggled then
                    --    click(Location(AUTOBATTLE_X, AUTOBATTLE_Y))
                    --    self.autoBattleToggled = true
                    --end
                    clickLocation(EMBARK_X, EMBARK_Y)
                    if handleRestoreNRG(self.restoreNrg, self.restoreNrgCount, self.restoreNrgCountMax, self.nrgRestoreType) then
                        wait(1)
                        clickLocation(EMBARK_X, EMBARK_Y)
                        return "InBattle"
                    else
                        return "InEmbarkPage"
                    end
                end
            end
            return "InEmbarkPage"
        end,

        ["InChooseCompanionPage"] = function()
            wait(2)
            if checkRegion(INCHOOSECOMPANIONPAGE_REGION, "BlueButton.png") then
                clickLocation(CHOOSECOMPANION_X, CHOOSECOMPANION_X)
                wait(1)
                --if DEBUG then AUTOBATTLE_REGION:highlight(self.highlightTime) end
                --if not self.autoBattleToggled then
                    --click(Location(AUTOBATTLE_X, AUTOBATTLE_Y))
                    --self.autoBattleToggled = true
                --end
                clickLocation(EMBARK_X, EMBARK_Y)
                if handleRestoreNRG(self.restoreNrg, self.restoreNrgCount, self.restoreNrgCountMax, self.nrgRestoreType) then
                    wait(1)
                    clickLocation(EMBARK_X, EMBARK_Y)
                    return "InBattle"
                else
                    return "InEmbarkPage"
                end
            end
            return "InChooseCompanionPage"
        end,

        ["InBattle"] = function(farmer)
            if checkRegion(MISSIONCOMPLETE_REGION, "MissionComplete.png") then
                wait(2)
                clickLocation(INEMBARKPAGE_X, INEMBARKPAGE_Y)
                wait(1)
                clickLocation(INEMBARKPAGE_X, INEMBARKPAGE_Y)
                clickLocation(MISSIONCOMPLETENEXT_X, MISSIONCOMPLETENEXT_Y)
                return "InResult"
            end
            wait(self.scanInterval)
            return "InBattle"
        end,

        ["InResult"] = function(farmer)
            wait(2)
            if checkRegion(SHARDDREACHEDMAX_REGION, "DialogLabel.png") then
                wait(1)
                clickLocation(SHARDDREACHEDMAXOK_X, SHARDDREACHEDMAXOK_Y)
                wait(1)
            end
            if checkRegion(INFEVERPAGE_REGION, "Fever.png") then
                writeLog("a", self.loopCount.."_FEVER_AVAILABLE")
                wait(1)
                clickLocation(GOFEVERLATER_X, GOFEVERLATER_Y)
                wait(1)
            end
            if checkRegion(INWHIMSYSHOPPAGE_REGION, "WhimsyShop.png") then
                writeLog("a", self.loopCount.."_WHIMSYSHOP_AVAILABLE")
                if self.buyShardFromWhimsyShop then
                    wait(1)
                    clickLocation(GOTOWHIMSYSHOP_X, GOTOWHIMSYSHOP_Y)
                    wait(10)
                    return "InWhimsyShopPage"
                else
                    wait(1)
                    clickLocation(GOTOWHIMSYSHOPLATER_X, GOTOWHIMSYSHOPLATER_Y)
                    wait(1)
                end
            end
            return "Clear"
        end,

        ["ToBattle"] = function(farmer)
            if checkRegion(INRESULTPAGE_REGION, "InResultPage.png") then
                if self.chooseCompanion then
                    clickLocation(RETURNTOEMBARKSCREEN_X, RETURNTOEMBARKSCREEN_Y)
                    if handleRestoreNRG(self.restoreNrg, self.restoreNrgCount, self.restoreNrgCountMax, self.nrgRestoreType) then
                        wait(1)
                        clickLocation(RETURNTOEMBARKSCREEN_X, RETURNTOEMBARKSCREEN_Y)
                        return "InBattle"
                    else
                        return "InEmbarkPage"
                    end
                else
                    clickLocation(EMBARKAGAIN_X, EMBARKAGAIN_Y)
                    if handleRestoreNRG(self.restoreNrg, self.restoreNrgCount, self.restoreNrgCountMax, self.nrgRestoreType) then
                        wait(1)
                        clickLocation(EMBARKAGAIN_X, EMBARKAGAIN_Y)
                        return "InBattle"
                    else
                        return "InEmbarkPage"
                    end
                end
            end
            return "ToBattle"
        end,

        ["InWhimsyShopPage"] = function(farmer)
            if checkRegion(INWHIMSYSHOPBUY_REGION, "InWhimsyShop.png") then
                for i, v in ipairs(self.buyShardList) do
                    if clickRegion(WHIMSYSHOPBUY1x1_REGION, "Shard_"..self.buyShardList[i]..".png") then
                        self:handleBuyShard(self.buyShardList[i])
                    end
                    if clickRegion(WHIMSYSHOPBUY1x2_REGION, "Shard_"..self.buyShardList[i]..".png") then
                        self:handleBuyShard(self.buyShardList[i])
                    end
                    if clickRegion(WHIMSYSHOPBUY1x3_REGION, "Shard_"..self.buyShardList[i]..".png") then
                        self:handleBuyShard(self.buyShardList[i])
                    end
                end
            end
            finish("InWhimsyShopPage")
        end,
    }

    self.totalTimer = Timer()
    local questTimer = Timer()
    self.totalTimer:set()
    questTimer:set()

    self.loopCount = 0
    if self.recordLog then
        writeLog("w", "SCRIPT_BEGIN")
    end
    while self.looperCountMax == 0 or self.loopCount < self.looperCountMax do
        if DEBUG then toast(self.state.." count = "..self.loopCount.." count max = "..self.looperCountMax) end
        if self.state == "InEmbarkPage" or self.state == "ToBattle" then
            writeLog("a", self.loopCount.."_BATTLE_BEGIN")
        end
        -- run state machine
        newState = self.switch[self.state](self)
        if newState ~= self.state then
            self.state = newState
        end

        if (self.state == "Clear") then
            writeLog("a", self.loopCount.."_BATTLE_END")
            self.state = "ToBattle"
            self.loopCount = self.loopCount + 1
            local msg = "Quest clear:"..self.loopCount.."/"..self.looperCountMax.."("..questTimer:check().."s)"
            toast(msg)
            questTimer:set()
            self.errorCount = 0

            -- The debug mode may be opened due to error.  Close it when the error pass.
            if not self.debug then
                DEBUG = false
            end
        end
    end
    writeLog("a", "SCRIPT_END")
    finish("腳本結束")
end

function Event:handleBuyShard(name)
    clickLocation(BUYSHARD_X, BUYSHARD_Y)
    wait(2)
    if checkRegion(SHARDDREACHEDMAX_REGION, "DialogLabel.png") then
        wait(1)
        clickLocation(SHARDDREACHEDMAXOK_X, SHARDDREACHEDMAXOK_Y)
        wait(1)
        writeLog("a", self.loopCount.."_BOUGHT_SHARD_"..name)
        if checkRegion(SHARDBOUGHT_REGION, "DialogLabel.png") then
            clickLocation(SHARDBOUGHTOK_X, SHARDBOUGHTOK_Y)
        end
        return true
    end
    writeLog("a", self.loopCount.."_BOUGHT_SHARD_FAILED_"..name)
    return false
end
