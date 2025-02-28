#!/bin/bash
set -e

# ======================================================================
# File:       buildtahoma.sh
# Author:     Charlie Martínez® <cmartinez@quirinux.org>
# License:    BSD 3-Clause "New" or "Revised" License
# Purpose:    Metascript that collects the original Tahoma2D build CI scripts.
# Supported:  Only works in Ubuntu 20.04
# =====================================================================
# This code gathers all the official Tahoma2D build CI scripts into a 
# single one, tailored for a specific environment.
#
# Made for the development of Quirinux Tweaks, this script uses 
# Charlie Martínez’s GitHub repositories instead of the official Tahoma2D 
# repositories for building the software. While some improvements from 
# Quirinux Tweaks may be incorporated into the official development, 
# this repository is not an official Tahoma2D project.

# =====================================================================
# Co-Authored-By: manongjohn <19245851+manongjohn@users.noreply.github.com>
# Co-Authored-By: jeremybullock <79284068+jeremybullock@users.noreply.github.com>
# =====================================================================

#
# Copyright (c) 2019-2025 Charlie Martínez. All Rights Reserved.  
# License: BSD 3-Clause "New" or "Revised" License
# Authorized and unauthorized uses of the Quirinux trademark:  
# See https://www.quirinux.org/aviso-legal  
#
# Tahoma2D and OpenToonz are registered trademarks of their respective 
# owners, and any other third-party projects that may be mentioned or 
# affected by this code belong to their respective owners and follow 
# their respective licenses.
#

_000_var () {
	
	REPO_URL="https://github.com/charliemartinez/tahoma2d.git" #author script fork
	
		if [ ! -e ./tahoma2d-master ];then 
			wget -O master.zip https://github.com/charliemartinez/tahoma2d/archive/refs/heads/master.zip && unzip master.zip && rm master.zip
  		fi
  		
 	cd ./tahoma2d-master
 	
	CHECK_FOLDER="/opt/buildtahoma/checkfiles"
	
	if [ ! -e "$CHECK_FOLDER" ]; then
		sudo mkdir -p "$CHECK_FOLDER"
	fi
	
	CHECK_INSTALL="$CHECK_FOLDER/ok-install"
	CHECK_FFMPEG="$CHECK_FOLDER/ok-ffmpeg"
	CHECK_OPENCV="$CHECK_FOLDER/ok-opencv"
	CHECK_MYPAINT="$CHECK_FOLDER/ok-mypaint"
	CHECK_GPHOTO="$CHECK_FOLDER/ok-gphoto"

}

_001_install () {

		if [ ! -e "$CHECK_INSTALL" ]; then 

			sudo add-apt-repository --yes ppa:beineri/opt-qt-5.15.2-focal
			sudo apt-get update
			sudo apt-get install -y cmake liblzo2-dev liblz4-dev libfreetype6-dev libpng-dev libegl1-mesa-dev libgles2-mesa-dev libglew-dev freeglut3-dev qt515script libsuperlu-dev qt515svg qt515tools qt515multimedia wget libboost-all-dev liblzma-dev libjson-c-dev libjpeg-turbo8-dev libturbojpeg0-dev libglib2.0-dev qt515serialport
			sudo apt-get install -y nasm yasm libgnutls28-dev libunistring-dev libass-dev libbluray-dev libmp3lame-dev libopus-dev libsnappy-dev libtheora-dev libvorbis-dev libvpx-dev libwebp-dev libxml2-dev libfontconfig1-dev libfreetype6-dev libopencore-amrnb-dev libopencore-amrwb-dev libspeex-dev libsoxr-dev libopenjp2-7-dev
			sudo apt-get install -y python3-pip
			sudo apt-get install -y build-essential libgirepository1.0-dev autotools-dev intltool gettext libtool patchelf autopoint libusb-1.0-0 libusb-1.0-0-dev
			sudo apt-get install -y libdeflate-dev

			pip3 install --upgrade pip
			pip3 install numpy

			# Leave repo directory for this step
			cd ..

			# Remove this as the version that is there is old and causes issues compiling opencv
			sudo apt-get remove libprotobuf-dev

			# Need protoc3 for some compiles.  don't use the apt-get version as it's too old.

			if [ ! -d protoc3 ]; then
			wget https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip
			# Unzip
			unzip protoc-3.6.1-linux-x86_64.zip -d protoc3
			fi

			# Move protoc to /usr/local/bin/
			sudo cp -pr protoc3/bin/* /usr/local/bin/

			# Move protoc3/include to /usr/local/include/
			sudo cp -pr protoc3/include/* /usr/local/include/

			sudo ldconfig
			
		fi

	sudo touch "$CHECK_INSTALL"

}

_002_ffmpeg() {

		if [ ! -e "$CHECK_FFMPEG" ]; then
		
			cd thirdparty

			if [ -d "openh264" ]; then
				rm -rf "openh264"
			fi

			echo ">>> Cloning openH264"
			git clone https://github.com/cisco/openh264.git openh264

			cd openh264
			echo "*" >| .gitignore

			echo ">>> Making openh264"
			make

			echo ">>> Installing openh264"
			sudo make install

			cd ..

			if [ -d "ffmpeg" ]; then
				rm -rf "ffmpeg"
			fi
			
			echo ">>> Cloning ffmpeg"
			git clone -b v4.3.1 https://github.com/charliemartinez/FFmpeg ffmpeg

			cd ffmpeg
			echo "*" >| .gitignore

			echo ">>> Configuring to build ffmpeg (shared)"
			export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

			./configure  --prefix=/usr/local \
					--cc="$CC" \
					--cxx="$CXX" \
					--toolchain=hardened \
					--pkg-config-flags="--static" \
					--extra-cflags="-I/usr/local/include" \
					--extra-ldflags="-L/usr/local/lib" \
					--enable-pthreads \
					--enable-version3 \
					--enable-avresample \
					--enable-gnutls \
					--enable-libbluray \
					--enable-libmp3lame \
					--enable-libopus \
					--enable-libsnappy \
					--enable-libtheora \
					--enable-libvorbis \
					--enable-libvpx \
					--enable-libwebp \
					--enable-libxml2 \
					--enable-lzma \
					--enable-libfreetype \
					--enable-libass \
					--enable-libopencore-amrnb \
					--enable-libopencore-amrwb \
					--enable-libopenjpeg \
					--enable-libspeex \
					--enable-libsoxr \
					--enable-libopenh264 \
					--enable-shared \
					--disable-static \
					--disable-libjack \
					--disable-indev=jack

			echo ">>> Building ffmpeg (shared)"
			make

			echo ">>> Installing ffmpeg (shared)"
			sudo make install

			sudo ldconfig
		fi

	sudo touch "$CHECK_FFMPEG"

}

_003_opencv() {

		if [ ! -e "$CHECK_OPENCV" ]; then
		
			cd thirdparty

			if [ -d "opencv" ]; then
				rm -rf "opencv"
			fi
			
			echo ">>> Cloning opencv"
			git clone https://github.com/charliemartinez/opencv

			cd opencv
			echo "*" >| .gitignore

				if [ ! -d build ]; then
					mkdir -p build
				fi
			cd build

			echo ">>> Cmaking openv"
			cmake -DCMAKE_BUILD_TYPE=Release \
					-DBUILD_JASPER=OFF \
					-DBUILD_JPEG=OFF \
					-DBUILD_OPENEXR=OFF \
					-DBUILD_PERF_TESTS=OFF \
					-DBUILD_PNG=OFF \
					-DBUILD_PROTOBUF=OFF \
					-DBUILD_TESTS=OFF \
					-DBUILD_TIFF=OFF \
					-DBUILD_WEBP=OFF \
					-DBUILD_ZLIB=OFF \
					-DBUILD_opencv_hdf=OFF \
					-DBUILD_opencv_java=OFF \
					-DBUILD_opencv_text=ON \
					-DOPENCV_ENABLE_NONFREE=ON \
					-DOPENCV_GENERATE_PKGCONFIG=ON \
					-DPROTOBUF_UPDATE_FILES=ON \
					-DWITH_1394=OFF \
					-DWITH_CUDA=OFF \
					-DWITH_EIGEN=ON \
					-DWITH_FFMPEG=ON \
					-DWITH_GPHOTO2=OFF \
					-DWITH_GSTREAMER=ON \
					-DWITH_JASPER=OFF \
					-DWITH_OPENEXR=ON \
					-DWITH_OPENGL=OFF \
					-DWITH_QT=OFF \
					-DWITH_TBB=ON \
					-DWITH_VTK=ON \
					-DBUILD_opencv_python2=OFF \
					-DBUILD_opencv_python3=ON \
					-DCMAKE_INSTALL_NAME_DIR=/usr/local/lib \
					..

			echo ">>> Building opencv"
			make

			echo ">>> Installing opencv"
			sudo make install
		fi

	sudo touch "$CHECK_OPENCV"

}

_004_mypaint() {

		if [ ! -e "$CHECK_OPENCV" ]; then
			cd thirdparty/libmypaint

			if [ -d "src" ]; then
				rm -rf "src"
			fi

			echo ">>> Cloning libmypaint"
			git clone https://github.com/charliemartinez/libmypaint src

			cd src
			echo "*" >| .gitignore

			export CFLAGS='-Ofast -ftree-vectorize -fopt-info-vec-optimized -march=native -mtune=native -funsafe-math-optimizations -funsafe-loop-optimizations'

			echo ">>> Generating libmypaint environment"
			./autogen.sh

			echo ">>> Configuring libmypaint build"
			sudo ./configure

			echo ">>> Building libmypaint"
			sudo make

			echo ">>> Installing libmypaint"
			sudo make install

			sudo ldconfig

		fi

	sudo touch "CHECK_LIBMYPAINT"

}

_005_gphoto() {

		if [ ! -e "$CHECK_GPHOTO" ]; then

			cd thirdparty

			if [ -d "libgphoto2_src" ]; then
				rm -rf "libgphoto2_src"
			fi

			echo ">>> Cloning libgphoto2"
			git clone https://github.com/charliemartinez/libgphoto2.git libgphoto2_src

			cd libgphoto2_src

			git checkout tahoma2d-version

			echo ">>> Configuring libgphoto2"
			autoreconf --install --symlink

			./configure --prefix=/usr/local

			echo ">>> Making libgphoto2"
			make

			echo ">>> Installing libgphoto2"
			sudo make install

			cd ..

		fi

	sudo touch "$CHECK_GPHOTO"

}

_006_build(){

	pushd thirdparty/tiff-4.2.0
	CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --disable-jbig --disable-webp && make
	popd

	cd toonz

		if [ ! -d build ]; then
			mkdir -p build
		fi
		
		cd build

	source /opt/qt515/bin/qt515-env.sh

		if [ -d ../../thirdparty/canon/Header ]; then
			export CANON_FLAG=-DWITH_CANON=ON
		fi

	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	cmake ../sources  $CANON_FLAG \
		-DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DWITH_GPHOTO2:BOOL=ON \
		-DWITH_SYSTEM_SUPERLU=ON

	make -j7

}

_007_apps(){

	cd thirdparty

		if [ ! -d apps ]; then
			mkdir -p apps
		fi
		
	cd apps
	echo "*" >| .gitignore

	echo ">>> Getting FFmpeg"
	
		if [ -d ffmpeg ]; then
			rm -rf ffmpeg
		fi
		
	wget https://github.com/charliemartinez/FFmpeg/releases/download/v5.0.0/ffmpeg-5.0.0-linux64-static-lgpl.zip
	unzip ffmpeg-5.0.0-linux64-static-lgpl.zip 
	mv ffmpeg-5.0.0-linux64-static-lgpl ffmpeg


	echo ">>> Getting Rhubarb Lip Sync"
	
		if [ -d rhubarb ]; then
			rm -rf rhubarb ]
		fi
		
		wget https://github.com/charliemartinez/rhubarb-lip-sync/releases/download/v1.13.0/rhubarb-lip-sync-tahoma2d-linux.zip
		unzip rhubarb-lip-sync-tahoma2d-linux.zip -d rhubarb

}

_008_dpkg() {

	source /opt/qt515/bin/qt515-env.sh

	echo ">>> Temporary install of Tahoma2D"
	SCRIPTPATH=`dirname "$0"`
	export BUILDDIR=$SCRIPTPATH/../../toonz/build
	cd $BUILDDIR
	sudo make install

	sudo ldconfig

	echo ">>> Creating appDir"
		if [ -d appdir ]; then
			rm -rf appdir
		fi
		
	mkdir -p appdir/usr

	echo ">>> Copy and configure Tahoma2D installation in appDir"
	cp -r /opt/tahoma2d/* appdir/usr
	cp appdir/usr/share/applications/*.desktop appdir
	cp appdir/usr/share/icons/hicolor/*/apps/*.png appdir
	mv appdir/usr/lib/tahoma2d/* appdir/usr/lib
	rmdir appdir/usr/lib/tahoma2d

	echo ">>> Creating Tahoma2D directory"
		if [ -d Tahoma2D ]; then
			rm -rf Tahoma2D
		fi
	mkdir -p Tahoma2D

	echo ">>> Copying stuff to Tahoma2D/tahomastuff"

	mv appdir/usr/share/tahoma2d/stuff Tahoma2D/tahomastuff
	chmod -R 777 Tahoma2D/tahomastuff
	rmdir appdir/usr/share/tahoma2d

	find Tahoma2D/tahomastuff -name .gitkeep -exec rm -f {} \;

		if [ -d ../../thirdparty/apps/ffmpeg/bin ]; then
			echo ">>> Copying FFmpeg to Tahoma2D/ffmpeg"
			if [ -d Tahoma2D/ffmpeg ]; then
				rm -rf Tahoma2D/ffmpeg
			fi
			mkdir -p Tahoma2D/ffmpeg
			cp -R ../../thirdparty/apps/ffmpeg/bin/ffmpeg ../../thirdparty/apps/ffmpeg/bin/ffprobe Tahoma2D/ffmpeg
			chmod -R 755 Tahoma2D/ffmpeg
		fi

		if [ -d ../../thirdparty/apps/rhubarb ]; then
			echo ">>> Copying Rhubarb Lip Sync to Tahoma2D/rhubarb"
			if [ -d Tahoma2D/rhubarb ]; then
			  rm -rf Tahoma2D/rhubarb
			fi
			mkdir -p Tahoma2D/rhubarb
			cp -R ../../thirdparty/apps/rhubarb/rhubarb ../../thirdparty/apps/rhubarb/res Tahoma2D/rhubarb
			chmod 755 -R Tahoma2D/rhubarb
		fi

		if [ -d ../../thirdparty/canon/Library ]; then
			echo ">>> Copying canon libraries"
			cp -R ../../thirdparty/canon/Library/x86_64/* appdir/usr/lib
		fi

	echo ">>> Copying libghoto2 supporting directories"
	cp -r /usr/local/lib/libgphoto2 appdir/usr/lib
	cp -r /usr/local/lib/libgphoto2_port appdir/usr/lib

	rm appdir/usr/lib/libgphoto2/print-camera-list
	find appdir/usr/lib/libgphoto2* -name *.la -exec rm -f {} \;
	find appdir/usr/lib/libgphoto2* -name *.so -exec patchelf --set-rpath '$ORIGIN/../..' {} \;

	echo ">>> Creating Tahoma2D/Tahoma2D.AppImage"

		if [ ! -f linuxdeployqt*.AppImage ]; then
			wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
			chmod a+x linuxdeployqt*.AppImage
		fi

	export LD_LIBRARY_PATH=appdir/usr/lib/tahoma2d
	./linuxdeployqt*.AppImage appdir/usr/bin/Tahoma2D -bundle-non-qt-libs -verbose=0 -always-overwrite -no-strip \
		-executable=appdir/usr/bin/lzocompress \
		-executable=appdir/usr/bin/lzodecompress \
		-executable=appdir/usr/bin/tcleanup \
		-executable=appdir/usr/bin/tcomposer \
		-executable=appdir/usr/bin/tconverter \
		-executable=appdir/usr/bin/tfarmcontroller \
		-executable=appdir/usr/bin/tfarmserver 

	rm appdir/AppRun
	cp ../sources/scripts/AppRun appdir
	chmod 775 appdir/AppRun

	./linuxdeployqt*.AppImage appdir/usr/bin/Tahoma2D -appimage -no-strip 

	mv Tahoma2D*.AppImage Tahoma2D/Tahoma2D.AppImage

	echo ">>> Creating Tahoma2D Linux package"
	tar zcf Tahoma2D-linux.tar.gz Tahoma2D

}

 # ======================================================================
 # Main
 # ======================================================================

_main() {

	_000_var
	_001_install
	_002_ffmpeg
	_003_opencv
	_004_mypaint
	_005_gphoto
	_006_build
	_007_apps
	_008_dpkg
	
}

_main
