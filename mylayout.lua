local naughty = require("naughty")

local testLayout = {}

local function myArrange (params)
   local clients = params.clients
   local clientsCount = #clients
   local gap = params.useless_gap

   local offsetX = 0
   local offsetY = 0

   -- naughty.notify({title = "values", text = tostring(params.workarea.width)})

   for i = clientsCount, 1, -1 do
      client = clients[i]
      if clientsCount == 1 then
         client.width = params.workarea.width - gap * 2
         client.height = params.workarea.height - gap * 3
         client.x = gap + params.workarea.x
         client.y = gap + params.workarea.y
      elseif clientsCount == 2 then
         local clientWidth = params.workarea.width / 2
         client.width = clientWidth - gap * 2
         client.height = params.workarea.height - gap * 3
         client.x = params.workarea.x + offsetX + gap
         client.y = gap + params.workarea.y
         offsetX = offsetX + clientWidth
      else
         local clientWidth = params.workarea.width / 2
         client.width = clientWidth - gap * 2
         offsetX = clientWidth
         client.x = params.workarea.x + offsetX + gap

         if (i == clientsCount) then
            client.height = params.workarea.height - gap * 3
            client.y = gap + params.workarea.y
            client.x = params.workarea.x + gap
         else
            local clientHeight = (params.workarea.height - (gap * 3)) / (clientsCount - 1)
            client.height = clientHeight - gap * 2
            client.y = gap + params.workarea.y + offsetY
            offsetY = offsetY + clientHeight
         end

         offsetX = clientWidth

      end
   end

end

testLayout.name = 'testLayout'
testLayout.arrange = myArrange
-- function testLayout.arrange (params)
--    return myArrange(params)
-- end


return testLayout
