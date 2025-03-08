local nk = require("nakama")

local error_codes = {
    OK                  = 0,  -- HTTP 200
    CANCELED            = 1,  -- HTTP 499
    UNKNOWN             = 2,  -- HTTP 500
    INVALID_ARGUMENT    = 3,  -- HTTP 400
    DEADLINE_EXCEEDED   = 4,  -- HTTP 504
    NOT_FOUND           = 5,  -- HTTP 404
    ALREADY_EXISTS      = 6,  -- HTTP 409
    PERMISSION_DENIED   = 7,  -- HTTP 403
    RESOURCE_EXHAUSTED  = 8,  -- HTTP 429
    FAILED_PRECONDITION = 9,  -- HTTP 400
    ABORTED             = 10, -- HTTP 409
    OUT_OF_RANGE        = 11, -- HTTP 400
    UNIMPLEMENTED       = 12, -- HTTP 501
    INTERNAL            = 13, -- HTTP 500
    UNAVAILABLE         = 14, -- HTTP 503
    DATA_LOSS           = 15, -- HTTP 500
    UNAUTHENTICATED     = 16  -- HTTP 401
}

local M = {}

-- RPC functions, callable by client
--[[
Creates a new match.
Records the callers id inside the starting gamestate.
Returns the id of the new match
]]
function create_match(context, payload)
    -- the user id should be inside the http request
    local id = context.user_id

    -- if it did not have a user id
    if id == nil then
        -- throw error
        error("Request must contain user_id", error_codes.INVALID_ARGUMENT)
    end

    -- this name relates to a lua file with game logic, eg. match.lua
    local module = "match"

    -- the starting state of the game
    local setupstate = {
        -- record who created the game, they become the owner
        ownerid = id
    }

    -- call nakama, ask it to create a new game
    local match_id, err = nk.match_create(module, setupstate)

    -- return the id of the new game
    return nk.json_encode({ matchid = match_id })
end

--[[
Returns a list of matches, passed upon the payload
We expect json structured as follows
{
    "limit" : 10,
    "isAuthoritative" : true,
    "label" : "",
    "min_size" : 0,
    "max_size" : 4,
    "query" : ""
}
]]
function get_matches(context, payload)
    -- set default values for search
    local limit = 10
    local isAuthoritative = true
    local label = ""
    local min_size = 0
    local max_size = 4
    local query = ""

    if payload == nil or string.len(payload) == 0 then
        error([[You must pass search parameters as json:
{
    'limit' : 10,
    'isAuthoritative' : true,
    'label' : '',
    'min_size' : 0,
    'max_size' : 4,
    'query' : ''
}]], error_codes.INVALID_ARGUMENT)
    end

    -- create a readable json object
    local json = nk.json_decode(payload)

    print("test\n")
    print("limit", json.limit)
    print("isAuthoritative", json.isAuthoritative)
    print("label", json.label)
    print("min_size", json.min_size)
    print("max_size", json.max_size)
    print("query", json.query)

    -- allows the caller to alter the default search values
    if json.limit then limit = json.limit end
    if json.isAuthoritative then isAuthoritative = json.isAuthoritative end
    if json.label then label = json.label end
    if json.min_size then min_size = json.min_size end
    if json.max_size then max_size = json.max_size end
    if json.query then query = json.query end

    -- ask nakama for games that match the search criteria
    local matches = nk.match_list(limit, isAuthoritative, label, min_size, max_size, query)

    -- return a json list of games
    return nk.json_encode({ matches = matches })
end

-- helper functions
function is_match_owner(context, payload)
    return nk.json_encode({ success = false })
end

-- Nakama functions, callable only by server

-- Nakama calls this function before our game is created
function M.match_init(context, setupstate)
    -- here we can add data that is carried over between function calls
    local gamestate = {
        -- users that are in the game
        presences = {},
        -- who owns the match
        ownerid = setupstate.ownerid,
    }

    -- how quickly does match_loop get called?
    -- higher number means it gets called more often.
    -- this means our gamestate can get updated more often
    -- giving our players a better game experience
    local tickrate = 1 -- per sec

    -- create labels that allows queries for games
    local label = { ownerid = gamestate.ownerid }
    -- returning json object allows nakama to index our label
    local match_labels = nk.json_encode(label)

    return gamestate, tickrate, match_labels
end

function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
    local acceptuser = true
    return state, acceptuser
end

function M.match_join(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.session_id] = presence
    end

    return state
end

function M.match_leave(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.session_id] = nil
    end

    return state
end

function M.match_loop(context, dispatcher, tick, state, messages)
    for _, p in pairs(state.presences) do
        nk.logger_info(string.format("Presence %s named %s", p.user_id, p.username))
    end

    for _, m in ipairs(messages) do
        nk.logger_info(string.format("Received %s from %s", m.data, m.sender.username))
        local decoded = nk.json_decode(m.data)

        for k, v in pairs(decoded) do
            nk.logger_info(string.format("Key %s contains value %s", k, v))
        end

        -- PONG message back to sender
        dispatcher.broadcast_message(1, m.data, { m.sender })
    end

    return state
end

function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
    local message = "Server shutting down in " .. grace_seconds .. " seconds"
    dispatcher.broadcast_message(2, message)

    return nil
end

function M.match_signal(context, dispatcher, tick, state, data)
    return state, "signal received: " .. data
end

return M
