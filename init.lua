----------------------------------------------------------------------
-- RestClient:
-- A library that simplifies interaction with REST APIs.
----------------------------------------------------------------------

-- Deps:
local socket = require 'socket'
local http = require 'socket.http'
local surl = require 'socket.url'
local mime = require 'mime'
local ltn12 = require 'ltn12'
local ok,json = pcall(require, 'cjson')
if not ok then
   ok,json = pcall(require, 'json')
   if ok then
      print('warning: please install lua-cjson for efficient json handling')
   else
      print('warning: could not find a json library, please install lua-cjson')
   end
end
local ok,gm = pcall(require, 'graphicsmagick')
if not ok then
   print('warning: please install graphicsmagcick to support images')
end

-- Format options:
local function formatUrl(url,options)
   -- Format query:
   local query 
   if options and next(options) then
      query = {}
      for k,v in pairs(options) do
         table.insert(query, k .. '=' .. v)
      end
      query = table.concat(query,'&')
   end

   -- Create full URL:
   if query then url = url .. '?' .. query end
   return url
end

-- Get:
local get = function(args)
   -- URL:
   local url = args.url or (args.host .. (args.path or '/'))
   local query = args.query
   local format = args.format or 'raw' -- or 'json', 'image'

   -- GET:
   local response = {}
   local ok,code = http.request{
      url = formatUrl(url,query),
      method = 'GET',
      sink = ltn12.sink.table(response)
   }

   -- OK?
   if not ok then
      return nil,code
   elseif code ~= 200 then
      return nil,code
   end

   -- Produce response:
   response = table.concat(response)
   
   -- Encode into given format:
   if format == 'json' then
      response = json.decode(response)
   elseif format == 'image' then
      response = gm.Image():fromString(response)
   end

   -- Return response:
   return response,code
end

-- Put:
local post = function(args)
   -- URL:
   local url = args.url or (args.host .. (args.path or '/'))
   local form = args.form or error('please provide field: form')
   local format = args.format or 'raw'  -- or 'json'

   -- Serialize data keys:
   local nform = {}
   for k,v in pairs(form) do
      if type(v) == 'table' then
         local data = v.data or error('expecting table to have a field: data')
         local format = v.format
         if format == 'base64' then
            v = mime.b64(data)
         else
            v = data
         end
      end
      nform[k] = v
   end

   -- Serialize form:
   local payload = json.encode(nform)
   
   -- GET:
   local response = {}
   local ok,code = http.request{
      url = url,
      method = 'POST',
      source = ltn12.source.string(payload),
      sink = ltn12.sink.table(response),
      headers = {
         ['content-Type'] = 'application/json',
         ['content-length'] = #payload,
      }
   }
   
   -- OK?
   if not ok then
      return nil,code
   elseif code ~= 200 then
      return nil,code
   end

   -- Response
   response = table.concat(response)
   if format == 'json' then
      response = json.decode(response)
   end
   return response,code
end

-- Exports:
return {
   get = get,
   post = post,
}

