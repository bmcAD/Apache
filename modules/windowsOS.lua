--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 2/9/2016
-- Time: 9:56 AM
-- To change this template use File | Settings | File Templates.
--

local _helper = require('pluginHelper')
local _framework = require('framework')
local _logger = require ('log')

local windowsOS = {}
local apacheProperties
local apache_exe_path
local apache_root_directory
local serverArchitecture
local serverConfigFile
local serverConfigFilePath

local fileLocation = "http://vw-tlv-ad-qa18/Apache/"
local downloadFileDestination = process.cwd().."\\apache_module_archive\\"
local installFileDestination = process.cwd().."\\apache_module\\"

local APACHE_MODULE_ARCHIVE_TEMPLATE = "EuemApache%sWin%s.zip"
local APACHE_MODULE_CONF_TEMPLATE = "bmc-aeuem-apache%s.conf"
local APACHE_MODULE_FILE_NAME = "BmcEuemApache%s.so"
local JS_URL = "http://52.71.68.191:880/static-resources/aeuem-10.1.0.js"

local function execute()
    _logger.info("Verifying supported windows os version. ")
    if (_helper.isSupportedWinOSVersion()) then
        apache_exe_path = _helper.get_win_binary_path()
        apache_root_directory = _helper.get_win_apache_root_directory(apache_exe_path)
        apacheProperties = _helper.get_win_apache_properties(apache_exe_path)
        serverArchitecture = apacheProperties["serverArchitecture"]
        serverConfigFile = apacheProperties["serverConfigFile"]
        serverConfigFilePath = apache_root_directory..serverConfigFile

        local apacheRelease = string.sub(apacheProperties["serverVersion"], 1, 3):gsub("%.", "")
        local downloadFileName = string.format(APACHE_MODULE_ARCHIVE_TEMPLATE, apacheRelease, serverArchitecture)
        local confFileName = string.format(APACHE_MODULE_CONF_TEMPLATE, apacheRelease)
        local apacheModuleFileName = string.format(APACHE_MODULE_FILE_NAME, apacheRelease)
        --local authInfo = _framework.params["username"]..":".._framework.params["apiToken"]
       
        local authInfo = "nitsan_daniel@bmc.com:api.0a6d9584e2-9040"

        _helper.downloadFile(fileLocation, downloadFileDestination, downloadFileName, function()
        _helper.unzip(downloadFileDestination, downloadFileName, installFileDestination)
        _helper.updateModuleConfFile(confFileName, installFileDestination, apacheModuleFileName, JS_URL, authInfo)
        _helper.createBackupHttpdConfFile(serverConfigFilePath)
        _helper.updateHttpdConfFile(serverConfigFilePath, installFileDestination..confFileName)
        print(_helper.winApacheRestart(apache_exe_path))
        _logger.info("Plugin installation finished. ")
        end)
    end
end

windowsOS.execute = execute

return windowsOS


