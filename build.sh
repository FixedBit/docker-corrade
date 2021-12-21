#!/usr/bin/env bash
# Custom docker build shell script that should be adaptable for about anything you could want
# Author: Jason Hawks
# Contact: jason *at* fixedbit.com

# Pull in our environment variables
set -e

# Your registry url, leave blank if local
DOCKER_REGISTRY=fixedbit
# Name of the image we are building
IMAGE_NAME=corrade
# Should we upload this to the registry?
IMAGE_UPLOAD=false
# Do you want to keep a copy of the build log?
KEEP_BUILD_LOG=false
# Set the name of your source file, leave blank if none
SOURCE_FILE=$PWD/_source.sh

# I suggest do not touch these unless you know what you are doing!
# Set the build log and build file directory
BUILD_LOG_DIR=$PWD/build_logs
BUILD_LOG=$BUILD_LOG_DIR/build.txt
# Set our script name for use below
SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# Set our default Dockerfile location, this variable is overwritten if you do -f path/Dockerfile
DOCKER_FILE_LOCATION='.'

# You need help with this?
show_help()
{
    echo "** ${SCRIPT_NAME} HELP **"
    echo "* Any of these flags may be combined"
    echo "* '${SCRIPT_NAME} -n' sets no cache so it always pulls latest containers"
    echo "* '${SCRIPT_NAME} -p' force pulls latest of every Docker image"
    echo "* '${SCRIPT_NAME} -s source.sh' sets a script to source variables from"
    echo "* '${SCRIPT_NAME} -i name-of-image' overwrites the pre-set image name used for building"
    echo "* '${SCRIPT_NAME} -f Dockerfile' OPTIONAL - allows you to point this script to a different Dockerfile"
}

# check if we got a help flag of some type
[ ! -z "$1" ] && [ "$1" == "-h" ] && show_help && exit 1

# Set our arguments passed into an array and iterate over them
argArr=( "$@" )
for ((i=0;i < ${#argArr[@]};i++)) {
    # Get our current argument and the next for setting variables
    CURRENT=${argArr[i]}
    NEXT=${argArr[$((i + 1))]}
    # We go through each of the arguments passed and set as neccessary
    # Check 'docker-build.sh -h' for help on what each does
    if [ "${CURRENT}" == "-n" ]; then
      OPTS="--no-cache ${OPTS}"
    elif [ "${CURRENT}" == "-p" ]; then
      OPTS="--pull ${OPTS}"
    elif [ "${CURRENT}" == "-f" ]; then
      [[ $NEXT != -* ]] && [[ ! -z $NEXT ]] && DOCKER_FILE_LOCATION="-f ${NEXT} ." && i=$((i + 1)) || ERRORS+=("Invalid Dockerfile path passed to -f")
    elif [ "${CURRENT}" == "-i" ]; then
      [[ $NEXT != -* ]] && [[ ! -z $NEXT ]] && IMAGE_NAME_OUT="-t ${NEXT}" && i=$((i + 1)) || ERRORS+=("Invalid image name passed to -i")
    elif [ "${CURRENT}" == "-s" ]; then
      [[ $NEXT != -* ]] && [[ $NEXT == *.sh ]] && SOURCE_FILE="${NEXT}" && i=$((i + 1)) || ERRORS+=("Invalid shell script passed to -s")
    else
      ERRORS+=("${CURRENT} is not a valid argument for ${SCRIPT_NAME}")
    fi
}

# If DOCKER_REGISTRY IS blank, IMAGE_NAME_OUT NOT blank and IMAGE_NAME NOT blank
if [ -z "${DOCKER_REGISTRY}" ] && [ -z "${IMAGE_NAME_OUT}" ] && [ ! -z "${IMAGE_NAME}" ]; then
    IMAGE_NAME_OUT="-t ${IMAGE_NAME}"
# Else if IMAGE_NAME_OUT IS blank, IMAGE_NAME NOT blank and DOCKER_REGISTRY NOT blank
elif [ -z "${IMAGE_NAME_OUT}" ] && [ ! -z "${IMAGE_NAME}" ] && [ ! -z "${DOCKER_REGISTRY}" ]; then
    IMAGE_NAME_OUT="-t ${DOCKER_REGISTRY}/${IMAGE_NAME}"
# Check one final time to make sure they are set
elif [ -z "${IMAGE_NAME_OUT}" ] && [ -z "${IMAGE_NAME}" ]; then
    ERRORS+=("You must pass an image name in with '-i' or set 'IMAGE_NAME' in ${SCRIPT_NAME}")
fi


# If we have any errors then display them
if [ ${#ERRORS[@]} -gt 0 ]; then
    # Display errors
    echo "** THE FOLLOWING ERRORS WERE RETURNED **"
    for error in "${ERRORS[@]}"
    do
        echo $error
    done
    # Exit script
    exit 1
fi

# Check if we have a source file set and it exists
if [ ! -v "${SOURCE_FILE}" ] && [ -f "${SOURCE_FILE}" ]; then
    echo "Sourcing '${SOURCE_FILE}'"
    . "${SOURCE_FILE}"
fi

[ ! -d $BUILD_LOG_DIR ] && mkdir -p $BUILD_LOG_DIR
[ ! -f $BUILD_LOG ] && touch $BUILD_LOG
tail -n 0 -F $BUILD_LOG &
TIMESTAMP=$(date +%s)
echo "Build Opts: ${OPTS}${IMAGE_NAME_OUT}" > $BUILD_LOG
printf "\n\nTAIL TIMESTAMP ${TIMESTAMP}\n\n" >> $BUILD_LOG
printf "\n\n*** BUILDING IMAGE ***\n\n" >> $BUILD_LOG
docker build ${OPTS}${IMAGE_NAME_OUT} ${DOCKER_FILE_LOCATION} >> $BUILD_LOG
RESULT=$?
if [ $RESULT -eq 0 ] && [ "${IMAGE_UPLOAD}" == "true" ] && [ ! -z "${DOCKER_REGISTRY}" ]; then
  printf "\n\n*** PUSHING IMAGE ***\n\n" >> $BUILD_LOG
  docker push ${DOCKER_REGISTRY}/${IMAGE_NAME} >> $BUILD_LOG
elif [ $RESULT -gt 0 ]; then
    printf "\n\n*** Build FAILED ***\n\n"
else
    printf "\n\n*** Build COMPLETE - NOT PUSHING ***\n\n"
fi
killall tail &>/dev/null
sleep 1
[ "${KEEP_BUILD_LOG}" == "true" ] && mv $BUILD_LOG $BUILD_LOG_DIR/build_$TIMESTAMP.txt || echo "** Set 'KEEP_BUILD_LOG' to 'true' for build logs **" && rm -rf $BUILD_LOG