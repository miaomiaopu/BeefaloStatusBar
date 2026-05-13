local Widget = require "widgets/widget"
local BeefaloBadge = require "widgets/beefaloBadge"

local function OnMountData(self, classified)
    local data = classified.beefaloData:value()
    if data ~= "dismount" then self:Activate(json.decode(data)) else self:Deactivate() end
end

local function OnHealthDirty(self, classified) self:UpdateHealth(classified.beefaloHealth:value()) end

local function OnDomesticationDirty(self, classified)
    local data = json.decode(classified.beefaloDomestication:value())
    self:UpdateDomestication(data.domestication, data.tendency)
end

local function OnObedienceDirty(self, classified) self:UpdateObedience(classified.beefaloObedience:value()) end
local function OnHungerDirty(self, classified) self:UpdateHunger(classified.beefaloHunger:value()) end

local BeefaloStatusBar = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "BeefaloStatusBar")
    self.owner = owner
    self.CONFIG = config

    self.isHidden = true

    self.maxHealth = TUNING.BEEFALO_HEALTH
    self.maxHunger = TUNING.BEEFALO_HUNGER
    self.buckDelay = 0
    self.mountStartTime = 0
    self.mounted = false
    self.tendency = nil
    self.timerTask = nil
    self.lastHunger = 0

    self.root = self:AddChild(Widget("root"))

    self.badgeStartPosition = -148
    self.badgeGap = self.CONFIG.GAP_MODIFIER + (self.CONFIG.THEME == "TheForge" and 4 or 0)
    self.badgeWidth = 74 + self.badgeGap

    self.BADGE_CONFIG = {theme = self.CONFIG.THEME, brightness = self.CONFIG.BG_BRIGHTNESS, opacity = self.CONFIG.BG_OPACITY}

    self.healthBadge = self.root:AddChild(BeefaloBadge(self.BADGE_CONFIG, {174 / 255, 21 / 255, 21 / 255, 1}, "status_health", nil, self.CONFIG.HEALTH_CLEAR_BG))
    self.healthBadge:SetPosition(self.badgeStartPosition, 0)

    self.domesticationBadge = self.root:AddChild(BeefaloBadge(self.BADGE_CONFIG, self.CONFIG.BADGE_COLORS.ORNERY, nil, nil, true))
    self.domesticationBadge:SetPosition(self.badgeStartPosition + self.badgeWidth, 0)
    self.domesticationBadge.icon:SetTexture("minimap/minimap_data.xml", "beefalo_domesticated.png")

    self.obedienceBadge = self.root:AddChild(BeefaloBadge(self.BADGE_CONFIG, self.CONFIG.BADGE_COLORS.OBEDIENCE, nil, nil, true))
    self.obedienceBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 2, 0)
    self.obedienceBadge.icon:SetTexture(GetInventoryItemAtlas("whip.tex"), "whip.tex")

    self.timerBadge = self.root:AddChild(BeefaloBadge(self.BADGE_CONFIG, self.CONFIG.BADGE_COLORS.TIMER, nil, true, true))
    self.timerBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 3, 0)
    self.timerBadge.icon:SetTexture(GetInventoryItemAtlas("saddle_basic.tex"), "saddle_basic.tex")

    self.hungerBadge = self.root:AddChild(BeefaloBadge(self.BADGE_CONFIG, {215 / 255, 165 / 255, 0 / 255, 1}, "status_hunger", nil, true))
    self.hungerBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 4, -130)
    self.hungerBadge:Hide()


    if self.healthBadge.bg ~= nil then
        self.CONFIG.ROOT_Y = 18
    elseif self.CONFIG.THEME == "TheForge" then
        self.CONFIG.BASE_Y = self.CONFIG.BASE_Y + 4
    end

    self.CONFIG.ROOT_X = self.badgeWidth / 2 - (self.badgeGap * 2)

    self:Hide()
    self:SetScale(self.CONFIG.SCALE)
    self:SetPosition(self.CONFIG.BASE_X, self.CONFIG.BASE_Y)
    self.root:SetPosition(self.CONFIG.ROOT_X, self.CONFIG.ROOT_Y_HIDDEN)


    self.owner:DoTaskInTime(0.1, function()
        if not self.owner.player_classified then return end
        self.owner.player_classified:ListenForEvent("beefaloDataDirty", function(classified) OnMountData(self, classified) end)
        self.owner.player_classified:ListenForEvent("beefaloHealthDirty", function(classified) OnHealthDirty(self, classified) end)
        self.owner.player_classified:ListenForEvent("beefaloDomesticationDirty", function(classified) OnDomesticationDirty(self, classified) end)
        self.owner.player_classified:ListenForEvent("beefaloObedienceDirty", function(classified) OnObedienceDirty(self, classified) end)
        self.owner.player_classified:ListenForEvent("beefaloHungerDirty", function(classified) OnHungerDirty(self, classified) end)
        self.owner.player_classified:ListenForEvent("beefaloFed", function()
            self:OnBeefaloFed()
        end)
    end)

    self.owner:ListenForEvent("RepositionStatusBar", function() self:Reposition() end)

    if self.CONFIG.TOGGLE_KEY then
        self.owner:ListenForEvent("ToggleStatusBar", function() self:Toggle() end)
    end
end)


function BeefaloStatusBar:UpdateHealth(health)
    self.healthBadge:SetPercent(health / self.maxHealth, self.maxHealth)
end

function BeefaloStatusBar:UpdateDomestication(domestication, tendency)
    local displayValue = tonumber(string.format("%.1f", domestication))
    self.domesticationBadge:SetPercent(domestication / 100, 100, displayValue)
    if self.tendency ~= tendency then
        self.tendency = tendency
        self.domesticationBadge.anim:GetAnimState():SetMultColour(unpack(self.CONFIG.BADGE_COLORS[tendency] or self.CONFIG.BADGE_COLORS.DEFAULT))
    end
end

function BeefaloStatusBar:UpdateObedience(obedience)
    self.obedienceBadge:SetPercent(obedience / 100, 100)
end

function BeefaloStatusBar:UpdateTimer()
    local timeLeft = math.floor(self.mountStartTime + self.buckDelay - GetTime())
    if timeLeft >= 0 then
        local seconds = timeLeft % 60
        local displayTime = math.floor(timeLeft / 60) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
        self.timerBadge:SetPercent(timeLeft / self.buckDelay, self.buckDelay, displayTime)
    end
end

function BeefaloStatusBar:StartTimer()
    if self.timerTask == nil and self.mounted then
        self.timerTask = self.owner:DoPeriodicTask(1, function() self:UpdateTimer() end, 0)
    end
end

function BeefaloStatusBar:StopTimer()
    if self.timerTask ~= nil then self.timerTask:Cancel() self.timerTask = nil end
end

function BeefaloStatusBar:SetSaddle(saddleUses)
    local saddle = self.owner.replica.rider:GetSaddle()
    if not saddle then
        self.timerBadge:SetTooltip("无鞍具")
        self.timerBadge.icon:SetTexture(GetInventoryItemAtlas("saddle_basic.tex"), "saddle_basic.tex")
        return
    end

    local image = saddle.replica.inventoryitem:GetImage()
    local displayName = saddle:GetDisplayName() or "鞍具"

    local usesText = ""
    if saddleUses and saddleUses > 0 then
        if saddleUses > 1 then
            usesText = "\n" .. saddleUses .. " 次可用"
        else
            usesText = "\n无可用"
        end
    end

    self.timerBadge:SetTooltip(displayName .. usesText)

    if image then
        self.timerBadge.icon:SetTexture(GetInventoryItemAtlas(image), image)
    else
        self.timerBadge.icon:SetTexture(GetInventoryItemAtlas("saddle_basic.tex"), "saddle_basic.tex")
    end
end

function BeefaloStatusBar:UpdateHunger(hunger, initial)
    local lastHunger = self.lastHunger or hunger
    self.lastHunger = hunger

    if not initial and hunger > lastHunger then
        self.mountStartTime = GetTime()
        if self.timerTask then
            self:UpdateTimer()
        end
    end

    self.hungerBadge:SetPercent(hunger / self.maxHunger, self.maxHunger)
    self:UpdateHungerVisibility(hunger)
end

function BeefaloStatusBar:UpdateHungerVisibility(hunger)
    if not self.CONFIG.HUNGER_THRESHOLD then
        self:SetHungerVisibility(false)
        return
    end

    if hunger >= self.CONFIG.HUNGER_THRESHOLD then
        self:SetHungerVisibility(true)
    else
        self:SetHungerVisibility(false)
    end
end

function BeefaloStatusBar:OnBeefaloFed()
    if self.mounted then
        self.mountStartTime = GetTime()
        if self.timerTask then
            self:UpdateTimer()
        end
    end
end

function BeefaloStatusBar:SetHungerVisibility(visible, transition)
    if self.hungerBadge.shown == visible then
        return
    end

    transition = transition or 0.4
    local ROOT_POS_Y = self.isHidden and self.CONFIG.ROOT_Y_HIDDEN or self.CONFIG.ROOT_Y
    self.CONFIG.ROOT_X = visible and 0 - self.badgeGap * 2 or self.badgeWidth / 2 - (self.badgeGap * 2)
    self.root:MoveTo(self.root:GetPosition(), {x = self.CONFIG.ROOT_X, y = ROOT_POS_Y, z = 0}, transition)
    local badgeTransition = transition == 0 and transition or transition / 1.5
    if visible then self.hungerBadge:Show() end
    self.hungerBadge:MoveTo(self.hungerBadge:GetPosition(), {x = self.badgeStartPosition + self.badgeWidth * 4, y = visible and 0 or -130, z = 0}, badgeTransition, function()
        if not visible then self.hungerBadge:Hide() end
    end)
end

function BeefaloStatusBar:Activate(data)
    self.maxHealth = data.maxHealth
    self.maxHunger = data.maxHunger
    self.buckDelay = data.buckDelay
    self.mountStartTime = GetTime()
    self.mounted = true

    self:UpdateHealth(data.health)
    self:UpdateDomestication(data.domestication, data.tendency)
    self:UpdateObedience(data.obedience)
    self:SetSaddle(data.saddleUses)
    self:UpdateHunger(data.hunger, true)

    if self.CONFIG.SHOW_BY_DEFAULT then self:SlideIn() end
end

function BeefaloStatusBar:Deactivate()
    self.mounted = false
    if self:IsVisible() then self:SlideOut() end
end


function BeefaloStatusBar:SlideIn(transition)
    transition = transition or 0.5
    self.isHidden = false
    self:Show()
    self:StartTimer()
    self.root:CancelMoveTo()
    self.root:MoveTo(self.root:GetPosition(), {x = self.CONFIG.ROOT_X, y = self.CONFIG.ROOT_Y, z = 0}, transition, function()
        if self.CONFIG.ENABLE_SOUNDS then TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open") end
    end)
    self.root:ScaleTo(0.2, 1, transition)
end

function BeefaloStatusBar:SlideOut()
    self.isHidden = true
    self:StopTimer()
    self.root:CancelMoveTo()
    self.root:MoveTo(self.root:GetPosition(), {x = self.CONFIG.ROOT_X, y = self.CONFIG.ROOT_Y_HIDDEN, z = 0}, 0.5, function() self:Hide() end)
    self.root:ScaleTo(1, 0.1, 0.5)

    if self.CONFIG.ENABLE_SOUNDS then TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close") end
end

function BeefaloStatusBar:Reposition()
    local inventoryStateOffset = 0
    if Profile:GetIntegratedBackpack() or TheInput:ControllerAttached() then
        local backpack = self.owner.replica.inventory:GetOverflowContainer()
        if backpack and backpack:IsOpenedBy(self.owner) then inventoryStateOffset = 45 end
    end

    if self:IsVisible() then
        self:MoveTo(self:GetPosition(), {x = self.CONFIG.BASE_X, y = self.CONFIG.BASE_Y + inventoryStateOffset, z = 0}, 0.15)
    else
        self:SetPosition(self.CONFIG.BASE_X, self.CONFIG.BASE_Y + inventoryStateOffset)
    end
end

function BeefaloStatusBar:Toggle()
    local screen = tostring(TheFrontEnd:GetActiveScreen())
    if screen == "HUD" and self.mounted and not self.owner.HUD:IsCraftingOpen() and not self.owner.HUD:HasInputFocus() then
        if self.isHidden then
            self.CONFIG.SHOW_BY_DEFAULT = true
            self:SlideIn(0.3)
        else
            self.CONFIG.SHOW_BY_DEFAULT = false
            self:SlideOut()
        end
    end
end

return BeefaloStatusBar
