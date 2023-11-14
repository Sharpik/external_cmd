-- External Command (external_cmd) mod by Sharp & Menche
-- Allows server commands / chat from outside minetest
-- License: LGPL
-- Version 1.0

-- Put the external commands to "../world/external_cmd/commands_input.txt"

local repeat_after = tonumber(minetest.settings:get("external_cmd_interval")) or 2 -- repeat every x seconds
local report_back = minetest.settings:get_bool("external_cmd_log", true) -- make commands_output.csv with commands log
local show_notification = minetest.settings:get_bool("external_cmd_notifi", false) -- do you want to see notification that command was executed in game?

-- register this user first at your server and give it full permissions (/setpassword SERVER <secretpass> && /grant SERVER all)
local admin = "SERVER"

local world_dir = minetest.get_worldpath("external_cmd")
minetest.mkdir(world_dir.."/external_cmd/")

local function cron()
	local dtime = minetest.get_gametime()
	local file_input = "commands_input.txt"
	local file_output = "commands_output.csv"
	local message_type = "command"
	
	local file_in = (io.open(world_dir.."/external_cmd/"..file_input, "r"))
		if (file_in ~= nil) then
			for command in file_in:lines() do
				if (command ~= nil) then
					local cmd, param = string.match(command, "^/([^ ]+) *(.*)")
					if not param then
						param = ""
					end
					
					local cmd_obj = minetest.chatcommands[cmd]
					if cmd_obj then
						if (show_notification == true) then
							minetest.log("external_cmd: "..dtime.." Issued command /"..cmd.." "..param)
						end
						cmd_obj.func(admin, param)
					else
						minetest.chat_send_all(admin..": "..command)
						message_type = "message"
					end
					
					if (report_back == true) then
						-- Report it back to external file
						local file_out = (io.open(world_dir.."/external_cmd/"..file_output, "a"))
						if file_out ~= nil then
							file_out:write(dtime..";"..admin..";"..message_type..";"..command,'\n')
							file_out:close()
						end
					end
				end
			end
			
			file_in:close()
			os.remove(world_dir.."/external_cmd/"..file_input)
		end
	-- repeat that function after the time interval
	minetest.after(repeat_after, cron)
end

local function check_priv()
	if minetest.check_player_privs(admin, "server") then
		return true
	else
		minetest.log("external_cmd: Don't have permissions set! Set permissions and restart the server.")
		return false
	end
end

--[[
if check_priv() then
	minetest.after(repeat_after, cron)
end
--]]

minetest.after(repeat_after, cron)
