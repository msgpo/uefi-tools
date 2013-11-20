#!/bin/bash

#
# Board Configuration Section
# ===========================
#
# To add a new platform:
# - add a <shortname> to the "boards" array
# - create a <shortname>_LONGNAME variable with a descriptive name
# - create a <shortname>_BUILDFLAGS variable with any platform specific
#   options for edk2 'build'.
# And for platforms using standard edk2 'build':
# - create a <shortname>_DSC variable containing the path to the
#   platform .dsc file.
# Or for platforms not using edk2 'build' directly:
# - create a <shortname>_BUILDCMD variable pointing to the path of the
#   build command to use.
#

boards=( a5 a9 tc1 tc2 panda origen arndale rtsm_a9x4 rtsm_a15x1 rtsm_a15mpcore rtsm_aarch64 beagle fvp foundation )

fvp_LONGNAME="aarch64 FVP RTSM"
fvp_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-FVP-AArch64.dsc"
fvp_BUILDFLAGS="-D ARM_FOUNDATION_FVP=1"
fvp_ARCH="AARCH64"

rtsm_aarch64_LONGNAME="aarch64 RTSM"
rtsm_aarch64_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-RTSM-AEMv8Ax4.dsc"
rtsm_aarch64_BUILDFLAGS=""
rtsm_aarch64_ARCH="AARCH64"

foundation_LONGNAME="Foundation Model RTSM"
foundation_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-RTSM-AEMv8Ax4-foundation.dsc"
foundation_BUILDFLAGS=""
foundation_PREBUILD_CMDS="pushd ArmPlatformPkg/ArmVExpressPkg/Scripts/uefi-aarch64-bootstrap/ ; CROSS_COMPILE=aarch64-linux-gnu- make uefi-bootstrap-el3-foundation.axf; popd"
foundation_ARCH="AARCH64"

a5_LONGNAME="Versatile Express A5"
a5_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
a5_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA5s.dsc"
a5_ARCH="ARM"

a9_LONGNAME="Versatile Express A9"
a9_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1 -D EDK2_ARMVE_SINGLE_BINARY=1"
a9_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA9x4.dsc"
a9_ARCH="ARM"

rtsm_a9x4_LONGNAME="Versatile Express RTSM A9x4"
rtsm_a9x4_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
rtsm_a9x4_DSC=" ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-RTSM-A9x4.dsc"
rtsm_a9x4_ARCH="ARM"

rtsm_a15x1_LONGNAME="Versatile Express RTSM A15 single core"
rtsm_a15x1_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
rtsm_a15x1_DSC=" ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-RTSM-A15.dsc"
rtsm_a15x1_ARCH="ARM"

rtsm_a15mpcore_LONGNAME="Versatile Express RTSM A15 MPCore"
rtsm_a15mpcore_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
rtsm_a15mpcore_DSC=" ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-RTSM-A15_MPCore.dsc"
rtsm_a15mpcore_ARCH="ARM"

tc1_LONGNAME="Versatile Express TC1"
tc1_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
tc1_DSC=" ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15x2.dsc"
tc1_ARCH="ARM"

tc2_LONGNAME="Versatile Express TC2"
tc2_BUILDFLAGS="-D ARM_BIGLITTLE_TC2=1"
tc2_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15-A7.dsc"
tc2_ARCH="ARM"

panda_LONGNAME="TI Pandaboard"
panda_BUILDCMD="./PandaBoardPkg/build.sh"
panda_BUILDFLAGS=""
panda_ARCH="ARM"

origen_LONGNAME="Samsung Origen"
origen_BUILDFLAGS=""
origen_DSC="SamsungPlatformPkgOrigen/OrigenBoardPkg/OrigenBoardPkg-Exynos.dsc"
origen_ARCH="ARM"

arndale_LONGNAME="Samsung Arndale"
arndale_BUILDFLAGS="-D EXYNOS5250_EVT1 -D DDR3"
arndale_DSC="SamsungPlatformPkg/ArndaleBoardPkg/arndale-Exynos5250.dsc"
arndale_ARCH="ARM"

beagle_LONGNAME="BeagleBoard"
beagle_BUILDFLAGS=""
beagle_DSC="BeagleBoardPkg/BeagleBoardPkg.dsc"
beagle_ARCH="ARM"

#
# End of Board Configuration Section.
#
# No need to edit below unless you are changing script functionality.
#

RESULT_BUF=`echo -e --------------------------------------------`
PASS_COUNT=0
FAIL_COUNT=0

function log_result
{
	if [ $1 -eq 0 ]; then
		RESULT_BUF="`printf \"%s\n%32s\tpass\" \"$RESULT_BUF\" \"$2\"`"
		PASS_COUNT=$(($PASS_COUNT + 1))
	else
		RESULT_BUF="`printf \"%s\n%32s\tfail\" \"$RESULT_BUF\" \"$2\"`"
		FAIL_COUNT=$(($FAIL_COUNT + 1))
	fi
}

function print_result
{
	printf "%s" "$RESULT_BUF"
	echo -e "\n--------------------------------------------"
	printf "pass\t$PASS_COUNT\n"
	printf "fail\t$FAIL_COUNT\n"

	exit $FAIL_COUNT
}

function build_platform
{
	PLATFORM_NAME="$board"_LONGNAME
	PLATFORM_PREBUILD_CMDS="$board"_PREBUILD_CMDS
	PLATFORM_BUILDFLAGS="$board"_BUILDFLAGS
	PLATFORM_BUILDFLAGS="${!PLATFORM_BUILDFLAGS} ${EXTRA_OPTIONS[@]}"
	PLATFORM_BUILDCMD="$board"_BUILDCMD
	PLATFORM_DSC="$board"_DSC
	PLATFORM_ARCH="$board"_ARCH

	BUILD_ARCH=`uname -m`
	case $BUILD_ARCH in
		arm*)
			TEMP_CROSS_COMPILE=
			;;
		aarch64)
			TEMP_CROSS_COMPILE=
			;;
		*)
			if [ "${!PLATFORM_ARCH}" == "AARCH64" ]; then
				TEMP_CROSS_COMPILE=aarch64-linux-gnu-
			else
				TEMP_CROSS_COMPILE=arm-linux-gnueabi-
			fi
			;;
	esac
	if [ "$CROSS_COMPILE" != "" ]; then
		TEMP_CROSS_COMPILE="$CROSS_COMPILE"
	fi

	echo "Building ${!PLATFORM_NAME}"
	echo "CROSS_COMPILE=\"$TEMP_CROSS_COMPILE\""
	echo "$board"_BUILDFLAGS="'${PLATFORM_BUILDFLAGS}'"

	if [ "$TARGETS" == "" ]; then
		TARGETS=( RELEASE )
	fi

	for target in "${TARGETS[@]}" ; do
		if [ X"${!PLATFORM_PREBUILD_CMDS}" != X"" ]; then
			echo "Run pre build commands"
			eval ${!PLATFORM_PREBUILD_CMDS}
		fi
		if [ X"${!PLATFORM_BUILDCMD}" == X"" ]; then
			CROSS_COMPILE="$TEMP_CROSS_COMPILE" build -a "${!PLATFORM_ARCH}" -t ARMLINUXGCC -p "${!PLATFORM_DSC}" -b "$target" \
				${PLATFORM_BUILDFLAGS}
		else
			${!PLATFORM_BUILDCMD} -b "$target" ${PLATFORM_BUILDFLAGS}
		fi
		log_result $? "${!PLATFORM_NAME} ${target}"
	done
}


function uefishell
{
	BUILD_ARCH=`uname -m`
	case $BUILD_ARCH in
		arm*)
			ARCH=ARM
			;;
		aarch64)
			ARCH=AARCH64
			;;
		*)
			unset ARCH
			;;
	esac
	export ARCH
	echo "Setting up shell for building UEFI"
	export TOOLCHAIN=ARMLINUXGCC
	export EDK_TOOLS_PATH=`pwd`/BaseTools
	. edksetup.sh `pwd`/BaseTools/
	make -C $EDK_TOOLS_PATH
	if [ $? -ne 0 ]; then
		echo " !!! UEFI BaseTools failed to build !!! " >&2
		exit 1
	fi
}


function usage
{
	echo "usage:"
	echo -n "uefi-build.sh [-b DEBUG | RELEASE] [ all "
	for board in "${boards[@]}" ; do
	    echo -n "| $board "
	done
	echo "]"
	printf "%8s\tbuild %s\n" "all" "all supported platforms"
	for board in "${boards[@]}" ; do
		PLATFORM_NAME="$board"_LONGNAME
		printf "%8s\tbuild %s\n" "$board" "${!PLATFORM_NAME}"
	done
}

builds=()

# If there were no args, use a menu to select a single board / all boards to build
if [ $# = 0 ]
then
	read -p "$(
			f=0
			for board in "${boards[@]}" ; do
					echo "$((++f)): $board"
			done
			echo $((++f)): all

			echo -ne '> '
	)" selection

	if [ "$selection" -eq $((${#boards[@]} + 1)) ]; then
		builds=(${boards[@]})
	else
		builds="${boards[$((selection-1))]}"
	fi
else
	while [ "$1" != "" ]; do
		case $1 in
			all )
				builds=(${boards[@]})
				break
				;;
			"/h" | "/?" | "-?" | "-h" | "--help" )
				usage
				exit
				;;
			"-b" | "--build" )
				shift
				echo "Adding Build profile: $1"
				TARGETS=( ${TARGETS[@]} $1 )
				;;
			"-D" )
				shift
				echo "Adding option: -D $1"
				EXTRA_OPTIONS=( ${EXTRA_OPTIONS[@]} "-D" $1 )
				;;
			* )
				MATCH=0
				for board in "${boards[@]}" ; do
					if [ "$1" == $board ]; then
						MATCH=1
						builds=(${builds[@]} "$board")
						break
					fi
				done

				if [ $MATCH -eq 0 ]; then
					echo "unknown arg $1"
					usage
					exit 1
				fi
				;;
		esac
		shift
	done
fi

# Check to see if we are in a UEFI repository
# refuse to continue if we aren't
if [ ! -e BaseTools ]
then
	echo "ERROR: we aren't in the UEFI directory."
	echo "       I can tell because I can't see the BaseTools directory"
	exit 1
fi

uefishell

for board in "${builds[@]}" ; do
	build_platform
done

print_result
