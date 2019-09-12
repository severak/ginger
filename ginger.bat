@echo off
setlocal
:: GINGER - an easy to use git wrapper
:: (c) Severak 2016-19

if "%1" EQU "?" goto help
if "%1" EQU "-h" goto help
if "%1" EQU "/h" goto help
if "%1" EQU "help" goto help

:: ensure we are in repo
git rev-parse --show-toplevel >nul || exit /b

if "%1" EQU "login" goto login

:: ensure we have user
git config user.name >nul || (echo ginger: User not configured. Use: ginger login && exit /b)

:: set codepage
set LC_ALL=C.UTF-8

if "%1" EQU "look" goto look
if "%1" EQU "changed" goto changed
if "%1" EQU "sweep" goto sweep
if "%1" EQU "sweep" goto sweep
if "%1" EQU "branches" goto branches
if "%1" EQU "switch" goto switch
if "%1" EQU "spinoff" goto spinoff
if "%1" EQU "stage" goto stage
if "%1" EQU "unstage" goto unstage
if "%1" EQU "log" goto log
if "%1" EQU "" goto help
echo Error: Unknown command %1
goto :eof

:login
set "_global="
git config user.name >nul || (choice /m "Wanna set global config?" & if %ERRORLEVEL% NEQ 1 set _global=--global)

set /P _username=User name: 
set /P _email=E-mail: 

git config %_global% user.name "%_username%"
git config %_global% user.email "%_email%"
goto :eof

:look
echo repo:
git rev-parse --show-toplevel
echo branch:
git symbolic-ref --short -q HEAD
echo:
echo user:
git config user.name
git config user.email
echo:
git log --format="format:%%an %%ar:%%n%%h %%s" -n 1
echo:
:: fallthrough to changed

:changed
if "%2" NEQ "" (
	git diff -- %2
	goto :eof
)

echo -- STAGED:
git diff --name-status --staged
echo -- UNSTAGED:
git diff --name-status
goto :eof

:sweep
if "%2" NEQ "" (
	git checkout HEAD -- %2
	echo OK
	goto :eof
)
git reset --hard HEAD
goto :eof

:branches
git branch -a -v
goto :eof

:switch
if "%2" EQU "" (
	echo Error: Please, specify brach name.
	exit /b
)
git checkout %2
	
goto :eof

:spinoff
if "%2" EQU "" (
	echo Error: Please, specify brach name.
	exit /b
)
git checkout -b %2
goto :eof

:stage
if "%2" EQU "" (
	echo Error: Please, provide file name to stage.
	exit /b
)

if "%2" EQU "." (
	echo staging all changed files...
	git add --update
	goto :eof
)

git add %2
goto :eof

:unstage
if "%2" EQU "" (
	echo Error: Please, provide file name to stage.
	exit /b
)

if "%2" EQU "." (
	echo staging all changed files...
	git reset
	goto :eof
)

git reset -- %2
goto :eof

:log
git log
goto :eof

:help
echo GINGER - an easy to use git wrapper
echo (c) Severak 2016-19
echo: 
echo No help available yet. See source code.
goto :eof
