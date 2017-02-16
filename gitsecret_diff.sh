#!/usr/bin/env bash

die() { echo "$@" 1>&2 ; exit 1; }

PASSWORD=""
SHA1=""
SHA2=""
WORKING_DIR=""

function usage()
{
    echo "gitsecret_diff gitSha1 \n"\
         "  -s | --sha2 <second commit sha to compare> \n"\
         "  -p | --password <git secret password> \n"\
         "  -w | --working-dir <the working dir to run>\n"\
         "  -h | --help"
}

function reveal()
{
    if [[ -z ${PASSWORD} ]]; then
        git secret reveal
    else
        git secret reveal -p ${PASSWORD}
    fi
}

function compare_with_sha()
{
    git checkout $1

    if [[ -z ${PASSWORD} ]]; then
        git secret changes
    else
        git secret changes -p ${PASSWORD}
    fi
}

function compare_with_local()
{
    echo "Compare $SHA1 with local"
    compare_with_sha ${SHA1}
}

function compare_with_other()
{
    echo "comparing revision $SHA1 with $SHA2"

    git checkout ${SHA1}
    reveal

    compare_with_sha ${SHA2}
}

# Parse arguments
TEMP=$(getopt -n "$0" --options p:s:w:h --longoptions sha2:,password:,working-dir:,help -- $@)
# Die if they fat finger arguments, this program will be run as root
[ $? = 0 ] || die "Error parsing arguments. gitsecret_diff --help"

eval set -- "${TEMP}"
while true; do
    case $1 in
        -h|--help)
            usage
            exit 0
        ;;
        -p|--password)
            PASSWORD=$2; shift 2
        ;;
        -s|--sha2)
            SHA2=$2; shift 2
        ;;
        -w|--working-dir)
            WORKING_DIR=$2; shift 2
        ;;
        --)
            # no more arguments to parse
            break
        ;;
        *)
            printf "Unknown option %s\n" "$1"
            usage
            exit 1
        ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
        ;;
    esac
done

SHA1=$2;shift

# check for empty args
if [[ $@ = '' ]]; then
    echo "Please provide the sha to compare to!"
    usage
    exit 1
fi

eval set -- "$@"

if [[ ! -z ${WORKING_DIR} ]]; then
    pushd ${WORKING_DIR}
fi

ACTUAL_SHA=`git rev-parse HEAD`
MODIFIED_FILES=`git ls-files -m`
if [[ ! -z ${MODIFIED_FILES} ]]; then
    echo "The following files are modified:\n$MODIFIED_FILES\n\nPlease stash them or clean it in order to safely run this script."
    exit 1
fi

if [[ -z ${SHA2} ]]; then
        compare_with_local
    else
        compare_with_other
fi

# Restore state
git checkout ${ACTUAL_SHA}
reveal
if [[ ! -z ${WORKING_DIR} ]]; then
    popd
fi
