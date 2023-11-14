# external_cmd
Minetest mod that run commands from text file (usable for remote commands)

First initialization of this mod:
1) create SERVER user and give him all permissions that you want to use in remote commands
2) setup the mod in mod settings
3) invoke commands by writing them in the "--worlds\<your world>\external_cmd\commands_input.txt"
4) every one line is one command
5) commands_input.txt would be deleted after mod invoke it
