WebBanking {
  version = 0.1,
  url = "https://www.bondora.com",
  services = { "Bondora Account" }
}

local connection

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Bondora Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  html = HTML(connection:get(url))
  html:xpath("//input[@name='Email']"):attr("value", username)
  html:xpath("//input[@name='Password']"):attr("value", password)
  connection:request(html:xpath("//form[@action='/login']//button[@type='submit']"):click())

  if string.match(connection:getBaseURL(), 'login') then
    return LoginFailed
  end
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Bondora Summary",
    accountNumber = "Bondora Summary",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function AccountSummary ()
  local headers = {accept = "application/json"}
  local content = connection:request(
    "GET",
    "https://www.bondora.com/de/dashboard/overviewnumbers/",
    "",
    "application/json",
    headers
  )
  return JSON(content):dictionary()
end



function RefreshAccount (account, since)
  local s = {}
  summary = AccountSummary()

  print(summary.Stats[1].Value)
  print(summary.Stats[2].Value)

  local value = summary.Stats[1].Value
  local profit = summary.Stats[2].Value
  profit = string.gsub(profit, "€", "")
  value = string.gsub(value, "€", "")
  profit = string.gsub(profit, "%.", "")
  value = string.gsub(value, "%.", "")

  print(value)
  print(profit)
  
  local security = {
    name = "Account",
    price = tonumber(value),
    quantity = 1,
    purchasePrice = tonumber(value) - tonumber(profit),
    curreny = nil,
  }

  table.insert(s, security)

  return {securities = s}
end


function EndSession ()
  connection:get("https://www.bondora.com/de/authorize/logout/")
  return nil
end
