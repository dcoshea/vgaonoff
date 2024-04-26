tasm vgaonoff,,vgaonoff.lst
if errorlevel 1 goto :end
tlink /t vgaonoff
:end

