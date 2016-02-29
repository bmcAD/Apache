--
-- Created by IntelliJ IDEA.
-- User: kavraham
-- Date: 1/28/2016
-- Time: 11:53 AM
-- To change this template use File | Settings | File Templates.
--

local _windowsOS = require('windowsOS')
local _linuxOS = require('linuxOS')
local _timer = require('timer')
local _logger = require ('log')

_logger.debug("Verifying operating system. ")
if jit.os == 'Windows' then
    _logger.info("OS: Windows. ")
    _windowsOS.execute()
else
    _logger.info("OS: Linux. ")
    _linuxOS.execute()
end

_timer.setInterval(60000, function() end)