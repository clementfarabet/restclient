
local ffi = require 'ffi'
ffi.cdef[[
typedef unsigned char u_char;
int res_9_b64_ntop(u_char const *src, size_t srclength, char *target, size_t targsize);
int res_9_b64_pton(char const *src, u_char *target, size_t targsize);
]]
local C = ffi.load('resolv')

local base64 = {}

function base64.encode(str)
   local target = ffi.new('char[?]', 2 * #str)
   C.res_9_b64_ntop(str,#str, target,2*#str)
   return ffi.string(target)
end

function base64.decode(str)
   local dec = ffi.new('char[?]',#str)
   n = C.res_9_b64_pton(str, dec, #str)
   return ffi.string(dec,n)
end

return base64

