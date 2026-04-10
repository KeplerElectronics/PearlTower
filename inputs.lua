--input

keymap={jump="z",
        run="x",
        float="s",
        swing="a",
        pause="escape",

        up="up",
        down="down",
        left="left",
        right="right"}

joymap={jump="a",
        runaxis="triggerright",
        runbtn="x",
        floataxis="triggerleft",
        floatbtn="y",
        swing="x",

        pause="start",

        up="dpup",
        down="dpdown",
        left="dpleft",
        right="dpright"}

function down(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.down) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({joymap.down}) 
    or p[plyr].joystick:getGamepadAxis("lefty")>0.5 then
        return true
    end
end

function up(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.up) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({joymap.up}) 
    or p[plyr].joystick:getGamepadAxis("lefty")<-0.5 then
        return true
    end
end

function left(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.left) then
        return true
    end

    if not p[plyr].joystick then return false end
    if p[plyr].joystick:isGamepadDown({joymap.left}) 
    or p[plyr].joystick:getGamepadAxis("leftx")<-0.5 then
        return true
    end
end

function right(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.right) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({joymap.right}) 
    or p[plyr].joystick:getGamepadAxis("leftx")>0.5 then
        return true
    end
end

function jump(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.jump) then
        return true
    end

    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({"a"}) then
        return true
    end
end

function run(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.run) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({joymap.runbtn}) 
    or p[plyr].joystick:getGamepadAxis(joymap.runaxis)>0 then
        return true
    end
end

function float(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.float) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown({joymap.floatbtn}) 
    or p[plyr].joystick:getGamepadAxis(joymap.floataxis)>0 then
        return true
    end
end

function swing(plyr)
    if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.swing) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown(joymap.swing) then
        return true
    end
end

function trigpause(plyr)
        if not plyr then plyr=1 end
    if love.keyboard.isDown(keymap.pause) then
        return true
    end
    if not p[plyr].joystick then return end
    if p[plyr].joystick:isGamepadDown(joymap.pause) then
        return true
    end
end
