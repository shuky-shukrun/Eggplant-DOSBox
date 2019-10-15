# Eggplant-DOSBox
An automation tool for running and debugging .asm and .c files with DOSBox.

Many times (espasially when you're student...) you write a code, run it, and get a compilation error. No big deal when you work on modern operating system, but super annoing when it's stuck your DOSBox emulator and force you to reboot. This tool take care of this problem for you. It's opening DOSBox, mount the nessecery folders, compile and run / run the debugger for you.

This is a beta version and I'll probebly leave it that way. 
**I created this project in my 2th semester so the coding level is... 2th-semester-student-level :)**
The project based on Auto Hot Key - AHK, an old, open source automation language, developed by Microsoft.

* This version should work with single or multiple asm and c files (auto detection for file type).
* This is not a compiler or debuger so it wont tell you if have logic or syntax error - it only automating your run process.

## User Instructions:
- Make sure you installed DOSBox 0.74/0.74-2 and Notepad++ on your computer.
- Make sure you have tasm, tcc and tlink at c:\tc\bin
- Download this project and install EggplantDOSBox setup-v0.85.exe.
your antivirus may say someting about viruses, this is why you can check the source code and compile it yourself using ahk compile tool.
- Open Eggplant DOSBox
- Choose file\s to run
- Run :)

BONUS:
Type newasm on notepad++ and then Ctrl+Alt+N.
It will create a simple asm file.
