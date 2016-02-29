--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 2/8/2016
-- Time: 2:11 PM
-- To change this template use File | Settings | File Templates.
--

local _openZip = require('zip')
local _fsSync = require('sync-fs')
local _os = require('os')
local _fs = require('fs')
local _io = require('io')
local _http = require('http')
local _table = require('table')
local _logger = require ('log')

local pluginHelper = {}


---------------------------------------------------------------------------------------------------------
-- Download functions
---------------------------------------------------------------------------------------------------------

local function downloadFile(fileLocation, fileDestination, fileName, onEnd)
    _logger.info("Download '"..fileName.."' from '"..fileDestination.."'.")
    _fs.mkdirSync(fileDestination,"w")
    local exit = false
    local req
    local f = assert(_io.open(fileDestination..fileName, 'wb')) -- open in "binary" mode
    req = _http.get(fileLocation..fileName, function(res)
        res:on('data', function (chunk)
            f:write(chunk)
        end)
        res:on('end', function ()
            local current=f:seek()    -- get current position
            local size=f:seek("end")  -- get file size
            f:seek("set", current)  -- restore position
            onEnd()
        end)
    end)
    req:done()
end



---------------------------------------------------------------------------------------------------------
-- OS functions
---------------------------------------------------------------------------------------------------------

local function getOsArtchitecture()
    local os = _os.type()
   if (string.find(os, "32")) then
       _logger.info("OS Architecture: 32 bit. ")
       return "32" end
    if (string.find(os, "64")) then
        _logger.info("OS Architecture: 64 bit. ")
        return "64" end
end

local function isSupportedWinOSVersion()
    local verCommand = "ver"
    local verHandle = _io.popen(verCommand)
    local verResult = verHandle:read("*a")
    verHandle:close()
    local s,_ = string.find(verResult, "Version 6.")
    if(s ~= nil) then _logger.info("OS version '"..verResult.."' is supported. ")
    else _logger.info("OS version '"..verResult.."' is not supported. ") end
    return s ~= nil
end

---------------------------------------------------------------------------------------------------------
-- Zip functions
---------------------------------------------------------------------------------------------------------

local function unzip(zipPath, zipFileName, destinationPath)
    _logger.info("Unzip '"..zipFileName.."' file to ' "..destinationPath.."'.")
    local fd = _fsSync.open(zipPath .. zipFileName, "r", tonumber("644", 8))
    local zip = _openZip(fd, _fsSync)

    _fs.mkdirSync(destinationPath, "w")

    local entries = zip["entries"]
    for k, v in pairs(entries) do
        local target_file = _io.open(destinationPath .. k, "w")
        target_file:write(zip.readfile(k))
        target_file:close()
    end
end

---------------------------------------------------------------------------------------------------------
-- Files functions
---------------------------------------------------------------------------------------------------------

local function updateModuleConfFile(confFileName, installDirectory, moduleFileName, jsUrl, authInfo)
    _logger.info("Update module configuration file. ")
    local confFile = _io.open( installDirectory .. confFileName, "r" )
    local confStr = confFile:read( "*a" )
    confStr = string.gsub(confStr, "${INSTALL_DIR}", installDirectory)
    confStr = string.gsub(confStr, "${MODULEFILE}", moduleFileName)
    confStr = string.gsub(confStr, "${JS_URL}", jsUrl)
    confStr = string.gsub(confStr, "${AUTH_INFO}", authInfo)
    confFile:close()

    confFile = _io.open( installDirectory .. confFileName, "w" )
    confFile:write( confStr )
    confFile:close()
end


local function createBackupHttpdConfFile(httpdConfFilePath)
    _logger.info("Create backup file for apache configuration. ")
    local backupConfFile = _io.open( httpdConfFilePath, "r" )
    local backuoConfStr = backupConfFile:read( "*a" )
    backupConfFile:close()

    backupConfFile = _io.open( httpdConfFilePath .. ".bmc.backup", "w" )
    backupConfFile:write( backuoConfStr )
    backupConfFile:close()
end


local function updateHttpdConfFile(httpdConfFilePath, confFileName)
    _logger.info("Update apache configuration file with APM nodule. ")
    local confFile = _io.open( httpdConfFilePath, "a" )
    confFile:write( "\r\n" )
    confFile:write( "## Include for BMC Apache plugin\r\n" )
    confFile:write( "include "..confFileName )
    confFile:close()
end


---------------------------------------------------------------------------------------------------------
-- Restart Apache functions
---------------------------------------------------------------------------------------------------------

local function winApacheRestart(apacheExePath)
    _logger.info("Restart (graceful) apache service. ")
    local Command = apacheExePath.." -k restart"
    local Handle = _io.popen(Command)
    local Result = Handle:read("*a")
    Handle:close()
    return Result
end

local function linuxApacheRestart()
    _logger.info("Restart (graceful) apache service. ")
    local Command = "hapachectl –k graceful"
    local Handle = _io.popen(Command)
    local Result = Handle:read("*a")
    Handle:close()
    return Result
end

---------------------------------------------------------------------------------------------------------
-- Parser functions
---------------------------------------------------------------------------------------------------------


function lines(str)
    local t = {}
    local function helper(line) _table.insert(t, line) return "" end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
end


local function get_win_binary_path()
    _logger.info("Get apache binary path. ")
    local commandOutput = nil
    local result = nil

    local ver22Handle = _io.popen('c:/Windows/System32/sc.exe qc apache2.2')
    local ver22Result = ver22Handle:read("*a")
    ver22Handle:close()
    if string.find(ver22Result, "SUCCES") then commandOutput = ver22Result end

    local ver24Handle = _io.popen('c:/Windows/System32/sc.exe qc apache2.4')
    local ver24Result = ver24Handle:read("*a")
    ver24Handle:close()
    if string.find(ver24Result, "SUCCES") then commandOutput = ver24Result end

    if (commandOutput ~= nil) then
        local _lines = {}
        _lines = lines(commandOutput)
        for i=1,#_lines do
            if (string.find(_lines[i], "BINARY_PATH_NAME")) then
                for token in string.gmatch(_lines[i], "[^\"]+") do
                    if (string.find(token, ".exe")) then
                        result = string.gsub(string.sub(token, 0, -1), "\\", "/")
                        break
                    end
                end
            end

        end
    end
    _logger.info("Apache binary path: '"..result.."'.")
    return result
end


local function get_win_apache_root_directory(path)
    _logger.info("Get apache root directory.")
    local i = string.find(path, "/bin")
    local rootDirectory = string.sub(path, 0, i)
    _logger.info("Apache root directory: '"..rootDirectory.."'.")
    return rootDirectory
end


local function get_win_apache_properties(path)
    _logger.info("Get apache properties.")
    local apacheProperties = {}
    local Handle = _io.popen(path.." -V")
    local Result = Handle:read("*a")
    Handle:close()

    if (Result ~= nil) then
        local _lines = {}
        _lines = lines(Result)
        for i=1,#_lines do
            if (string.find(_lines[i], "Server version:")) then
                apacheProperties["serverVersion"] = string.sub(string.sub(_lines[i], 16):match( "^%s*(.+)" ), 8, -8)
            end
            if (string.find(_lines[i], "Architecture:")) then
                apacheProperties["serverArchitecture"] = string.sub(string.sub(_lines[i], 14):match( "^%s*(.+)" ), 0, -5)
            end
            if (string.find(_lines[i], "-D SERVER_CONFIG_FILE=")) then apacheProperties["serverConfigFile"]= string.sub(_lines[i], 25, -2)
            end
            i = i+1
        end
    end
    _logger.info("Apache server version: "..apacheProperties["serverVersion"]..".")
    _logger.info("Apache server architecture: "..apacheProperties["serverArchitecture"]..".")
    _logger.info("Apache server config file: "..apacheProperties["serverConfigFile"]..".")
    return apacheProperties
end


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

pluginHelper.getOsArtchitecture = getOsArtchitecture
pluginHelper.isSupportedWinOSVersion = isSupportedWinOSVersion
pluginHelper.downloadFile = downloadFile
pluginHelper.unzip = unzip
pluginHelper.get_win_binary_path = get_win_binary_path
pluginHelper.get_win_apache_properties = get_win_apache_properties
pluginHelper.get_win_apache_root_directory = get_win_apache_root_directory
pluginHelper.updateModuleConfFile = updateModuleConfFile
pluginHelper.updateHttpdConfFile = updateHttpdConfFile
pluginHelper.createBackupHttpdConfFile = createBackupHttpdConfFile
pluginHelper.winApacheRestart = winApacheRestart
pluginHelper.linuxApacheRestart = linuxApacheRestart


return pluginHelper
