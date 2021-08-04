Scorpio "SpaUI" ""

class "LruCache"(function(_ENV)

    __Arguments__(NaturalNumber)
    function __new(_, capacity)
        if capacity <= 0 then
            capacity = 1
        end

        local head = {}
        local tail = {}
        head.next = tail
        tail.pre = head
        return {Capacity = capacity, Cache = {}, Head = head, Tail = tail, CacheSize = 0}
    end

    __Arguments__(NEString)
    function __index(self, key)
        local cache = self.Cache
        local node = cache[key]
        if node then
            node.pre.next = node.next
            node.next.pre = node.pre

            self.Tail.pre.next = node
            node.next = self.Tail
            node.pre = self.Tail.pre
            self.Tail.pre = node
            return node.value
        end
        return -1
    end

    __Arguments__{NEString, Any/nil}
    function __newindex(self, key, value)
        if self[key] ~= -1 then
            self.Tail.pre.value = value
        else
            if self.CacheSize == self.Capacity then
                self.Cache[self.Head.next.key] = nil
                self.CacheSize = self.CacheSize - 1
                self.Head.next = self.Head.next.next
                self.Head.next.pre = self.Head 
            end

            local node  = {}
            node.key = key
            node.value = value
            
            self.Tail.pre.next = node
            node.pre = self.Tail.pre
            node.next = self.Tail
            self.Tail.pre = node

            self.Cache[key] = node
            self.CacheSize = self.CacheSize + 1
        end
    end
end)