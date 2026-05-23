-- intro.lua
-- Handles the full intro sequence before gameplay begins:
--   1. Black screen → fade in studio logo → hold → fade out  (music plays throughout)
--   2. Fade in game intro image → hold → "Press Enter to continue" popup
--      (same music, continuous – stops when player presses Enter)
--   3. Father & daughter image + monologue audio → Enter/Space starts game

local Intro = {}

-- ── State machine ──────────────────────────────────────────────────────────
-- Stages (in order):
--   "studio_fadein"  → "studio_hold"  → "studio_fadeout"
--   "intro_fadein"   → "intro_hold"
--   "intro_prompt"   (same image, prompt visible, waiting for Enter)
--   "cutscene"       (fatheranddaughter image + monologue playing)
--   "done"           (caller should start gameplay)

local FADE_SPEED   = 1.2   -- alpha units per second (1 = full fade in 1/1.2 s ≈ 0.83 s)
local STUDIO_HOLD  = 5     -- seconds the studio logo stays fully visible
local INTRO_HOLD   = 5     -- seconds before the "Press Enter" prompt appears
local PROMPT_BLINK = 0.6   -- seconds per blink cycle for the prompt text

local stage        = "studio_fadein"
local alpha        = 0      -- 0 = transparent, 1 = fully opaque (image)
local blackAlpha   = 1      -- overlay for fades; 1 = black screen
local holdTimer    = 0
local blinkTimer   = 0
local showPrompt   = true

-- Assets (loaded in Intro.load)
local imgStudio, imgIntro, imgCutscene
local musicShared                        -- plays from studio logo all the way through intro; stops on Enter
local sfxMonologue                       -- the monologue voice clip

-- ── Helpers ────────────────────────────────────────────────────────────────

local function screenW() return love.graphics.getWidth()  end
local function screenH() return love.graphics.getHeight() end

-- Draw an image centred & scaled to fill the screen, preserving aspect ratio
local function drawImageFill(img)
    if not img then return end
    local iw, ih = img:getDimensions()
    local sw, sh = screenW(), screenH()
    local scale  = math.min(sw / iw, sh / ih)  -- was math.max
    local dx     = (sw - iw * scale) / 2
    local dy     = (sh - ih * scale) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, dx, dy, 0, scale, scale)
end

-- Draw centred on screen (for the small studio logo which has its own black bg)
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

-- ── Public API ─────────────────────────────────────────────────────────────

function Intro.load()
    -- Images
    imgStudio = love.graphics.newImage("studio.png")
    imgIntro = love.graphics.newImage("intro.png")
    imgCutscene = love.graphics.newImage("fatheranddaughter.png")

    -- Shared intro music (studio logo → intro image, stops on Enter)
    -- Swap filename when you have the real track
    local musicOk, musicErr = pcall(function()
        musicShared = love.audio.newSource("fallapart.mp3", "stream")
        musicShared:setLooping(true)
    end)
    if not musicOk then
        musicShared = nil
        print("[intro] Intro music not found – skipping: " .. tostring(musicErr))
    end

    -- Monologue
    local monoOk, monoErr = pcall(function()
        sfxMonologue = love.audio.newSource("monologue.mp3", "stream")
    end)
    if not monoOk then
        sfxMonologue = nil
        print("[intro] Monologue not found – skipping: " .. tostring(monoErr))
    end

    -- Reset state
    stage      = "studio_fadein"
    alpha      = 0
    blackAlpha = 1
    holdTimer  = 0
    blinkTimer = 0
    showPrompt = true
end

function Intro.update(dt)
    blinkTimer = blinkTimer + dt

    if stage == "studio_fadein" then
        blackAlpha = blackAlpha - FADE_SPEED * dt
        if blackAlpha <= 0 then
            blackAlpha = 0
            -- Music starts as soon as the logo is fully visible
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
            stage      = "intro_fadein"
            holdTimer  = 0
            -- Music keeps playing – no action needed
        end

    elseif stage == "intro_fadein" then
        blackAlpha = blackAlpha - FADE_SPEED * dt
        if blackAlpha <= 0 then
            blackAlpha = 0
            stage      = "intro_hold"
            holdTimer  = 0
        end

    elseif stage == "intro_hold" then
        holdTimer = holdTimer + dt
        if holdTimer >= INTRO_HOLD then
            stage = "intro_prompt"
        end

    elseif stage == "intro_prompt" then
        -- Waiting for Enter key (handled in Intro.keypressed)
        -- Prompt blink is driven by blinkTimer in draw

    elseif stage == "cutscene" then
        -- Waiting for Enter / Space (handled in Intro.keypressed)
        -- Monologue plays until the player skips

    elseif stage == "done" then
        -- Nothing to update; caller checks Intro.isDone()
    end
end

function Intro.draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenW(), screenH())

    if stage == "studio_fadein" or stage == "studio_hold" or stage == "studio_fadeout" then
        -- Draw studio logo (it already has a black background in the PNG)
        drawImageCentered(imgStudio)
        -- Black overlay for fade
        love.graphics.setColor(0, 0, 0, blackAlpha)
        love.graphics.rectangle("fill", 0, 0, screenW(), screenH())

    elseif stage == "intro_fadein" or stage == "intro_hold" or stage == "intro_prompt" then
        drawImageFill(imgIntro)
        -- Black overlay for fade-in
        if blackAlpha > 0 then
            love.graphics.setColor(0, 0, 0, blackAlpha)
            love.graphics.rectangle("fill", 0, 0, screenW(), screenH())
        end
        -- "Press Enter to continue" blinking prompt
        if stage == "intro_prompt" then
            local blink = (blinkTimer % (PROMPT_BLINK * 2)) < PROMPT_BLINK
            if blink then
                local sw, sh = screenW(), screenH()
                love.graphics.setFont(love.graphics.newFont(20))
                local text = "Press Enter to continue"
                local tw   = love.graphics.getFont():getWidth(text)
                -- White text with a subtle black shadow for readability
                love.graphics.setColor(0, 0, 0, 0.7)
                love.graphics.print(text, math.floor((sw - tw) / 2) + 2, sh - 62)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(text, math.floor((sw - tw) / 2), sh - 64)
            end
        end

    elseif stage == "cutscene" then
        drawImageFill(imgCutscene)

    elseif stage == "done" then
        -- Draw nothing; game takes over
    end
end

function Intro.keypressed(key)
    if stage == "intro_prompt" and key == "return" then
        -- Stop shared music, switch to cutscene
        if musicShared then musicShared:stop() end
        if sfxMonologue then sfxMonologue:play() end
        stage = "cutscene"

    elseif stage == "cutscene" and (key == "return" or key == "space") then
        -- Player skips / monologue ends → start game
        if sfxMonologue then sfxMonologue:stop() end
        stage = "done"
    end
end

-- Call this in love.keypressed to let the intro handle keys first
-- Returns true while the intro is active (game should NOT process its own input)
function Intro.isActive()
    return stage ~= "done"
end

function Intro.isDone()
    return stage == "done"
end

return Intro