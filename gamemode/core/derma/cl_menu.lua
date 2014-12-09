--[[
    NutScript is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NutScript is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with NutScript.  If not, see <http://www.gnu.org/licenses/>.
--]]

local PANEL = {}
	local gradient = nut.util.getMaterial("vgui/gradient-u")
	local gradient2 = nut.util.getMaterial("vgui/gradient-d")
	local alpha = 80

	function PANEL:Init()
		if (IsValid(nut.gui.menu)) then
			nut.gui.menu:Remove()
		end

		nut.gui.menu = self

		self:SetSize(ScrW(), ScrH())
		self:SetAlpha(0)
		self:AlphaTo(255, 0.25, 0)
		self:SetPopupStayAtBack(true)

		self.tabs = self:Add("DHorizontalScroller")
		self.tabs:SetWide(0)
		self.tabs:SetTall(86)

		self.panel = self:Add("EditablePanel")
		self.panel:SetSize(ScrW() * 0.6, ScrH() * 0.65)
		self.panel:Center()
		self.panel:SetPos(self.panel.x, self.panel.y + 72)
		self.panel:SetAlpha(0)

		self.title = self:Add("DLabel")
		self.title:SetPos(self.panel.x, self.panel.y - 80)
		self.title:SetTextColor(color_white)
		self.title:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.title:SetFont("nutTitleFont")
		self.title:SetText("")
		self.title:SetAlpha(0)
		self.title:SetSize(self.panel:GetWide(), 72)

		local tabs = {}

		hook.Run("CreateMenuButtons", tabs)

		for name, callback in SortedPairs(tabs) do
			self:addTab(L(name), callback)
		end

		self:MakePopup()
	end

	function PANEL:OnKeyCodePressed(key)
		if (key == KEY_F1) then
			self:remove()
		end
	end

	local color_bright = Color(240, 240, 240, 180)

	function PANEL:Paint(w, h)
		nut.util.drawBlur(self, 12)

		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(30, 30, 30, alpha)
		surface.DrawRect(0, 0, w, 78)

		surface.SetDrawColor(color_bright)
		surface.DrawRect(0, 78, w, 8)
	end

	function PANEL:addTab(name, callback, noTranslate)
		name = noTranslate and name or L(name)

		local function PaintTab(tab, w, h)
			if (self.activeTab == tab) then
				surface.SetDrawColor(ColorAlpha(nut.config.get("color"), 200))
				surface.DrawRect(0, h - 8, w, 8)
			elseif (tab.Hovered) then
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(0, h - 8, w, 8)
			end
		end

		surface.SetFont("nutMenuButtonLightFont")
		local w = surface.GetTextSize(name)

		local tab = self.tabs:Add("DButton")
			tab:SetSize(0, self.tabs:GetTall())
			tab:SetText(name)
			tab:SetPos(self.tabs:GetWide(), 0)
			tab:SetTextColor(Color(250, 250, 250))
			tab:SetFont("nutMenuButtonLightFont")
			tab:SetExpensiveShadow(1, Color(0, 0, 0, 150))
			tab:SizeToContentsX()
			tab:SetWide(w + 32)
			tab.Paint = PaintTab
			tab.DoClick = function(this)
				self.panel:Clear()

				self.title:SetText(this:GetText())
				self.title:AlphaTo(255, 0.5)

				self.panel:AlphaTo(255, 0.5, 0.1)
				self.activeTab = this

				if (callback) then
					callback(self.panel, this)
				end
			end
		self.tabs:AddPanel(tab)

		self.tabs:SetWide(math.min(self.tabs:GetWide() + tab:GetWide(), ScrW()))
		self.tabs:SetPos((ScrW() * 0.5) - (self.tabs:GetWide() * 0.5), 0)
	end

	function PANEL:remove()
		if (!self.closing) then
			self:AlphaTo(0, 0.25, 0, function()
				self:Remove()
			end)
			self.closing = true
		end
	end
vgui.Register("nutMenu", PANEL, "EditablePanel")

if (IsValid(nut.gui.menu)) then
	vgui.Create("nutMenu")
end