#!/usr/bin/env bash
# Custom docker build shell script that should be adaptable for about anything you could want
# Author: Jason Hawks
# Contact: jason *at* fixedbit.com

# Note: This script can use cross building from Docker, enable it in this script and
# run this command once to set it up: docker buildx create --name cross_build --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=50000000 --use 

set -e

# Your registry url, leave blank if local
DOCKER_REGISTRY=
# Name of the image we are building
IMAGE_NAME=corrade
# Should we upload this to the registry?
IMAGE_UPLOAD=false
# Do you want to keep a copy of the build log?
KEEP_BUILD_LOG=false
# Set the name of your source file, leave blank if none
SOURCE_FILE=$PWD/_source.sh
# Do you want to cross-build this image?
CROSS_BUILD=false
# Is this to be tagged as latest?
TAG_LATEST=false

# I suggest do not touch these unless you know what you are doing!

# Set the build log and build file directory
BUILD_LOG_DIR=$PWD/build_logs
BUILD_LOG=$BUILD_LOG_DIR/build.txt
# Set our script name for use below
SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# Set our default Dockerfile location, this variable is overwritten if you do -f path/Dockerfile
DOCKER_FILE_LOCATION='.'
# Set our Docker BuildX platforms
BUILD_ARCHS='linux/amd64,linux/armhf,linux/arm64'

# You need help with this?
show_help()
{
    echo "* ~~ Any of these flags may be combined ~~"
    echo "* '${SCRIPT_NAME} -n' sets no cache so it always pulls latest containers"
    echo "* '${SCRIPT_NAME} -c' sets crossbuilding between all supported Linux platforms"
    echo "* '${SCRIPT_NAME} -l' sets current build as latest"
    echo "* '${SCRIPT_NAME} -p' force pulls latest of every Docker image"
    echo "* '${SCRIPT_NAME} -u' Uploads the image to the registry"
    echo "* '${SCRIPT_NAME} -b' Keeps a copy of the build log"
    echo "* '${SCRIPT_NAME} -r docker-registry' Sets a docker registry"
    echo "* '${SCRIPT_NAME} -s source.sh' sets a script to source variables from"
    echo "* '${SCRIPT_NAME} -i name-of-image' overwrites the pre-set image name used for building"
    echo "* '${SCRIPT_NAME} -a build-archs' overwrites the pre-set archictectures used for building"
    echo "* '${SCRIPT_NAME} -f Dockerfile' OPTIONAL - allows you to point this script to a different Dockerfile"
}

# Iterate over arguments and process them
while (( "${#}" )); do
    case "${1}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--cross-build)
            echo "Cross building for multiple platforms"
            CROSS_BUILD=true
            ;;
        -l|--latest)
            echo "Tagging this build as \"latest\""
            TAG_LATEST=true
            ;;
        -b|--buildlog)
            echo "Keeping a copy of the build log"
            KEEP_BUILD_LOG=true
            ;;
        -n|--no-cache)
            echo "Forcing full build with no cache"
            OPTS="--no-cache ${OPTS}"
            ;;
        -p|--pull)
            echo "Pull Enabled"
            OPTS="--pull ${OPTS}"
            ;;
        -u|--upload)
            echo "Upload Enabled"
            IMAGE_UPLOAD=true
            ;;
        -a|--archs)
            [[ ${2} != -* && ! -z ${2} ]] && { BUILD_ARCHS="${2}"; echo "Using build ARCHs: ${2}"; } || { ERRORS+=("Invalid build ARCHs passed to -a"); }
            shift
            ;;
        -r|--registry)
            [[ ${2} != -* && ! -z ${2} ]] && { DOCKER_REGISTRY="${2}"; echo "Using Docker Registry: ${2}"; } || { ERRORS+=("Invalid Docker Registry passed to -r"); }
            shift
            ;;
        -i|--image)
            [[ ${2} != -* && ! -z ${2} ]] && { IMAGE_NAME="${2}"; echo "Using image name: ${2}"; } || { ERRORS+=("Invalid image name passed to -i"); }
            shift
            ;;
        -f|--file)
            [[ ${2} != -* && ! -z ${2} && -f ${2} ]] && { DOCKER_FILE_LOCATION="-f ${2} ."; echo "Using Dockerfile: ${2}"; } || { 
                    [[ ${2} != -* && ! -f ${2} && ! -z ${2} ]] && {
                        ERROR="\"${2}\" does not exist to be used for a '-f' docker file";
                    } || {
                        ERROR="No filename for -f Dockerfile was passed";
                    }; 
                    ERRORS+=("${ERROR}");
                }
            shift
            ;;
        -s|--source)
            [[ ${2} != -* && ! -z ${2} && -f ${2} ]] && { SOURCE_FILE="source ${2}"; echo "Using source file: ${2}"; } || { 
                    [[ ${2} != -* && ! -f ${2} && ! -z ${2} ]] && {
                        ERROR="\"${2}\" does not exist to be used for a '-s' source file";
                    } || {
                        ERROR="No filename for -s Source File was passed";
                    }; 
                    ERRORS+=("${ERROR}");
                }
            shift
            ;;
        *)
            ERRORS+=("${1} is not a valid argument for ${SCRIPT_NAME}")
            ;;
    esac
    shift
done

# Check if we have a source file exists
if [ -f "${SOURCE_FILE}" ]; then
    echo "Sourcing '${SOURCE_FILE}'"
    source "${SOURCE_FILE}"
fi

# If DOCKER_REGISTRY IS blank and IMAGE_NAME is NOT blank
if [[ -z "${DOCKER_REGISTRY}" && ! -z "${IMAGE_NAME}" ]]; then
    BUILD_TAGS+=("${IMAGE_NAME}:${CORRADE_VERSION}")
    [ "${TAG_LATEST}" == "true" ] && BUILD_TAGS+=("${IMAGE_NAME}:latest")
# Else if IMAGE_NAME NOT blank and DOCKER_REGISTRY NOT blank
elif [[ ! -z "${IMAGE_NAME}" && ! -z "${DOCKER_REGISTRY}" ]]; then
    BUILD_TAGS+=("${DOCKER_REGISTRY}/${IMAGE_NAME}:${CORRADE_VERSION}")
    [ "${TAG_LATEST}" == "true" ] && BUILD_TAGS+=("${DOCKER_REGISTRY}/${IMAGE_NAME}:latest")
# If no image name is set then we error out
elif [ -z "${IMAGE_NAME}" ]; then
    ERRORS+=("You must pass an image name in with '-i' or set 'IMAGE_NAME' in ${SCRIPT_NAME}")
fi

# Check if we have tags to name our docker image and no other errors
if [ "${#BUILD_TAGS[@]}" -gt 0 ]; then
    # Generate our BUILD_TAG_OUT used by the build command
    for buildtag in "${BUILD_TAGS[@]}"; do
        BUILD_TAG_OUT="${BUILD_TAG_OUT} -t ${buildtag}"
    done
else
    ERRORS+=("There were no tags for this script to build")
fi

# Print out our errors if we have any
if [ ! -z ${ERRORS} ]; then
    printf "\n~~ The following Errors Were Found ~~\n"
    for error in "${ERRORS[@]}"; do
        printf "\n~ ${error}\n"
    done
    exit 1
fi

# Check if we crossbuild or not, otherwise do a normal build and optional push
[ "${CROSS_BUILD}" == "true" ] && {
     [ "${IMAGE_UPLOAD}" == "true" ] && { EXTRA_CROSS_OPTS='--push'; } || { EXTRA_CROSS_OPTS=''; };
     BUILD_COMMAND="docker buildx build --build-arg CORRADE_VERSION=${CORRADE_VERSION} --platform ${BUILD_ARCHS} ${OPTS}${BUILD_TAG_OUT} ${EXTRA_CROSS_OPTS} ${DOCKER_FILE_LOCATION}"; 
   } || {
     BUILD_COMMAND="docker build --build-arg CORRADE_VERSION=${CORRADE_VERSION} ${OPTS}${BUILD_TAG_OUT} ${DOCKER_FILE_LOCATION}";
   }

[ ! -d ${BUILD_LOG_DIR} ] && mkdir -p ${BUILD_LOG_DIR}
[ ! -f ${BUILD_LOG} ] && touch ${BUILD_LOG}
tail -n 0 -F ${BUILD_LOG} &
TIMESTAMP=$(date +%s)
echo "Build Opts: ${OPTS}${IMAGE_NAME_OUT}" > ${BUILD_LOG}
printf "\n\nTAIL TIMESTAMP ${TIMESTAMP}\n\n" >> ${BUILD_LOG}
printf "\n\n*** BUILDING IMAGE ***\n\n" >> ${BUILD_LOG}
[ ! -z "${BUILD_COMMAND}" ] && { eval ${BUILD_COMMAND} 2>${BUILD_LOG} 1>&2; } || { echo "No build command found" >> ${BUILD_LOG}; }
RESULT=$?
if [[ ${RESULT} -eq 0 && "${IMAGE_UPLOAD}" == "true" && "${CROSS_BUILD}" != "true" && "${#BUILD_TAGS[@]}" -gt 0 ]]; then
    # Push all of our tagged images to the registry
    for buildtag in "${BUILD_TAGS[@]}"; do
        printf "\n\n*** PUSHING IMAGE \"${buildtag}\" ***\n\n" >> ${BUILD_LOG}
        docker push ${buildtag} >> ${BUILD_LOG}
    done
elif [ ${RESULT} -gt 0 ]; then
    printf "\n\n*** Build FAILED ***\n\n"
else
    printf "\n\n*** Build COMPLETE ***\n\n"
fi
killall tail &>/dev/null
sleep 1
[ "${KEEP_BUILD_LOG}" == "true" ] && { mv ${BUILD_LOG} ${BUILD_LOG_DIR}/build_${TIMESTAMP}.txt; } || { echo "** Set 'KEEP_BUILD_LOG' to 'true' for build logs **"; rm -rf $BUILD_LOG; }