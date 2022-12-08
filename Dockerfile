FROM ubuntu:22.04

# The tzdata package isn't docker-friendly, and something pulls it.
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/GMT

RUN apt update
RUN apt dist-upgrade -y
RUN apt install -y yasm nasm git zstd p7zip-full wget build-essential \
pkg-config-mingw-w64-i686 pkg-config-mingw-w64-x86-64 \
mingw-w64-i686-dev mingw-w64-x86-64-dev gcc-mingw-w64-i686-win32 gcc-mingw-w64-x86-64-win32 \
mono-runtime libmono-cil-dev

RUN wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
RUN git clone --depth 1 --branch n5.0.2 https://git.ffmpeg.org/ffmpeg.git

RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-aom-3.5.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-dav1d-1.0.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-gsm-1.0.22-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-lame-3.100-2-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libiconv-1.17-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libogg-1.3.5-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libtheora-1.1.1-7-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libvorbis-1.3.7-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libvpx-1.12.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-libwebp-1.2.4-2-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-shine-3.1.1-1-any.pkg.tar.xz
RUN wget https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-speex-1.2.1-1-any.pkg.tar.zst

RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-aom-3.5.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-dav1d-1.0.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-gsm-1.0.22-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-lame-3.100-2-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libiconv-1.17-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libogg-1.3.5-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libtheora-1.1.1-7-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libvorbis-1.3.7-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libvpx-1.12.0-1-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libwebp-1.2.4-2-any.pkg.tar.zst
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-shine-3.1.1-1-any.pkg.tar.xz
RUN wget https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-speex-1.2.1-1-any.pkg.tar.zst

RUN wget https://zlib.net/zlib-1.2.13.tar.gz

RUN mkdir msys2
WORKDIR /msys2
RUN for f in ../*.tar.zst ; do tar xvf $f ; done
RUN for f in ../*.tar.xz ; do tar xvf $f ; done
RUN find . -name *dll* -exec rm {} \;
RUN cp -rv mingw32/* /usr/i686-w64-mingw32
RUN cp -rv mingw64/* /usr/x86_64-w64-mingw32
RUN tar xvfz ../zlib-1.2.13.tar.gz
WORKDIR /msys2/zlib-1.2.13

RUN \
make -f win32/Makefile.gcc \
BINARY_PATH=/usr/i686-w64-mingw32/bin \
INCLUDE_PATH=/usr/i686-w64-mingw32/include \
LIBRARY_PATH=/usr/i686-w64-mingw32/lib \
SHARED_MODE=0 \
PREFIX=i686-w64-mingw32- \
install

WORKDIR /msys2
RUN rm -rf zlib-1.2.13
RUN tar xvfz ../zlib-1.2.13.tar.gz
WORKDIR /msys2/zlib-1.2.13

RUN \
make -f win32/Makefile.gcc \
BINARY_PATH=/usr/x86_64-w64-mingw32/bin \
INCLUDE_PATH=/usr/x86_64-w64-mingw32/include \
LIBRARY_PATH=/usr/x86_64-w64-mingw32/lib \
SHARED_MODE=0 \
PREFIX=x86_64-w64-mingw32- \
install

WORKDIR /ffmpeg

RUN ./configure \
--prefix=/ffmpeg-install-32-lgpl2 \

--arch=x86 --target-os=mingw64 --cross-prefix=i686-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

#RUN cat ffbuild/config.log && false

RUN make -j && make install
RUN git clean -f -d -x

RUN ./configure \
--prefix=/ffmpeg-install-64-lgpl2 \

--arch=x86_64 --target-os=mingw64 --cross-prefix=x86_64-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN mkdir -p /ffmpeg-package-lgpl2/build/native/bin/Win32
RUN mkdir -p /ffmpeg-package-lgpl2/build/native/bin/x64
RUN mkdir -p /ffmpeg-package-lgpl2/build/native/lib/Win32
RUN mkdir -p /ffmpeg-package-lgpl2/build/native/lib/x64
RUN cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-lgpl2/build/native/bin/Win32
RUN cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-lgpl2/build/native/bin/x64
RUN cp /usr/lib/gcc/i686-w64-mingw32/10-win32/libgcc_s_dw2-1.dll /ffmpeg-package-lgpl2/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-32-lgpl2/bin/*.dll /ffmpeg-package-lgpl2/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-64-lgpl2/bin/*.dll /ffmpeg-package-lgpl2/build/native/bin/x64
RUN cp -rv /ffmpeg-install-32-lgpl2/bin/*.lib /ffmpeg-package-lgpl2/build/native/lib/Win32
RUN cp -rv /ffmpeg-install-64-lgpl2/bin/*.lib /ffmpeg-package-lgpl2/build/native/lib/x64
RUN cp -rv /ffmpeg-install-32-lgpl2/include /ffmpeg-package-lgpl2/build

RUN ./configure \
--prefix=/ffmpeg-install-32-lgpl3 --enable-version3 \

--arch=x86 --target-os=mingw64 --cross-prefix=i686-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN ./configure \
--prefix=/ffmpeg-install-64-lgpl3 --enable-version3 \

--arch=x86_64 --target-os=mingw64 --cross-prefix=x86_64-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN mkdir -p /ffmpeg-package-lgpl3/build/native/bin/Win32
RUN mkdir -p /ffmpeg-package-lgpl3/build/native/bin/x64
RUN mkdir -p /ffmpeg-package-lgpl3/build/native/lib/Win32
RUN mkdir -p /ffmpeg-package-lgpl3/build/native/lib/x64
RUN cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-lgpl3/build/native/bin/Win32
RUN cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-lgpl3/build/native/bin/x64
RUN cp /usr/lib/gcc/i686-w64-mingw32/10-win32/libgcc_s_dw2-1.dll /ffmpeg-package-lgpl3/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-32-lgpl3/bin/*.dll /ffmpeg-package-lgpl3/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-64-lgpl3/bin/*.dll /ffmpeg-package-lgpl3/build/native/bin/x64
RUN cp -rv /ffmpeg-install-32-lgpl3/bin/*.lib /ffmpeg-package-lgpl3/build/native/lib/Win32
RUN cp -rv /ffmpeg-install-64-lgpl3/bin/*.lib /ffmpeg-package-lgpl3/build/native/lib/x64
RUN cp -rv /ffmpeg-install-32-lgpl3/include /ffmpeg-package-lgpl3/build

RUN ./configure \
--prefix=/ffmpeg-install-32-gpl2 --enable-gpl \

--arch=x86 --target-os=mingw64 --cross-prefix=i686-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN ./configure \
--prefix=/ffmpeg-install-64-gpl2 --enable-gpl \

--arch=x86_64 --target-os=mingw64 --cross-prefix=x86_64-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN mkdir -p /ffmpeg-package-gpl2/build/native/bin/Win32
RUN mkdir -p /ffmpeg-package-gpl2/build/native/bin/x64
RUN mkdir -p /ffmpeg-package-gpl2/build/native/lib/Win32
RUN mkdir -p /ffmpeg-package-gpl2/build/native/lib/x64
RUN cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-gpl2/build/native/bin/Win32
RUN cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-gpl2/build/native/bin/x64
RUN cp /usr/lib/gcc/i686-w64-mingw32/10-win32/libgcc_s_dw2-1.dll /ffmpeg-package-gpl2/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-32-gpl2/bin/*.dll /ffmpeg-package-gpl2/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-64-gpl2/bin/*.dll /ffmpeg-package-gpl2/build/native/bin/x64
RUN cp -rv /ffmpeg-install-32-gpl2/bin/*.lib /ffmpeg-package-gpl2/build/native/lib/Win32
RUN cp -rv /ffmpeg-install-64-gpl2/bin/*.lib /ffmpeg-package-gpl2/build/native/lib/x64
RUN cp -rv /ffmpeg-install-32-gpl2/include /ffmpeg-package-gpl2/build

RUN ./configure \
--prefix=/ffmpeg-install-32-gpl3 --enable-gpl --enable-version3 \

--arch=x86 --target-os=mingw64 --cross-prefix=i686-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN ./configure \
--prefix=/ffmpeg-install-64-gpl3 --enable-gpl --enable-version3 \

--arch=x86_64 --target-os=mingw64 --cross-prefix=x86_64-w64-mingw32- \
--disable-static --enable-shared --pkg-config-flags=--static \
--disable-programs --disable-doc \

--enable-dxva2 \
--enable-iconv \
--enable-libaom \
--enable-libdav1d \
--enable-libgsm \
--enable-libmp3lame \
--enable-libshine \
--enable-libspeex \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-schannel \
--enable-w32threads \
--enable-zlib

RUN make -j && make install
RUN git clean -f -d -x

RUN mkdir -p /ffmpeg-package-gpl3/build/native/bin/Win32
RUN mkdir -p /ffmpeg-package-gpl3/build/native/bin/x64
RUN mkdir -p /ffmpeg-package-gpl3/build/native/lib/Win32
RUN mkdir -p /ffmpeg-package-gpl3/build/native/lib/x64
RUN cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-gpl3/build/native/bin/Win32
RUN cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /ffmpeg-package-gpl3/build/native/bin/x64
RUN cp /usr/lib/gcc/i686-w64-mingw32/10-win32/libgcc_s_dw2-1.dll /ffmpeg-package-gpl3/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-32-gpl3/bin/*.dll /ffmpeg-package-gpl3/build/native/bin/Win32
RUN cp -rv /ffmpeg-install-64-gpl3/bin/*.dll /ffmpeg-package-gpl3/build/native/bin/x64
RUN cp -rv /ffmpeg-install-32-gpl3/bin/*.lib /ffmpeg-package-gpl3/build/native/lib/Win32
RUN cp -rv /ffmpeg-install-64-gpl3/bin/*.lib /ffmpeg-package-gpl3/build/native/lib/x64
RUN cp -rv /ffmpeg-install-32-gpl3/include /ffmpeg-package-gpl3/build

WORKDIR /

COPY *.nuspec /
COPY ffmpeg-lite.lgpl.native.targets /libffmpeg-lite.lgpl2.native.targets
COPY ffmpeg-lite.lgpl.native.targets /libffmpeg-lite.lgpl3.native.targets
COPY ffmpeg-lite.gpl.native.targets /libffmpeg-lite.gpl2.native.targets
COPY ffmpeg-lite.gpl.native.targets /libffmpeg-lite.gpl3.native.targets

RUN mono nuget.exe pack ffmpeg-lite.lgpl2.native.nuspec
RUN mono nuget.exe pack ffmpeg-lite.lgpl3.native.nuspec
RUN mono nuget.exe pack ffmpeg-lite.gpl2.native.nuspec
RUN mono nuget.exe pack ffmpeg-lite.gpl3.native.nuspec

