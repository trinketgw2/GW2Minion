gw2_api_manager = {}
gw2_api_manager.API_Data = {}
gw2_api_manager.path = GetLuaModsPath() .. "\\GW2Minion\\API_Data\\"
gw2_api_manager.icons_path = GetLuaModsPath() .. "\\GW2Minion\\Icons\\"
gw2_api_manager.API_Call_Ticks = 0
gw2_api_manager.imageticks = 0
gw2_api_manager.HTTP_Status = {
   queued = 1,
   request_sent = 2,
   data_received = 3,
   download_queued = 4,
   downloading = 5,
}
gw2_api_manager.http_requests = {}
gw2_api_manager.api_requests = {}
gw2_api_manager.API_Request_Running = false
gw2_api_manager.categories = {
   "skills",
   "items",
   "currencies",
   "files",
   "commerce",
}
gw2_api_manager.data_path = GetLuaModsPath() .. "\\GW2Minion\\API_Data\\"
gw2_api_manager.data_folders = {
   skills = gw2_api_manager.data_path .. "skills\\",
   items = gw2_api_manager.data_path .. "items\\",
   currencies = gw2_api_manager.data_path .. "currencies\\",
   files = gw2_api_manager.data_path .. "files\\",
   commerce = gw2_api_manager.data_path .. "commerce\\",
}
gw2_api_manager.folders = {
   skills = gw2_api_manager.icons_path .. "skills\\",
   items = gw2_api_manager.icons_path .. "items\\",
   currencies = gw2_api_manager.icons_path .. "currencies\\",
   files = gw2_api_manager.icons_path .. "files\\",
   commerce = gw2_api_manager.icons_path .. "commerce\\",
}
gw2_api_manager.hosts = {
   skills = "api.guildwars2.com",
   items = "api.guildwars2.com",
   currencies = "api.guildwars2.com",
   files = "api.guildwars2.com",
   commerce = "api.guildwars2.com",
}
gw2_api_manager.languages = {
   [0] = "en",
   [2] = "fr",
   [3] = "de",
   [4] = "es",
   [5] = "cn",
}
gw2_api_manager.paths = {
   skills = "/v2/skills",
   items = "/v2/items",
   currencies = "/v2/currencies",
   files = "v2/files",
   commerce = "/v2/commerce",
}
gw2_api_manager.language_dependent = {
   name = true,
   description = true,
   status = true,
   text = true,
}
gw2_api_manager.chinese = Player:GetLanguage() == 5

-- create folders, load already gathered data files
function gw2_api_manager.ModuleInit()

   for _, foldername in pairs(gw2_api_manager.folders) do
      if not FolderExists(foldername) then
         FolderCreate(foldername)
      end
   end

   for _, foldername in pairs(gw2_api_manager.data_folders) do
      if not FolderExists(foldername) then
         FolderCreate(foldername)
      end
   end

   gw2_api_manager.Load_API_Data()
   gw2_api_manager.Load_Blacklist()
end

-- load already gathered data files
function gw2_api_manager.Load_API_Data()
   for _, foldername in pairs(FolderList(gw2_api_manager.path, ".*", true)) do
      for _, file in pairs(FolderList(gw2_api_manager.path .. foldername, ".*.lua", false) or {}) do
         gw2_api_manager.API_Data[foldername] = gw2_api_manager.API_Data[foldername] or {}
         gw2_api_manager.API_Data[foldername][string.trim(file, 4)] = FileLoad(gw2_api_manager.path .. foldername .. "\\" .. file) or {}
      end
   end
end

-- save already gathered data to lua files
function gw2_api_manager.Save_API_Data(category, id)
   if not category then
      for category, v in pairs(gw2_api_manager.API_Data) do
         if category ~= "blacklist" then
            if not FolderExists(gw2_api_manager.data_path .. category) then
               FolderCreate(gw2_api_manager.data_path .. category)
            end

            for k2, v2 in pairs(gw2_api_manager.API_Data[category]) do
               FileSave(gw2_api_manager.data_path .. category .. "\\" .. k2 .. ".lua", gw2_api_manager.API_Data[category][k2])
            end
         end
      end
   else
      if category ~= "blacklist" then
         if not FolderExists(gw2_api_manager.data_path .. category) then
            FolderCreate(gw2_api_manager.data_path .. category)
         end

         if not id then
            for k, v in pairs(gw2_api_manager.API_Data[category]) do
               FileSave(gw2_api_manager.data_path .. category .. "\\" .. k .. ".lua", gw2_api_manager.API_Data[category][k])
            end

         elseif type(id) == "number" or type(id) == "string" then
            FileSave(gw2_api_manager.data_path .. category .. "\\" .. id .. ".lua", gw2_api_manager.API_Data[category][id])
         elseif type(id) == "table" then
            for _, entry in pairs(id) do
               FileSave(gw2_api_manager.data_path .. category .. "\\" .. entry .. ".lua", gw2_api_manager.API_Data[category][entry])
            end
         end
      end
   end
end

-- get passed time in seconds based on os.time(), we need to know if the data is from the same day or not
function gw2_api_manager.TimeSince(time)
   if time then
      return os.time() - time
   end

   return 86400 -- return 24 h when no time is given, just lazy stuff so we can call it without checking the time
end

-- create a new HTTP request to fetch data of an item/skill/currency/... - if not available yet or forced
function gw2_api_manager.queue_API_Data(id, category, forced)
   local tbl, ids = {}, {}
   local s = gw2_api_manager.HTTP_Status
   local categories = gw2_api_manager.categories
   local hosts = gw2_api_manager.hosts
   local languages = gw2_api_manager.languages
   local paths = gw2_api_manager.paths

   -- get category
   for k, v in pairs(categories) do
      if category == k or category == v then
         category = v
      end
   end

   gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
   gw2_api_manager.http_requests[category] = gw2_api_manager.http_requests[category] or {}
   gw2_api_manager.api_requests[category] = gw2_api_manager.api_requests[category] or {}

   if (type(id) == "string" or type(id) == "number") and not gw2_api_manager.is_Blacklisted(id, category) and (not gw2_api_manager.api_requests[category][id] or TimeSince(gw2_api_manager.api_requests[category][id]) > 5000) then
      gw2_api_manager.api_requests[category][id] = ml_global_information.Now
      tbl[category] = tbl[category] or {}
      tbl[category][id] = { status = s.queued, url = false, forced = forced or false }
      table.insert(ids, id)
   end

   if type(id) == "table" then
      local count = 0
      for _, entry in pairs(id) do
         if count < 200 and not gw2_api_manager.is_Blacklisted(entry, category) and (not gw2_api_manager.api_requests[category][entry] or TimeSince(gw2_api_manager.api_requests[category][entry]) > 5000) then
            gw2_api_manager.api_requests[category][entry] = ml_global_information.Now
            tbl[category] = tbl[category] or {}
            tbl[category][entry] = { status = s.queued, url = false, forced = forced or false }
            table.insert(ids, entry)
            count = count + 1
         end
      end
   end

   if tbl[category] then
      local idstring, count = "", 0
      for id, entry in pairs(tbl[category]) do
         if count < 200 and (entry.forced or ((not gw2_api_manager.http_requests[category][entry] or not gw2_api_manager.http_requests[category][entry].status == s.queued) and not gw2_api_manager.API_Data[category][entry] or (gw2_api_manager.API_Data[category][entry].lastupdate) and gw2_api_manager.TimeSince(gw2_api_manager.API_Data[category][entry].lastupdate) > 900)) then
            if (idstring == "") then
               idstring = tostring(id)
            else
               idstring = idstring .. "," .. tostring(id)
            end
            count = count + 1
         end
      end

      local function success(str)
         local data = json.decode(str)
         gw2_api_manager.API_Request_Running = false
         gw2_api_manager.http_requests[idstring .. " - " .. category] = nil

         if data.text == "all ids provided are invalid" then
            d("[gw2_api_manager]: Requested ids are invalid.")
            for k, v in pairs(ids) do
               gw2_api_manager.add_to_Blacklist(v, category)
            end
            return
         end

         d("[gw2_api_manager]: HTTP Request successful.")
         for k, v in pairs(ids) do
            local found = false
            for _, entry in pairs(data) do
               if entry.id == v then
                  found = true
               end
            end

            if not found then
               gw2_api_manager.add_to_Blacklist(v, category)
            end
         end

         local time = os.time()
         for _, entry in pairs(data) do
            gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
            gw2_api_manager.API_Data[category][entry.id] = gw2_api_manager.setEntryData(entry, category)
            gw2_api_manager.API_Data[category][entry.id].lastupdate = time
         end
         gw2_api_manager.Save_API_Data(category, ids)
      end

      local function failed(str)
         d("[gw2_api_manager]: HTTP Request failed.")
         local data = json.decode(str)
         d(data or str)
         gw2_api_manager.API_Request_Running = false
      end

      if count >= 1 then
         local params = { host = hosts[category], path = paths[category] .. "?ids=" .. idstring .. "&lang=" .. languages[Player:GetLanguage()], port = 443, method = "GET", https = true, onsuccess = success, onfailure = failed }
         gw2_api_manager.http_requests[idstring .. " - " .. category] = params
         gw2_api_manager.http_requests[idstring .. " - " .. category].status = s.queued
      end

      return tbl
   end

   return false
end

-- create a new HTTP request to fetch data of an item/skill/currency/... - if not available yet or forced
function gw2_api_manager.queue_API_Prices(id, forced)
   local tbl, ids = {}, {}
   local s = gw2_api_manager.HTTP_Status
   local categories = gw2_api_manager.categories
   local hosts = gw2_api_manager.hosts
   local languages = gw2_api_manager.languages
   local paths = gw2_api_manager.paths
   category = "commerce"
   tbl[category] = tbl[category] or {}

   gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
   gw2_api_manager.http_requests[category] = gw2_api_manager.http_requests[category] or {}
   gw2_api_manager.api_requests[category] = gw2_api_manager.api_requests[category] or {}

   if (type(id) == "string" or type(id) == "number") and not gw2_api_manager.is_Blacklisted(id, category) and (not gw2_api_manager.api_requests[category][id] or TimeSince(gw2_api_manager.api_requests[category][id]) > 5000) then
      gw2_api_manager.api_requests[category][id] = ml_global_information.Now
      tbl[category] = tbl[category] or {}
      tbl[category][id] = tbl[category][id] or { status = s.queued, url = false, forced = forced or false }
      table.insert(ids, id)
   end

   if type(id) == "table" then
      local count = 0
      for _, entry in pairs(id) do
         if count < 200 and not gw2_api_manager.is_Blacklisted(entry, category) and (not gw2_api_manager.api_requests[category][entry] or TimeSince(gw2_api_manager.api_requests[category][entry]) > 5000) then
            tbl[category][entry] = tbl[category][entry] or { status = s.queued, url = false, forced = forced or false }
            gw2_api_manager.api_requests[category][entry] = ml_global_information.Now
            table.insert(ids, entry)
            count = count + 1
         end
      end
   end

   local idstring, count = "", 0
   for id, entry in pairs(tbl[category]) do
      if count < 200 and (entry.forced or ((not gw2_api_manager.http_requests[category][entry] or not gw2_api_manager.http_requests[category][entry].status == s.queued) and not gw2_api_manager.API_Data[category][entry] or (gw2_api_manager.API_Data[category][entry].lastupdate) and gw2_api_manager.TimeSince(gw2_api_manager.API_Data[category][entry].lastupdate) > 900)) then
         if (idstring == "") then
            idstring = tostring(id)
         else
            idstring = idstring .. "," .. tostring(id)
         end
         count = count + 1
      end
   end

   local function success(str)
      local data = json.decode(str)

      if data.text == "all ids provided are invalid" then
         d("[gw2_api_manager]: Requested ids are invalid.")
         for k, v in pairs(ids) do
            gw2_api_manager.add_to_Blacklist(v, category)
         end
         return
      end

      for k, v in pairs(ids) do
         local found = false
         for _, entry in pairs(data) do
            if entry.id == v then
               found = true
            end
         end

         if not found then
            gw2_api_manager.add_to_Blacklist(v, category)
         end
      end

      d("[gw2_api_manager]: HTTP Request successful.")
      local time = os.time()
      for _, entry in pairs(data) do
         gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
         gw2_api_manager.API_Data[category][entry.id] = gw2_api_manager.setEntryData(entry, category)
         gw2_api_manager.API_Data[category][entry.id].lastupdate = time
      end
      gw2_api_manager.API_Request_Running = false
      gw2_api_manager.http_requests[idstring .. " - " .. category] = nil
      gw2_api_manager.Save_API_Data(category, ids)
   end

   local function failed(str)
      d("[gw2_api_manager]: HTTP Request failed.")
      gw2_api_manager.API_Request_Running = false
      local data = json.decode(str)
      d(data or str)
   end

   if count >= 1 then
      local params = { host = hosts[category], path = paths[category] .. "/prices?ids=" .. idstring, port = 443, method = "GET", https = true, onsuccess = success, onfailure = failed }
      gw2_api_manager.http_requests[idstring .. " - " .. category] = params
      gw2_api_manager.http_requests[idstring .. " - " .. category].status = s.queued
   end

   return tbl
end

-- create a new HTTP request to fetch data of an item/skill/currency/... - if not available yet or forced
function gw2_api_manager.queue_API_Listings(id, forced)
   local tbl, ids = {}, {}
   local s = gw2_api_manager.HTTP_Status
   local categories = gw2_api_manager.categories
   local hosts = gw2_api_manager.hosts
   local languages = gw2_api_manager.languages
   local paths = gw2_api_manager.paths
   category = "commerce"
   tbl[category] = tbl[category] or {}

   gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
   gw2_api_manager.http_requests[category] = gw2_api_manager.http_requests[category] or {}
   gw2_api_manager.api_requests[category] = gw2_api_manager.api_requests[category] or {}

   if (type(id) == "string" or type(id) == "number") and not gw2_api_manager.is_Blacklisted(id, category) and (not gw2_api_manager.api_requests[category][id] or TimeSince(gw2_api_manager.api_requests[category][id]) > 5000) then
      gw2_api_manager.api_requests[category][id] = ml_global_information.Now
      tbl[category] = tbl[category] or {}
      tbl[category][id] = tbl[category][id] or { status = s.queued, url = false, forced = forced or false }
      table.insert(ids, id)
   end

   if type(id) == "table" then
      local count = 0
      for _, entry in pairs(id) do
         if count < 200 and not gw2_api_manager.is_Blacklisted(entry, category) and (not gw2_api_manager.api_requests[category][entry] or TimeSince(gw2_api_manager.api_requests[category][entry]) > 5000) then
            tbl[category][entry] = tbl[category][entry] or { status = s.queued, url = false, forced = forced or false }
            gw2_api_manager.api_requests[category][entry] = ml_global_information.Now
            table.insert(ids, entry)
            count = count + 1
         end
      end
   end

   local idstring, count = "", 0
   for id, entry in pairs(tbl[category]) do
      if count < 200 and (entry.forced or ((not gw2_api_manager.http_requests[category][entry] or not gw2_api_manager.http_requests[category][entry].status == s.queued) and not gw2_api_manager.API_Data[category][entry] or (gw2_api_manager.API_Data[category][entry].lastupdate) and gw2_api_manager.TimeSince(gw2_api_manager.API_Data[category][entry].lastupdate) > 900)) then
         if (idstring == "") then
            idstring = tostring(id)
         else
            idstring = idstring .. "," .. tostring(id)
         end
         count = count + 1
      end
   end

   local function success(str)
      local data = json.decode(str)

      if data.text == "all ids provided are invalid" then
         d("[gw2_api_manager]: Requested ids are invalid.")
         for k, v in pairs(ids) do
            gw2_api_manager.add_to_Blacklist(v, category)
         end
         return
      end

      for k, v in pairs(ids) do
         local found = false
         for _, entry in pairs(data) do
            if entry.id == v then
               found = true
            end
         end

         if not found then
            gw2_api_manager.add_to_Blacklist(v, category)
         end
      end

      d("[gw2_api_manager]: HTTP Request successful.")
      local time = os.time()
      for _, entry in pairs(data) do
         gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
         gw2_api_manager.API_Data[category][entry.id] = gw2_api_manager.setEntryData(entry, category)
         gw2_api_manager.API_Data[category][entry.id].listing_update = time
         gw2_api_manager.API_Data[category][entry.id].lastupdate = time
      end
      gw2_api_manager.API_Request_Running = false
      gw2_api_manager.http_requests[idstring .. " - " .. category] = nil
      gw2_api_manager.Save_API_Data(category, ids)
   end

   local function failed(str)
      d("[gw2_api_manager]: HTTP Request failed.")
      gw2_api_manager.API_Request_Running = false
      local data = json.decode(str)
      d(data or str)
   end

   if count >= 1 then
      local params = { host = hosts[category], path = paths[category] .. "/listings?ids=" .. idstring, port = 443, method = "GET", https = true, onsuccess = success, onfailure = failed }
      gw2_api_manager.http_requests[idstring .. " - " .. category] = params
      gw2_api_manager.http_requests[idstring .. " - " .. category].status = s.queued
   end

   return tbl
end

-- download an Icon from the API, create a new HTTP request to fetch the data and icon url - if not available yet or forced
function gw2_api_manager.queue_API_Icon(id, category, url, forced)
   gw2_api_manager.ImageQueue = gw2_api_manager.ImageQueue or {}
   local s = gw2_api_manager.HTTP_Status
   local categories = gw2_api_manager.categories

   -- get category
   for k, v in pairs(categories) do
      if category == k or category == v then
         category = v
      end
   end

   if type(id) == "string" or type(id) == "number" then
      if not gw2_api_manager.is_Blacklisted(id, category) then
         gw2_api_manager.ImageQueue[category] = gw2_api_manager.ImageQueue[category] or {}
         gw2_api_manager.ImageQueue[category][id] = gw2_api_manager.ImageQueue[category][id] or { status = (url and s.download_queued) or s.queued, url = url or false, forced = forced or false }
         return gw2_api_manager.ImageQueue[category][id]
      end
   end

   if type(id) == "table" then
      local count = 0
      for _, entry in pairs(id) do
         if count < 200 and not gw2_api_manager.is_Blacklisted(id, category) then
            gw2_api_manager.ImageQueue[category] = gw2_api_manager.ImageQueue[category] or {}
            gw2_api_manager.ImageQueue[category][entry] = gw2_api_manager.ImageQueue[category][entry] or { status = (url and 2) or 1, url = url or false, forced = forced or false }
            count = count + 1
         end
      end
   end

   return gw2_api_manager.ImageQueue
end

-- add a manual HTTP request to the queue
function gw2_api_manager.add_HttpRequest(params)
   if table.valid(params) then
      table.insert(gw2_api_manager.http_requests, params)
      return true
   end

   return false
end

-- format the received lua table; since we have multiple languages we want to collect all names, descriptions, texts etc. so those are saved within name = {[0] = "english name", [3] = "german name" ....}
-- this way we can provide always the data in the Players language
function gw2_api_manager.setEntryData(data, category)
   gw2_api_manager.API_Data[category][data.id] = gw2_api_manager.API_Data[category][data.id] or {}
   local language = Player:GetLanguage()
   local tbl = gw2_api_manager.API_Data[category][data.id]
   for k, v in pairs(data) do
      if k == "sells" or k == "buys" then
         if table.valid(v) and v[1] then
            tbl[k] = tbl[k] or {}
            tbl[k] = v or {quantity = 0, unit_price = 0}
            tbl[k].quantity = v[1].quantity or 0
            tbl[k].unit_price = v[1].unit_price or 0
         elseif table.valid(v) then
            tbl[k] = tbl[k] or {quantity = 0, unit_price = 0}
            tbl[k].quantity = v.quantity or 0
            tbl[k].unit_price = v.unit_price or 0
         else
            tbl[k] = {quantity = 0, unit_price = 0}
         end
      elseif not gw2_api_manager.language_dependent[k] then
         tbl[k] = v
      elseif language ~= 5 then
         tbl[k] = tbl[k] or {}
         tbl[k][language] = v
      elseif gw2_api_manager.chinese and k == "name" then
         tbl[k] = tbl[k] or {}
         local _, item = next(Inventory("contentid=" .. data.id))
         if item then
            tbl[k][0] = v
            tbl[k][5] = item.name
         end
      end
   end

   return tbl
end

function gw2_api_manager.LoadData(category, id)
   local tbl = (gw2_api_manager.API_Data[category] and gw2_api_manager.API_Data[category][id] and gw2_api_manager.API_Data[category][id]) or FileLoad(gw2_api_manager.data_folders[category] .. id .. ".lua")
   local error

   if table.valid(tbl) then
      gw2_api_manager.API_Data[category][id] = tbl

      if category == "items" and gw2_api_manager.chinese and (not gw2_api_manager.API_Data[category][id].name[5] or gw2_api_manager.API_Data[category][id].name[5] == "") then

         local _, item = next(Inventory("contentid=" .. id))
         if item then
            gw2_api_manager.API_Data[category][id].name[5] = item.name
            gw2_api_manager.Save_API_Data("items", id)
         end
      end
   else
      tbl = {}
      error = "File contains not a valid table."
   end

   return tbl, error
end

-- returns the collected item/skill/currency/... info
-- for easy use juse use:
-- id = itemid / currency id / skillid or table of ids
-- category = item/skill/currency/...
-- all_data will force to return all language variants for the name, description, text ... ; default is false and returns only in Players language
-- creates automatically a new request if the requested info is not available
function gw2_api_manager.getInfo(id, category, all_data)
   local categories = gw2_api_manager.categories
   local request_ids, invalid_ids = {}, {}

   for k, v in pairs(categories) do
      if category == k or category == v then
         category = v
         break
      end
   end

   local tbl = {}
   if (type(id) == "string" or type(id) == "number") then
      if (gw2_api_manager.API_Data[category] and gw2_api_manager.API_Data[category][id]) or FileExists(gw2_api_manager.data_folders[category] .. id .. ".lua") then
         local info = gw2_api_manager.LoadData(category, id)

         for k, v in pairs(info) do
            if all_data or (not gw2_api_manager.language_dependent[k]) then
               tbl[k] = v
            else
               tbl[k] = v[Player:GetLanguage()]
               if not tbl[k] then
                  table.insert(request_ids, id)
               end
            end
         end
      elseif not gw2_api_manager.is_Blacklisted(id, category) then
         table.insert(request_ids, id)
      else
         table.insert(invalid_ids, id)
      end
   end

   if (type(id) == "table") then
      for _, entry in pairs(id) do
         if (gw2_api_manager.API_Data[category] and gw2_api_manager.API_Data[category][entry]) or FileExists(gw2_api_manager.data_folders[category] .. entry .. ".lua") then
            local info = gw2_api_manager.LoadData(category, entry)
            --local info = (gw2_api_manager.API_Data[category] and gw2_api_manager.API_Data[category][entry] and gw2_api_manager.API_Data[category][entry]) or FileLoad(gw2_api_manager.data_folders[category] .. entry .. ".lua")

            tbl[entry] = tbl[entry] or {}
            for k, v in pairs(info) do
               if all_data or (not gw2_api_manager.language_dependent[k]) then
                  tbl[entry][k] = v
               else
                  tbl[entry][k] = v[Player:GetLanguage()]
                  if not tbl[entry][k] then
                     table.insert(request_ids, entry)
                  end
               end
            end
         elseif not gw2_api_manager.is_Blacklisted(entry, category) then
            table.insert(request_ids, entry)
         else
            table.insert(invalid_ids, entry)
         end
      end
   end

   if table.valid(request_ids) then
      gw2_api_manager.queue_API_Data(request_ids, category)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

-- returns the collected trading post prices
-- id = itemid or table of ids
-- all_data will force to return all language variants for the name, description, text ... ; default is false and returns only in Players language
-- creates automatically a new request if the requested info is not available or older then 15 minutes
function gw2_api_manager.getPrice(id, all_data)
   local categories = gw2_api_manager.categories
   local request_ids, invalid_ids = {}, {}
   local category = "commerce"

   local tbl = {}
   if (type(id) == "number") then
      local info = gw2_api_manager.LoadData(category, id)
      local item_info = gw2_api_manager.LoadData("items", id)

      if table.valid(info) and gw2_api_manager.TimeSince(info.lastupdate) < 900 then
         if item_info then
            for k, v in pairs(item_info) do
               if all_data or (not gw2_api_manager.language_dependent[k]) then
                  tbl[k] = v
               else
                  tbl[k] = v[Player:GetLanguage()]
               end
            end
         end

         for k, v in pairs(info) do
            if k == "buys" or k == "sells" then
               if table.valid(v) then
                  if v.quantity and v.unit_price then
                     tbl[k] = {quantity = v.quantity, unit_price = v.unit_price}
                  else
                     table.insert(request_ids, id)
                  end
               end
            elseif all_data or (not gw2_api_manager.language_dependent[k]) then
               tbl[k] = v
            else
               tbl[k] = v[Player:GetLanguage()]
            end
         end
         tbl.time_since_update = gw2_api_manager.TimeSince(info.lastupdate)

      elseif not gw2_api_manager.is_Blacklisted(id, category) then
         table.insert(request_ids, id)
      else
         table.insert(invalid_ids, id)
      end
   end

   if (type(id) == "table") then
      for _, entry in pairs(id) do
         local info = gw2_api_manager.LoadData(category, entry)
         local item_info = gw2_api_manager.LoadData("items", entry)

         if table.valid(info) and gw2_api_manager.TimeSince(info.lastupdate) < 900 then
            tbl[entry] = tbl[entry] or {}
            if item_info then
               for k, v in pairs(item_info) do
                  if k == "buys" or k == "sells" then
                     tbl[entry][k] = v[1]
                  elseif all_data or (not gw2_api_manager.language_dependent[k]) then
                     tbl[entry][k] = v
                  else
                     tbl[entry][k] = v[Player:GetLanguage()]
                  end
               end
            end

            for k, v in pairs(info) do
               if k == "buys" or k == "sells" then
                  if table.valid(v) then
                     if v.quantity and v.unit_price then
                        tbl[entry][k] = {quantity = v.quantity, unit_price = v.unit_price}
                     else
                        table.insert(request_ids, entry)
                     end
                  end
               elseif all_data or (not gw2_api_manager.language_dependent[k]) then
                  tbl[entry][k] = v
               else
                  tbl[entry][k] = v[Player:GetLanguage()]
               end
            end
            tbl.time_since_update = gw2_api_manager.TimeSince(info.lastupdate)

         elseif not gw2_api_manager.is_Blacklisted(entry, category) then
            table.insert(request_ids, entry)
         else
            table.insert(invalid_ids, entry)
         end
      end
   end

   if table.valid(request_ids) then
      gw2_api_manager.queue_API_Prices(request_ids)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

function gw2_api_manager.getListings(id, all_data)
   local categories = gw2_api_manager.categories
   local request_ids, invalid_ids = {}, {}
   local category = "commerce"

   local tbl = {}
   if (type(id) == "number") then
      local info = gw2_api_manager.LoadData(category, id)
      local item_info = gw2_api_manager.LoadData("items", id)

      if table.valid(info) and info.listing_update and gw2_api_manager.TimeSince(info.listing_update) < 900 then
         if item_info then
            for k, v in pairs(item_info) do
               if all_data or (not gw2_api_manager.language_dependent[k]) then
                  tbl[k] = v
               else
                  tbl[k] = v[Player:GetLanguage()]
               end
            end
         end

         for k, v in pairs(info) do
            if all_data or (not gw2_api_manager.language_dependent[k]) then
               tbl[k] = v
            else
               tbl[k] = v[Player:GetLanguage()]
            end
         end
         tbl.time_since_update = gw2_api_manager.TimeSince(info.listing_update)

      elseif not gw2_api_manager.is_Blacklisted(id, category) then
         table.insert(request_ids, id)
      else
         table.insert(invalid_ids, id)
      end
   end

   if (type(id) == "table") then
      for _, entry in pairs(id) do
         local info = gw2_api_manager.LoadData(category, entry)
         local item_info = gw2_api_manager.LoadData("items", entry)

         if table.valid(info) and gw2_api_manager.TimeSince(info.listing_update) < 900 then
            tbl[entry] = tbl[entry] or {}
            if item_info then
               for k, v in pairs(item_info) do
                  if all_data or (not gw2_api_manager.language_dependent[k]) then
                     tbl[entry][k] = v
                  else
                     tbl[entry][k] = v[Player:GetLanguage()]
                  end
               end
            end

            for k, v in pairs(info) do
               if all_data or (not gw2_api_manager.language_dependent[k]) then
                  tbl[entry][k] = v
               else
                  tbl[entry][k] = v[Player:GetLanguage()]
               end
            end
            tbl.time_since_update = gw2_api_manager.TimeSince(info.listing_update)

         elseif not gw2_api_manager.is_Blacklisted(entry, category) then
            table.insert(request_ids, entry)
         else
            table.insert(invalid_ids, entry)
         end
      end
   end

   if table.valid(request_ids) then
      gw2_api_manager.queue_API_Listings(request_ids)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

-- returns the collected item/skill/currency/... icon for the passed id & category;
-- for easy use juse use:
-- id = itemid / currency id / skillid
-- category = item/skill/currency/...
-- creates automatically a new request if the requested icon is not available to get it and returns GetStartupPath().."\\GUI\\UI_Textures\\change.png" to have a placeholder and not mess up the UI
function gw2_api_manager.getIcon(id, category, fallback_icon)
   local categories = gw2_api_manager.categories
   local folder

   if FileExists(gw2_api_manager.icons_path .. category .. "\\" .. id .. ".png") then
      return gw2_api_manager.icons_path .. category .. "\\" .. id .. ".png"
   end

   for k, v in pairs(categories) do
      if category == k or category == v then
         category = v
         break
      end
   end

   return folder or gw2_api_manager.queue_API_Icon(id, category) and (fallback_icon or GetStartupPath() .. "\\GUI\\UI_Textures\\change.png") or false
end

function gw2_api_manager.add_to_Blacklist(id, category, reason)
   gw2_api_manager.blacklist[category] = gw2_api_manager.blacklist[category] or {}
   gw2_api_manager.blacklist[category][id] = { time = os.time(), reason = reason }
   gw2_api_manager.Save_Blacklist()
end

function gw2_api_manager.is_Blacklisted(id, category)
   if gw2_api_manager.blacklist[category] and gw2_api_manager.blacklist[category][id] and gw2_api_manager.TimeSince(gw2_api_manager.blacklist[category][id].time) > 300 then
      gw2_api_manager.blacklist[category][id] = nil
      gw2_api_manager.Save_Blacklist()
   end

   return (gw2_api_manager.blacklist[category] and gw2_api_manager.blacklist[category][id]) or false
end

function gw2_api_manager.Save_Blacklist()
   FileSave(GetLuaModsPath() .. "\\GW2Minion\\API_Data\\blacklist.lua", gw2_api_manager.blacklist)
end

function gw2_api_manager.Load_Blacklist()
   gw2_api_manager.blacklist = FileLoad(GetLuaModsPath() .. "\\GW2Minion\\API_Data\\blacklist.lua") or {}
end

-- Handler for the hole http request stuff
function gw2_api_manager.API_DataHandler(_, ticks)
   local folders = gw2_api_manager.folders
   local hosts = gw2_api_manager.hosts
   local languages = gw2_api_manager.languages
   local paths = gw2_api_manager.paths
   local s = gw2_api_manager.HTTP_Status

   -- image downloading, restart each 10 seconds
   if ticks - gw2_api_manager.imageticks > 15 then
      gw2_api_manager.imageticks = ticks
      if table.valid(gw2_api_manager.ImageQueue) and (not gw2_api_manager.lastImage or FileExists(gw2_api_manager.lastImage) or gw2_api_manager.TimeSince(gw2_api_manager.lastDownload) > 10) then
         if gw2_api_manager.TimeSince(gw2_api_manager.lastDownload) > 10 then
            for k, v in pairs(folders) do
               for k2, v2 in pairs(FolderList(v, ".*.png_tmp")) do
                  FileDelete(v .. v2)
               end
            end
         end

         local download_started
         gw2_api_manager.lastImage = false
         gw2_api_manager.lastDownload = gw2_api_manager.lastDownload or 0
         for category, v in pairs(gw2_api_manager.ImageQueue) do
            if table.valid(v) and not gw2_api_manager.lastImage then
               for id, entry in pairs(v) do
                  if entry.url and ((entry.status == s.download_queued) or gw2_api_manager.TimeSince(gw2_api_manager.lastDownload) > 10) then
                     d("[gw2_api_manager]: Start download for " .. tostring(category) .. " id: " .. tostring(id))
                     WebAPI:GetImage(id, entry.url, folders[category] .. id .. ".png")
                     entry.status = s.downloading
                     entry.download_start = os.time()
                     entry.folder = folders[category] .. id .. ".png"
                     gw2_api_manager.lastImage = folders[category] .. id .. ".png"
                     gw2_api_manager.lastDownload = os.time()
                     break
                  end

                  if gw2_api_manager.API_Data[category] and gw2_api_manager.API_Data[category][id] and gw2_api_manager.API_Data[category][id].icon and not FileExists(folders[category] .. id .. ".png") then
                     d("[gw2_api_manager]: Start download for " .. tostring(category) .. " id: " .. tostring(id))
                     WebAPI:GetImage(id, gw2_api_manager.API_Data[category][id].icon, folders[category] .. id .. ".png")
                     entry.status = s.downloading
                     entry.download_start = os.time()
                     entry.folder = folders[category] .. id .. ".png"
                     gw2_api_manager.lastImage = folders[category] .. id .. ".png"
                     gw2_api_manager.lastDownload = os.time()
                     break
                  end
               end

               if gw2_api_manager.lastImage then
                  break
               end
            end
         end
      end
   end

   if gw2_api_manager.API_Request_Running and gw2_api_manager.TimeSince(gw2_api_manager.API_Request_Running) > 90 then
      gw2_api_manager.API_Request_Running = false
   end

   -- API data get, tick ever 666ms, max requests are one each 200 ms so we added a bit of a tolerance to prevent issues
   if ticks - gw2_api_manager.API_Call_Ticks > 1000 * (2 / 3) then
      gw2_api_manager.API_Call_Ticks = ticks
      if table.valid(gw2_api_manager.ImageQueue) then
         for category, v in pairs(gw2_api_manager.ImageQueue) do
            local idstring = ""
            local ids = {}
            local count = 0
            if table.valid(v) then
               for id, entry in pairs(v) do

                  -- file exists, remove file from queue
                  if FileExists(folders[category] .. id .. ".png") or gw2_api_manager.is_Blacklisted(id, category) then
                     gw2_api_manager.ImageQueue[category][id] = nil

                     -- add to api request to get icon url
                  elseif count < 200 and entry.status == s.queued then
                     if (not gw2_api_manager.API_Request_Running) and not gw2_api_manager.is_Blacklisted(id, category) and (not gw2_api_manager.API_Data[category] or not gw2_api_manager.API_Data[category][id] or not gw2_api_manager.API_Data[category][id].icon or entry.forced) then
                        if (idstring == "") then
                           idstring = tostring(id)
                        else
                           idstring = idstring .. "," .. tostring(id)
                        end
                        table.insert(ids, id)
                        count = count + 1
                     end
                  end
               end

               local function success(str)
                  local data = json.decode(str)
                  if data.text == "all ids provided are invalid" then
                     d("[gw2_api_manager]: Requested ids are invalid.")
                     for k, v in pairs(ids) do
                        d(v)
                        gw2_api_manager.add_to_Blacklist(v, category)
                     end
                     return
                  end

                  for k, v in pairs(ids) do
                     local found = false
                     for _, entry in pairs(data) do
                        if entry.id == v then
                           found = true
                        end
                     end

                     if not found then
                        gw2_api_manager.add_to_Blacklist(v, category)
                     end
                  end

                  d("[gw2_api_manager]: HTTP Request to get Image URL successful.")
                  for _, entry in pairs(data) do
                     gw2_api_manager.ImageQueue[category][entry.id] = { url = entry.icon, status = s.download_queued, name = entry.name }
                     gw2_api_manager.API_Data[category] = gw2_api_manager.API_Data[category] or {}
                     gw2_api_manager.API_Data[category][entry.id] = gw2_api_manager.setEntryData(entry, category)
                     gw2_api_manager.API_Data[category][entry.id].lastupdate = os.time()
                  end
                  gw2_api_manager.API_Request_Running = false
                  gw2_api_manager.http_requests[idstring .. " - " .. category] = nil

                  gw2_api_manager.Save_API_Data(category, ids)
               end

               local function failed(str)
                  d("[gw2_api_manager]: HTTP Request failed.")
                  local data = json.decode(str)
                  d(data or str)
                  gw2_api_manager.API_Request_Running = false
                  --local data = json.decode(str)
               end

               if count >= 1 then
                  local params = { host = hosts[category], path = paths[category] .. "?ids=" .. idstring .. "&lang=" .. languages[Player:GetLanguage()], port = 443, method = "GET", https = true, onsuccess = success, onfailure = failed }
                  gw2_api_manager.http_requests[idstring .. " - " .. category] = params
                  gw2_api_manager.http_requests[idstring .. " - " .. category].status = s.queued
               end
            else
               gw2_api_manager.ImageQueue[category] = nil
            end
         end
      end

      if table.valid(gw2_api_manager.http_requests) then
         for identifier, params in pairs(gw2_api_manager.http_requests) do
            if params.host and (not params.status or params.status == s.queued) then
               d("[gw2_api_manager]: Send HTTP Request to get Infos for ids " .. tostring(identifier))
               HttpRequest(params)
               params.status = s.request_sent
               gw2_api_manager.API_Request_Running = os.time()
               break
            end
         end
      end
   end
end

RegisterEventHandler("Module.Initalize", gw2_api_manager.ModuleInit, "gw2_api_manager.ModuleInit")
RegisterEventHandler("Gameloop.Update", gw2_api_manager.API_DataHandler, "gw2_api_manager.API_DataHandler")
