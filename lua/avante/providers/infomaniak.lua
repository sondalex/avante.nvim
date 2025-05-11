---@class AvanteInfomaniakProvider: AvanteDefaultBaseProvider
---@field product_id_name string

local P = require("avante.providers")
local Utils = require("avante.utils")
local OpenAI = require("avante.providers").openai
local Config = require("avante.config")

---@class AvanteProviderFunctor
local M = {}

M.api_key_name = "INFOMANIAK_LLM_API_TOKEN"
M.product_id_name = "INFOMANIAK_LLM_PRODUCT_ID"
setmetatable(M, { __index = OpenAI })

M.role_map = {
  user = "user",
  assistant = "assistant",
  system = "system",
}

function M:parse_curl_args(prompt_opts)
  local provider_conf, request_body = P.parse_config(self)
  local headers = {
    ["Content-Type"] = "application/json",
  }
  ---@diagnostic disable-next-line: undefined-field
  local api_key_name = prompt_opts.api_key_name or M.api_key_name
  ---@diagnostic disable-next-line: undefined-field
  local product_id_name = prompt_opts.product_id_name or M.product_id_name

  local api_key = os.getenv(api_key_name)
  local product_id = os.getenv(product_id_name)

  if api_key == nil then
    error(Config.provider .. " API key is not set. Please set it in your environment variable or config file.")
  end
  if product_id == nil then
    error(Config.provider .. " Product ID is not set. Please set it in your environment variable.")
  end

  headers["Authorization"] = "Bearer " .. api_key
  return {
    url = Utils.url_join(provider_conf.endpoint, "ai/", product_id, "/openai/chat/completions"),
    proxy = provider_conf.proxy,
    insecure = provider_conf.allow_insecure,
    headers = headers,
    body = vim.tbl_deep_extend("force", {
      model = provider_conf.model,
      messages = self:parse_messages(prompt_opts),
      ---@diagnostic disable-next-line: undefined-field
      stream = provider_conf.stream or false,
    }, request_body),
  }
end

function M:parse_messages(opts)
  local messages = {}

  table.insert(messages, { role = "system", content = opts.system_prompt })

  vim.iter(opts.messages):each(function(msg)
    vim.print(msg)
    table.insert(messages, { role = M.role_map[msg.role], content = msg.content })
  end)

  return messages
end


return M
