#!/usr/bin/env bash

PASSWORD=""
SHA1=""
SHA2=""
WORKING_DIR=""
FILENAMES=""

function die()
{
    echo "$@" 1>&2
    usage
    exit 1
}

function usage()
{
    printf "gitsecret_diff [secret files to compare] \n\
           -a | --sha1 <first commit sha to compare> \n\
           -b | --sha2 <second commit sha to compare> \n\
           -p | --password <git secret password> \n\
           -w | --working-dir <the working dir to run>\n\
           -h | --help\n"
}

function reveal()
{
    if [[ -z "$PASSWORD" ]]; then
        git secret reveal
    else
        git secret reveal -p "$PASSWORD"
    fi
}

function compare()
{
    if [[ -z "$PASSWORD" ]]; then
        git secret changes "$FILENAMES"
    else
        git secret changes -p "$PASSWORD" "$FILENAMES"
    fi
}

function compare_with_local()
{
    compare
}

function compare_with_sha()
{
    git checkout "$1" > /dev/null 2>&1

    compare
}

function compare_sha_with_local()
{
    echo "Compare $SHA1 with local"
    compare_with_sha "$SHA1"
}

function compare_with_other()
{
    echo "comparing revision $SHA1 with $SHA2"

    git checkout "$SHA1" > /dev/null 2>&1
    reveal

    compare_with_sha "$SHA2"
}

function do_compare()
{
    if [[ -z "$SHA1" ]]; then
        compare_with_local
    elif [[ -z "$SHA2" ]]; then
        check_modified_files
        compare_sha_with_local
    else
        check_modified_files
        compare_with_other
    fi
}

function check_modified_files()
{
    MODIFIED_FILES=$(git ls-files -m)
    if [[ -n "$MODIFIED_FILES" ]]; then
        printf "The following files are modified:\n%s\n\nPlease stash them or clean it in order to safely run this script." "$MODIFIED_FILES"
        exit 1
    fi
}

get_initial_state()
{
    ACTUAL_SHA=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$ACTUAL_SHA" == "HEAD" ]]; then
        echo "on Head"
        ACTUAL_SHA=$(git rev-parse HEAD)
    fi

    if [[ -n "$WORKING_DIR" ]]; then
        pushd "$WORKING_DIR"
    fi
}

restore_state()
{
    # Restore state
    git checkout "$ACTUAL_SHA" > /dev/null 2>&1
    reveal > /dev/null 2>&1
    if [[ -n "$WORKING_DIR" ]]; then
        popd
    fi
}

check_arguments()
{
    # Parse arguments
    TEMP=$(getopt -n "$0" --options p:a:b:w:h --longoptions sha1:,sha2:,password:,working-dir:,help -- "$@")

    eval set -- "$TEMP"
    while true; do
        case $1 in
            -h|--help)
                usage
                exit 0
            ;;
            -p|--password)
                PASSWORD=$2; shift 2
            ;;
            -a|--sha1)
                SHA1=$2; shift 2
            ;;
            -b|--sha2)
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

    SHA1_INFO="commit"
    SHA2_INFO="commit"

    if [[ -n "$SHA1" ]]; then
        SHA1_INFO=$(git cat-file -t "$SHA1" 2>&1)
    fi

    if [[ -n "$SHA2" ]]; then
        SHA2_INFO=$(git cat-file -t "$SHA2" 2>&1)
    fi

    if [[ "$SHA1_INFO" != "commit" || "$SHA2_INFO" != "commit" ]]; then
        die "Check that commits SHAs are valid."
    fi

    shift $((OPTIND-1))
    [ "$1" = '--' ] && shift

    FILENAMES=( $@ );shift

    eval set -- "$@"
}

check_arguments "$@"
get_initial_state
do_compare
restore_state
