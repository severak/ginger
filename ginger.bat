@echo off
:: GINGER - an easy to use git wrapper
:: (c) Severak 2018-19

if "%1" EQU "?" goto help
if "%1" EQU "-h" goto help
if "%1" EQU "/h" goto help
if "%1" EQU "help" goto help

:: ensure we are in repo
git rev-parse --show-toplevel >nul || exit /b
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
:unstage
echo TBD
goto :eof


:help
echo GINGER - an easy to use git wrapper
echo (c) Severak 2018-19
echo: 
echo No help available yet.
goto :eof
