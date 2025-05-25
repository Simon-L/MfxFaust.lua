wget https://github.com/Simon-L/libMfxFaust/releases/download/Nightly/libMfxFaust-ubuntu-x86_64.tar.gz
wget https://github.com/Simon-L/mfx-base-app/releases/download/Nightly/mfx-base-app-ubuntu-x86_64.tar.gz

7z x mfx-base-app-ubuntu-x86_64.tar.gz
7z x mfx-base-app-ubuntu-x86_64.tar
rm mfx-base-app-ubuntu-x86_64.tar.gz mfx-base-app-ubuntu-x86_64.tar

7z x libMfxFaust-ubuntu-x86_64.tar.gz
7z x libMfxFaust-ubuntu-x86_64.tar
rm libMfxFaust-ubuntu-x86_64.tar.gz libMfxFaust-ubuntu-x86_64.tar

mv libMfxFaust.so bin/