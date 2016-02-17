--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 2/9/2016
-- Time: 9:57 AM
-- To change this template use File | Settings | File Templates.
--


local linuxOS = {}



local apacheProperties = {}
local apache_exe_path = nil
local apache_root_directory = nil
local serverVersion = nil
local serverArchitecture = nil
local serverConfigFile = nil
local serverConfigFilePath = nil


local fileLocation = "http://vw-tlv-ad-qa18/Apache/"
local downloadFileDestination = ""
local installFileDestination = ""


local fileNameApache24_64bit_rhel7 = "rhel7-64-apache24.tar"
local fileNameApache22_64bit_rhel7 = "rhel7-64-apache22.tar"
local fileNameApache24_64bit_rhel6 = "rhel6-64-apache24.tar"
local fileNameApache22_64bit_rhel6 = "rhel6-64-apache22.tar"
local confFileNameApache22 = "bmc-aeuem-apache22.conf"
local confFileNameApache24 = "bmc-aeuem-apache24.conf"

local function execute()
end


linuxOS.execute = execute


return linuxOS

