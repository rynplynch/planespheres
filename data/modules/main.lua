local nk = require("nakama")
local match = require("match")

-- functions relating to match interaction
-- create a match, sets ownerid to callers userid
nk.register_rpc(create_match, "create_match")

-- returns matches based upon the json payload
nk.register_rpc(get_matches, "get_matches")
