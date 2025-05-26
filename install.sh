platform=ubuntu-x86_64
# platform=windows

wget https://github.com/Simon-L/libMfxFaust/releases/download/Nightly/libMfxFaust-$platform.tar.gz
wget https://github.com/Simon-L/mfx-base-app/releases/download/Nightly/mfx-base-app-$platform.tar.gz

7z x mfx-base-app-$platform.tar.gz
7z x mfx-base-app-$platform.tar
rm mfx-base-app-$platform.tar.gz mfx-base-app-$platform.tar

7z x libMfxFaust-$platform.tar.gz
7z x libMfxFaust-$platform.tar
rm libMfxFaust-$platform.tar.gz libMfxFaust-$platform.tar

mv *.so *.dll bin/  2>/dev/null
rm *.lib *.exp 2>/dev/null