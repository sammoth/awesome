--DOC_HIDE_ALL
local a_tag = require("awful.tag")
local a_layout = require("awful.layout")
local magnifier = require("awful.layout.dynamic.suit.magnifier")

screen._setup_grid(128, 96, {4})

local tags = {}

local function add_clients(s, count)
    local x, y = s.geometry.x, s.geometry.y
    for _=1, count do
        local c1 = client.gen_fake {x = x+45, y = y+35, width=40, height=30, screen=s}
        c1:_hide()
    end
end

local function show_layout(f, s, mwfact)
    local t = tags[s]

    t.layout = f

    local l = a_tag.getproperty(t, "layout")

    -- Test if the stateful layout track the right number of clients
    assert(#t:clients() == #l.wrappers)

    tags[s].master_width_factor = mwfact

    local margin = l.widget:get_children_by_id("front_layout")[1]

    local params = a_layout.parameters(t, s)

    -- Test if the number of clients wrapper is right and if they are there
    -- only once
    local all_widget = l.widget:get_all_children()
    local cls, inv = {},{}
    for _, w in ipairs(all_widget) do
        if w._client then
            assert(not inv[w._client])
            inv[w._client] = w
            table.insert(cls, w._client)
        end
    end
    assert(#cls == #t:clients())

    l.arrange(params)

    -- Test if the main client was correctly set
    assert(margin.top == s.workarea.height/2 * mwfact)

    -- Finally, test if the clients total size match the workarea
    local total = 0
    for _, c in ipairs(t:clients()) do
        local geo = c:geometry()
        geo.height, geo.width = geo.height+2*c.border_width, geo.width+2*c.border_width
        total = total + geo.height*geo.width
    end
--     assert(s.workarea.width * s.workarea.height == total)--FIXME there is a 1px gap
end

for i=1, 4 do
    tags[screen[i]] = a_tag.add("Test"..i, {screen=screen[i]})
    add_clients(screen[i],4)
    show_layout(magnifier, screen[i], 0.2*i)
end

-- The previous tests proved that setting mwfact before clients
-- are added works, now test dynamic changes and reproductability
--TODO

return {hide_lines=true}
