local dlg = Dialog {title = "Outline Merged"}

local sprite = app.activeSprite
local defaultColor = app.fgColor

local directions = {
    ["up-left"] = {x = -1, y = -1},
    ["up"] = {x = 0, y = -1},
    ["up-right"] = {x = 1, y = -1},
    ["right"] = {x = 1, y = 0},
    ["down-right"] = {x = 1, y = 1},
    ["down"] = {x = 0, y = 1},
    ["down-left"] = {x = -1, y = 1},
    ["left"] = {x = -1, y = 0}
}

local dirStatus = {
    ["up-left"] = false,
    ["up"] = true,
    ["up-right"] = false,
    ["right"] = true,
    ["down-right"] = false,
    ["down"] = true,
    ["down-left"] = false,
    ["left"] = true
}

local buttonText = {
    ["up-left"] = "⬛",
    ["up"] = "■",
    ["up-right"] = "⬛",
    ["right"] = "■",
    ["down-right"] = "⬛",
    ["down"] = "■",
    ["down-left"] = "⬛",
    ["left"] = "■"
}

dlg:color{id = "color", label = "Outline Color: ", color = defaultColor}

dlg:number{
    id = "thickness",
    label = "Outline Thickness: ",
    min = 1,
    value = 1,
    text = "1"
}

dlg:separator{id = "dirLabel", text = "Outline Presets"}

dlg:combobox{
    id = "presets",
    option = "Circle",
    options = {"Circle", "Square"},
    onchange = function()
        local option = dlg.data["presets"]
        local newDirStatus = {}
        if option == "Square" then
            newDirStatus = {
                ["up-left"] = true,
                ["up"] = true,
                ["up-right"] = true,
                ["right"] = true,
                ["down-right"] = true,
                ["down"] = true,
                ["down-left"] = true,
                ["left"] = true
            }
        elseif option == "Circle" then
            newDirStatus = {
                ["up-left"] = false,
                ["up"] = true,
                ["up-right"] = false,
                ["right"] = true,
                ["down-right"] = false,
                ["down"] = true,
                ["down-left"] = false,
                ["left"] = true
            }
        end

        for key, value in pairs(newDirStatus) do
            modifyDirStatus(key, value)
        end
    end
}

dlg:separator{id = "dirLabel", text = "Outline Directions"}

dlg:button{
    id = "up-left",
    text = buttonText["up-left"],
    hexpand = false,
    onclick = function() toggle("up-left") end
}
dlg:button{
    id = "up",
    text = buttonText["up"],
    hexpand = false,
    onclick = function() toggle("up") end
}
dlg:button{
    id = "up-right",
    text = buttonText["up-right"],
    hexpand = false,
    onclick = function() toggle("up-right") end
}
dlg:newrow()
dlg:button{
    id = "right",
    text = buttonText["right"],
    hexpand = false,
    onclick = function() toggle("right") end
}
dlg:button{id = "center", enabled = false, hexpand = false}
dlg:button{
    id = "left",
    text = buttonText["left"],
    hexpand = false,
    onclick = function() toggle("left") end
}
dlg:newrow()
dlg:button{
    id = "down-right",
    text = buttonText["down-right"],
    hexpand = false,
    onclick = function() toggle("down-right") end
}
dlg:button{
    id = "down",
    text = buttonText["down"],
    hexpand = false,
    onclick = function() toggle("down") end
}
dlg:button{
    id = "down-left",
    text = buttonText["down-left"],
    hexpand = false,
    onclick = function() toggle("down-left") end
}
dlg:newrow()

function toggle(key) modifyDirStatus(key, not dirStatus[key]) end

function modifyDirStatus(key, isTrue)
    dirStatus[key] = isTrue
    if isTrue then
        modifyButtonText(key, "■")
    else
        modifyButtonText(key, "⬛")
    end
end

function modifyButtonText(widgetID, newText)
    buttonText[widgetID] = newText
    dlg:modify{id = widgetID, text = newText}
end

dlg:button{
    id = "outline",
    text = "OUTLINE",
    onclick = function()
        sprite = app.activeSprite
        local range = app.range
        local layers = range.layers
        local frameNumToCels

        if (range.type == RangeType.FRAMES) then
            app.alert(
                "Frames selected. Please select either cels, layers, or leave the selection empty to select all cels. Cancelling...")
            return
        elseif (range.type == RangeType.EMPTY) then
            frameNumToCels = getCellsFromLayers(sprite.layers)
        elseif (range.type == RangeType.LAYERS) then
            frameNumToCels = getCellsFromLayers(range.layers)
        elseif (range.type == RangeType.CELS) then
            frameNumToCels = groupCellsByFrame(range.cels)
        end

        local frameNumToMergedImage = combineCelImages(frameNumToCels)

        local outlines = outline(frameNumToMergedImage)

        for i = 2, dlg.data.thickness do
            frameNumToMergedImage = mergeFrameImages(frameNumToMergedImage,
                                                     outlines)
            outlines =
                mergeFrameImages(outlines, outline(frameNumToMergedImage))
        end

        drawImages(outlines)

        app.refresh()
    end
}

-- returns all the cells in the layers, grouped by frames
function getCellsFromLayers(layers)
    frameNumToCels = {}
    for _, layer in ipairs(layers) do
        if (#layer.cels ~= 0) then
            for __, cel in ipairs(layer.cels) do
                add(frameNumToCels, cel.frame.frameNumber, cel)
            end
        end
    end

    return frameNumToCels
end

function groupCellsByFrame(cels)
    frameNumToCels = {}
    for _, cel in ipairs(cels) do
        add(frameNumToCels, cel.frame.frameNumber, cel)
    end
    return frameNumToCels
end

function add(t, key, value)
    if t[key] == nil then
        t[key] = {value}
    else
        table.insert(t[key], value)
    end
end

function combineCelImages(frameNumToCels)
    local frameNumToImage = {}
    for frameNumber, cels in pairs(frameNumToCels) do
        local image = Image(sprite.width, sprite.height)
        frameNumToImage[frameNumber] = image
        for _, cel in ipairs(cels) do combineIntoImage(image, cel) end
    end
    return frameNumToImage
end

function combineIntoImage(image, cel) image:drawImage(cel.image, cel.position) end

function mergeFrameImages(frameNumToImage1, frameNumToImage2)
    local frameNumToImage = {}
    for frameNumber, image in pairs(frameNumToImage1) do
        local newImage = Image(sprite.width, sprite.height)
        newImage:drawImage(image)
        frameNumToImage[frameNumber] = newImage
    end

    for frameNumber, image in pairs(frameNumToImage2) do
        local existingImage = frameNumToImage[frameNumber]
        if existingImage == nil then
            local newImage = Image(sprite.width, sprite.height)
            frameNumToImage[frameNumber] = newImage
            image:drawImage(image, Point(0, 0))
        else
            existingImage:drawImage(image, Point(0, 0), 255, BlendMode.NORMAL)
        end
    end

    return frameNumToImage
end

function outline(frameNumToImage)
    local frameNumToOutline = {}
    for frameNumber, image in pairs(frameNumToImage) do
        local outlineImage = Image(sprite.width, sprite.height)

        for pixel in image:pixels() do
            if not isTransparent(pixel()) then
                outlinePixel(outlineImage, image, pixel)
            end
        end

        frameNumToOutline[frameNumber] = outlineImage
    end
    return frameNumToOutline
end

function isTransparent(pixelValue)
    if app.pixelColor.rgbaA(pixelValue) ~= 0 then return false end
    return true
end

function outlinePixel(drawingImage, refImage, pixel)
    local clr = dlg.data.color
    local color = app.pixelColor.rgba(clr.red, clr.green, clr.blue)

    for key, dir in pairs(directions) do
        if (dirStatus[key]) then
            local pos = {x = pixel.x + dir.x, y = pixel.y + dir.y}
            if (isTransparent(refImage:getPixel(pos.x, pos.y))) then
                drawingImage:drawPixel(pos.x, pos.y, color)
            end
        end
    end
end

function drawImages(frameNumToImage)
    app.command.NewLayer {name = "Outline", top = true}

    local newLayer = app.activeLayer

    for frameNumber, image in pairs(frameNumToImage) do
        sprite:newCel(newLayer, frameNumber, image)
    end
end

dlg:button{id = "close", text = "CLOSE", onclick = function() dlg:close() end}

dlg:show{wait = false}
