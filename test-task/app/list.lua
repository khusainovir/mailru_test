-- This code is just a copypase from lua official website
-- https://www.lua.org/pil/11.4.html
-- I strongly need queue implementatiom so the quickest way to get it was third-party
-- Ilyas K

List = {}
    function List.new ()
      return {first = 0, last = -1}
    end
-- Now, we can insert or remove an element at both ends in constant time:
    function List.pushleft (list, value)
      local first = list.first - 1
      list.first = first
      list[first] = value
    end
    
    function List.pushright (list, value)
      local last = list.last + 1
      list.last = last
      list[last] = value
    end
    
    function List.popleft (list)
      local first = list.first
      if first > list.last then error("list is empty") end
      local value = list[first]
      list[first] = nil        -- to allow garbage collection
      list.first = first + 1
      return value
    end
    
    function List.popright (list)
      local last = list.last
      if list.first > last then error("list is empty") end
      local value = list[last]
      list[last] = nil         -- to allow garbage collection
      list.last = last - 1
      return value
    end

    return {
        List = List,
    }
