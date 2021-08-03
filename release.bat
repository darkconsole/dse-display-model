@echo off

echo DID YOU INCREMEMENT THE VERSION NUMBER IN THE MAIN SCRIPT ASSHOLE?

call php patch.php push sfnone
call php patch.php push slaoff
call c:\local\unxutils\usr\local\wbin\zip dse-display-model-v%~1.zip -q -r *.esp configs interface meshes patches scripts seq textures fomod

