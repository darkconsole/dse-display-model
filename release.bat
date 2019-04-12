@echo off

echo DID YOU INCREMEMENT THE VERSION NUMBER IN THE MAIN SCRIPT ASSHOLE?

c:\local\unxutils\usr\local\wbin\zip dse-display-model-v%~1.zip -q -r *.esp configs interface meshes scripts seq textures

