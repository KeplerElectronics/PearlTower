--inputs

function down()
    if love.keyboard.isDown("down") then
        return true
    end
    if not active then return end
    if active:isGamepadDown({"dpdown"}) 
    or active:getGamepadAxis("lefty")<-0.5 then
        return true
    end
end

function up()
    if love.keyboard.isDown("up") then
        return true
    end
    if not active then return end
    if active:isGamepadDown({"dpup"}) 
    or active:getGamepadAxis("lefty")>0.5 then
        return true
    end
end

function left()
    if love.keyboard.isDown("left") then
        return true
    end

    if not active then return false end
    if active:isGamepadDown({"dpleft"}) 
    or active:getGamepadAxis("leftx")<-0.5 then
        return true
    end
end

function right()
    if love.keyboard.isDown("right") then
        return true
    end
    if not active then return end
    if active:isGamepadDown({"dpright"}) 
    or active:getGamepadAxis("leftx")>0.5 then
        return true
    end
end

function jump()
    if love.keyboard.isDown("z") then
        return true
    end

    if not active then return end
    if active:isGamepadDown({"a"}) then
        return true
    end
end

function run()
    if love.keyboard.isDown("x") then
        return true
    end
    if not active then return end
    if active:getGamepadAxis("triggerright")>0 then
        return true
    end
end

function float()
    if love.keyboard.isDown("s") then
        return true
    end
    if not active then return end
    if active:getGamepadAxis("triggerleft")>0 then
        return true
    end
end

function swing()

    if love.keyboard.isDown("a") then
        return true
    end
    if not active then return end
    if active:isGamepadDown("x") then
        return true
    end
end

function trigpause()
    if love.keyboard.isDown("escape") then
        return true
    end
    if not active then return end
    if active:isGamepadDown("start") then
        return true
    end
end
