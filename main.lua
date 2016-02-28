--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 1/28/2016
-- Time: 11:53 AM
-- To change this template use File | Settings | File Templates.
--

local _helper = require('pluginHelper')
local _windowsOS = require('windowsOS')
local _linuxOS = require('linuxOS')
local _timer = require('timer')
local _json = require('json')

local json_blob
local params = {}
if (pcall(function () json_blob = fs.readFileSync("param.json") end)) then
    pcall(function () params = _json.parse(json_blob) end)
end

if jit.os == 'Windows' then
    _windowsOS.execute(params)
else
    _linuxOS.execute(params)
end

_timer.setInterval(60000, function() end)