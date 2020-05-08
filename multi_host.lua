MultiHost = {}
MultiHost.__index = MultiHost

setmetatable(MultiHost, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function MultiHost.new()
    local self = setmetatable({}, MultiHost)
    self.errorCount = 0
    self.debug = false
    self.looperCountMax = 0
    self.restoreNrg = false
    self.restoreNrgCount = 0
    self.restoreNrgCountMax = 0
    self.recordLog = true

    self.state = "InEmbarkPage"
    self.States = {
        "InEmbarkPage",
        "CheckInEmbarkPage",
        "InBattle",
        "InResult",
        "Clear",
    }
    self.nrgRestoreType = 1
    self.NrgRestoreType = {
        "大",
        "中",
        "小",
        "大到小",
        "小到大"
    }
    self.buyShardList = {}

    self.switch = {}

    self:init()
    if BRIGHTNESS then
        proSetBrightness(0)
    end
    return self
end

function MultiHost:init()
    dialogInit()
    RECORD_LOG = true
    addCheckBox("RECORD_LOG", "記錄日誌", true)newRow()
    LOOPER_COUNT_MAX = 0
    addTextView("執行次數:(0 = 無限次數)")addEditNumber("LOOPER_COUNT_MAX", 0)newRow()
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

function MultiHost:looper()

    self.switch = {
        ["InEmbarkPage"] = function()
            --if DEBUG then REQUEST_REGION:highlight(self.highlightTime) end
            if checkRegion(INMULTIEMBARKPAGE_REGION, "InMultiEmbarkPage.png") then
                clickLocation(EMBARK_X, EMBARK_Y)
                if handleRestoreNRG(self.restoreNrg, self.restoreNrgCount, self.restoreNrgCountMax, self.nrgRestoreType) then
                    wait(1)
                    clickLocation(EMBARK_X, EMBARK_Y)
                    wait(1)
                    if checkRegion(NRGNOTENOUGH_REGION, "DialogLabel.png") then
                        clickLocation(NRGRESTOREYES_X, NRGRESTOREYES_Y)
                    end
                    if checkRegion(CONFIRMEMBARK_REGION, "DialogLabel.png") then
                        clickLocation(CONFIRMEMBARKOK_X, CONFIRMEMBARKOK_Y)
                    end
                end
                return "CheckInEmbarkPage"
            end
            wait(self.scanInterval)
            return "InEmbarkPage"
        end,

        ["CheckInEmbarkPage"] = function(farmer)
            if checkRegion(INMULTIEMBARKPAGE_REGION, "InMultiEmbarkPage.png") then
                return "InEmbarkPage"
            end
            return "InBattle"
        end,

        ["InBattle"] = function(farmer)
            if checkRegion(MISSIONCOMPLETE_REGION, "MissionComplete.png") then
                wait(2)
                clickLocation(MISSIONCOMPLETENEXT_X, MISSIONCOMPLETENEXT_Y)
                return "InResult"
            end
            wait(self.scanInterval)
            return "InBattle"
        end,

        ["InResult"] = function(farmer)
            wait(4)
            if checkRegion(FRIENDREQUESTS_REGION, "DialogLabel.png") then
                clickLocation(REQUESTCANCEL_X, REQUESTCANCEL_Y)
                wait(1)
            end
            if checkRegion(INRESULTPAGE_REGION, "InResultPage.png") then
                clickLocation(MISSIONCOMPLETENEXT_X, MISSIONCOMPLETENEXT_Y)
                wait(10)
                return "Clear"
            end
            return "InResult"
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
        if self.state == "InBattle" then
            writeLog("a", self.loopCount.."_BATTLE_BEGIN")
        end
        -- run state machine
        newState = self.switch[self.state](self)
        if newState ~= self.state then
            self.state = newState
        end

        if (self.state == "Clear") then
            writeLog("a", self.loopCount.."_BATTLE_END")
            self.state = "InEmbarkPage"
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
    self:finish("腳本結束")
end

function MultiHost:finish(reason)
    print("Quest clear:"..self.loopCount.."/"..self.looperCountMax.."("..self.totalTimer:check().."s)")
    scriptExit(reason)
end
