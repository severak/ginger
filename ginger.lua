-- Ginger beta

gi_is_debug = os.getenv('GINGER_DEBUG')
gi_is_windows = package.config:sub(1, 1) == "\\"


----------------
--- Lua 5.1/5.2/5.3 compatibility.
-- Ensures that `table.pack` and `package.searchpath` are available
-- for Lua 5.1 and LuaJIT.
-- The exported function `load` is Lua 5.2 compatible.
-- `compat.setfenv` and `compat.getfenv` are available for Lua 5.2, although
-- they are not always guaranteed to work.
-- @module pl.compat

local compat = {}

compat.lua51 = _VERSION == 'Lua 5.1'

local isJit = (tostring(assert):match('builtin') ~= nil)
if isJit then
    -- 'goto' is a keyword when 52 compatibility is enabled in LuaJit
    compat.jit52 = not loadstring("local goto = 1")
end

--- execute a shell command.
-- This is a compatibility function that returns the same for Lua 5.1 and Lua 5.2
-- @param cmd a shell command
-- @return true if successful
-- @return actual return code
function compat.execute (cmd)
    local res1,_,res3 = os.execute(cmd)
    if compat.lua51 and not compat.jit52 then
        return res1==0,res1
    else
        return not not res1,res3
    end
end

--- return the contents of a file as a string
-- (stolen from penlight)
-- @param filename The file path
-- @param is_bin open in binary mode
-- @return file contents
function gi_readfile(filename,is_bin)
    local mode = is_bin and 'b' or ''
    --utils.assert_string(1,filename)
    local f,open_err = io.open(filename,'r'..mode)
    if not f then return error (open_err) end
    local res,read_err = f:read('*a')
    f:close()
    if not res then
        -- Errors in io.open have "filename: " prefix,
        -- error in file:read don't, add it.
        return raise (filename..": "..read_err)
    end
    return res
end

---Return a suitable full path to a new temporary file name.
-- unlike os.tmpnam(), it always gives you a writeable path (uses TEMP environment variable on Windows)
-- (stolen from penlight)
function gi_tmpname ()
    local res = os.tmpname()
    -- On Windows if Lua is compiled using MSVC14 os.tmpname
    -- already returns an absolute path within TEMP env variable directory,
    -- no need to prepend it.
    if gi_is_windows and not res:find(':') then
        res = os.getenv('TEMP')..res
    end
    return res
end

--- Quote an argument of a command.
-- Quotes a single argument of a command to be passed
-- to `os.execute`, `pl.utils.execute` or `pl.utils.executeex`.
-- (stolen from penlight)
-- @string argument the argument.
-- @return quoted argument.
function gi_quote_arg(argument)
    if gi_is_windows then
        if argument == "" or argument:find('[ \f\t\v]') then
            -- Need to quote the argument.
            -- Quotes need to be escaped with backslashes;
            -- additionally, backslashes before a quote, escaped or not,
            -- need to be doubled.
            -- See documentation for CommandLineToArgvW Windows function.
            argument = '"' .. argument:gsub([[(\*)"]], [[%1%1\"]]):gsub([[\+$]], "%0%0") .. '"'
        end

        -- os.execute() uses system() C function, which on Windows passes command
        -- to cmd.exe. Escape its special characters.
        return (argument:gsub('["^<>!|&%%]', "^%0"))
    else
        if argument == "" or argument:find('[^a-zA-Z0-9_@%+=:,./-]') then
            -- To quote arguments on posix-like systems use single quotes.
            -- To represent an embedded single quote close quoted string ('),
            -- add escaped quote (\'), open quoted string again (').
            argument = "'" .. argument:gsub("'", [['\'']]) .. "'"
        end

        return argument
    end
end

--- execute a shell command and return the output.
-- This function redirects the output to tempfiles and returns the content of those files.
-- (stolen from penlight)
-- @param cmd a shell command
-- @param bin boolean, if true, read output as binary file
-- @return true if successful
-- @return actual return code
-- @return stdout output (string)
-- @return errout output (string)
function gi_executeex(cmd, bin)
    local mode
    local outfile = gi_tmpname()
    local errfile = gi_tmpname()

    cmd = cmd .. " > " .. gi_quote_arg(outfile) .. " 2> " .. gi_quote_arg(errfile)

    local success, retcode = compat.execute(cmd)
    local outcontent = gi_readfile(outfile, bin)
    local errcontent = gi_readfile(errfile, bin)
    os.remove(outfile)
    os.remove(errfile)
    return success, retcode, (outcontent or ""), (errcontent or "")
end

function gi_die(msg)
	io.stderr:write(msg .. '\n')
	os.exit(1)
end

function gi_less(text)
	local tmpname, tmpfile
	tmpname = gi_tmpname ()
	tmpfile = io.open(tmpname, 'w+')
	if not tmpfile then
		gi_die('error writing tmp file')
	end
	tmpfile:write(text)
	tmpfile:close()
	if gi_is_windows then
		gi_do('notepad ' .. tmpname)
	else
		gi_do('less ' .. tmpname)
	end
	os.remove(tmpname)
end

function gi_do(cmd)
	if gi_is_debug then
		print(cmd)
	end
	os.execute(cmd)
end

local commands = {}

function commands.commands()
	gi_less [[GINGER - an easy to use git wrapper

ginger commands
  Display list of commands.

~ginger help [command]
  Display help (for command).

~ginger version
  Show version number etc.

~ginger init
  Invokes repository init wizard.

~ginger clone <uri>
  Clones remote repository from <uri>.

ginger changed [path]
  Displays what changed since last commit.
  Used as diff when you provides [path].

~ginger changes <from> <to> [path]

~ginger commit
  Let you commit a change.

~ginger sweep
  Undo local changes to last commit.

~ginger pull
  Pulls changes from remote repository protecting your local files optionally.

~ginger push
  Pushes changes back to the server.

~ginger spinoff
  Creates new branch from current branch.

ginger branches
  Display list of branches.

~ginger branch <add|remove> <name>
  
ginger switch <branch>
  Switches to <branch>.

~ginger look
  Displays current repository, branch and user.

~ginger history [path]
  Displays history of commits.

~ means that command is not yet implemented
]]
end

function commands.changed(path)
	if path then
		gi_die 'ginger changed [path]: Not yet implemented.'
	end
	-- viz http://stackoverflow.com/a/18892826
	gi_do 'git diff --raw --staged'
	gi_do 'git diff --raw'
end

function commands.look()
	local _, is_git, root, branch
	_, _, root, _ = gi_executeex('git rev-parse --show-toplevel')
	if is_git then
		gi_die 'Fatal: Not a git repository.'
	end
	_, _, branch, _ = gi_executeex('git symbolic-ref --short -q HEAD')
	print('repository: ' .. root)
	print('branch: ' .. branch)
end

function commands.switch(branch)
	if not branch then
		gi_die('Please, specify brach name.')
	end
	gi_do('git checkout ' .. branch)
end

function commands.branches()
	gi_do('git branch -a -v')
end


function main(arg)
	local cmdname
	if #arg<1 then
		gi_die 
[[No command specified. Use
   > ginger <command>
or
   > ginger commands
to list possible commands. 
]]
	end
	cmdname = table.remove(arg, 1)
	if commands[cmdname] then
		commands[cmdname](unpack(arg))
	else
		gi_die('Cannot into ' .. cmdname .. ' command.')
	end
end

main(arg)
