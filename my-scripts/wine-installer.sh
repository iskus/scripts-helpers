#!/bin/bash
	
	cd ~
	sudo dpkg --add-architecture i386
	sudo apt update && sudo apt full-upgrade -y
	sudo apt install \
      wine \
      wine32 \
      wine64 \
      libwine \
      libwine:i386 \
      fonts-wine -y
    sudo apt install \
      wine-development \
      wine32-development \
      wine64-development \
      libwine-development \
      libwine-development:i386 \
      fonts-wine -y
      
    wget https://dl.winehq.org/wine-builds/Release.key                         │
    sudo apt-key add Release.key                                               │
    sudo apt-add-repository 'https://dl.winehq.org/wine-builds/debian/' 
	echo 'export WINEARCH="win64"' >> ~/.profile
	export WINE=/usr/bin/wine-development
	export WINESERVER=/usr/bin/wineserver-development
	
	#wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	#chmod +x winetricks
	sudo apt install winetricks -y
	winetricks corefonts
	winetricks directx9 d3dx9 d3dx9_26 d3dx9_28 d3dx9_31 d3dx9_35 d3dx9_36 d3dx9_42 d3dx9_43 d3dx10 d3dx10_43 d3dx11_42 d3dx11_43 d3dxof devenum dinput8 dinput dirac directmusic directplay dmsynth dsound
	winetricks dxdiagn gdiplus gfw mfc40 mfc42 msxml6 quartz
	winetricks vb5run vb6run vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun6 vcrun6sp6
	winetricks wsh57 wsh56vb xact xact_jun2010 xinput
	#winecfg check max version windows
	#or install other NET
	wget https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe
	wine start /unix NDP452-KB2901907-x86-x64-AllOS-ENU.exe
	sudo apt-get install p7zip-full -y
