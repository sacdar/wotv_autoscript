function writeLog(mode, log)
    if DEBUG then
        logFile = io.open(LOG_FILENAME, mode)
        logFile:write(os.date("%Y%m%d%H%M%S"))
        logFile:write(","..log.."\n")
        io.close(logFile)
    end
end