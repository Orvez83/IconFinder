local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local PlatformURLs = {
	["Lucide"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Lucide.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide.lua"
	},
	["Gravity"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Gravity.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Gravity.lua"
	},
	["Solar"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Solar.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Solar.lua"
	},
	["SFSymbols"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/SFSymbols.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/SFSymbols.lua"
	}
}

local IconCache = {}
local CurrentCopyMode = "ID"
local CopyOnPress = false
local CurrentFilters = {All = true}
local CurrentSort = "A-Z"
local MultiSelectMode = false
local SelectedIcons = {}
local CurrentAlphabetFilter = nil

local MAX_SETTINGS_HEIGHT = 230

local function HttpGetWithRetry(urls, maxRetries)
	maxRetries = maxRetries or 3
	local lastError = "Unknown error"

	for _, url in ipairs(urls) do
		for attempt = 1, maxRetries do
			local success, result = pcall(function()
				return game:HttpGet(url)
			end)

			if success then
				return true, result
			end

			lastError = tostring(result)

			if lastError:find("429") then
				task.wait(attempt * 1.5)
			else
				break
			end
		end
	end

	return false, lastError
end

local PlatformOrder = {
	"Lucide",
	"Gravity",
	"Solar",
	"SFSymbols"
}

local CurrentIcons = {}
local IconObjects = {}

local IconFinder = Instance.new("ScreenGui")
IconFinder.Parent = game:GetService("CoreGui")
IconFinder.ScreenInsets = Enum.ScreenInsets.None
IconFinder.DisplayOrder = 100000000
IconFinder.Name = "IconFinder"
IconFinder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TopBarHolder = Instance.new("Frame")
TopBarHolder.Parent = IconFinder
TopBarHolder.Visible = false
TopBarHolder.BorderSizePixel = 0
TopBarHolder.BackgroundColor3 = Color3.fromRGB(0,0,0)
TopBarHolder.AnchorPoint = Vector2.new(1,0)
TopBarHolder.Size = UDim2.new(0.797,0,0,38)
TopBarHolder.Position = UDim2.new(1,0,0,15)
TopBarHolder.Name = "TopBarHolder"
TopBarHolder.BackgroundTransparency = 1

local OpenUI = Instance.new("TextButton")
OpenUI.Parent = TopBarHolder
OpenUI.BorderSizePixel = 0
OpenUI.BackgroundColor3 = Color3.fromRGB(21,21,21)
OpenUI.AnchorPoint = Vector2.new(0,0.5)
OpenUI.BackgroundTransparency = 0.1
OpenUI.Size = UDim2.new(0,135,0,38)
OpenUI.Text = ""
OpenUI.Name = "OpenUI"
OpenUI.Position = UDim2.new(0,65,0.5,0)

local OIcon = Instance.new("ImageLabel")
OIcon.Parent = OpenUI
OIcon.BorderSizePixel = 0
OIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
OIcon.AnchorPoint = Vector2.new(0,0.5)
OIcon.Image = "rbxassetid://129989433311409"
OIcon.Size = UDim2.new(0,22,0,22)
OIcon.BackgroundTransparency = 1
OIcon.Name = "OIcon"
OIcon.Position = UDim2.new(0,12,0.5,-1)

local OpenCorner = Instance.new("UICorner")
OpenCorner.Parent = OpenUI
OpenCorner.CornerRadius = UDim.new(1,0)

local Title2 = Instance.new("TextLabel")
Title2.Parent = OpenUI
Title2.TextWrapped = true
Title2.BorderSizePixel = 0
Title2.TextScaled = true
Title2.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
Title2.TextColor3 = Color3.fromRGB(226,226,226)
Title2.BackgroundTransparency = 1
Title2.AnchorPoint = Vector2.new(1,0.5)
Title2.Size = UDim2.new(0,80,0,28)
Title2.Text = "Icon Finder"
Title2.Name = "Title2"
Title2.Position = UDim2.new(1,-14,0.5,0)

local MainUI = Instance.new("Frame")
MainUI.Parent = IconFinder
MainUI.BorderSizePixel = 0
MainUI.BackgroundColor3 = Color3.fromRGB(21,21,21)
MainUI.AnchorPoint = Vector2.new(0.5,0.5)
MainUI.Size = UDim2.new(1.112, 0, 1.11, 0)
MainUI.Position = UDim2.new(0.5,0,0.5,0)
MainUI.Name = "MainUI"
MainUI.BackgroundTransparency = 0.03
MainUI.ClipsDescendants = true

local UiScale = Instance.new("UIScale")
UiScale.Scale = 0.90
UiScale.Parent = MainUI

local SearchBar = Instance.new("Frame")
SearchBar.Parent = MainUI
SearchBar.ZIndex = 2
SearchBar.BorderSizePixel = 0
SearchBar.BackgroundColor3 = Color3.fromRGB(31,31,31)
SearchBar.AnchorPoint = Vector2.new(0.5,1)
SearchBar.Size = UDim2.new(0.45,0,0.08,0)
SearchBar.Position = UDim2.new(0.5,0,1,-14)
SearchBar.Name = "SearchBar"
SearchBar.BackgroundTransparency = 0.05

local UIStroke7 = Instance.new("UIStroke")
UIStroke7.Parent = SearchBar
UIStroke7.Transparency = 0.93
UIStroke7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke7.Color = Color3.fromRGB(255,255,255)

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchBar
SearchBox.Name = "SearchBox"
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.BorderSizePixel = 0
SearchBox.TextWrapped = true
SearchBox.TextSize = 14
SearchBox.TextColor3 = Color3.fromRGB(246,246,246)
SearchBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
SearchBox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
SearchBox.AnchorPoint = Vector2.new(1,0.5)
SearchBox.PlaceholderText = "Search Icon..."
SearchBox.Size = UDim2.new(0.9,0,0.66,0)
SearchBox.Position = UDim2.new(1,-12,0.5,0)
SearchBox.Text = ""
SearchBox.BackgroundTransparency = 1

local SbarCorner = Instance.new("UICorner")
SbarCorner.Parent = SearchBar
SbarCorner.CornerRadius = UDim.new(1,0)

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Parent = SearchBar
SearchIcon.BorderSizePixel = 0
SearchIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
SearchIcon.ImageColor3 = Color3.fromRGB(241,241,241)
SearchIcon.AnchorPoint = Vector2.new(0,0.5)
SearchIcon.Image = "rbxassetid://121018724060431"
SearchIcon.Size = UDim2.new(0,16,0,16)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Name = "SearchIcon"
SearchIcon.Position = UDim2.new(0,9,0.5,0)

local MUICorner = Instance.new("UICorner")
MUICorner.Parent = MainUI
MUICorner.CornerRadius = UDim.new(0,25)

local PViewFrame = Instance.new("Frame")
PViewFrame.Parent = MainUI
PViewFrame.Visible = false
PViewFrame.BorderSizePixel = 0
PViewFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
PViewFrame.AnchorPoint = Vector2.new(0.5,0.5)
PViewFrame.Size = UDim2.new(0.34,0,0.45,0)
PViewFrame.Position = UDim2.new(0.5,0,0.5,0)
PViewFrame.Name = "PViewFrame"
PViewFrame.BackgroundTransparency = 0.01
PViewFrame.ZIndex = 5

local PViewStroke = Instance.new("UIStroke")
PViewStroke.Parent = PViewFrame
PViewStroke.Transparency = 0.93
PViewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
PViewStroke.Color = Color3.fromRGB(255,255,255)

local IconName = Instance.new("TextLabel")
IconName.Parent = PViewFrame
IconName.TextWrapped = true
IconName.BorderSizePixel = 0
IconName.TextScaled = true
IconName.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
IconName.TextColor3 = Color3.fromRGB(226,226,226)
IconName.BackgroundTransparency = 1
IconName.AnchorPoint = Vector2.new(0.5,0)
IconName.Size = UDim2.new(0,264,0,22)
IconName.Text = "Name"
IconName.Name = "IconName"
IconName.Position = UDim2.new(0.5,0,0,83)

local PViewCorner = Instance.new("UICorner")
PViewCorner.Parent = PViewFrame
PViewCorner.CornerRadius = UDim.new(0,20)

local ClosePView = Instance.new("ImageButton")
ClosePView.Parent = PViewFrame
ClosePView.BorderSizePixel = 0
ClosePView.BackgroundTransparency = 1
ClosePView.BackgroundColor3 = Color3.fromRGB(255,255,255)
ClosePView.AnchorPoint = Vector2.new(1,0)
ClosePView.Image = "rbxassetid://118026365011536"
ClosePView.Size = UDim2.new(0,21,0,22)
ClosePView.Name = "ClosePView"
ClosePView.Position = UDim2.new(1,-11,0,6)

local CopyID = Instance.new("TextButton")
CopyID.Parent = PViewFrame
CopyID.BorderSizePixel = 0
CopyID.BackgroundColor3 = Color3.fromRGB(46,46,46)
CopyID.AnchorPoint = Vector2.new(0,1)
CopyID.BackgroundTransparency = 0.45
CopyID.Size = UDim2.new(0,124,0,40)
CopyID.Text = ""
CopyID.Name = "CopyID"
CopyID.Position = UDim2.new(0,12,1,-16)

local CopyIDCorner = Instance.new("UICorner")
CopyIDCorner.Parent = CopyID
CopyIDCorner.CornerRadius = UDim.new(0,15)

local CPIcon = Instance.new("ImageLabel")
CPIcon.Parent = CopyID
CPIcon.BorderSizePixel = 0
CPIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
CPIcon.AnchorPoint = Vector2.new(0.5,0.5)
CPIcon.Image = "rbxassetid://78979572434545"
CPIcon.Size = UDim2.new(0,22,0,22)
CPIcon.BackgroundTransparency = 1
CPIcon.Name = "CPIcon"
CPIcon.Position = UDim2.new(0.5,0,0.5,0)

local CopyIDUIStroke = Instance.new("UIStroke")
CopyIDUIStroke.Parent = CopyID
CopyIDUIStroke.Transparency = 0.93
CopyIDUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CopyIDUIStroke.Color = Color3.fromRGB(255,255,255)

local PreviewIcon = Instance.new("ImageLabel")
PreviewIcon.Parent = PViewFrame
PreviewIcon.BorderSizePixel = 0
PreviewIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
PreviewIcon.AnchorPoint = Vector2.new(0.5,0)
PreviewIcon.Image = ""
PreviewIcon.Size = UDim2.new(0,55,0,55)
PreviewIcon.BackgroundTransparency = 1
PreviewIcon.Name = "PreviewIcon"
PreviewIcon.Position = UDim2.new(0.5,-1,0,17)

local CopyName = Instance.new("TextButton")
CopyName.Parent = PViewFrame
CopyName.BorderSizePixel = 0
CopyName.BackgroundColor3 = Color3.fromRGB(46,46,46)
CopyName.AnchorPoint = Vector2.new(1,1)
CopyName.BackgroundTransparency = 0.45
CopyName.Size = UDim2.new(0,124,0,40)
CopyName.Text = ""
CopyName.Name = "CopyName"
CopyName.Position = UDim2.new(1,-12,1,-16)

local CopyNCorner = Instance.new("UICorner")
CopyNCorner.Parent = CopyName
CopyNCorner.CornerRadius = UDim.new(0,15)

local CNIcon = Instance.new("ImageLabel")
CNIcon.Parent = CopyName
CNIcon.BorderSizePixel = 0
CNIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
CNIcon.AnchorPoint = Vector2.new(0.5,0.5)
CNIcon.Image = "rbxassetid://111491496660216"
CNIcon.Size = UDim2.new(0,23,0,23)
CNIcon.BackgroundTransparency = 1
CNIcon.Name = "CNIcon"
CNIcon.Position = UDim2.new(0.5,0,0.5,0)

local CopyNameStroke9 = Instance.new("UIStroke")
CopyNameStroke9.Parent = CopyName
CopyNameStroke9.Transparency = 0.93
CopyNameStroke9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CopyNameStroke9.Color = Color3.fromRGB(255,255,255)

local TopBarUI = Instance.new("Frame")
TopBarUI.Parent = MainUI
TopBarUI.BorderSizePixel = 0
TopBarUI.BackgroundColor3 = Color3.fromRGB(255,255,255)
TopBarUI.AnchorPoint = Vector2.new(0.5,0)
TopBarUI.Size = UDim2.new(0.99,0,0.088,0)
TopBarUI.Position = UDim2.new(0.5,0,0,4)
TopBarUI.Name = "TopBarUI"
TopBarUI.BackgroundTransparency = 1

local Divider = Instance.new("Frame")
Divider.Parent = TopBarUI
Divider.BorderSizePixel = 0
Divider.BackgroundColor3 = Color3.fromRGB(255,255,255)
Divider.AnchorPoint = Vector2.new(1,0.5)
Divider.Size = UDim2.new(0,2,0,20)
Divider.Position = UDim2.new(1,-45,0.5,0)
Divider.Name = "Divider"
Divider.BackgroundTransparency = 0.9

local IconsCount = Instance.new("Frame")
IconsCount.Parent = TopBarUI
IconsCount.BorderSizePixel = 0
IconsCount.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconsCount.AnchorPoint = Vector2.new(1,0.5)
IconsCount.Size = UDim2.new(0,105,0,28)
IconsCount.Position = UDim2.new(1,-135,0.5,0)
IconsCount.Name = "IconsCount"
IconsCount.BackgroundTransparency = 0.9

local IcountCorner = Instance.new("UICorner")
IcountCorner.Parent = IconsCount
IcountCorner.CornerRadius = UDim.new(0,10)

local Icon = Instance.new("ImageLabel")
Icon.Parent = IconsCount
Icon.BorderSizePixel = 0
Icon.BackgroundColor3 = Color3.fromRGB(255,255,255)
Icon.AnchorPoint = Vector2.new(1,0.5)
Icon.Image = "rbxassetid://129989433311409"
Icon.Size = UDim2.new(0,19,0,19)
Icon.BackgroundTransparency = 1
Icon.Name = "Icon"
Icon.Position = UDim2.new(1,-5,0.5,0)

local CountLabel = Instance.new("TextLabel")
CountLabel.Parent = IconsCount
CountLabel.TextWrapped = true
CountLabel.BorderSizePixel = 0
CountLabel.TextSize = 20
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
CountLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
CountLabel.TextColor3 = Color3.fromRGB(215,215,215)
CountLabel.BackgroundTransparency = 1
CountLabel.AnchorPoint = Vector2.new(1,0.5)
CountLabel.Size = UDim2.new(0,69,0,19)
CountLabel.Text = "0"
CountLabel.Name = "CountLabel"
CountLabel.Position = UDim2.new(1,-29,0.5,0)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = TopBarUI
RefreshBtn.BorderSizePixel = 0
RefreshBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
RefreshBtn.AnchorPoint = Vector2.new(1,0.5)
RefreshBtn.BackgroundTransparency = 1
RefreshBtn.Size = UDim2.new(0,32,0,28)
RefreshBtn.Text = ""
RefreshBtn.Name = "RefreshBtn"
RefreshBtn.Position = UDim2.new(1,-91,0.5,0)

local RIcon = Instance.new("ImageLabel")
RIcon.Parent = RefreshBtn
RIcon.BorderSizePixel = 0
RIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
RIcon.AnchorPoint = Vector2.new(0.5,0.5)
RIcon.Image = "rbxassetid://138133190015277"
RIcon.Size = UDim2.new(0,21,0,21)
RIcon.BackgroundTransparency = 1
RIcon.Name = "RIcon"
RIcon.Position = UDim2.new(0.5,0,0.5,0)

local CloseUI = Instance.new("TextButton")
CloseUI.Parent = TopBarUI
CloseUI.BorderSizePixel = 0
CloseUI.BackgroundColor3 = Color3.fromRGB(255,255,255)
CloseUI.AnchorPoint = Vector2.new(1,0.5)
CloseUI.BackgroundTransparency = 1
CloseUI.Size = UDim2.new(0,32,0,28)
CloseUI.Text = ""
CloseUI.Name = "CloseUI"
CloseUI.Position = UDim2.new(1,-52,0.5,0)

local CIcon = Instance.new("ImageLabel")
CIcon.Parent = CloseUI
CIcon.BorderSizePixel = 0
CIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
CIcon.AnchorPoint = Vector2.new(0.5,0.5)
CIcon.Image = "rbxassetid://116269596042539"
CIcon.Size = UDim2.new(0,21,0,21)
CIcon.BackgroundTransparency = 1
CIcon.Name = "CIcon"
CIcon.Position = UDim2.new(0.5,0,0.5,0)

local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Parent = TopBarUI
DestroyBtn.BorderSizePixel = 0
DestroyBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
DestroyBtn.AnchorPoint = Vector2.new(1,0.5)
DestroyBtn.BackgroundTransparency = 1
DestroyBtn.Size = UDim2.new(0,32,0,28)
DestroyBtn.Text = ""
DestroyBtn.Name = "DestroyBtn"
DestroyBtn.Position = UDim2.new(1,-8,0.5,0)

local DIcon = Instance.new("ImageLabel")
DIcon.Parent = DestroyBtn
DIcon.BorderSizePixel = 0
DIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
DIcon.AnchorPoint = Vector2.new(0.5,0.5)
DIcon.Image = "rbxassetid://110786993356448"
DIcon.Size = UDim2.new(0,21,0,21)
DIcon.BackgroundTransparency = 1
DIcon.Name = "DIcon"
DIcon.Position = UDim2.new(0.5,0,0.5,0)

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Parent = TopBarUI
SettingsBtn.BorderSizePixel = 0
SettingsBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
SettingsBtn.AnchorPoint = Vector2.new(1,0.5)
SettingsBtn.BackgroundTransparency = 0.9
SettingsBtn.Size = UDim2.new(0,47,0,28)
SettingsBtn.Text = ""
SettingsBtn.Name = "SettingsBtn"
SettingsBtn.Position = UDim2.new(1,-360,0.5,0)

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.Parent = SettingsBtn
SettingsCorner.CornerRadius = UDim.new(0,10)

local SIcon = Instance.new("ImageLabel")
SIcon.Parent = SettingsBtn
SIcon.BorderSizePixel = 0
SIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
SIcon.AnchorPoint = Vector2.new(0.5,0.5)
SIcon.Image = "rbxassetid://140704441124047"
SIcon.Size = UDim2.new(0,18,0,18)
SIcon.BackgroundTransparency = 1
SIcon.Name = "SIcon"
SIcon.Position = UDim2.new(0.5,0,0.5,0)

local SettingsMenu = Instance.new("ScrollingFrame")
SettingsMenu.Parent = SettingsBtn
SettingsMenu.Visible = false
SettingsMenu.BorderSizePixel = 0
SettingsMenu.BackgroundColor3 = Color3.fromRGB(36,36,36)
SettingsMenu.AnchorPoint = Vector2.new(0.5,1)
SettingsMenu.Size = UDim2.new(0,150,0,0)
SettingsMenu.Position = UDim2.new(0.5,0,1,0)
SettingsMenu.Name = "SettingsMenu"
SettingsMenu.ZIndex = 20
SettingsMenu.ScrollBarThickness = 1.8
SettingsMenu.ScrollBarImageColor3 = Color3.fromRGB(205,205,205)
SettingsMenu.ScrollingDirection = Enum.ScrollingDirection.Y
SettingsMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsMenu.CanvasSize = UDim2.new(0,0,0,0)
SettingsMenu.ClipsDescendants = true

local SettingsMenuCorner = Instance.new("UICorner")
SettingsMenuCorner.Parent = SettingsMenu
SettingsMenuCorner.CornerRadius = UDim.new(0,14)

local SettingsMenuLayout = Instance.new("UIListLayout")
SettingsMenuLayout.Parent = SettingsMenu
SettingsMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsMenuLayout.Padding = UDim.new(0, 3)
SettingsMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SettingsMenuPadding = Instance.new("UIPadding")
SettingsMenuPadding.Parent = SettingsMenu
SettingsMenuPadding.PaddingTop = UDim.new(0, 6)
SettingsMenuPadding.PaddingBottom = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Parent = TopBarUI
Title.TextWrapped = true
Title.BorderSizePixel = 0
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
Title.TextColor3 = Color3.fromRGB(246,246,246)
Title.BackgroundTransparency = 1
Title.AnchorPoint = Vector2.new(0,0.5)
Title.Size = UDim2.new(0.2,0,0.65,0)
Title.Text = "Icons Finder"
Title.Name = "Title"
Title.Position = UDim2.new(0,14,0.5,0)

local TbCorner = Instance.new("UICorner")
TbCorner.Parent = TopBarUI
TbCorner.CornerRadius = UDim.new(0,25)

local IconPicker = Instance.new("TextButton")
IconPicker.Parent = TopBarUI
IconPicker.BorderSizePixel = 0
IconPicker.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconPicker.AnchorPoint = Vector2.new(1,0.5)
IconPicker.BackgroundTransparency = 0.9
IconPicker.Size = UDim2.new(0,98,0,28)
IconPicker.Text = ""
IconPicker.Name = "IconPicker"
IconPicker.Position = UDim2.new(1,-250,0.5,0)

local IconPCorner = Instance.new("UICorner")
IconPCorner.Parent = IconPicker
IconPCorner.CornerRadius = UDim.new(0,10)

local ChevIcon = Instance.new("ImageLabel")
ChevIcon.Parent = IconPicker
ChevIcon.BorderSizePixel = 0
ChevIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
ChevIcon.ImageColor3 = Color3.fromRGB(246,246,246)
ChevIcon.AnchorPoint = Vector2.new(1,0.5)
ChevIcon.Image = "rbxassetid://131833120209646"
ChevIcon.Size = UDim2.new(0,19,0,19)
ChevIcon.BackgroundTransparency = 1
ChevIcon.Name = "ChevIcon"
ChevIcon.Position = UDim2.new(1,-4,0.5,0)

local PlatformName = Instance.new("TextLabel")
PlatformName.Parent = IconPicker
PlatformName.BorderSizePixel = 0
PlatformName.TextSize = 18
PlatformName.BackgroundColor3 = Color3.fromRGB(255,255,255)
PlatformName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
PlatformName.TextColor3 = Color3.fromRGB(236,236,236)
PlatformName.BackgroundTransparency = 1
PlatformName.AnchorPoint = Vector2.new(0,0.5)
PlatformName.Size = UDim2.new(0,64,0,18)
PlatformName.Text = "Lucide"
PlatformName.Name = "PlatformName"
PlatformName.Position = UDim2.new(0,5,0.5,0)

local Container = Instance.new("Frame")
Container.Parent = IconPicker
Container.Visible = false
Container.BorderSizePixel = 0
Container.BackgroundColor3 = Color3.fromRGB(36,36,36)
Container.AnchorPoint = Vector2.new(0.5,1)
Container.Size = UDim2.new(0,108,0,0)
Container.Position = UDim2.new(0.5,0,1,0)
Container.Name = "Container"
Container.ZIndex = 10

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.Parent = Container
ContainerCorner.CornerRadius = UDim.new(0,14)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPaddingContainer = Instance.new("UIPadding")
UIPaddingContainer.Parent = Container
UIPaddingContainer.PaddingTop = UDim.new(0, 4)
UIPaddingContainer.PaddingBottom = UDim.new(0, 4)

local SelectCheck = Instance.new("ImageLabel")
SelectCheck.Name = "SelectCheck"
SelectCheck.BackgroundTransparency = 1
SelectCheck.BorderSizePixel = 0
SelectCheck.AnchorPoint = Vector2.new(0.5, 0.5)
SelectCheck.Size = UDim2.new(0.96, 0, 0, 23)
SelectCheck.Position = UDim2.new(0.5, 0, 0.5, 0)
SelectCheck.Image = "rbxassetid://80742398186218"
SelectCheck.ImageColor3 = Color3.fromRGB(236, 236, 236)
SelectCheck.ImageTransparency = 0.8

local SUICorner = Instance.new("UICorner")
SUICorner.Parent = SelectCheck
SUICorner.CornerRadius = UDim.new(1, 0)

local IconList = Instance.new("ScrollingFrame")
IconList.Parent = MainUI
IconList.BorderSizePixel = 0
IconList.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
IconList.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconList.Name = "IconList"
IconList.AnchorPoint = Vector2.new(0.5,1)
IconList.Size = UDim2.new(0.99,0,0.873,0)
IconList.Position = UDim2.new(0.5,0,1,-6)
IconList.ZIndex = -5
IconList.ScrollBarThickness = 0
IconList.BackgroundTransparency = 1
IconList.AutomaticCanvasSize = Enum.AutomaticSize.Y
IconList.CanvasSize = UDim2.new(0, 0, 0, 0)

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	local containerWidth = TopBarHolder.AbsoluteSize.X
	local uiWidth = OpenUI.AbsoluteSize.X
	
	local newX = startPos.X.Offset + delta.X
	local minX = 0
	local maxX = containerWidth - uiWidth
	
	local clampedX = math.clamp(newX, minX, maxX)
	
	OpenUI.Position = UDim2.new(startPos.X.Scale, clampedX, OpenUI.Position.Y.Scale, OpenUI.Position.Y.Offset)
end

OpenUI.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = OpenUI.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

OpenUI.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

local IListCorner = Instance.new("UICorner")
IListCorner.Parent = IconList
IListCorner.CornerRadius = UDim.new(0,18)

local UIGrid = Instance.new("UIGridLayout")
UIGrid.Parent = IconList
UIGrid.CellPadding = UDim2.new(0, 11, 0, 11)
UIGrid.CellSize = UDim2.new(0, 60, 0, 60)
UIGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = IconList
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)

local AlphabetHandle = Instance.new("TextButton")
AlphabetHandle.Parent = MainUI
AlphabetHandle.Text = ""
AlphabetHandle.AutoButtonColor = false
AlphabetHandle.BorderSizePixel = 0
AlphabetHandle.BackgroundColor3 = Color3.fromRGB(31,31,31)
AlphabetHandle.BackgroundTransparency = 1
AlphabetHandle.AnchorPoint = Vector2.new(0,0.5)
AlphabetHandle.Size = UDim2.new(0,25,0,240)
AlphabetHandle.Position = UDim2.new(0,0,0.5,0)
AlphabetHandle.Name = "AlphabetHandle"
AlphabetHandle.ZIndex = 6

local AlphabetSidebar = Instance.new("Frame")
AlphabetSidebar.Parent = MainUI
AlphabetSidebar.BorderSizePixel = 0
AlphabetSidebar.BackgroundColor3 = Color3.fromRGB(30,30,30)
AlphabetSidebar.BackgroundTransparency = 0.01
AlphabetSidebar.AnchorPoint = Vector2.new(0,0.5)
AlphabetSidebar.Size = UDim2.new(0,150,0.873,0)
AlphabetSidebar.Position = UDim2.new(0,-165,0.5,0)
AlphabetSidebar.Name = "AlphabetSidebar"
AlphabetSidebar.ZIndex = 8
AlphabetSidebar.ClipsDescendants = false

local ASideStroke = Instance.new("UIStroke")
ASideStroke.Parent = AlphabetSidebar
ASideStroke.Transparency = 0.93
ASideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ASideStroke.Color = Color3.fromRGB(255,255,255)

local AlphabetSidebarCorner = Instance.new("UICorner")
AlphabetSidebarCorner.Parent = AlphabetSidebar
AlphabetSidebarCorner.CornerRadius = UDim.new(0,16)

local CloseSidebarBtn = Instance.new("ImageButton")
CloseSidebarBtn.Parent = AlphabetSidebar
CloseSidebarBtn.BorderSizePixel = 0
CloseSidebarBtn.BackgroundTransparency = 1
CloseSidebarBtn.AnchorPoint = Vector2.new(1,0.5)
CloseSidebarBtn.Position = UDim2.new(1,27,0.5,0)
CloseSidebarBtn.Size = UDim2.new(0,20,0,26)
CloseSidebarBtn.Image = "rbxassetid://73780377692148"
CloseSidebarBtn.ImageColor3 = Color3.fromRGB(220,220,220)
CloseSidebarBtn.Name = "CloseSidebarBtn"
CloseSidebarBtn.ZIndex = 10

local CloseSidebarCorner = Instance.new("UICorner")
CloseSidebarCorner.Parent = CloseSidebarBtn
CloseSidebarCorner.CornerRadius = UDim.new(0,8)

local AllRowBtn = Instance.new("TextButton")
AllRowBtn.Parent = AlphabetSidebar
AllRowBtn.BorderSizePixel = 0
AllRowBtn.BackgroundTransparency = 1
AllRowBtn.Text = ""
AllRowBtn.AnchorPoint = Vector2.new(0,0)
AllRowBtn.Position = UDim2.new(0,10,0,10)
AllRowBtn.Size = UDim2.new(1,-20,0,24)
AllRowBtn.Name = "AllRowBtn"
AllRowBtn.ZIndex = 9

local AllRowLabel = Instance.new("TextLabel")
AllRowLabel.Parent = AllRowBtn
AllRowLabel.BackgroundTransparency = 1
AllRowLabel.Size = UDim2.new(1,0,1,0)
AllRowLabel.TextXAlignment = Enum.TextXAlignment.Left
AllRowLabel.Text = "All"
AllRowLabel.TextColor3 = Color3.fromRGB(255,255,255)
AllRowLabel.TextSize = 16
AllRowLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
AllRowLabel.Name = "AllRowLabel"
AllRowLabel.ZIndex = 9

local AllRowQuantity = Instance.new("TextLabel")
AllRowQuantity.Parent = AllRowBtn
AllRowQuantity.BackgroundTransparency = 1
AllRowQuantity.Size = UDim2.new(1,0,1,0)
AllRowQuantity.TextXAlignment = Enum.TextXAlignment.Right
AllRowQuantity.Text = "0"
AllRowQuantity.TextColor3 = Color3.fromRGB(170,170,170)
AllRowQuantity.TextSize = 14
AllRowQuantity.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
AllRowQuantity.Name = "AllRowQuantity"
AllRowQuantity.ZIndex = 9

local AlphabetHeader = Instance.new("TextLabel")
AlphabetHeader.Parent = AlphabetSidebar
AlphabetHeader.BackgroundTransparency = 1
AlphabetHeader.Position = UDim2.new(0,10,0,40)
AlphabetHeader.Size = UDim2.new(1,-20,0,18)
AlphabetHeader.Text = "Alphabetical"
AlphabetHeader.TextXAlignment = Enum.TextXAlignment.Left
AlphabetHeader.TextColor3 = Color3.fromRGB(160,160,160)
AlphabetHeader.TextSize = 13
AlphabetHeader.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
AlphabetHeader.Name = "AlphabetHeader"
AlphabetHeader.ZIndex = 9

local AlphabetList = Instance.new("ScrollingFrame")
AlphabetList.Parent = AlphabetSidebar
AlphabetList.BorderSizePixel = 0
AlphabetList.BackgroundTransparency = 1
AlphabetList.Position = UDim2.new(0,10,0,64)
AlphabetList.Size = UDim2.new(1,-20,1,-74)
AlphabetList.ScrollBarThickness = 3
AlphabetList.ScrollBarImageColor3 = Color3.fromRGB(200,200,200)
AlphabetList.CanvasSize = UDim2.new(0,0,0,0)
AlphabetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
AlphabetList.Name = "AlphabetList"
AlphabetList.ZIndex = 9

local AlphabetListLayout = Instance.new("UIListLayout")
AlphabetListLayout.Parent = AlphabetList
AlphabetListLayout.SortOrder = Enum.SortOrder.LayoutOrder
AlphabetListLayout.Padding = UDim.new(0,2)

local function ProcessFiltersAndSort()
	local query = SearchBox.Text:lower():gsub("%s+", "")
	local visibleIcons = {}

	for _, item in ipairs(CurrentIcons) do
		local iconName = item.Name:lower():gsub("%s+", "")
		local matchesSearch = (query == "") or (iconName:find(query, 1, true) ~= nil)
		local matchesFilter = false

		if CurrentFilters["All"] then
			matchesFilter = true
		else
			if CurrentFilters["Fill/Bold"] and (iconName:find("fill", 1, true) ~= nil or iconName:find("bold", 1, true) ~= nil) then
				matchesFilter = true
			end
			if CurrentFilters["Square"] and iconName:find("square", 1, true) ~= nil then
				matchesFilter = true
			end
			if CurrentFilters["Circle"] and iconName:find("circle", 1, true) ~= nil then
				matchesFilter = true
			end
			if CurrentFilters["Triangle"] and iconName:find("triangle", 1, true) ~= nil then
				matchesFilter = true
			end
		end

		local matchesAlpha = true
		if CurrentAlphabetFilter then
			local firstChar = string.sub(iconName, 1, 1):upper()
			matchesAlpha = (firstChar == CurrentAlphabetFilter)
		end

		if matchesSearch and matchesFilter and matchesAlpha then
			item.Obj.Visible = true
			table.insert(visibleIcons, item)
		else
			item.Obj.Visible = false
		end
	end

	if CurrentSort == "Z-A" then
		table.sort(visibleIcons, function(a, b) return a.Name > b.Name end)
	else
		table.sort(visibleIcons, function(a, b) return a.Name < b.Name end)
	end

	for i, item in ipairs(visibleIcons) do
		item.Obj.LayoutOrder = i
	end
end

local function ToggleFilter(name)
	if name == "All" then
		CurrentFilters = {All = true}
	else
		if CurrentFilters["All"] then
			CurrentFilters = {}
		end

		if CurrentFilters[name] then
			CurrentFilters[name] = nil
		else
			CurrentFilters[name] = true
		end

		local any = false
		for _ in pairs(CurrentFilters) do
			any = true
			break
		end

		if not any then
			CurrentFilters = {All = true}
		end
	end
end

local function SetSort(mode)
	CurrentSort = mode
end

local function SetCopyMode(mode)
	CurrentCopyMode = mode
end

local function ToggleCopyOnPress()
	CopyOnPress = not CopyOnPress
end

local function FormatClipboardOutput(id, name)
	local pureId = tostring(id):match("%d+$") or tostring(id)
	if CurrentCopyMode == "ID" then
		return pureId
	elseif CurrentCopyMode == "rbxassetid://ID" then
		return "rbxassetid://" .. pureId
	end
	return pureId
end

local function GetLetterCounts()
	local counts = {}
	for i = 65, 90 do
		counts[string.char(i)] = 0
	end
	local totalCount = 0
	for _, item in ipairs(CurrentIcons) do
		local iconName = item.Name
		local matchesFilter = false
		if CurrentFilters["All"] then
			matchesFilter = true
		else
			if CurrentFilters["Fill/Bold"] and (iconName:find("fill", 1, true) ~= nil or iconName:find("bold", 1, true) ~= nil) then
				matchesFilter = true
			end
			if CurrentFilters["Square"] and iconName:find("square", 1, true) ~= nil then
				matchesFilter = true
			end
			if CurrentFilters["Circle"] and iconName:find("circle", 1, true) ~= nil then
				matchesFilter = true
			end
			if CurrentFilters["Triangle"] and iconName:find("triangle", 1, true) ~= nil then
				matchesFilter = true
			end
		end

		if matchesFilter then
			totalCount = totalCount + 1
			local firstChar = string.sub(iconName, 1, 1):upper()
			if counts[firstChar] ~= nil then
				counts[firstChar] = counts[firstChar] + 1
			end
		end
	end
	return counts, totalCount
end

local function BuildAlphabetSidebar()
	for _, child in ipairs(AlphabetList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local counts, totalCount = GetLetterCounts()

	AllRowQuantity.Text = tostring(totalCount)
	AllRowLabel.TextColor3 = (CurrentAlphabetFilter == nil) and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,190,190)

	for i = 65, 90 do
		local letter = string.char(i)
		local row = Instance.new("TextButton")
		row.BorderSizePixel = 0
		row.BackgroundTransparency = 1
		row.Text = ""
		row.Size = UDim2.new(1, 0, 0, 24)
		row.LayoutOrder = i
		row.Name = letter .. "Row"
		row.Parent = AlphabetList

		local bar = Instance.new("Frame")
		bar.Parent = row
		bar.BorderSizePixel = 0
		bar.AnchorPoint = Vector2.new(0, 0.5)
		bar.Position = UDim2.new(0, 0, 0.5, 0)
		bar.Size = UDim2.new(0, 2, 0, 16)
		bar.BackgroundColor3 = (CurrentAlphabetFilter == letter) and Color3.fromRGB(255,255,255) or Color3.fromRGB(85,85,85)
		bar.Name = "Bar"

        local BarCorner = Instance.new("UICorner")
        BarCorner.Parent = bar
        BarCorner.CornerRadius = UDim.new(1,0)

		local letterLabel = Instance.new("TextLabel")
		letterLabel.Parent = row
		letterLabel.BackgroundTransparency = 1
		letterLabel.Position = UDim2.new(0, 10, 0, 0)
		letterLabel.Size = UDim2.new(0.5, 0, 1, 0)
		letterLabel.TextXAlignment = Enum.TextXAlignment.Left
		letterLabel.Text = letter
		letterLabel.TextSize = 15
		letterLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", (CurrentAlphabetFilter == letter) and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		letterLabel.TextColor3 = (CurrentAlphabetFilter == letter) and Color3.fromRGB(255,255,255) or Color3.fromRGB(210,210,210)
		letterLabel.Name = "LetterLabel"

		local quantityLabel = Instance.new("TextLabel")
		quantityLabel.Parent = row
		quantityLabel.BackgroundTransparency = 1
		quantityLabel.Position = UDim2.new(0.5, 0, 0, 0)
		quantityLabel.Size = UDim2.new(0.5, -6, 1, 0)
		quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
		quantityLabel.Text = tostring(counts[letter])
		quantityLabel.TextSize = 13
		quantityLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		quantityLabel.TextColor3 = Color3.fromRGB(160,160,160)
		quantityLabel.Name = "QuantityLabel"

		row.MouseButton1Click:Connect(function()
			if CurrentAlphabetFilter == letter then
				CurrentAlphabetFilter = nil
			else
				CurrentAlphabetFilter = letter
			end
			ProcessFiltersAndSort()
			BuildAlphabetSidebar()
		end)
	end
end

local function SelectAlphabet(letter)
	if letter == nil then
		CurrentAlphabetFilter = nil
	elseif CurrentAlphabetFilter == letter then
		CurrentAlphabetFilter = nil
	else
		CurrentAlphabetFilter = letter
	end
	ProcessFiltersAndSort()
	BuildAlphabetSidebar()
end

local sidebarOpen = false

local function OpenAlphabetSidebar()
	if sidebarOpen then return end
	sidebarOpen = true
	AlphabetHandle.Visible = false
	local tween = TweenService:Create(AlphabetSidebar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,12,0.5,0)})
	tween:Play()
end

local function CloseAlphabetSidebar()
	if not sidebarOpen then return end
	sidebarOpen = false
	local tween = TweenService:Create(AlphabetSidebar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0,-160,0.5,0)})
	tween:Play()
	AlphabetHandle.Visible = true
end

CloseSidebarBtn.MouseButton1Click:Connect(function()
	CloseAlphabetSidebar()
end)

AllRowBtn.MouseButton1Click:Connect(function()
	SelectAlphabet(nil)
end)

local alphaDragging = false
local alphaDragStartX = 0

AlphabetHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		alphaDragging = true
		alphaDragStartX = input.Position.X
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if alphaDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local deltaX = input.Position.X - alphaDragStartX
		if deltaX > 30 then
			alphaDragging = false
			OpenAlphabetSidebar()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		alphaDragging = false
	end
end)

local function HandleIconClick(data, btn, Holder)
	local idStr = (string.find(tostring(data.ID), "rbxassetid://") and tostring(data.ID)) or "rbxassetid://" .. tostring(data.ID)

	if CopyOnPress then
		setclipboard(FormatClipboardOutput(data.ID, data.Name))
		return
	end

	if MultiSelectMode then
		if SelectedIcons[data.ID] then
			SelectedIcons[data.ID] = nil
			Holder.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		else
			SelectedIcons[data.ID] = {Name = data.Name, ID = data.ID, Image = idStr}
			Holder.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
		end
	else
		PreviewIcon.Image = idStr
		IconName.Text = data.Name
		PViewFrame.Visible = true
	end
end

local function LoadIcons(platform)
	for _, obj in pairs(IconObjects) do obj:Destroy() end
	IconObjects = {}
	CurrentIcons = {}
	SelectedIcons = {}
	CurrentAlphabetFilter = nil
	CountLabel.Text = "Loading..."
	PlatformName.Text = platform

	task.spawn(function()
		local success, result

		if IconCache[platform] then
			success, result = true, IconCache[platform]
		else
			local ok, rawData = HttpGetWithRetry(PlatformURLs[platform])

			if ok then
				success, result = pcall(function()
					local func = loadstring(rawData)
					if not func then error("Syntax Error in Raw Data") end
					return func()
				end)

				if success and type(result) == "table" then
					IconCache[platform] = result
				end
			else
				success, result = false, rawData
			end
		end

		if success and type(result) == "table" then
			local sorted = {}
			for name, id in pairs(result) do
				table.insert(sorted, {Name = name, ID = id})
			end
			table.sort(sorted, function(a, b) return a.Name:lower() < b.Name:lower() end)

			for i, data in ipairs(sorted) do
				local Holder = Instance.new("TextButton")
				Holder.Text = ""
				Holder.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
				Holder.Parent = IconList
				Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 12)

				local btn = Instance.new("ImageLabel")
				btn.BackgroundTransparency = 1
				btn.Image = (string.find(tostring(data.ID), "rbxassetid://") and tostring(data.ID)) or "rbxassetid://" .. tostring(data.ID)
				btn.Parent = Holder

				Holder.Size = UDim2.new(0, 60, 0, 60)
				btn.Size = UDim2.new(0, 40, 0, 40)
				btn.Position = UDim2.new(0.5, 0, 0.5, 0)
				btn.AnchorPoint = Vector2.new(0.5, 0.5)

				Holder.MouseButton1Click:Connect(function()
					HandleIconClick(data, btn, Holder)
				end)

				table.insert(IconObjects, Holder)
				table.insert(CurrentIcons, {Obj = Holder, Name = data.Name:lower(), ID = data.ID})
			end
			CountLabel.Text = tostring(#sorted)
			ProcessFiltersAndSort()
		else
			CountLabel.Text = "HTTP Err"
		end

		BuildAlphabetSidebar()
	end)
end

local function SetPlatform(name, btn)
	SelectCheck.Parent = btn
	Container.Visible = false
	LoadIcons(name)
end

local function BuildPlatformMenu()
	for _, child in ipairs(Container:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local validCount = 0
	for orderIndex, platformName in ipairs(PlatformOrder) do
		if PlatformURLs[platformName] then
			validCount = validCount + 1
			local PlatformBtn = Instance.new("TextButton")
			PlatformBtn.Parent = Container
			PlatformBtn.BorderSizePixel = 0
			PlatformBtn.TextSize = 18
			PlatformBtn.TextColor3 = Color3.fromRGB(231,231,231)
			PlatformBtn.BackgroundColor3 = Color3.fromRGB(51,51,51)
			PlatformBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
			PlatformBtn.BackgroundTransparency = 1
			PlatformBtn.Size = UDim2.new(0,103,0,26)
			PlatformBtn.Text = platformName
			PlatformBtn.Name = platformName .. "Btn"
			PlatformBtn.LayoutOrder = orderIndex

			if PlatformName.Text == platformName then
				SelectCheck.Parent = PlatformBtn
			end

			PlatformBtn.MouseButton1Click:Connect(function()
				SetPlatform(platformName, PlatformBtn)
			end)
		end
	end

	local totalHeight = (validCount * 26) + ((validCount - 1) * 3) + 8
	Container.Size = UDim2.new(0, 108, 0, totalHeight)
	Container.Position = UDim2.new(0.5, 0, 1, totalHeight + 2)
end

local function BuildSettingsMenu()
	for _, child in ipairs(SettingsMenu:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local items = {
		{Type = "Label", Text = "Copy Mode", Icon = "rbxassetid://113618379616952"},
		{Type = "Button", Text = "ID", Action = function() SetCopyMode("ID") BuildSettingsMenu() end, Checked = (CurrentCopyMode == "ID")},
		{Type = "Button", Text = "rbxassetid://ID", Action = function() SetCopyMode("rbxassetid://ID") BuildSettingsMenu() end, Checked = (CurrentCopyMode == "rbxassetid://ID")},
		{Type = "Button", Text = "Copy on Press", Action = function() ToggleCopyOnPress() BuildSettingsMenu() end, Checked = CopyOnPress},
		{Type = "Divider"},
		{Type = "Label", Text = "Filter", Icon = "rbxassetid://96385120752336"},
		{Type = "Button", Text = "All", Action = function() ToggleFilter("All") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildSettingsMenu() end, Checked = (CurrentFilters["All"] == true)},
		{Type = "Button", Text = "Fill/Bold", Action = function() ToggleFilter("Fill/Bold") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildSettingsMenu() end, Checked = (CurrentFilters["Fill/Bold"] == true)},
		{Type = "Button", Text = "Square", Action = function() ToggleFilter("Square") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildSettingsMenu() end, Checked = (CurrentFilters["Square"] == true)},
		{Type = "Button", Text = "Circle", Action = function() ToggleFilter("Circle") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildSettingsMenu() end, Checked = (CurrentFilters["Circle"] == true)},
		{Type = "Button", Text = "Triangle", Action = function() ToggleFilter("Triangle") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildSettingsMenu() end, Checked = (CurrentFilters["Triangle"] == true)},
		{Type = "Divider"},
		{Type = "Label", Text = "Sort", Icon = "rbxassetid://85780258549577"},
		{Type = "Button", Text = "A-Z", Action = function() SetSort("A-Z") ProcessFiltersAndSort() BuildSettingsMenu() end, Checked = (CurrentSort == "A-Z")},
		{Type = "Button", Text = "Z-A", Action = function() SetSort("Z-A") ProcessFiltersAndSort() BuildSettingsMenu() end, Checked = (CurrentSort == "Z-A")}
	}

	local totalHeight = 12
	local layoutOrder = 1

	for _, item in ipairs(items) do
		if item.Type == "Label" then
			local container = Instance.new("Frame")
			container.Size = UDim2.new(0, 140, 0, 24)
			container.BackgroundTransparency = 1
			container.LayoutOrder = layoutOrder
			container.Parent = SettingsMenu

			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(0, 16, 0, 16)
			img.Position = UDim2.new(0, 6, 0.5, 0)
			img.AnchorPoint = Vector2.new(0, 0.5)
			img.BackgroundTransparency = 1
			img.Image = item.Icon
			img.ImageColor3 = Color3.fromRGB(200, 200, 200)
			img.Parent = container

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -28, 1, 0)
			lbl.Position = UDim2.new(0, 26, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = item.Text
			lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
			lbl.TextSize = 14
			lbl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = container

			totalHeight = totalHeight + 27
		elseif item.Type == "Button" then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 138, 0, 24)
			btn.BackgroundTransparency = 1
			btn.Text = "  " .. item.Text
			btn.TextColor3 = item.Checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 210)
			btn.TextSize = 14
			btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", item.Checked and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.LayoutOrder = layoutOrder
			btn.Parent = SettingsMenu

			local chk = Instance.new("ImageLabel")
			chk.Size = UDim2.new(1.03, 0, 0, 18)
			chk.Position = UDim2.new(0.5, 0, 0.5, 0)
			chk.AnchorPoint = Vector2.new(0.5, 0.5)
			chk.BackgroundTransparency = 1
			chk.ImageTransparency = 0.75
			chk.Image = "rbxassetid://80742398186218"
			chk.ImageColor3 = Color3.fromRGB(255, 255, 255)
			chk.Visible = item.Checked
			chk.Parent = btn

			local chkCorner = Instance.new("UICorner")
			chkCorner.CornerRadius = UDim.new(0, 5)
			chkCorner.Parent = chk

			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 6)
			itemCorner.Parent = btn

			btn.MouseButton1Click:Connect(item.Action)
			totalHeight = totalHeight + 27
		elseif item.Type == "Divider" then
			local div = Instance.new("Frame")
			div.Size = UDim2.new(0, 130, 0, 1)
			div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			div.BackgroundTransparency = 0.8
			div.BorderSizePixel = 0
			div.LayoutOrder = layoutOrder
			div.Parent = SettingsMenu
			totalHeight = totalHeight + 4
		end
		layoutOrder = layoutOrder + 1
	end

	local displayHeight = math.min(totalHeight, MAX_SETTINGS_HEIGHT)
	SettingsMenu.Size = UDim2.new(0, 150, 0, displayHeight)
	SettingsMenu.Position = UDim2.new(0.5, 0, 1, displayHeight + 2)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	ProcessFiltersAndSort()
end)

local isFocused = false

SearchBar.MouseEnter:Connect(function()
	if not isFocused then
		UIStroke7.Transparency = 0.15
	end
end)

SearchBar.MouseLeave:Connect(function()
	if not isFocused then
		UIStroke7.Transparency = 0.93
	end
end)

SearchBox.Focused:Connect(function()
	isFocused = true
	UIStroke7.Transparency = 0.15
end)

SearchBox.FocusLost:Connect(function()
	isFocused = false
	UIStroke7.Transparency = 0.93
end)

IconPicker.MouseButton1Click:Connect(function()
	Container.Visible = not Container.Visible
	SettingsMenu.Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	SettingsMenu.Visible = not SettingsMenu.Visible
	Container.Visible = false
end)

ClosePView.MouseButton1Click:Connect(function() PViewFrame.Visible = false end)

CopyID.MouseButton1Click:Connect(function()
	local id = PreviewIcon.Image:match("%d+$")
	if id then 
		setclipboard(FormatClipboardOutput(id, IconName.Text)) 
	end
end)

CopyName.MouseButton1Click:Connect(function()
	if IconName.Text ~= "" then setclipboard(IconName.Text) end
end)

CloseUI.MouseButton1Click:Connect(function()
	MainUI.Visible = false
	TopBarHolder.Visible = true
end)

OpenUI.MouseButton1Click:Connect(function()
	MainUI.Visible = true
	TopBarHolder.Visible = false
end)

DestroyBtn.MouseButton1Click:Connect(function() IconFinder:Destroy() end)

local refreshSpinning = false
RefreshBtn.MouseButton1Click:Connect(function()
	LoadIcons(PlatformName.Text)

	if refreshSpinning then return end
	refreshSpinning = true

	local targetRotation = RIcon.Rotation + 360
	local spinTween = TweenService:Create(
		RIcon,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Rotation = targetRotation}
	)

	spinTween.Completed:Connect(function()
		RIcon.Rotation = targetRotation % 360
		refreshSpinning = false
	end)

	spinTween:Play()
end)

BuildPlatformMenu()
BuildSettingsMenu()
BuildAlphabetSidebar()
LoadIcons("Lucide")