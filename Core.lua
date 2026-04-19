if not TabiuxDb then
    TabiuxDb = {}
end

print("Tabiux loaded")

local function getHealth(target)
    local healthPercentage = UnitHealthPercent(target, true, CurveConstants.ScaleTo100)
    local healthAbbreviated = AbbreviateNumbers(UnitHealth(target, true))
    return healthPercentage, healthAbbreviated
end

local function healthChange(self, ...)
    local healthPercentage, healthAbbreviated = getHealth(self.target)
    self.percentage:SetText(
        string.format("%.0f", healthPercentage) .. "%"
    )
    self.abbreviated:SetText(healthAbbreviated)
    self:SetValue(healthPercentage)
end

local function newHealthframe(self, target, width, height)
    local f = CreateFrame("Frame", "Tabiux-" .. target .. "-base", UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
    })
    local className, classFilename, classId = UnitClass(target)
    local red, green, blue = GetClassColor(classFilename)
    if not red or not green or not blue then
        red = 1
        green = 1
        blue = 1
    end
    f:SetBackdropColor(red, green, blue)
    f:SetBackdropBorderColor(0, 0, 0)
    local healthPercentage, healthAbbreviated = getHealth(target)

    f.bar = CreateFrame("StatusBar", "Tabiux-" .. target .. "-healthbar", f)
    f.bar:SetSize(width, height - 3)
    f.bar:SetPoint("TOP", f, "TOP", 0, 0)
    f.bar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
    f.bar:SetStatusBarColor(0, 0, 0)
    f.bar:SetMinMaxValues(0, 100)
    f.bar:SetValue(100)
    f.bar.target = target

    -- Percentage health
    f.bar.percentage = f.bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.bar.percentage:SetPoint("LEFT", f, "LEFT", height / 3, 0)
    f.bar.percentage:SetTextColor(red, green, blue)
    f.bar.percentage:SetText(
        string.format("%.0f", healthPercentage) .. "%"
    )
    -- Abbreviated health; e.g. 570000 = 570k
    f.bar.abbreviated = f.bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.bar.abbreviated:SetPoint("RIGHT", f, "RIGHT", -height / 3, 0)
    f.bar.abbreviated:SetTextColor(red, green, blue)
    f.bar.abbreviated:SetText(healthAbbreviated)

    f.bar:RegisterUnitEvent("UNIT_HEALTH", target)
    f.bar:RegisterEvent("PLAYER_TARGET_CHANGED")
    f.bar:SetScript("OnEvent", healthChange)
    f.bar:SetScript("OnShow", healthChange)
    return f
end

local player = CreateFrame("Frame", "Tabiux-player", UIParent)
player.health = newHealthframe(UIParent, "player", 200, 36)
player.health:SetPoint("TOPLEFT", UIParent, "LEFT", 700, -150)

local target = CreateFrame("Frame", "Tabiux-target", UIParent)
target.health = newHealthframe(UIParent, "target", 200, 36)
target.health:SetPoint("TOPRIGHT", UIParent, "RIGHT", -700, -150)

target:RegisterEvent("PLAYER_TARGET_CHANGED")
target:SetScript("OnEvent", function(self, event, payload)
    local first, last = UnitName("target")
    if (first) then
        target.health:Show()
        return
    end
    target.health:Hide()
end)
