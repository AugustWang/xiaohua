@echo off

path %path%;"D:\cocos2d-x\校花配置工具\png压缩exe"

set outDirName=outdir
set curPath=%~dp0
set len=0
:her
call set u=%%curPath:~%len%,1%%
if not "%u%"=="" (
set /a len+=1
goto her
)
::echo curPathLen：%len%

rd /s /q %curPath%%outDirName%
::变量延迟
setlocal enabledelayedexpansion
for /f "delims=" %%d in ('dir /ad/b/s ""') do (
set tmp=%%d
set newdirname=!curPath!outdir\!tmp:~%len%!
md !newdirname!
)
md %curPath%%outDirName%

set num=0;
for /f "usebackq tokens=*" %%d in (`dir /s /b *.png`) do (
set tmp=%%d
pngquant --force --verbose 256 --quality=0-85 %%d --output !curPath!!outDirName!\!tmp:~%len%!
set /a num+=1
)
echo num = %num%
pause
