@echo off
rem The first call will redundantly enable output, but will leave it disabled
rem on return.
call progress [___]
call spam
call progress [#__]
call spam
call progress [##_]
call spam
call progress [###]
rem The last call to progress.bat redundantly disables output.
vgaonoff on
