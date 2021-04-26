local newdecoder = require ("extensions.BGASM_Econ.lua.json.lunajson.decoder")
local newencoder = require ("extensions.BGASM_Econ.lua.json.lunajson.encoder")
-- local sax = require ("extensions.BGASM_Econ.lua.json.lunajson.sax")
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	-- newparser = sax.newparser,
	--newfileparser = sax.newfileparser,
}
