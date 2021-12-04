GPIO = {}

GPIO.setMode = function(pin, mode)
    mode = mode or "output"

    local md
    if mode == "input" then
        md = " ip"
    elseif mode == "output" then
        md = " op"
    elseif mode == "pullup" then
        md = " ip pu"
    elseif mode == "pulldown" then
        md = " ip pd"
    else
        md = " ip"
        print("ERROR SETTING PIN MODE... " .. mode .. " not a mode")
    end
    os.execute("raspi-gpio set " .. pin .. md)
end

GPIO.set = function(pin, val)
    local v
    if val == true then
        v = " dh"
    else
        v = " dl"
    end

    os.execute("raspi-gpio set " .. pin .. v)
end

GPIO.get = function(pin)
    local handle = io.popen("raspi-gpio get " .. pin)
    local str = handle:read("*a")
    handle:close()

    debugText = debugText .. "\n" .. str
end
