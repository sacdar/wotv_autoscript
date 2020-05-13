function handleShardsExceeded()
    if checkRegion(SHARDDREACHEDMAX_REGION, "DialogLabel.png") then
        wait(1)
        clickLocation(SHARDDREACHEDMAXOK_X, SHARDDREACHEDMAXOK_Y)
        wait(1)
    end
end

function handleRestoreNRGBig()
    if checkRegion(USEITEMROW2_REGION, "RestoreNRGBig.png") then
        if clickRegion(USEITEMADDROW2_REGION, "RestoreNRGAvailable.png") then
            clickLocation(RESTORENRG_X, RESTORENRG_Y)
            wait(1)
            if checkRegion(NRGRESTORED_REGION, "DialogLabel.png") then
                clickLocation(NRGRESTOREDOK_X, NRGRESTOREDOK_Y)
                writeLog("a", "NRG_BIG_RESTORED")
                return true
            end
        end
    end
    writeLog("a", "NO_NRG_BIG_ITEM")
    return false
end

function handleRestoreNRGMedium()
    if checkRegion(USEITEMROW2_REGION, "RestoreNRGMedium.png") then
        if clickRegion(USEITEMADDROW2_REGION, "RestoreNRGAvailable.png") then
            clickLocation(RESTORENRG_X, RESTORENRG_Y)
            wait(1)
            if checkRegion(NRGRESTORED_REGION, "DialogLabel.png") then
                clickLocation(NRGRESTOREDOK_X, NRGRESTOREDOK_Y)
                writeLog("a", "NRG_MEDIUM_RESTORED")
                return true
            end
        end
    end
    writeLog("a", "NO_NRG_MEDIUM_ITEM")
    return false
end

function handleRestoreNRGSmall()
    if checkRegion(USEITEMROW1_REGION, "RestoreNRGSmall.png") then
        if clickRegion(USEITEMADDROW1_REGION, "RestoreNRGAvailable.png") then
            clickLocation(RESTORENRG_X, RESTORENRG_Y)
            wait(1)
            if checkRegion(NRGRESTORED_REGION, "DialogLabel.png") then
                clickLocation(NRGRESTOREDOK_X, NRGRESTOREDOK_Y)
                writeLog("a", "NRG_SMALL_RESTORED")
                return true
            end
        end
    end
    writeLog("a", "NO_NRG_SMALL_ITEM")
    return false
end

function handleRestoreNRG(restoreNrg, restoreNrgCount, restoreNrgCountMax, nrgRestoreType)
    if not restoreNrg then
        if checkRegion(NRGNOTENOUGH_REGION, "DialogLabel.png") then
            -- back to embark page
            clickLocation(NRGRESTORENO_X, NRGRESTORENO_Y)
            if checkRegion(INRESULTPAGE_REGION, "InResultPage.png") then
                wait(1)
                clickLocation(RETURNTOEMBARKSCREEN_X, RETURNTOEMBARKSCREEN_Y)
            end
        end
        return false
    end
    if checkRegion(NRGNOTENOUGH_REGION, "DialogLabel.png") then
        if restoreNrgCount == 0 or restoreNrgCount < restoreNrgCountMax then
            wait(1)
            clickLocation(NRGRESTOREYES_X, NRGRESTOREYES_Y)
            wait(3)
            if checkRegion(NRGRESTOREPAGE_REGION, "DialogLabel.png") then
                clickLocation(USEITEM_X, USEITEM_Y)
                wait(1)
                if nrgRestoreType == 1 then
                    dragDrop(Location(USEITEMBIGDRAGDROPFROM_X, USEITEMBIGDRAGDROPFROM_Y), Location(USEITEMBIGDRAGDROPTO_X, USEITEMBIGDRAGDROPTO_Y))
                    if not handleRestoreNRGBig() then
                        finish("體力道具不足")
                    end
                elseif nrgRestoreType == 2 then
                    if not handleRestoreNRGMedium() then
                        finish("體力道具不足")
                    end
                elseif nrgRestoreType == 3 then
                    if not handleRestoreNRGSmall() then
                        finish("體力道具不足")
                    end
                elseif nrgRestoreType == 4 then
                    dragDrop(Location(USEITEMBIGDRAGDROPFROM_X, USEITEMBIGDRAGDROPFROM_Y), Location(USEITEMBIGDRAGDROPTO_X, USEITEMBIGDRAGDROPTO_Y))
                    if not handleRestoreNRGBig() then
                        dragDrop(Location(USEITEMBIGDRAGDROPTO_X, USEITEMBIGDRAGDROPTO_Y), Location(USEITEMBIGDRAGDROPFROM_X, USEITEMBIGDRAGDROPFROM_Y))
                        if not handleRestoreNRGMedium() then
                            if not handleRestoreNRGSmall() then
                                finish("體力道具不足")
                            end
                        end
                    end
                elseif nrgRestoreType == 5 then
                    if not handleRestoreNRGSmall() then
                        if not handleRestoreNRGMedium() then
                            dragDrop(Location(USEITEMBIGDRAGDROPFROM_X, USEITEMBIGDRAGDROPFROM_Y), Location(USEITEMBIGDRAGDROPTO_X, USEITEMBIGDRAGDROPTO_Y))
                            if not handleRestoreNRGBig() then
                                finish("體力道具不足")
                            end
                        end
                    end
                end
            end
        else
            -- back to embark page
            clickLocation(NRGRESTORENO_X, NRGRESTORENO_Y)
            if checkRegion(INRESULTPAGE_REGION, "InResultPage.png") then
                wait(1)
                clickLocation(RETURNTOEMBARKSCREEN_X, RETURNTOEMBARKSCREEN_Y)
            end
            return false
        end
    end

    return true
end

function finish(reason)
    print("Quest clear:"..self.loopCount.."/"..self.looperCountMax.."("..self.totalTimer:check().."s)")
    scriptExit(reason)
end