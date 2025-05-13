---@class AvanteXAIProvider: AvanteDefaultBaseProvider
---@field product_id_name string

-- local P = require("avante.providers")
-- local Utils = require("avante.utils")
local OpenAI = require("avante.providers").openai
-- local Config = require("avante.config")

---@class AvanteProviderFunctor
local M = {}

M.api_key_name = "XAI_LLM_API_TOKEN"

setmetatable(M, { __index = OpenAI })


M.role_map = {
  user = "user",
  assistant = "assistant",
  system = "system",
}

function M.parse_api_key()
  local api_key = os.getenv(M.api_key_name)
  return api_key
end

return M;
