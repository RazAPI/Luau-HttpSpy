--[[
    Filename.: HttpSpy.luau
    Description.: HttpSpy that sends detailed information of an HTTP Request, this is for low level executors \\ externals executors.
    Author.: lucibedroque \\ RazAPIx64 \\ RazAPI \\ Raz \\ Lucien,
	Credits.: laera/laeraz (debugging)
]]

local PrintConsole = function(Option, ...)
    assert(Option < 4, "No options above 3")

    local Options = {[1] = print, [2] = warn, [3] = error}
    if not Options[Option] then return "Invalid Option" end

    return Options[Option](...)
end

local SignConnection = function(Connection, Callback)
    assert(type(Callback) == "function", "Bad argument")
    return Connection:Connect(Callback)
end

local HSIHService = { --// HttpSpyInterfaceHandleService
	Fonts = { Inter = Font.fromId(12187365364) },

    CreateObject = function(Class, Properties)
		local Object = Instance.new(Class)

		for i,v in Properties do
			Object[i] = v
		end

		Object.Name = "\0" .. Object.Name
		return Object
	end,

	CheckServiceHandleByName = function(Name)
		local Success, Result = pcall(function()
			return game:GetService(Name):GetFullName()
		end)

		if Name == "CoreGui" and not Success then
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end

		if Success then
			return game:GetService(Name)
		end
	end,
}

local HttpSpyDeps = { Check = function(Object, Fallback) if type(Object) ~= "function" then return Fallback or nil end return Object end }
local HttpSpySources = { getgenv = HttpSpyDeps.Check(getgenv, getfenv(0)), New = Instance.new, DataModel = game }
--// Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
--// Studio check, no ones using this in studio anyway.

if RunService:IsStudio() then
    PrintConsole(2, "[ HttpSpy ]: Cannot use in Studio, switch to the Roblox Client.")
    return --[[ 72 65 74 75 72 6e 20 22 54 68 69 73 20 70 72 6f 76 69 64 65 72 20 63 61 6e 6e 6f 74 20 65 6e 66 6f 72 63 65 20 74 68 65 20 67 72 6f 75 70 20 70 6f 6c 69 63 79 20 62 79 20 52 6f 62 6c 6f 78 20 53 74 75 64 69 6f 2c 20 73 77 69 74 63 68 20 74 6f 20 74 68 65 20 52 6f 62 6c 6f 78 20 50 6c 61 79 65 72 20 43 6c 69 65 6e 74 20 69 6e 6f 72 64 65 72 20 74 6f 20 75 73 65 20 74 68 65 20 48 44 55 22  ]]
end

--[[
    -- Settings Documentation --
        [ Set User Agent ]:
        
    This sets a custom header (User-Agent) when sending requests.

    false: Uses the default User-Agent the executor uses.
    string: Sets the User-Agent to that specific string.
]]

local KeyCheckState = {
    Decided = false,
    Result = false
}
local HttpSpyConfig = { ["SetUserAgent"] = false }

HttpSpyDeps.WrapUserData = function(IndexModify, NewIndexModify)
    local Proxy = newproxy(true)
    local Metatable = getmetatable(Proxy)

    Metatable.__index = IndexModify
    Metatable.__newindex = NewIndexModify

    return Proxy
end

HttpSpySources.request = HttpSpyDeps.Check(request)

if HttpSpySources.request == nil then
    PrintConsole(2, `[ HttpSpy ]: The function "request" is needed inorder to continue.`)
end

HttpSpyDeps.DisplayConnMessageBox = function(Url, Method, State)
    local ScreenGui = HSIHService.CreateObject("ScreenGui", { Name = "MessageBoxHandle", Parent = HSIHService.CheckServiceHandleByName("CoreGui"), DisplayOrder = 2147483647 })
    local MessageBox = HSIHService.CreateObject("Frame", { Name = "MessageBox", Parent = ScreenGui, Position = UDim2.new(0.3385, 0, 0.1828, 0), Size = UDim2.new(0, 544, 0, 257), BackgroundColor3 = Color3.new(0.098, 0.098, 0.1176), BackgroundTransparency = 0.02, BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0) })
    local Close = HSIHService.CreateObject("TextButton", { Name = "Close", Parent = MessageBox, Position = UDim2.new(0.9495, 0, 0.0794, 0), Size = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.new(1, 0.4157, 0.4235), BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0), Text = "", TextColor3 = Color3.new(0, 0, 0), FontFace = HSIHService.Fonts.Inter, TextSize = 14 })
    HSIHService.CreateObject("UICorner", { Parent = Close })
    HSIHService.CreateObject("UICorner", { Parent = MessageBox, CornerRadius = UDim.new(0, 15) })
    local Seperator = HSIHService.CreateObject("Frame", { Name = "Seperator", Parent = MessageBox, Position = UDim2.new(0.0306, 0, 0.1854, 0), Size = UDim2.new(0, 521, 0, 1), BackgroundColor3 = Color3.new(0.1176, 0.1176, 0.1373), BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.01 })
    local ConnectionIntercepted = HSIHService.CreateObject("TextLabel", { Name = "ConnectionIntercepted", Parent = MessageBox, Position = UDim2.new(0.0414, 0, 0.0506, 0), Size = UDim2.new(0, 135, 0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0), Text = "Connection Intercepted", TextColor3 = Color3.new(1, 1, 1), FontFace = HSIHService.Fonts.Inter, TextSize = 16 })
    local Frame = HSIHService.CreateObject("Frame", { Name = "Frame", Parent = MessageBox, Position = UDim2.new(0.0603, 0, 0.2423, 0), Size = UDim2.new(0, 468, 0, 132), BackgroundColor3 = Color3.new(0.1176, 0.1176, 0.1373), BackgroundTransparency = 0.3, BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0) })
    HSIHService.CreateObject("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 13) })
    HSIHService.CreateObject("UIStroke", { Parent = Frame, Thickness = 2, Color = Color3.fromRGB(25, 25, 30), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round, Transparency = 0, ZIndex = 1 })
    local TimeAndDateInfo = HSIHService.CreateObject("TextLabel", { Name = "TimeAndDateInfo", Parent = Frame, Position = UDim2.new(0.3678, 0, -0.0075, 0), Size = UDim2.new(0, 122, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "0/00/0000 — 00:00:00", TextColor3 = Color3.new(0.6667, 0.6667, 0.6667), FontFace = HSIHService.Fonts.Inter, TextSize = 12 })
    local Cancel = HSIHService.CreateObject("TextButton", { Name = "Cancel", Parent = MessageBox, Position = UDim2.new(0.7105, 0, 0.8016, 0), Size = UDim2.new(0, 114, 0, 38), BackgroundColor3 = Color3.new(0.1373, 0.1373, 0.1569), BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0), Text = "Cancel", TextColor3 = Color3.new(1, 1, 1), FontFace = HSIHService.Fonts.Inter, TextSize = 16 })
    HSIHService.CreateObject("UICorner", { Parent = Cancel, CornerRadius = UDim.new(0, 30) })
    local Allow = HSIHService.CreateObject("TextButton", { Name = "Allow", Parent = MessageBox, Position = UDim2.new(0.0592, 0, 0.8016, 0), Size = UDim2.new(0, 114, 0, 38), BackgroundColor3 = Color3.new(0.1373, 0.1373, 0.1569), BorderSizePixel = 0, BorderColor3 = Color3.new(0, 0, 0), Text = "Allow", TextColor3 = Color3.new(1, 1, 1), FontFace = HSIHService.Fonts.Inter, TextSize = 16 })
    HSIHService.CreateObject("UICorner", { Parent = Allow, CornerRadius = UDim.new(0, 30) })
    local ConfirmText = HSIHService.CreateObject("TextLabel", {
        Name = "ConfirmText",   
        Parent = Frame,
        Position = UDim2.new(0.03, 0, 0.15, 0),
        Size = UDim2.new(0.94, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Text = `Are you sure you would like to send a {Method} request to {Url}?`,
        TextColor3 = Color3.new(1, 1, 1),
        FontFace = HSIHService.Fonts.Inter,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })

    State.ConfirmText = ConfirmText

    SignConnection(Close.MouseButton1Click, function()
        ScreenGui:Destroy()
    end)

    SignConnection(Allow.MouseButton1Click, function()
        State.Result = true
        State.Decided = true

        if State.ConfirmText then
            State.ConfirmText.Text = State.ConfirmText.Text .. "\n\nSending request..."
        end
    end)

    SignConnection(Cancel.MouseButton1Click, function()
        State.Result = false
        State.Decided = true
        ScreenGui:Destroy()
    end)

    task.spawn(function()
        while ScreenGui.Parent do
            local GlutTaskProcess = os.date("*t")
            local LocaleTime = os.date("%X")
            
            TimeAndDateInfo.Text = `{GlutTaskProcess.month}/{GlutTaskProcess.day}/{GlutTaskProcess.year} — {(LocaleTime:find("AM") or LocaleTime:find("PM")) and ((GlutTaskProcess.hour % 12 == 0 and 12 or GlutTaskProcess.hour % 12)) or GlutTaskProcess.hour}:{(GlutTaskProcess.min < 10 and `0{GlutTaskProcess.min}` or GlutTaskProcess.min)}:{(GlutTaskProcess.sec < 10 and `0{GlutTaskProcess.sec}` or GlutTaskProcess.sec)}{(LocaleTime:find("AM") or LocaleTime:find("PM")) and ((GlutTaskProcess.hour >= 12) and " PM" or " AM") or ""}`
            task.wait()
        end
    end)
end


HttpSpyDeps.ProcessConnection = function(State)
    local Connection

    local KeyActions = {
        [Enum.KeyCode.Insert] = function()
            State.Result = true
            State.Decided = true

            if State.ConfirmText then
                State.ConfirmText.Text = State.ConfirmText.Text .. "\n\nSending request..."
            end
        end,

        [Enum.KeyCode.Delete] = function()
            State.Result = false
            State.Decided = true
        end
    }

    Connection = SignConnection(UserInputService.InputBegan, function(Input, GameProcessed)
        if GameProcessed or State.Decided then
            return
        end

        local Action = KeyActions[Input.KeyCode]
        if Action then
            Action()
            Connection:Disconnect()
        end
    end)

    repeat
        task.wait()
    until State.Decided

    if Connection then
        Connection:Disconnect()
    end

    return State.Result
end

getgenv().request = function(Options)
    --[[
        {
            Url: string,
            Method: string,
            Body: string?,
            Headers: table?,
            Cookies: table?
        }
    ]]

    assert(type(Options) == "table", `invalid argument #1 for "request", expected table got {type(Options)}`)

    if type(Options.Url) == "string" and type(Options.Method) == "string" then
        PrintConsole(1, `[ HttpSpy - Connection ({Options.Method}) ]: Send {Options.Method} request to {Options.Url}?\n\n(Press Insert key to Allow, Press Delete key to Abort/Cancel)`)

        local State = KeyCheckState

        HttpSpyDeps.DisplayConnMessageBox(Options.Url, Options.Method, State)

        if HttpSpyDeps.ProcessConnection(State) then
            local StartTime = State.StartTime or os.clock()

            if HttpSpyConfig.SetUserAgent ~= false then
                local Success, Result = pcall(function()
                    return HttpSpySources.request({
                        Url = Options.Url,
                        Method = Options.Method,
                        Headers = HttpService:JSONEncode({
                            ["user-agent"] = HttpSpyConfig.SetUserAgent
                        })
                    }).Body
                end)

                local Took = math.floor((os.clock() - StartTime) * 1000)

                if State.ConfirmText then
                    State.ConfirmText.Text = State.ConfirmText.Text .. `\n\nFinished in {Took} ms`
                end

                if Success then
                    return Result.Body
                else
                    PrintConsole(2, `[HttpSpy - VSE]: Failed to set user-agent.`)
                end
            else
                local Result = HttpSpySources.request({ 
                    Url = Options.Url,
                    Method = Options.Method,
                })

                local Took = math.floor((os.clock() - StartTime) * 1000)

                if State.ConfirmText then
                    State.ConfirmText.Text = State.ConfirmText.Text .. `\n\nFinished in {Took} ms`
                end

                return Result.Body
            end
        else
            PrintConsole(2, `[ HttpSpy - Connection ]: {Options.Method} request to {Options.Url} cancelled`)
        end
    end

    --// No typechecks, considering the fact it's supposed to be handled by the main function instead.
end

getgenv().game = HttpSpyDeps.WrapUserData(HttpSpySources.DataModel, function(self, Index)
    if Index == "HttpGet" then
        return function(self, Url)
            assert(type(Url) == "string", `[ HttpSpy ] invalid argument #1 to HttpGet, expected string got {type(Url)}`)

            PrintConsole(1, `[ HttpSpy - Connection (GET) ]: Send GET request to {Url}?\n\n(Press Insert key to Allow, Press Delete key to Abort/Cancel)`)

            local State = KeyCheckState
            HttpSpyDeps.DisplayConnMessageBox(Url, "GET", State)

            local StartTime = os.clock()
            if HttpSpyDeps.ProcessConnection(State) then
                if HttpSpyConfig.SetUserAgent ~= false then
                    local Success, Result = pcall(function()
                        return HttpSpySources.request({
                            Url = Url,
                            Method = "GET",
                            Headers = { ["user-agent"] = HttpSpyConfig.SetUserAgent }
                        })
                    end)

                    local Took = math.floor((os.clock() - StartTime) * 1000)
                    if State.ConfirmText then
                        State.ConfirmText.Text = State.ConfirmText.Text .. `\nFinished in {Took} ms`
                    end

                    if Success then
                        return Result.Body
                    else
                        PrintConsole(2, `[HttpSpy - VSE ]: Failed to set user-agent to {HttpSpyConfig.SetUserAgent}, your current exploit does not allow you to change headers.`)
                    end
                else
                    local Result = HttpSpySources.request({
                        Url = Url,
                        Method = "GET",
                    })

                    local Took = math.floor((os.clock() - StartTime) * 1000)
                    if State.ConfirmText then
                        State.ConfirmText.Text = State.ConfirmText.Text .. `\nFinished in {Took} ms`
                    end

                    return Result.Body
                end
            else
                PrintConsole(2, `[ HttpSpy - Connection ]: GET request to {Url} cancelled`)
            end
        end

    elseif Index == "HttpPost" then
        return function(self, Url, Body, Headers)
            assert(type(Url) == "string", `[HttpSpy] invalid argument #1 to HttpPost, expected string got {type(Url)}`)

            PrintConsole(1, `[HttpSpy - Connection (POST)]: Send POST request to {Url}? (Insert = Allow, Delete = Abort)`)

            local State = KeyCheckState
            HttpSpyDeps.DisplayConnMessageBox(Url, "POST", State)

            local StartTime = os.clock()
            if HttpSpyDeps.ProcessConnection(State) then
                if HttpSpyConfig.SetUserAgent ~= false then
                    local Success, Result = pcall(function()
                        return HttpSpySources.request({
                            Url = Url,
                            Method = "POST",
                            Body = Body,
                            Headers = { ["user-agent"] = HttpSpyConfig.SetUserAgent }
                        })
                    end)

                    local Took = math.floor((os.clock() - StartTime) * 1000)
                    if State.ConfirmText then
                        State.ConfirmText.Text = State.ConfirmText.Text .. `\nFinished in {Took} ms`
                    end

                    if Success then 
                        return Result.Body
                    else
                        PrintConsole(2, `[HttpSpy - VSE ]: Failed to set user-agent to {HttpSpyConfig.SetUserAgent}, your current exploit does not allow you to change headers.`) 
                    end
                else
                    local Result = HttpSpySources.request({
                        Url = Url,
                        Method = "POST",
                        Body = Body,
                        Headers = Headers
                    })

                    local Took = math.floor((os.clock() - StartTime) * 1000)
                    if State.ConfirmText then
                        State.ConfirmText.Text = State.ConfirmText.Text .. `\nFinished in {Took} ms`
                    end

                    return Result.Body
                end
            else
                PrintConsole(2, `[HttpSpy]: POST request to {Url} cancelled`)
            end
        end
    end

    return HttpSpySources.DataModel[Index]
end)

return HttpSpyConfig
