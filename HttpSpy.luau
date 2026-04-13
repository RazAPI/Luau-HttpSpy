--[[
    Filename.: HttpSpy.luau
    Description.: HttpSpy that sends detailed information of an HTTP Request (print-only, no UI).
    Author.: lucibedroque \ RazAPIx64 \ RazAPI \ Raz \ Lucien
    Credits.: laera/laeraz (debugging)
]]

--// Dependency Library
local RazAPI = {}

RazAPI.TypeCheck = function(Object, Type, FunctionName, Param)
	assert(typeof(Object) == Type, `invalid argument #{Param} for {FunctionName}, expected {Type}, got {typeof(Object)}`)
end
--// Environment Dependencies
local PrintConsole = function(Option, ...)
    assert(Option < 4, "No options above 3")

    local Options = {[1] = print, [2] = warn}
    if not Options[Option] then return "Invalid Option" end

    return Options[Option](...)
end

local SignConnection = function(Connection, Callback)
    assert(type(Callback) == "function", "Bad argument")
    return Connection:Connect(Callback)
end

local HttpSpyDeps = { Check = function(Object, Fallback) if type(Object) ~= "function" then return Fallback or nil end return Object end }
local HttpSpySources = { getgenv = HttpSpyDeps.Check(getgenv, getfenv(0)), New = Instance.new, DataModel = game }

--// Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
--// Studio check, no ones using this in studio anyway.

if RunService:IsStudio() then
    PrintConsole(2, "[ HttpSpy ]: Cannot use in Studio, switch to the Roblox Client.")
    return
end

--[[
    -- Settings Documentation --
        [ Set User Agent ]:
        
    This sets a custom header (User-Agent) when sending requests.

    false: Uses the default User-Agent the executor uses.
    string: Sets the User-Agent to that specific string.
]]

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
    PrintConsole(2, `[ HttpSpy ]: The function "request" is needed in order to continue.`)
    return
end

local function BuildHeaders(ExtraHeaders)
    if HttpSpyConfig.SetUserAgent ~= false then
        local Headers = ExtraHeaders or {}
        Headers["user-agent"] = HttpSpyConfig.SetUserAgent
        return Headers
    end

    return ExtraHeaders
end

local function ExecuteRequest(Options)
    local StartTime = os.clock()

    local Success, Result = pcall(HttpSpySources.request, {
        Url = Options.Url,
        Method = Options.Method,
        Body = Options.Body,
        Headers = BuildHeaders(Options.Headers),
    })

    local Took = math.floor((os.clock() - StartTime) * 1000)

    if Success then
        PrintConsole(1, `[ HttpSpy ]: {Options.Method} {Options.Url} — {Took} ms | Status: {Result.StatusCode}`)
        return Result.Body
    else
        PrintConsole(2, `[ HttpSpy ]: {Options.Method} {Options.Url} failed after {Took} ms — {Result}`)
        return nil
    end
end

local function ProcessConnection()
    local Decided = false
    local Allowed = false
    local Connection

    Connection = SignConnection(UserInputService.InputBegan, function(Input, GameProcessed)
        if GameProcessed or Decided then return end

        if Input.KeyCode == Enum.KeyCode.Insert then
            Allowed = true
            Decided = true
        elseif Input.KeyCode == Enum.KeyCode.Delete then
            Allowed = false
            Decided = true
        end

        if Decided and Connection then
            Connection:Disconnect()
        end
    end)

    repeat task.wait() until Decided

    if Connection then Connection:Disconnect() end
    return Allowed
end

getgenv().request = function(Options)
    RazAPI.TypeCheck(Options.Url, "string", "request", 1)
    RazAPI.TypeCheck(Options.Method, "string", "request", 1)

    PrintConsole(1, `[ HttpSpy - Connection ({Options.Method}) ]: Send {Options.Method} request to {Options.Url}? (Insert = Allow | Delete = Cancel)`)

    if ProcessConnection() then
        return ExecuteRequest(Options)
    else
        PrintConsole(2, `[ HttpSpy ]: {Options.Method} request to {Options.Url} cancelled.`)
    end
end

getgenv().game = HttpSpyDeps.WrapUserData(HttpSpySources.DataModel, function(self, Index)
    if Index == "HttpGet" then
        return function(self, Url)
            assert(type(Url) == "string", `[ HttpSpy ] invalid argument #1 to HttpGet, expected string got {type(Url)}`)
            PrintConsole(1, `[ HttpSpy - Connection (GET) ]: Send GET request to {Url}? (Insert = Allow | Delete = Cancel)`)

            if ProcessConnection() then
                return ExecuteRequest({ Url = Url, Method = "GET" })
            else
                PrintConsole(2, `[ HttpSpy ]: GET request to {Url} cancelled.`)
            end
        end

    elseif Index == "HttpPost" then
        return function(self, Url, Body, Headers)
            assert(type(Url) == "string", `[ HttpSpy ] invalid argument #1 to HttpPost, expected string got {type(Url)}`)
            PrintConsole(1, `[ HttpSpy - Connection (POST) ]: Send POST request to {Url}? (Insert = Allow | Delete = Cancel)`)

            if ProcessConnection() then
                return ExecuteRequest({ Url = Url, Method = "POST", Body = Body, Headers = Headers })
            else
                PrintConsole(2, `[ HttpSpy ]: POST request to {Url} cancelled.`)
            end
        end
    end

    return HttpSpySources.DataModel[Index]
end)

return HttpSpyConfig
