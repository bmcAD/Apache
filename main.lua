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


if jit.os == 'Windows' then
    _windowsOS.execute()
else
    _linuxOS.execute()
end

_timer.setInterval(60000, function() end)