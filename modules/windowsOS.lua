--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 2/9/2016
-- Time: 9:56 AM
-- To change this template use File | Settings | File Templates.
--

local _helper = require('pluginHelper')
local _timer = require('timer')

local windowsOS = {}


local apacheProperties = {}
local apache_exe_path = nil
local apache_root_directory = nil
local serverVersion = nil
local serverArchitecture = nil
local serverConfigFile = nil
local serverConfigFilePath = nil


local fileLocation = "http://vw-tlv-ad-qa18/Apache/"
local downloadFileDestination = "C:\\tmp\\Apache\\"
local installFileDestination = "C:\\tmp\\Apache_unzipped\\"


local fileNameApache22_64bit = "Apache22Win64bit.zip"
local fileNameApache24_64bit = "Apache24Win64bit.zip"
local fileNameApache22_32bit = "Apache22Win32bit.zip"
local fileNameApache24_32bit = "Apache24Win32bit.zip"
local confFileNameApache22 = "bmc-aeuem-apache22.conf"
local confFileNameApache24 = "bmc-aeuem-apache24.conf"



local function execute()
    if (_helper.isSupportedWinOSVersion()) then
        apache_exe_path = _helper.get_win_binary_path()
        apache_root_directory = _helper.get_win_apache_root_directory(apache_exe_path)
        apacheProperties = _helper.get_win_apache_properties(apache_exe_path)
        serverVersion = apacheProperties["serverVersion"]
        serverArchitecture = apacheProperties["serverArchitecture"]
        serverConfigFile = apacheProperties["serverConfigFile"]
        serverConfigFilePath = apache_root_directory..serverConfigFile

        local downloadFileName = nil
        local confFileName = nil

        if(string.find(serverVersion, "2.4.")) then
            confFileName = confFileNameApache24
            if(serverArchitecture == "64") then
                downloadFileName = fileNameApache24_64bit
            else
                downloadFileName = fileNameApache24_32bit
            end
        elseif (string.find(serverVersion, "2.2.")) then
            confFileName = confFileNameApache22
            if(serverArchitecture == "64") then
                downloadFileName = fileNameApache22_64bit
            else
                downloadFileName = fileNameApache22_32bit
            end
    end
    
        _helper.downloadFile(fileLocation, downloadFileDestination, downloadFileName, function()
        _helper.unzip(downloadFileDestination, downloadFileName, installFileDestination)
        _helper.updateModuleConfFile(confFileName, installFileDestination)
        _helper.createBackupHttpdConfFile(serverConfigFilePath)
        _helper.updateHttpdConfFile(serverConfigFilePath, installFileDestination..confFileName)
        print(_helper.winApacheRestart(apache_root_directory))
        end)
        print("finished")
    end
     _timer.setInterval(60000, function() end)
end

windowsOS.execute = execute

return windowsOS


