local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PlatformURLs = {
	["Lucide"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Lucide.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide.lua"
	},
	["Gravity"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Gravity.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Gravity.lua"
	},
	["Material"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Material.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Material.lua"
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

local DefaultCornerRadius = 25
local DefaultBgTransparency = 0.03
local DefaultIconButtonTransparency = 0
local DefaultIconGridSize = 60
local DefaultMainUIScaleX = 1.112
local DefaultMainUIOffsetX = 0
local DefaultMainUIScaleY = 1.11
local DefaultMainUIOffsetY = 0
local DefaultUIScale = 0.90
local DefaultHoverAnimations = true
local HoverAnimations = DefaultHoverAnimations
local SettingsFileName = "IconFinder_Settings.json"

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
	"Material",
	"Solar",
	"SFSymbols"
}

local CurrentIcons = {}
local currentLoadToken = 0

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
OpenUI.Size = UDim2.new(0,135,0,39)
OpenUI.Text = ""
OpenUI.Name = "OpenUI"
OpenUI.Position = UDim2.new(0,65,0.5,0)

local OIcon = Instance.new("ImageLabel")
OIcon.Parent = OpenUI
OIcon.BorderSizePixel = 0
OIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
OIcon.AnchorPoint = Vector2.new(0,0.5)
OIcon.Image = "rbxassetid://112877276144236"
OIcon.Size = UDim2.new(0,26,0,26)
OIcon.BackgroundTransparency = 1
OIcon.Name = "OIcon"
OIcon.Position = UDim2.new(0,12,0.5,-0.82)

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
Title2.Position = UDim2.new(1,-14,0.5,-1)

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
SearchBox.Size = UDim2.new(0.9,-16,0.66,0)
SearchBox.Position = UDim2.new(1,-28,0.5,0)
SearchBox.Text = ""
SearchBox.BackgroundTransparency = 1

local ClearBox = Instance.new("ImageButton")
ClearBox.Parent = SearchBar
ClearBox.Name = "ClearBox"
ClearBox.Visible = false
ClearBox.BorderSizePixel = 0
ClearBox.BackgroundTransparency = 1
ClearBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
ClearBox.ImageColor3 = Color3.fromRGB(210,210,210)
ClearBox.AnchorPoint = Vector2.new(1,0.5)
ClearBox.Image = "rbxassetid://102572546754562"
ClearBox.Size = UDim2.new(0,26,0,26)
ClearBox.Position = UDim2.new(1,-9,0.5,0)
ClearBox.ZIndex = 3

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

local PreviewIconScale = Instance.new("UIScale")
PreviewIconScale.Scale = 1
PreviewIconScale.Parent = PreviewIcon

local PreviewIconBaseRotation = 0
local PreviewIconBaseSize = PreviewIcon.Size
local PreviewMorphToken = 0

local PreviewMorphOut = TweenInfo.new(
	0.1,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.In
)

local PreviewMorphIn = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)

local PreviewMorphSettle = TweenInfo.new(
	0.18,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local function TweenPreviewIcon(object, tweenInfo, properties)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

local function MorphPreviewIcon(newImage)
	if not newImage or newImage == "" then
		PreviewIcon.Image = newImage or ""
		return
	end

	if PreviewIcon.Image == "" then
		PreviewIcon.Image = newImage
		PreviewIcon.ImageTransparency = 0
		PreviewIcon.Rotation = PreviewIconBaseRotation
		PreviewIcon.Size = PreviewIconBaseSize
		PreviewIconScale.Scale = 1
		return
	end

	if PreviewIcon.Image == newImage then
		return
	end

	PreviewMorphToken = PreviewMorphToken + 1
	local token = PreviewMorphToken

	TweenPreviewIcon(PreviewIcon, PreviewMorphOut, {
		ImageTransparency = 1,
		Rotation = PreviewIconBaseRotation - 16,
		Size = UDim2.new(
			PreviewIconBaseSize.X.Scale, math.floor(PreviewIconBaseSize.X.Offset * 0.8 + 0.5),
			PreviewIconBaseSize.Y.Scale, math.floor(PreviewIconBaseSize.Y.Offset * 0.18 + 0.5)
		)
	})

	TweenPreviewIcon(PreviewIconScale, PreviewMorphOut, {
		Scale = 0.9
	})

	task.delay(0.09, function()
		if token ~= PreviewMorphToken then
			return
		end

		PreviewIcon.Image = newImage
		PreviewIcon.ImageTransparency = 1
		PreviewIcon.Rotation = PreviewIconBaseRotation + 16
		PreviewIcon.Size = UDim2.new(
			PreviewIconBaseSize.X.Scale, math.floor(PreviewIconBaseSize.X.Offset * 0.8 + 0.5),
			PreviewIconBaseSize.Y.Scale, math.floor(PreviewIconBaseSize.Y.Offset * 0.18 + 0.5)
		)
		PreviewIconScale.Scale = 0.9

		TweenPreviewIcon(PreviewIcon, PreviewMorphIn, {
			ImageTransparency = 0,
			Rotation = PreviewIconBaseRotation,
			Size = UDim2.new(
				PreviewIconBaseSize.X.Scale, math.floor(PreviewIconBaseSize.X.Offset * 1.12 + 0.5),
				PreviewIconBaseSize.Y.Scale, math.floor(PreviewIconBaseSize.Y.Offset * 1.12 + 0.5)
			)
		})

		TweenPreviewIcon(PreviewIconScale, PreviewMorphIn, {
			Scale = 1
		})

		task.delay(0.24, function()
			if token ~= PreviewMorphToken then
				return
			end

			TweenPreviewIcon(PreviewIcon, PreviewMorphSettle, {
				Size = PreviewIconBaseSize
			})
		end)
	end)
end

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

local FilterBtn = Instance.new("TextButton")
FilterBtn.Parent = TopBarUI
FilterBtn.BorderSizePixel = 0
FilterBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
FilterBtn.AnchorPoint = Vector2.new(1,0.5)
FilterBtn.BackgroundTransparency = 0.9
FilterBtn.Size = UDim2.new(0,47,0,28)
FilterBtn.Text = ""
FilterBtn.Name = "FilterBtn"
FilterBtn.Position = UDim2.new(1,-360,0.5,0)

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.Parent = FilterBtn
SettingsCorner.CornerRadius = UDim.new(0,10)

local FIcon = Instance.new("ImageLabel")
FIcon.Parent = FilterBtn
FIcon.BorderSizePixel = 0
FIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
FIcon.AnchorPoint = Vector2.new(0.5,0.5)
FIcon.Image = "rbxassetid://118174229311920"
FIcon.Size = UDim2.new(0,18,0,18)
FIcon.BackgroundTransparency = 1
FIcon.Name = "FIcon"
FIcon.Position = UDim2.new(0.5,0,0.5,0)

local FilterMenu = Instance.new("ScrollingFrame")
FilterMenu.Parent = FilterBtn
FilterMenu.Visible = false
FilterMenu.BorderSizePixel = 0
FilterMenu.BackgroundColor3 = Color3.fromRGB(36,36,36)
FilterMenu.AnchorPoint = Vector2.new(0.5,1)
FilterMenu.Size = UDim2.new(0,150,0,0)
FilterMenu.Position = UDim2.new(0.5,0,1,0)
FilterMenu.Name = "FilterMenu"
FilterMenu.ZIndex = 20
FilterMenu.ScrollBarThickness = 1.8
FilterMenu.ScrollBarImageColor3 = Color3.fromRGB(205,205,205)
FilterMenu.ScrollingDirection = Enum.ScrollingDirection.Y
FilterMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
FilterMenu.CanvasSize = UDim2.new(0,0,0,0)
FilterMenu.ClipsDescendants = true

local FilterMenuCorner = Instance.new("UICorner")
FilterMenuCorner.Parent = FilterMenu
FilterMenuCorner.CornerRadius = UDim.new(0,14)

local FilterMenuLayout = Instance.new("UIListLayout")
FilterMenuLayout.Parent = FilterMenu
FilterMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
FilterMenuLayout.Padding = UDim.new(0, 3)
FilterMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local FilterMenuPadding = Instance.new("UIPadding")
FilterMenuPadding.Parent = FilterMenu
FilterMenuPadding.PaddingTop = UDim.new(0, 6)
FilterMenuPadding.PaddingBottom = UDim.new(0, 6)

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Parent = TopBarUI
SettingsBtn.BorderSizePixel = 0
SettingsBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
SettingsBtn.AnchorPoint = Vector2.new(1,0.5)
SettingsBtn.BackgroundTransparency = 0.9
SettingsBtn.Size = UDim2.new(0,37,0,28)
SettingsBtn.Text = ""
SettingsBtn.Name = "SettingsBtn"
SettingsBtn.Position = UDim2.new(1,-418,0.5,0)

local SBtnCorner = Instance.new("UICorner")
SBtnCorner.Parent = SettingsBtn
SBtnCorner.CornerRadius = UDim.new(0,10)

local SGearIcon = Instance.new("ImageLabel")
SGearIcon.Parent = SettingsBtn
SGearIcon.BorderSizePixel = 0
SGearIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
SGearIcon.AnchorPoint = Vector2.new(0.5,0.5)
SGearIcon.Image = "rbxassetid://94345128715799"
SGearIcon.ImageColor3 = Color3.fromRGB(246,246,246)
SGearIcon.Size = UDim2.new(0,19,0,19)
SGearIcon.BackgroundTransparency = 1
SGearIcon.Name = "SGearIcon"
SGearIcon.Position = UDim2.new(0.5,0,0.5,0)

local SettingsMenu = Instance.new("ScrollingFrame")
SettingsMenu.Parent = SettingsBtn
SettingsMenu.Visible = false
SettingsMenu.BorderSizePixel = 0
SettingsMenu.BackgroundColor3 = Color3.fromRGB(36,36,36)
SettingsMenu.AnchorPoint = Vector2.new(0.5,1)
SettingsMenu.Size = UDim2.new(0,240,0,0)
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
SettingsMenuPadding.PaddingLeft = UDim.new(0, 6)
SettingsMenuPadding.PaddingRight = UDim.new(0, 6)

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
IconList.VerticalScrollBarInset = Enum.ScrollBarInset.None
IconList.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconList.Name = "IconList"
IconList.AnchorPoint = Vector2.new(0.5,1)
IconList.Size = UDim2.new(0.99,0,0.873,0)
IconList.Position = UDim2.new(0.5,0,1,-6)
IconList.ZIndex = -5
IconList.ScrollBarImageTransparency = 1
IconList.ScrollBarImageColor3 = Color3.fromRGB(200,200,200)
IconList.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
IconList.BackgroundTransparency = 1
IconList.AutomaticCanvasSize = Enum.AutomaticSize.None
IconList.ScrollBarThickness = 0
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

local ScrollTrack = Instance.new("Frame")
ScrollTrack.Parent = MainUI
ScrollTrack.Name = "ScrollTrack"
ScrollTrack.BorderSizePixel = 0
ScrollTrack.Active = true
ScrollTrack.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScrollTrack.BackgroundTransparency = 0.95
ScrollTrack.AnchorPoint = Vector2.new(1,1)
ScrollTrack.Size = UDim2.new(0,11,0.853,0)
ScrollTrack.Position = UDim2.new(0.995,-6,1,-16)
ScrollTrack.ZIndex = 30
ScrollTrack.Visible = false

local ScrollTrackCorner = Instance.new("UICorner")
ScrollTrackCorner.CornerRadius = UDim.new(1,0)
ScrollTrackCorner.Parent = ScrollTrack

local ScrollHandle = Instance.new("Frame")
ScrollHandle.Parent = ScrollTrack
ScrollHandle.Name = "ScrollHandle"
ScrollHandle.BorderSizePixel = 0
ScrollHandle.Active = true
ScrollHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScrollHandle.BackgroundTransparency = 0.05
ScrollHandle.Size = UDim2.new(1,0,0.3,0)
ScrollHandle.Position = UDim2.new(0,0,0,0)
ScrollHandle.ZIndex = 31

local ScrollHandleCorner = Instance.new("UICorner")
ScrollHandleCorner.CornerRadius = UDim.new(1,0)
ScrollHandleCorner.Parent = ScrollHandle

local ScrollHandleStroke = Instance.new("UIStroke")
ScrollHandleStroke.Parent = ScrollHandle
ScrollHandleStroke.Thickness = 1
ScrollHandleStroke.Transparency = 0.6
ScrollHandleStroke.Color = Color3.fromRGB(0,0,0)

local ScrollHitArea = Instance.new("Frame")
ScrollHitArea.Parent = ScrollTrack
ScrollHitArea.Name = "ScrollHitArea"
ScrollHitArea.BackgroundTransparency = 1
ScrollHitArea.Active = true
ScrollHitArea.AnchorPoint = Vector2.new(0.5, 0)
ScrollHitArea.Size = UDim2.new(0, 26, 1, 0)
ScrollHitArea.Position = UDim2.new(0.5, 0, 0, 0)
ScrollHitArea.ZIndex = 32

local function UpdateScrollHandle()
	local canvasHeight = IconList.AbsoluteCanvasSize.Y
	local viewHeight = IconList.AbsoluteWindowSize.Y

	if canvasHeight <= viewHeight or canvasHeight <= 0 or viewHeight <= 0 then
		ScrollTrack.Visible = false
		return
	end

	ScrollTrack.Visible = true
	local ratio = math.clamp(viewHeight / canvasHeight, 0.06, 1)
	local maxScroll = canvasHeight - viewHeight
	local posRatio = maxScroll > 0 and (IconList.CanvasPosition.Y / maxScroll) or 0

	ScrollHandle.Size = UDim2.new(1, 0, ratio, 0)
	ScrollHandle.Position = UDim2.new(0, 0, posRatio * (1 - ratio), 0)
end

IconList:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateScrollHandle)
IconList:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(UpdateScrollHandle)
IconList:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(UpdateScrollHandle)
UpdateScrollHandle()

local scrollDragging = false
local scrollDragStartY = 0
local scrollDragStartCanvasY = 0

local function ScrollDragUpdate(input)
	local canvasHeight = IconList.AbsoluteCanvasSize.Y
	local viewHeight = IconList.AbsoluteWindowSize.Y
	local maxScroll = math.max(canvasHeight - viewHeight, 0)
	local trackHeight = ScrollTrack.AbsoluteSize.Y

	if trackHeight <= 0 or maxScroll <= 0 then return end

	local deltaY = input.Position.Y - scrollDragStartY
	local deltaCanvas = (deltaY / trackHeight) * canvasHeight
	local newY = math.clamp(scrollDragStartCanvasY + deltaCanvas, 0, maxScroll)
	IconList.CanvasPosition = Vector2.new(0, newY)
end

ScrollHitArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		scrollDragging = true
		scrollDragStartY = input.Position.Y
		scrollDragStartCanvasY = IconList.CanvasPosition.Y

		local canvasHeight = IconList.AbsoluteCanvasSize.Y
		local viewHeight = IconList.AbsoluteWindowSize.Y
		local maxScroll = math.max(canvasHeight - viewHeight, 0)
		local trackHeight = ScrollTrack.AbsoluteSize.Y
		local handleTop = ScrollHandle.AbsolutePosition.Y
		local handleBottom = handleTop + ScrollHandle.AbsoluteSize.Y

		if trackHeight > 0 and (input.Position.Y < handleTop or input.Position.Y > handleBottom) then
			local relY = math.clamp((input.Position.Y - ScrollTrack.AbsolutePosition.Y) / trackHeight, 0, 1)
			IconList.CanvasPosition = Vector2.new(0, relY * maxScroll)
			scrollDragStartCanvasY = IconList.CanvasPosition.Y
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if scrollDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		ScrollDragUpdate(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		scrollDragging = false
	end
end)

local AlphabetHandle = Instance.new("TextButton")
AlphabetHandle.Parent = MainUI
AlphabetHandle.Text = ""
AlphabetHandle.AutoButtonColor = false
AlphabetHandle.BorderSizePixel = 0
AlphabetHandle.BackgroundColor3 = Color3.fromRGB(31,31,31)
AlphabetHandle.BackgroundTransparency = 1
AlphabetHandle.AnchorPoint = Vector2.new(0,0.5)
AlphabetHandle.Size = UDim2.new(0,28,0,345)
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
CloseSidebarBtn.Position = UDim2.new(1,38,0.5,0)
CloseSidebarBtn.Size = UDim2.new(0,31,0,28)
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

local GRID_PAD = 11
local TOP_PAD = 10
local BOTTOM_PAD = 10
local BUFFER_ROWS = 2
local SEARCH_DEBOUNCE = 0.15

local GridCell = DefaultIconGridSize
local GridCols = 1
local GridStride = GridCell + GRID_PAD
local GridX0 = 0

local FilteredIcons = {}
local IconPool = {}
local PoolSize = 0
local isLoadingIcons = false
local renderDirty = false

local lastLayout = {w = -1, h = -1, cell = -1, k = -1}

local HandleIconClick

local COLOR_NORMAL = Color3.fromRGB(31, 31, 31)
local COLOR_SELECTED = Color3.fromRGB(56, 56, 56)
local WHITE = Color3.fromRGB(255, 255, 255)

local HoverInfoBg = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HoverInfoScale = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local LeaveInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PressInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ReleaseInfo = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function MatchesFilter(item)
	if CurrentFilters["All"] then
		return true
	end
	local f = item.Flags
	if CurrentFilters["Fill/Bold"] and f.FillBold then return true end
	if CurrentFilters["Square"] and f.Square then return true end
	if CurrentFilters["Circle"] and f.Circle then return true end
	if CurrentFilters["Triangle"] and f.Triangle then return true end
	return false
end

local function CreateIconSlot()
	local bgTransparency = IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency
	local imgSize = math.floor(GridCell * 0.667 + 0.5)

	local Holder = Instance.new("TextButton")
	Holder.Text = ""
	Holder.BackgroundColor3 = COLOR_NORMAL
	Holder.BackgroundTransparency = bgTransparency
	Holder.Size = UDim2.new(0, GridCell, 0, GridCell)
	Holder.Visible = false
	Holder.Parent = IconList

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = Holder

	local btn = Instance.new("ImageLabel")
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(0, imgSize, 0, imgSize)
	btn.Position = UDim2.new(0.5, 0, 0.5, 0)
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Parent = Holder

	local HolderStroke = Instance.new("UIStroke")
	HolderStroke.Thickness = 1
	HolderStroke.Transparency = 1
	HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HolderStroke.Color = WHITE
	HolderStroke.Parent = Holder

	local HolderScale = Instance.new("UIScale")
	HolderScale.Scale = 1
	HolderScale.Parent = Holder

	local slot = {
		Holder = Holder,
		Image = btn,
		Stroke = HolderStroke,
		Scale = HolderScale,
		Index = nil,
		Data = nil,
		Hovering = false,
	}

	Holder.MouseEnter:Connect(function()
		slot.Hovering = true
		if not HoverAnimations then return end
		local currentBg = IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency
		TweenService:Create(Holder, HoverInfoBg, {BackgroundTransparency = math.max(currentBg - 0.55, 0)}):Play()
		TweenService:Create(HolderStroke, HoverInfoBg, {Transparency = 0.55}):Play()
		TweenService:Create(HolderScale, HoverInfoScale, {Scale = 1.08}):Play()
	end)

	Holder.MouseLeave:Connect(function()
		slot.Hovering = false
		if not HoverAnimations then return end
		local currentBg = IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency
		TweenService:Create(Holder, LeaveInfo, {BackgroundTransparency = currentBg}):Play()
		TweenService:Create(HolderStroke, LeaveInfo, {Transparency = 1}):Play()
		TweenService:Create(HolderScale, LeaveInfo, {Scale = 1}):Play()
	end)

	Holder.MouseButton1Click:Connect(function()
		local data = slot.Data
		if not data then return end

		if HoverAnimations then
			TweenService:Create(HolderScale, PressInfo, {Scale = slot.Hovering and 0.95 or 0.92}):Play()
		end
		task.delay(0.08, function()
			if HoverAnimations and Holder.Parent then
				TweenService:Create(HolderScale, ReleaseInfo, {Scale = slot.Hovering and 1.08 or 1}):Play()
			end
		end)

		HandleIconClick(data, btn, Holder)
	end)

	return slot
end

local function HideSlot(slot)
	slot.Index = nil
	slot.Data = nil
	slot.Holder.Visible = false
	if slot.Hovering then
		slot.Hovering = false
		slot.Scale.Scale = 1
		slot.Stroke.Transparency = 1
		slot.Holder.BackgroundTransparency = IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency
	end
end

local function BindSlot(slot, i)
	local item = FilteredIcons[i]
	local idx = i - 1
	local row = math.floor(idx / GridCols)
	local col = idx - row * GridCols

	slot.Index = i
	slot.Data = item
	slot.Holder.Position = UDim2.new(0, GridX0 + col * GridStride, 0, TOP_PAD + row * GridStride)
	slot.Image.Image = item.Image
	slot.Holder.BackgroundColor3 = SelectedIcons[item.ID] and COLOR_SELECTED or COLOR_NORMAL
	slot.Holder.Visible = true
end

local function RenderVisibleIcons()
	local total = #FilteredIcons
	if PoolSize <= 0 then return end

	local k = UiScale.Scale
	local scrollY = IconList.CanvasPosition.Y / k
	local firstRow = math.max(0, math.floor((scrollY - TOP_PAD) / GridStride) - BUFFER_ROWS)
	local first = firstRow * GridCols + 1
	local last = math.min(total, first + PoolSize - 1)

	for s = 1, #IconPool do
		local slot = IconPool[s]
		if slot.Index and (s > PoolSize or slot.Index < first or slot.Index > last) then
			HideSlot(slot)
		elseif s > PoolSize and slot.Holder.Visible then
			HideSlot(slot)
		end
	end

	for i = first, last do
		local slot = IconPool[(i - 1) % PoolSize + 1]
		if slot.Index ~= i then
			BindSlot(slot, i)
		end
	end
end

local function Relayout(force)
	local k = UiScale.Scale
	local winX = IconList.AbsoluteWindowSize.X / k
	local winY = IconList.AbsoluteWindowSize.Y / k
	if winX <= 0 or winY <= 0 then return end

	if not force
		and lastLayout.w == winX and lastLayout.h == winY
		and lastLayout.cell == GridCell and lastLayout.k == k then
		return
	end
	lastLayout.w, lastLayout.h, lastLayout.cell, lastLayout.k = winX, winY, GridCell, k

	GridStride = GridCell + GRID_PAD
	GridCols = math.max(1, math.floor((winX + GRID_PAD) / GridStride))
	GridX0 = math.max(0, math.floor((winX - (GridCols * GridStride - GRID_PAD)) / 2))

	local total = #FilteredIcons
	local rows = math.ceil(total / GridCols)
	local canvasH = 0
	if rows > 0 then
		canvasH = TOP_PAD + rows * GridStride - GRID_PAD + BOTTOM_PAD
	end
	IconList.CanvasSize = UDim2.new(0, 0, 0, canvasH)

	local visibleRows = math.ceil(winY / GridStride) + 1 + BUFFER_ROWS * 2
	PoolSize = visibleRows * GridCols
	while #IconPool < PoolSize do
		table.insert(IconPool, CreateIconSlot())
	end

	local imgSize = math.floor(GridCell * 0.667 + 0.5)
	for _, slot in ipairs(IconPool) do
		slot.Holder.Size = UDim2.new(0, GridCell, 0, GridCell)
		slot.Image.Size = UDim2.new(0, imgSize, 0, imgSize)
		HideSlot(slot)
	end

	RenderVisibleIcons()
end

local function ProcessFiltersAndSort()
	local query = SearchBox.Text:lower():gsub("%s+", "")
	local out = {}
	local n = 0

	local from, to, step = 1, #CurrentIcons, 1
	if CurrentSort == "Z-A" then
		from, to, step = #CurrentIcons, 1, -1
	end

	local alpha = CurrentAlphabetFilter
	for i = from, to, step do
		local item = CurrentIcons[i]
		if (not alpha or item.FirstChar == alpha)
			and MatchesFilter(item)
			and (query == "" or item.CleanName:find(query, 1, true)) then
			n = n + 1
			out[n] = item
		end
	end

	FilteredIcons = out
	for _, slot in ipairs(IconPool) do
		HideSlot(slot)
	end
	IconList.CanvasPosition = Vector2.new(0, 0)
	Relayout(true)

	if not isLoadingIcons then
		CountLabel.Text = tostring(n)
	end
end

IconList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	renderDirty = true
end)
IconList:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
	Relayout(false)
end)
UiScale:GetPropertyChangedSignal("Scale"):Connect(function()
	Relayout(false)
end)

local renderConn = RunService.Heartbeat:Connect(function()
	if renderDirty then
		renderDirty = false
		RenderVisibleIcons()
	end
end)
IconFinder.Destroying:Connect(function()
	renderConn:Disconnect()
end)

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
		if MatchesFilter(item) then
			totalCount = totalCount + 1
			local firstChar = item.FirstChar
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

HandleIconClick = function(data, btn, Holder)
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
		MorphPreviewIcon(idStr)
		IconName.Text = data.Name
		PViewFrame.Visible = true
	end
end

local ItemCache = {}

local function BuildItems(result)
	local items, n = {}, 0
	for name, id in pairs(result) do
		name = tostring(name)
		local clean = (name:lower():gsub("%s+", ""))
		local idStr = tostring(id)
		if not idStr:find("rbxassetid://", 1, true) then
			idStr = "rbxassetid://" .. idStr
		end
		n = n + 1
		items[n] = {
			Name = name,
			ID = id,
			Image = idStr,
			CleanName = clean,
			FirstChar = clean:sub(1, 1):upper(),
			Flags = {
				FillBold = (clean:find("fill", 1, true) ~= nil) or (clean:find("bold", 1, true) ~= nil),
				Square = clean:find("square", 1, true) ~= nil,
				Circle = clean:find("circle", 1, true) ~= nil,
				Triangle = clean:find("triangle", 1, true) ~= nil,
			},
		}
		if n % 2500 == 0 then task.wait() end
	end
	table.sort(items, function(a, b) return a.CleanName < b.CleanName end)
	return items
end

local function LoadIcons(platform)
	currentLoadToken = currentLoadToken + 1
	local myToken = currentLoadToken

	isLoadingIcons = true
	CurrentIcons = {}
	SelectedIcons = {}
	CurrentAlphabetFilter = nil
	CountLabel.Text = "Loading..."
	PlatformName.Text = platform
	ProcessFiltersAndSort()

	task.spawn(function()
		local items = ItemCache[platform]

		if not items then
			local result = IconCache[platform]

			if not result then
				local ok, rawData = HttpGetWithRetry(PlatformURLs[platform])
				if ok then
					local s, r = pcall(function()
						local func = loadstring(rawData)
						if not func then error("Syntax Error in Raw Data") end
						return func()
					end)
					if s and type(r) == "table" then
						IconCache[platform] = r
						result = r
					end
				end
			end

			if myToken ~= currentLoadToken then return end

			if result then
				items = BuildItems(result)
				ItemCache[platform] = items
			end
		end

		if myToken ~= currentLoadToken then return end

		if items then
			CurrentIcons = items
			isLoadingIcons = false
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

local saveToken = 0

local function SaveSettings()
	if not writefile then return end
	saveToken = saveToken + 1
	local myToken = saveToken
	task.delay(0.6, function()
		if myToken ~= saveToken then return end
		pcall(function()
			writefile(SettingsFileName, HttpService:JSONEncode({
				CornerRadius = MUICorner.CornerRadius.Offset,
				BgTransparency = MainUI.BackgroundTransparency,
				IconButtonTransparency = IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency,
				IconGridSize = GridCell,
				SizeScaleX = MainUI.Size.X.Scale,
				SizeOffsetX = MainUI.Size.X.Offset,
				SizeScaleY = MainUI.Size.Y.Scale,
				SizeOffsetY = MainUI.Size.Y.Offset,
				UIScale = UiScale.Scale,
				HoverAnimations = HoverAnimations,
			}))
		end)
	end)
end

function ApplyCornerRadius(v)
	MUICorner.CornerRadius = UDim.new(0, v)
	TbCorner.CornerRadius = UDim.new(0, v)
	SaveSettings()
end

function ApplyBgTransparency(v)
	MainUI.BackgroundTransparency = v
	SaveSettings()
end

function ApplyIconButtonTransparency(v)
	IconList:SetAttribute("IconButtonTransparency", v)
	for _, slot in ipairs(IconPool) do
		slot.Holder.BackgroundTransparency = v
	end
	SaveSettings()
end

function ApplyIconGridSize(v)
	GridCell = v
	Relayout(true)
	SaveSettings()
end

function ApplyMainUISize(sx, ox, sy, oy)
	MainUI.Size = UDim2.new(sx, ox, sy, oy)
	SaveSettings()
end

function ApplyUIScale(v)
	UiScale.Scale = v
	SaveSettings()
end

function ApplyHoverAnimations(v)
	HoverAnimations = v and true or false
	SaveSettings()
end

local function LoadSettings()
	if not (isfile and readfile) then return end
	local ok, data = pcall(function()
		if not isfile(SettingsFileName) then return nil end
		return HttpService:JSONDecode(readfile(SettingsFileName))
	end)
	if not ok or type(data) ~= "table" then return end

	local function num(key, min, max, default)
		local v = tonumber(data[key])
		if not v then return default end
		return math.clamp(v, min, max)
	end

	ApplyCornerRadius(num("CornerRadius", 0, 50, DefaultCornerRadius))
	ApplyBgTransparency(num("BgTransparency", 0, 1, DefaultBgTransparency))
	ApplyIconButtonTransparency(num("IconButtonTransparency", 0, 1, DefaultIconButtonTransparency))
	ApplyIconGridSize(num("IconGridSize", 40, 90, DefaultIconGridSize))
	ApplyMainUISize(
		num("SizeScaleX", 0.2, 3, DefaultMainUIScaleX),
		num("SizeOffsetX", -2000, 2000, DefaultMainUIOffsetX),
		num("SizeScaleY", 0.2, 3, DefaultMainUIScaleY),
		num("SizeOffsetY", -2000, 2000, DefaultMainUIOffsetY)
	)
	ApplyUIScale(num("UIScale", 0.7, 1.3, DefaultUIScale))
	if type(data.HoverAnimations) == "boolean" then
		ApplyHoverAnimations(data.HoverAnimations)
	end
end

local ActiveSettingsSlider = nil

local function CreateSettingsSliderRow(parent, order, label, min, max, value, decimals, suffix, onChange)
	suffix = suffix or ""

	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 48)
	row.LayoutOrder = order
	row.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BorderSizePixel = 0
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -62, 0, 18)
	lbl.Position = UDim2.new(0, 6, 0, 0)
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	lbl.Parent = row

	local valuePill = Instance.new("Frame")
	valuePill.BorderSizePixel = 0
	valuePill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	valuePill.BackgroundTransparency = 0.9
	valuePill.AnchorPoint = Vector2.new(1, 0)
	valuePill.Size = UDim2.new(0, 54, 0, 18)
	valuePill.Position = UDim2.new(1, -6, 0, 0)
	valuePill.Parent = row

	local valuePillCorner = Instance.new("UICorner")
	valuePillCorner.CornerRadius = UDim.new(1, 0)
	valuePillCorner.Parent = valuePill

	local valueLbl = Instance.new("TextLabel")
	valueLbl.BorderSizePixel = 0
	valueLbl.BackgroundTransparency = 1
	valueLbl.Size = UDim2.new(1, 0, 1, 0)
	valueLbl.Text = tostring(value) .. suffix
	valueLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLbl.TextSize = 12
	valueLbl.TextXAlignment = Enum.TextXAlignment.Center
	valueLbl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	valueLbl.Parent = valuePill

	local track = Instance.new("Frame")
	track.BorderSizePixel = 0
	track.Size = UDim2.new(1, -12, 0, 8)
	track.Position = UDim2.new(0, 6, 0, 28)
	track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	track.BackgroundTransparency = 0.9
	track.Parent = row

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fraction = math.clamp((value - min) / (max - min), 0, 1)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(fraction, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local hitArea = Instance.new("Frame")
	hitArea.BorderSizePixel = 0
	hitArea.BackgroundTransparency = 1
	hitArea.Active = true
	hitArea.AnchorPoint = Vector2.new(0.5, 0.5)
	hitArea.Size = UDim2.new(1, 0, 0, 24)
	hitArea.Position = UDim2.new(0.5, 0, 0.5, 0)
	hitArea.ZIndex = 2
	hitArea.Parent = track

	local function SetFraction(f)
		f = math.clamp(f, 0, 1)
		local v = min + (max - min) * f
		if decimals and decimals > 0 then
			local mult = 10 ^ decimals
			v = math.floor(v * mult + 0.5) / mult
		else
			v = math.floor(v + 0.5)
		end
		fill.Size = UDim2.new(f, 0, 1, 0)
		valueLbl.Text = tostring(v) .. suffix
		onChange(v)
	end

	local dragging = false
	local sliderId = {}

	hitArea.InputBegan:Connect(function(input)
		if ActiveSettingsSlider ~= nil then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			ActiveSettingsSlider = sliderId
			SetFraction((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
		end
	end)

	local changedConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			SetFraction((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
		end
	end)

	local endedConn = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if ActiveSettingsSlider == sliderId then
				ActiveSettingsSlider = nil
			end
		end
	end)

	row.Destroying:Connect(function()
		if ActiveSettingsSlider == sliderId then
			ActiveSettingsSlider = nil
		end
		changedConn:Disconnect()
		endedConn:Disconnect()
	end)

	return row
end

local function CreateSettingsToggleRow(parent, order, label, value, onChange)
	local btn = Instance.new("TextButton")
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Text = "  " .. label
	btn.LayoutOrder = order
	btn.Parent = parent

	local chk = Instance.new("ImageLabel")
	chk.Size = UDim2.new(1.03, 0, 0, 18)
	chk.Position = UDim2.new(0.5, 0, 0.5, 0)
	chk.AnchorPoint = Vector2.new(0.5, 0.5)
	chk.BackgroundTransparency = 1
	chk.ImageTransparency = 0.75
	chk.Image = "rbxassetid://80742398186218"
	chk.ImageColor3 = Color3.fromRGB(255, 255, 255)
	chk.Parent = btn

	local chkCorner = Instance.new("UICorner")
	chkCorner.CornerRadius = UDim.new(0, 5)
	chkCorner.Parent = chk

	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 6)
	itemCorner.Parent = btn

	local function Render()
		chk.Visible = value
		btn.TextColor3 = value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 210)
		btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", value and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end

	Render()

	btn.MouseButton1Click:Connect(function()
		value = not value
		Render()
		onChange(value)
	end)

	return btn
end

local function CreateSettingsSizeInputRow(parent, order, label, defaultSX, defaultOX, defaultSY, defaultOY, onApply)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 78)
	row.LayoutOrder = order
	row.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BorderSizePixel = 0
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.Position = UDim2.new(0, 6, 0, 0)
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	lbl.Parent = row

	local function MakeBox(defaultValue, placeholder, posX, posY)
		local box = Instance.new("TextBox")
		box.BorderSizePixel = 0
		box.Size = UDim2.new(0, 108, 0, 26)
		box.Position = UDim2.new(0, posX, 0, posY)
		box.BackgroundColor3 = Color3.fromRGB(46,46,46)
		box.BackgroundTransparency = 0.45
		box.Text = tostring(defaultValue)
		box.PlaceholderText = placeholder
		box.TextColor3 = Color3.fromRGB(230,230,230)
		box.TextSize = 13
		box.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		box.Parent = row

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0,10)
		boxCorner.Parent = box

		local boxStroke = Instance.new("UIStroke")
		boxStroke.Transparency = 0.93
		boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		boxStroke.Color = Color3.fromRGB(255,255,255)
		boxStroke.Parent = box

		return box
	end

	local sxBox = MakeBox(defaultSX, "Scale X", 6, 22)
	local oxBox = MakeBox(defaultOX, "Offset X", 120, 22)
	local syBox = MakeBox(defaultSY, "Scale Y", 6, 52)
	local oyBox = MakeBox(defaultOY, "Offset Y", 120, 52)

	local function Submit()
		local sx = tonumber(sxBox.Text) or defaultSX
		local ox = tonumber(oxBox.Text) or defaultOX
		local sy = tonumber(syBox.Text) or defaultSY
		local oy = tonumber(oyBox.Text) or defaultOY
		sxBox.Text = tostring(sx)
		oxBox.Text = tostring(ox)
		syBox.Text = tostring(sy)
		oyBox.Text = tostring(oy)
		onApply(sx, ox, sy, oy)
	end

	sxBox.FocusLost:Connect(Submit)
	oxBox.FocusLost:Connect(Submit)
	syBox.FocusLost:Connect(Submit)
	oyBox.FocusLost:Connect(Submit)

	return row
end

local function CreateSettingsButtonRow(parent, order, label, onClick)
	local btn = Instance.new("TextButton")
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(46,46,46)
	btn.BackgroundTransparency = 0.45
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(230,230,230)
	btn.TextSize = 14
	btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	btn.LayoutOrder = order
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,15)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Transparency = 0.93
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.45}):Play()
	end)

	btn.MouseButton1Click:Connect(onClick)
	return btn
end

ResetUISettings = function()
	ApplyCornerRadius(DefaultCornerRadius)
	ApplyBgTransparency(DefaultBgTransparency)
	ApplyIconButtonTransparency(DefaultIconButtonTransparency)
	ApplyIconGridSize(DefaultIconGridSize)
	ApplyMainUISize(DefaultMainUIScaleX, DefaultMainUIOffsetX, DefaultMainUIScaleY, DefaultMainUIOffsetY)
	ApplyUIScale(DefaultUIScale)
	ApplyHoverAnimations(DefaultHoverAnimations)

	if BuildSettingsMenu then
		BuildSettingsMenu()
	end
end

function BuildSettingsMenu()
	for _, child in ipairs(SettingsMenu:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding") or child:IsA("UICorner") or child:IsA("UIStroke")) then
			child:Destroy()
		end
	end

	local order = 1
	local totalHeight = 16

	local function AddHeader(text)
		local header = Instance.new("Frame")
		header.BorderSizePixel = 0
		header.BackgroundTransparency = 1
		header.Size = UDim2.new(1, 0, 0, 24)
		header.LayoutOrder = order
		header.Parent = SettingsMenu

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(0, 16, 0, 16)
		img.Position = UDim2.new(0, 6, 0.5, 0)
		img.AnchorPoint = Vector2.new(0, 0.5)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://94345128715799"
		img.ImageColor3 = Color3.fromRGB(200, 200, 200)
		img.Parent = header

		local headerLbl = Instance.new("TextLabel")
		headerLbl.BorderSizePixel = 0
		headerLbl.BackgroundTransparency = 1
		headerLbl.Size = UDim2.new(1, -28, 1, 0)
		headerLbl.Position = UDim2.new(0, 26, 0, 0)
		headerLbl.Text = text
		headerLbl.TextXAlignment = Enum.TextXAlignment.Left
		headerLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
		headerLbl.TextSize = 14
		headerLbl.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		headerLbl.Parent = header

		order = order + 1
		totalHeight = totalHeight + 27
	end

	local function AddDivider()
		local div = Instance.new("Frame")
		div.BorderSizePixel = 0
		div.Size = UDim2.new(1, -20, 0, 1)
		div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		div.BackgroundTransparency = 0.8
		div.LayoutOrder = order
		div.Parent = SettingsMenu
		order = order + 1
		totalHeight = totalHeight + 4
	end

	AddHeader("Settings")

	CreateSettingsSliderRow(SettingsMenu, order, "Corner Radius", 0, 50, MUICorner.CornerRadius.Offset, 0, "px", function(v)
		ApplyCornerRadius(v)
	end)
	order = order + 1
	totalHeight = totalHeight + 52

	CreateSettingsSliderRow(SettingsMenu, order, "BG Transparency", 0, 100, MainUI.BackgroundTransparency * 100, 0, "%", function(v)
		ApplyBgTransparency(v / 100)
	end)
	order = order + 1
	totalHeight = totalHeight + 52

	CreateSettingsSliderRow(SettingsMenu, order, "Icon Button Transparency", 0, 100, (IconList:GetAttribute("IconButtonTransparency") or DefaultIconButtonTransparency) * 100, 0, "%", function(v)
		ApplyIconButtonTransparency(v / 100)
	end)
	order = order + 1
	totalHeight = totalHeight + 52

	CreateSettingsSliderRow(SettingsMenu, order, "Icon Grid", 40, 90, GridCell, 0, "px", function(v)
		ApplyIconGridSize(v)
	end)
	order = order + 1
	totalHeight = totalHeight + 52

	CreateSettingsSizeInputRow(SettingsMenu, order, "MainUI Size (Scale X, Offset X, Scale Y, Offset Y)", MainUI.Size.X.Scale, MainUI.Size.X.Offset, MainUI.Size.Y.Scale, MainUI.Size.Y.Offset, function(sx, ox, sy, oy)
		ApplyMainUISize(sx, ox, sy, oy)
	end)
	order = order + 1
	totalHeight = totalHeight + 82

	CreateSettingsSliderRow(SettingsMenu, order, "MainUI UIScale", 0.7, 1.3, UiScale.Scale, 2, "x", function(v)
		ApplyUIScale(v)
	end)
	order = order + 1
	totalHeight = totalHeight + 52

	CreateSettingsToggleRow(SettingsMenu, order, "Hover Animations", HoverAnimations, function(v)
		ApplyHoverAnimations(v)
	end)
	order = order + 1
	totalHeight = totalHeight + 27

	AddDivider()

	CreateSettingsButtonRow(SettingsMenu, order, "Reset to Default", function()
		ResetUISettings()
	end)
	order = order + 1
	totalHeight = totalHeight + 34

	local displayHeight = math.min(totalHeight, 330)
	SettingsMenu.Size = UDim2.new(0, 245, 0, displayHeight)
	SettingsMenu.Position = UDim2.new(0.5, 0, 1, displayHeight + 2)
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

local function BuildFilterMenu()
	for _, child in ipairs(FilterMenu:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local items = {
		{Type = "Label", Text = "Copy Mode", Icon = "rbxassetid://113618379616952"},
		{Type = "Button", Text = "ID", Action = function() SetCopyMode("ID") BuildFilterMenu() end, Checked = (CurrentCopyMode == "ID")},
		{Type = "Button", Text = "rbxassetid://ID", Action = function() SetCopyMode("rbxassetid://ID") BuildFilterMenu() end, Checked = (CurrentCopyMode == "rbxassetid://ID")},
		{Type = "Button", Text = "Copy on Press", Action = function() ToggleCopyOnPress() BuildFilterMenu() end, Checked = CopyOnPress},
		{Type = "Divider"},
		{Type = "Label", Text = "Filter", Icon = "rbxassetid://96385120752336"},
		{Type = "Button", Text = "All", Action = function() ToggleFilter("All") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildFilterMenu() end, Checked = (CurrentFilters["All"] == true)},
		{Type = "Button", Text = "Fill/Bold", Action = function() ToggleFilter("Fill/Bold") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildFilterMenu() end, Checked = (CurrentFilters["Fill/Bold"] == true)},
		{Type = "Button", Text = "Square", Action = function() ToggleFilter("Square") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildFilterMenu() end, Checked = (CurrentFilters["Square"] == true)},
		{Type = "Button", Text = "Circle", Action = function() ToggleFilter("Circle") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildFilterMenu() end, Checked = (CurrentFilters["Circle"] == true)},
		{Type = "Button", Text = "Triangle", Action = function() ToggleFilter("Triangle") ProcessFiltersAndSort() BuildAlphabetSidebar() BuildFilterMenu() end, Checked = (CurrentFilters["Triangle"] == true)},
		{Type = "Divider"},
		{Type = "Label", Text = "Sort", Icon = "rbxassetid://85780258549577"},
		{Type = "Button", Text = "A-Z", Action = function() SetSort("A-Z") ProcessFiltersAndSort() BuildFilterMenu() end, Checked = (CurrentSort == "A-Z")},
		{Type = "Button", Text = "Z-A", Action = function() SetSort("Z-A") ProcessFiltersAndSort() BuildFilterMenu() end, Checked = (CurrentSort == "Z-A")}
	}

	local totalHeight = 12
	local layoutOrder = 1

	for _, item in ipairs(items) do
		if item.Type == "Label" then
			local container = Instance.new("Frame")
			container.Size = UDim2.new(0, 140, 0, 24)
			container.BackgroundTransparency = 1
			container.LayoutOrder = layoutOrder
			container.Parent = FilterMenu

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
			btn.Parent = FilterMenu

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
			div.Parent = FilterMenu
			totalHeight = totalHeight + 4
		end
		layoutOrder = layoutOrder + 1
	end

	local displayHeight = math.min(totalHeight, 230)
	FilterMenu.Size = UDim2.new(0, 150, 0, displayHeight)
	FilterMenu.Position = UDim2.new(0.5, 0, 1, displayHeight + 2)
end

local searchToken = 0
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	ClearBox.Visible = SearchBox.Text ~= ""
	searchToken = searchToken + 1
	local myToken = searchToken
	task.delay(SEARCH_DEBOUNCE, function()
		if myToken == searchToken then
			ProcessFiltersAndSort()
		end
	end)
end)

ClearBox.MouseButton1Click:Connect(function()
	SearchBox.Text = ""
	SearchBox:CaptureFocus()
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
	FilterMenu.Visible = false
	SettingsMenu.Visible = false
end)

FilterBtn.MouseButton1Click:Connect(function()
	FilterMenu.Visible = not FilterMenu.Visible
	Container.Visible = false
	SettingsMenu.Visible = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
	SettingsMenu.Visible = not SettingsMenu.Visible
	Container.Visible = false
	FilterMenu.Visible = false
end)

ClosePView.MouseButton1Click:Connect(function()
	PViewFrame.Visible = false
	PreviewMorphToken = PreviewMorphToken + 1
	PreviewIcon.ImageTransparency = 0
	PreviewIcon.Rotation = PreviewIconBaseRotation
	PreviewIcon.Size = PreviewIconBaseSize
	PreviewIconScale.Scale = 1
end)

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
BuildFilterMenu()
LoadSettings()
BuildSettingsMenu()
BuildAlphabetSidebar()
LoadIcons("Lucide")