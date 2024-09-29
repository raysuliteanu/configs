#!/bin/bash
LN=ln
MD=mkdir
TARGET_DIR=${HOME}
ALWAYS_CONT=0
DEBUG=0

print_error() {
    echo "Error: $@" >&2
}

run_cmd() {
    local tmp_file=$(mktemp)
    "$@" | tee $tmp_file 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        print_error $(cat $tmp_file)

        if [[ "${ALWAYS_CONT}" == "1" ]]; then
            return 0
        fi

        read -p "Do you want to continue? (y/n): " answer
        case "$answer" in
        [yY])
            return 0
            ;;
        *)
            rm $tmp_file
            exit $status
            ;;
        esac
    fi
    rm -f $tmp_file
}

while getopts "cdt:" opt; do
    case ${opt} in
    c)
        ALWAYS_CONT=1
        ;;
    d)
        DEBUG=1
        ;;
    t)
        TARGET_DIR=${OPTARG}
        ;;
    [h?])
        echo "Usage: $0 [-c] [-d] [-?|-h]"
        echo "  -c: always continue on ln error (don't prompt)"
        echo "  -d: debug mode; don't actually execute anything"
        echo "  -h|-?: print usage"
        exit 0
        ;;
    *)
        echo "Invalid option: -$OPTARG" 1>&2 && exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# no-op the linking if executed with -x option or -d
if [ "$-" = "x" ] || [ "${DEBUG}" = "1" ]; then
    LN="echo DEBUG: ln"
    MD="echo DEBUG: mkdir"
    echo "ALWAYS_CONT=1"
    echo "DEBUG=1"
    echo "LN='${LN}'"
    echo "MD='${MD}'"
    echo "TARGET_DIR='${TARGET_DIR}'"
fi

if [ ! -d ${TARGET_DIR} ]; then
    echo "creating ${TARGET_DIR}"
    ${MD} -p ${TARGET_DIR} || exit 1
fi

# Gets the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
BIN_DIR=${SCRIPT_DIR}/bin
DEST_BIN_DIR=${TARGET_DIR}/bin

if [ ! -d ${DEST_BIN_DIR} ]; then
    echo "creating ${DEST_BIN_DIR}"
    ${MD} -p ${DEST_BIN_DIR} || exit 1
fi

for path in $(find ${BIN_DIR} -type f -name '*.sh'); do
    filename="$(basename ${path%.*})"
    echo "linking ${path} to ${DEST_BIN_DIR}/${filename}"
    run_cmd ${LN} -s ${path} ${DEST_BIN_DIR}/${filename}
done
