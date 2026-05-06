local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local PlatformURLs = {
	["Lucide"] = "https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide-Icons.lua",
	["Gravity"] = "https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Gravity-Icons.lua",
	["Solar"] = "https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Solar-Icons.lua",
	["SFSymbols"] = "https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/SFSymbols-Icons.lua"
}

local CurrentIcons = {}
local IconObjects = {}

local IconFinder = Instance.new("ScreenGui")
IconFinder.Parent = CoreGui
IconFinder.IgnoreGuiInset = true
IconFinder.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
IconFinder.Name = "IconFinder"
IconFinder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TopBarHolder = Instance.new("Frame")
TopBarHolder.Parent = IconFinder
TopBarHolder.Visible = false
TopBarHolder.BorderSizePixel = 0
TopBarHolder.BackgroundColor3 = Color3.fromRGB(0,0,0)
TopBarHolder.AnchorPoint = Vector2.new(1,0)
TopBarHolder.Size = UDim2.new(0.797,0,0,38)
TopBarHolder.Position = UDim2.new(1,0,0,16)
TopBarHolder.Name = "TopBarHolder"
TopBarHolder.BackgroundTransparency = 1

local UICorner = Instance.new("UICorner")
UICorner.Parent = TopBarHolder
UICorner.CornerRadius = UDim.new(1,0)

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

local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = OpenUI
UICorner2.CornerRadius = UDim.new(1,0)

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
MainUI.Size = UDim2.new(1,0,0.99,0)
MainUI.Position = UDim2.new(0.5,0,0.5,0)
MainUI.Name = "MainUI"
MainUI.BackgroundTransparency = 0.03

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
SearchBox.Size = UDim2.new(0.894,0,0.66,0)
SearchBox.Position = UDim2.new(1,-5,0.5,0)
SearchBox.Text = ""
SearchBox.BackgroundTransparency = 1

local UICorner3 = Instance.new("UICorner")
UICorner3.Parent = SearchBar
UICorner3.CornerRadius = UDim.new(1,0)

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

local UICorner4 = Instance.new("UICorner")
UICorner4.Parent = MainUI
UICorner4.CornerRadius = UDim.new(0,25)

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

local UICorner5 = Instance.new("UICorner")
UICorner5.Parent = PViewFrame
UICorner5.CornerRadius = UDim.new(0,20)

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

local UICorner6 = Instance.new("UICorner")
UICorner6.Parent = CopyID
UICorner6.CornerRadius = UDim.new(0,15)

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

local UIStroke7 = Instance.new("UIStroke")
UIStroke7.Parent = CopyID
UIStroke7.Transparency = 0.93
UIStroke7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke7.Color = Color3.fromRGB(255,255,255)

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

local UICorner7 = Instance.new("UICorner")
UICorner7.Parent = CopyName
UICorner7.CornerRadius = UDim.new(0,15)

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

local UIStroke9 = Instance.new("UIStroke")
UIStroke9.Parent = CopyName
UIStroke9.Transparency = 0.93
UIStroke9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke9.Color = Color3.fromRGB(255,255,255)

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
IconsCount.Position = UDim2.new(1,-133,0.5,0)
IconsCount.Name = "IconsCount"
IconsCount.BackgroundTransparency = 0.9

local UICorner8 = Instance.new("UICorner")
UICorner8.Parent = IconsCount
UICorner8.CornerRadius = UDim.new(0,10)

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
CountLabel.Position = UDim2.new(1,-31,0.5,0)

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
Title.Size = UDim2.new(0.1,0,0.65,0)
Title.Text = "Icons Finder"
Title.Name = "Title"
Title.Position = UDim2.new(0,14,0.5,0)

local UICorner9 = Instance.new("UICorner")
UICorner9.Parent = TopBarUI
UICorner9.CornerRadius = UDim.new(0,25)

local IconPicker = Instance.new("TextButton")
IconPicker.Parent = TopBarUI
IconPicker.BorderSizePixel = 0
IconPicker.BackgroundColor3 = Color3.fromRGB(255,255,255)
IconPicker.AnchorPoint = Vector2.new(1,0.5)
IconPicker.BackgroundTransparency = 0.9
IconPicker.Size = UDim2.new(0,95,0,28)
IconPicker.Text = ""
IconPicker.Name = "IconPicker"
IconPicker.Position = UDim2.new(1,-244,0.5,0)

local UICorner10 = Instance.new("UICorner")
UICorner10.Parent = IconPicker
UICorner10.CornerRadius = UDim.new(0,10)

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
Container.Size = UDim2.new(0,108,0,121)
Container.Position = UDim2.new(0.5,0,1,128)
Container.Name = "Container"
Container.ZIndex = 10

local UICorner11 = Instance.new("UICorner")
UICorner11.Parent = Container
UICorner11.CornerRadius = UDim.new(0,14)

local LucideBtn = Instance.new("TextButton")
LucideBtn.Parent = Container
LucideBtn.BorderSizePixel = 0
LucideBtn.TextSize = 18
LucideBtn.TextColor3 = Color3.fromRGB(231,231,231)
LucideBtn.BackgroundColor3 = Color3.fromRGB(51,51,51)
LucideBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
LucideBtn.AnchorPoint = Vector2.new(0.5,0)
LucideBtn.BackgroundTransparency = 1
LucideBtn.Size = UDim2.new(0,103,0,26)
LucideBtn.Text = "Lucide"
LucideBtn.Name = "LucideBtn"
LucideBtn.Position = UDim2.new(0.5,0,0,4)

local SelectLine = Instance.new("Frame")
SelectLine.Parent = LucideBtn
SelectLine.BorderSizePixel = 0
SelectLine.BackgroundColor3 = Color3.fromRGB(236,236,236)
SelectLine.AnchorPoint = Vector2.new(0,0.5)
SelectLine.Size = UDim2.new(0,3,0,16)
SelectLine.Position = UDim2.new(0,1,0.5,0)
SelectLine.Name = "SelectLine"

local UICorner12 = Instance.new("UICorner")
UICorner12.Parent = SelectLine
UICorner12.CornerRadius = UDim.new(1,0)

local GravityBtn = Instance.new("TextButton")
GravityBtn.Parent = Container
GravityBtn.BorderSizePixel = 0
GravityBtn.TextSize = 18
GravityBtn.TextColor3 = Color3.fromRGB(231,231,231)
GravityBtn.BackgroundColor3 = Color3.fromRGB(51,51,51)
GravityBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
GravityBtn.AnchorPoint = Vector2.new(0.5,0)
GravityBtn.BackgroundTransparency = 1
GravityBtn.Size = UDim2.new(0,103,0,26)
GravityBtn.Text = "Gravity"
GravityBtn.Name = "GravityBtn"
GravityBtn.Position = UDim2.new(0.5,0,0,33)

local SolarBtn = Instance.new("TextButton")
SolarBtn.Parent = Container
SolarBtn.BorderSizePixel = 0
SolarBtn.TextSize = 18
SolarBtn.TextColor3 = Color3.fromRGB(231,231,231)
SolarBtn.BackgroundColor3 = Color3.fromRGB(51,51,51)
SolarBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
SolarBtn.AnchorPoint = Vector2.new(0.5,1)
SolarBtn.BackgroundTransparency = 1
SolarBtn.Size = UDim2.new(0,103,0,26)
SolarBtn.Text = "Solar"
SolarBtn.Name = "SolarBtn"
SolarBtn.Position = UDim2.new(0.5,0,1,-33)

local SFSymbolsBtn = Instance.new("TextButton")
SFSymbolsBtn.Parent = Container
SFSymbolsBtn.BorderSizePixel = 0
SFSymbolsBtn.TextSize = 18
SFSymbolsBtn.TextColor3 = Color3.fromRGB(231,231,231)
SFSymbolsBtn.BackgroundColor3 = Color3.fromRGB(51,51,51)
SFSymbolsBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
SFSymbolsBtn.AnchorPoint = Vector2.new(0.5,1)
SFSymbolsBtn.BackgroundTransparency = 1
SFSymbolsBtn.Size = UDim2.new(0,103,0,26)
SFSymbolsBtn.Text = "SFSymbols"
SFSymbolsBtn.Name = "SFSymbolsBtn"
SFSymbolsBtn.Position = UDim2.new(0.5,0,1,-4)

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

local UserInputService = game:GetService("UserInputService")

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

local UICorner13 = Instance.new("UICorner")
UICorner13.Parent = IconList
UICorner13.CornerRadius = UDim.new(0,18)

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

local function LoadIcons(platform)
	for _, obj in pairs(IconObjects) do obj:Destroy() end
	IconObjects = {}
	CurrentIcons = {}
	CountLabel.Text = "Loading..."
	PlatformName.Text = platform

	task.spawn(function()
		local success, rawData = pcall(function()
			return game:HttpGet(PlatformURLs[platform])
		end)

		if success and rawData then
			local func = loadstring(rawData)
			if func then
				local result = func()
				if type(result) == "table" then
					local sorted = {}
					for name, id in pairs(result) do
						table.insert(sorted, {Name = name, ID = id})
					end
					table.sort(sorted, function(a, b) return a.Name:lower() < b.Name:lower() end)

					for i, data in ipairs(sorted) do
						local Holder = Instance.new("Frame")
						Holder.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
						Holder.Parent = IconList
						Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 12)

						local btn = Instance.new("ImageButton")
						btn.Size = UDim2.new(0, 40, 0, 40)
						btn.Position = UDim2.new(0.5, 0, 0.5, 0)
						btn.AnchorPoint = Vector2.new(0.5, 0.5)
						btn.BackgroundTransparency = 1
						btn.Image = (string.find(tostring(data.ID), "rbxassetid://") and tostring(data.ID)) or "rbxassetid://" .. tostring(data.ID)
						btn.Parent = Holder

						btn.MouseButton1Click:Connect(function()
							PreviewIcon.Image = btn.Image
							IconName.Text = data.Name
							PViewFrame.Visible = true
						end)

						table.insert(IconObjects, Holder)
						table.insert(CurrentIcons, {Obj = Holder, Name = data.Name:lower(), ID = data.ID})
					end
					CountLabel.Text = tostring(#sorted)
				end
			else
				CountLabel.Text = "Syntax Err"
			end
		else
			CountLabel.Text = "HTTP Err"
		end
	end)
end

local function UpdateSearch(text)
	local query = text:lower():gsub("%s+", "")
	for _, item in ipairs(CurrentIcons) do
		local iconName = item.Name:lower():gsub("%s+", "")
		if query == "" then
			item.Obj.Visible = true
		else
			item.Obj.Visible = iconName:find(query, 1, true) ~= nil
		end
	end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	UpdateSearch(SearchBox.Text)
end)

IconPicker.MouseButton1Click:Connect(function()
	Container.Visible = not Container.Visible
end)

local function SetPlatform(name, btn)
	SelectLine.Parent = btn
	Container.Visible = false
	LoadIcons(name)
end

LucideBtn.MouseButton1Click:Connect(function() SetPlatform("Lucide", LucideBtn) end)
GravityBtn.MouseButton1Click:Connect(function() SetPlatform("Gravity", GravityBtn) end)
SolarBtn.MouseButton1Click:Connect(function() SetPlatform("Solar", SolarBtn) end)
SFSymbolsBtn.MouseButton1Click:Connect(function() SetPlatform("SFSymbols", SFSymbolsBtn) end)

ClosePView.MouseButton1Click:Connect(function() PViewFrame.Visible = false end)

CopyID.MouseButton1Click:Connect(function()
	local id = PreviewIcon.Image:match("%d+$")
	if id then setclipboard(id) end
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
RefreshBtn.MouseButton1Click:Connect(function() LoadIcons(PlatformName.Text) end)

UIGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	IconList.CanvasSize = UDim2.new(0, 0, 0, UIGrid.AbsoluteContentSize.Y + 20)
end)

LoadIcons("Lucide")
