if not TabiuxDb then
    TabiuxDb = {}
end

local tabiux = CreateFrame("Frame", "TabiuxHealth", UIParent, "BackdropTemplate")

tabiux.target = "player"
tabiux.height = 36
tabiux.width = 200

tabiux:SetSize(tabiux.width, tabiux.height)
tabiux:SetPoint("TOPLEFT", UIParent, "LEFT", 700, -150)
tabiux:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
})
tabiux:SetBackdropColor(.6, .1, .1)
tabiux:SetBackdropBorderColor(0, 0, 0)

tabiux.statusbar = CreateFrame("StatusBar", "TabiuxHealthbar-" .. tabiux.target, tabiux)
tabiux.statusbar:SetSize(tabiux.width, tabiux.height - 3)
tabiux.statusbar:SetPoint("TOP", tabiux, "TOP", 0, 0)
tabiux.statusbar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
tabiux.statusbar:SetStatusBarColor(0, 0, 0)
tabiux.statusbar:SetMinMaxValues(0, 100)
tabiux.statusbar:SetValue(UnitHealthPercent(tabiux.target, false, CurveConstants.ScaleTo100))

tabiux.text = tabiux.statusbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tabiux.text:SetPoint("LEFT", tabiux, "LEFT", tabiux.height / 3, 0)
tabiux.text:SetText(UnitHealthPercent(tabiux.target, false, CurveConstants.ScaleTo100) .. "%")

tabiux.trigger = CreateFrame("Frame", "TabiuxHealthChange", UIParent)
local function healthChange(self, event, ...)
    if event and event == "UNIT_HEALTH" then
        self.value = UnitHealthPercent(tabiux.target, true, CurveConstants.ScaleTo100)
        tabiux.text:SetText(
            string.format("%.0f", self.value) .. "%"
        )
        tabiux.statusbar:SetValue(self.value)
    end
end

tabiux.trigger:SetScript("OnEvent", healthChange)
tabiux.trigger:RegisterUnitEvent("UNIT_HEALTH", tabiux.target)
