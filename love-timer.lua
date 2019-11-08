
local _dir = (...):match("(.-)[^%.]+$")
local deepcopy = require(_dir .. "deepcopy")

local timer = { -- ~in seconds, floating point number
  timestamp = {
    start = 0,
    time = -1,
    pause = 0,
    finish = math.huge
  },
  status = "stop"
}
-- If time is -1, then just count

local mt = {} -- Metatable

-- For "counter" mode just pass nothing (nil).
-- For "timer" mode pass a number to set the timer.
--
-- @param   time  nil for "counter" mode, number for "timer" mode
-- @return        new instance of timer
function timer.new (time)
  local tmr = deepcopy(timer)
  -- tmr.timestamp.start = love.timer.getTime()
  tmr:set(time)
  return tmr
end

-- You know what clone() does.
--
-- @return  clone of self
function timer:clone ()
  return (deepcopy(self) or nil)
end

-- Starts the timer
function timer:start ()
  now = love.timer.getTime()
  if self.timestamp.pause == 0 then
    self.timestamp.start = now
    if self.timestamp.time == -1 then
      self.timestamp.finish = self.timestamp.start
    else
      self.timestamp.finish = self.timestamp.start + self.timestamp.time
    end
  else
    if self.timestamp.time == -1 then
      self.timestamp.start = self.timestamp.start + (now - self.timestamp.pause)
    else
      self.timestamp.finish = now + (self.timestamp.time - (self.timestamp.pause - self.timestamp.start))
    end
    self.timestamp.pause = 0
  end
  self.status = "running"
end

-- Pauses the timer
function timer:pause ()
  self.timestamp.pause = love.timer.getTime()
  -- if self.timestamp.time ~= -1 then
  --   self.timestamp.finish = 0
  -- end
  self.status = "pause"
end

-- Stops the timer and resets the time
function timer:stop ()
  self.timestamp.start = 0
  self.timestamp.pause = 0
  self.timestamp.finish = math.huge
  self.status = "stop"
end

-- In "timer" mode returns true if timer finished, false otherwise.
-- In "counter" mode returns time from start.
--
-- @return  bool "finished?" or time from start (in seconds)
function timer:check ()
  if self.timestamp.time == -1 then
    return (love.timer.getTime() - self.timestamp.start)
  else
    return (love.timer.getTime() > self.timestamp.finish)
  end
end

-- In "timer" mode returns time left.
-- In "counter" mode returns time from start.
--
-- @return  time from start or remaining time (in seconds), nil if not running
function timer:time ()
  if self.timestamp.start == 0 then return 0 end
  if self.timestamp.time == -1 then
    if self.timestamp.pause == 0 then
      return (love.timer.getTime() - self.timestamp.start)
    else
      return (self.timestamp.pause - self.timestamp.start)
    end
  else
    return (self.timestamp.finish - love.timer.getTime())
  end
end

-- In "timer" mode returns time left.
-- In "counter" mode returns time from start.
--
-- @param   time  nil for "counter" mode, number for "timer" mode
function timer:set (time)
  if type(time) == "number" then
    if not (time < 0) then
      self.timestamp.time = time
    end
  elseif time == nil then
    self.timestamp.time = -1
  else
    error("Argument must be a positive number or nil")
  end
end

-- In "timer" mode returns time left.
-- In "counter" mode returns time from start.
--
-- @param   tmr  self
-- @return       time from start or remaining time (in seconds)
mt.__len = function (tmr)
  return tmr:time()
end

-- In "timer" mode returns true if timer finished, false otherwise.
-- In "counter" mode returns time from start.
--
-- @param   tmr  self
-- @return       bool "finished?" or time from start (in seconds)
mt.__call = function (tmr)
  return tmr:check()
end



timer = setmetatable(timer, mt)

return timer
