-- intro.lua
local Intro = {}

local FADE_SPEED   = 1.2
local STUDIO_HOLD  = 5
local INTRO_HOLD   = 5
local PROMPT_BLINK = 0.6
local FADE_DURATION = 0.8  -- durée du fondu entre images

local stage        = "studio_fadein"
local alpha        = 0
local blackAlpha   = 1
local holdTimer    = 0
local blinkTimer   = 0
local showPrompt   = true

-- Cutscene
local CUTSCENE_COUNT    = 13
local CUTSCENE_TOTAL    = 77  -- 1:17 en secondes
local CUTSCENE_DURATION = CUTSCENE_TOTAL / CUTSCENE_COUNT  -- ~5.54s par image
local cutsceneImages    = {}
local cutsceneIndex     = 1   -- image actuelle
local cutsceneTimer     = 0   -- temps passé sur l'image actuelle
local cutsceneFade      = 0   -- 0=opaque, 1=noir (fondu sortant)
local cutsceneFading    = false

local imgStudio, imgIntro
local musicShared
local sfxMonologue

local function screenW() return love.graphics.getWidth()  end
local function screenH() return love.graphics.getHeight() end

local function drawImageFill(img)
    if not img then return end
    local iw, ih = img:getDimensions()
    local sw, sh = screenW(), screenH()
    local scale  = math.min(sw / iw, sh / ih)
    local dx     = (sw - iw * scale) / 2
    local dy     = (sh - ih * scale) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, dx, dy, 0, scale, scale)
end

local function drawImageCentered(img)
    if not img then return end
    local iw, ih = img:getDimensions()
    local sw, sh = screenW(), screenH()
    local scale  = math.min(sw / iw, sh / ih)
    local dx     = (sw - iw * scale) / 2
    local dy     = (sh - ih * scale) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, dx, dy, 0, scale, scale)
end

function Intro.load()
    imgStudio = love.graphics.newImage("studio.png")
    imgIntro  = love.graphics.newImage("intro.png")

    for i = 1, CUTSCENE_COUNT do
        local ok, img = pcall(love.graphics.newImage, i .. ".png")
        if ok then
            cutsceneImages[i] = img
        else
            print("[intro] Image manquante : " .. i .. ".png")
        end
    end

    local musicOk, musicErr = pcall(function()
        musicShared = love.audio.newSource("fallapart.mp3", "stream")
        musicShared:setLooping(true)
    end)
    if not musicOk then
        musicShared = nil
        print("[intro] Intro music not found: " .. tostring(musicErr))
    end

    local monoOk, monoErr = pcall(function()
        sfxMonologue = love.audio.newSource("monologue.mp3", "stream")
    end)
    if not monoOk then
        sfxMonologue = nil
        print("[intro] Monologue not found: " .. tostring(monoErr))
    end

    stage          = "studio_fadein"
    alpha          = 0
    blackAlpha     = 1
    holdTimer      = 0
    blinkTimer     = 0
    showPrompt     = true
    cutsceneIndex  = 1
    cutsceneTimer  = 0
    cutsceneFade   = 0
    cutsceneFading = false
end

function Intro.update(dt)
    blinkTimer = blinkTimer + dt

    if stage == "studio_fadein" then
        blackAlpha = blackAlpha - FADE_SPEED * dt
        if blackAlpha <= 0 then
            blackAlpha = 0
            if musicShared then musicShared:play() end
            stage     = "studio_hold"
            holdTimer = 0
        end

    elseif stage == "studio_hold" then
        holdTimer = holdTimer + dt
        if holdTimer >= STUDIO_HOLD then
            stage = "studio_fadeout"
        end

    elseif stage == "studio_fadeout" then
        blackAlpha = blackAlpha + FADE_SPEED * dt
        if blackAlpha >= 1 then
            blackAlpha = 1
            stage     = "intro_fadein"
            holdTimer = 0
        end

    elseif stage == "intro_fadein" then
        blackAlpha = blackAlpha - FADE_SPEED * dt
        if blackAlpha <= 0 then
            blackAlpha = 0
            stage     = "intro_hold"
            holdTimer = 0
        end

    elseif stage == "intro_hold" then
        holdTimer = holdTimer + dt
        if holdTimer >= INTRO_HOLD then
            stage = "intro_prompt"
        end

    elseif stage == "intro_prompt" then
        -- attend Enter

    elseif stage == "cutscene" then
        cutsceneTimer = cutsceneTimer + dt

        local timeLeft = CUTSCENE_DURATION - cutsceneTimer

        -- commence le fondu sortant avant la fin
        if timeLeft <= FADE_DURATION and not cutsceneFading then
            cutsceneFading = true
        end

        if cutsceneFading then
            cutsceneFade = cutsceneFade + dt / FADE_DURATION
            if cutsceneFade >= 1 then
                cutsceneFade = 1
                -- passe à l'image suivante
                if cutsceneIndex < CUTSCENE_COUNT then
                    cutsceneIndex  = cutsceneIndex + 1
                    cutsceneTimer  = 0
                    cutsceneFade   = 0
                    cutsceneFading = false
                else
                    -- toutes les images jouées
                    if sfxMonologue then sfxMonologue:stop() end
                    stage = "done"
                end
            end
        end

    elseif stage == "done" then
        -- rien
    end
end

function Intro.draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenW(), screenH())

    if stage == "studio_fadein" or stage == "studio_hold" or stage == "studio_fadeout" then
        drawImageCentered(imgStudio)
        love.graphics.setColor(0, 0, 0, blackAlpha)
        love.graphics.rectangle("fill", 0, 0, screenW(), screenH())

    elseif stage == "intro_fadein" or stage == "intro_hold" or stage == "intro_prompt" then
        drawImageFill(imgIntro)
        if blackAlpha > 0 then
            love.graphics.setColor(0, 0, 0, blackAlpha)
            love.graphics.rectangle("fill", 0, 0, screenW(), screenH())
        end
        if stage == "intro_prompt" then
            local blink = (blinkTimer % (PROMPT_BLINK * 2)) < PROMPT_BLINK
            if blink then
                local sw, sh = screenW(), screenH()
                love.graphics.setFont(love.graphics.newFont(20))
                local text = "Press Enter to continue"
                local tw   = love.graphics.getFont():getWidth(text)
                love.graphics.setColor(0, 0, 0, 0.7)
                love.graphics.print(text, math.floor((sw - tw) / 2) + 2, sh - 62)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(text, math.floor((sw - tw) / 2), sh - 64)
            end
        end

    elseif stage == "cutscene" then
        local img = cutsceneImages[cutsceneIndex]
        drawImageFill(img)
        -- fondu noir sortant vers l'image suivante
        if cutsceneFade > 0 then
            love.graphics.setColor(0, 0, 0, cutsceneFade)
            love.graphics.rectangle("fill", 0, 0, screenW(), screenH())
        end

    elseif stage == "done" then
        -- rien
    end
end

function Intro.keypressed(key)
    if stage == "intro_prompt" and key == "return" then
        if musicShared then musicShared:stop() end
        if sfxMonologue then sfxMonologue:play() end
        stage          = "cutscene"
        cutsceneIndex  = 1
        cutsceneTimer  = 0
        cutsceneFade   = 0
        cutsceneFading = false

    elseif stage == "cutscene" and (key == "return" or key == "space") then
        if sfxMonologue then sfxMonologue:stop() end
        stage = "done"
    end
end

function Intro.isActive()
    return stage ~= "done"
end

function Intro.isDone()
    return stage == "done"
end

return Intro