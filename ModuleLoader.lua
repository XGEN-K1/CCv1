-- ModuleLoader.lua
-- Система завантаження та управління модулями

local ModuleLoader = {}

-- Глобальний доступ до модулів
getgenv().CC_Modules = {}

-- Функція безпечного завантаження модуля
function ModuleLoader.LoadModule(moduleName, url)
    local success, result = pcall(function()
        local content = game:HttpGet(url)
        local module = loadstring(content)()
        return module
    end)
    
    if success then
        print("✅ Завантажено модуль: " .. moduleName)
        getgenv().CC_Modules[moduleName] = result
        return result
    else
        warn("❌ Помилка завантаження модуля " .. moduleName .. ": " .. tostring(result))
        return nil
    end
end

-- Функція завантаження всіх модулів
function ModuleLoader.LoadAll(moduleUrls)
    local loadedModules = {}
    
    for moduleName, url in pairs(moduleUrls) do
        if moduleName ~= "ModuleLoader" then -- Не завантажуємо сам себе
            local module = ModuleLoader.LoadModule(moduleName, url)
            if module then
                loadedModules[moduleName] = module
            end
        end
    end
    
    return loadedModules
end

-- Функція отримання модуля
function ModuleLoader.GetModule(moduleName)
    return getgenv().CC_Modules[moduleName]
end

-- Функція перезавантаження модуля
function ModuleLoader.ReloadModule(moduleName, url)
    if getgenv().CC_Modules[moduleName] and getgenv().CC_Modules[moduleName].Destroy then
        pcall(getgenv().CC_Modules[moduleName].Destroy)
    end
    
    return ModuleLoader.LoadModule(moduleName, url)
end

-- Деструктор
function ModuleLoader.Destroy()
    for moduleName, module in pairs(getgenv().CC_Modules) do
        if module and module.Destroy then
            pcall(module.Destroy)
        end
    end
    getgenv().CC_Modules = {}
end

return ModuleLoader
