#!/usr/bin/env bash
#========================================================================================================
# HEADER
#========================================================================================================
#% DESCRIPTION
#%   Library of functions for logging, documentation and signals handling.
#========================================================================================================
# END_OF_HEADER
#========================================================================================================

# ==========#
# VARIABLES #
# ==========#

# Exit codes
#-----------
readonly GENERIC_ERROR=1
readonly INVALID_ARGS=4

# Script information variables
#-----------------------------
SCRIPT_NAME="$(basename "${0}")" # scriptname without path

# Logging defaults
#-----------------
LOG_FILE=${LOG_FILE:-}
QUIET=false
USE_COLOURS=false
VERBOSE=false

# Variables used by documentation
#--------------------------------
readonly SCRIPT_HEADSIZE=$(head -200 "${0}" |grep -n "^# END_OF_HEADER" | cut -f1 -d:)

# Variable to store arguments
#----------------------------
readonly args=("$@")

# Miscellaneous variables
#------------------------
TMP_DIR=
TIME_START=$(date +%s)

#=====================#
# DATE/TIME FUNCTIONS #
#=====================#

# Returns current date.
get_date() { date +%Y%m%d; }

# Returns current time for logging.
get_log_time() { date '+%Y/%m/%d, %H:%M:%S'; }

# Returns current time for file naming.
get_file_time() { date '+%Y%m%d_%H%M%S'; }

show_execution_time() {
    local -r _time_end=$(date +%s)
    info "Execution time: $(( _time_end - TIME_START )) seconds."
}

#=========================#
# DOCUMENTATION FUNCTIONS #
#=========================#

# Prints brief usage information.
# It shows the commented lines that start with "%+".
usage() {
    local -r _usage_str=$(head -${SCRIPT_HEADSIZE:-99} "${0}" | sed -n "/^#+/ {s|^#+\s\{3\}||g;s|\${SCRIPT_NAME}|${SCRIPT_NAME}|g;p}")
    if [ -n "${_usage_str}" ]; then printf "Usage:\n\t%s\n\nTry '%s -h' for more options.\n\n" "${_usage_str}" "${SCRIPT_NAME}"; fi
}

# Prints full usage information.
usagefull() {
    head -${SCRIPT_HEADSIZE:-99} "${0}" | sed -n "/^#[%+-]/ {s|^#[%+-]||g;s|\${SCRIPT_NAME}|${SCRIPT_NAME}|g;p}"
}

# Prints information about the script.
scriptinfo() {
    head -${SCRIPT_HEADSIZE:-99} "${0}" | sed -n "/^#-/ {s|^#-||g;s|\${SCRIPT_NAME}|${SCRIPT_NAME}|g;p}"
}

#===================#
# LOGGING FUNCTIONS #
#===================#

# Sets the current step's ID.
# Arguments:
#  - step_id: The step's ID.
set_step() {
    local -r _step_id=${1}
    [ -n "${_step_id}" ] && STEP_ID=${_step_id}
}

# Unsets the current step's ID.
unset_step() {
    STEP_ID=
}

# Logs a message.
# Arguments:
#  - level: The logging level.
#  - message: The message to be logged.
_log() {
    local -r _level=${1}
    local -r _message="${2}"

    if [ -n "${_message}" ]; then
        local -r _timestamp=$(get_log_time)
        local -r _log_level=$(echo "${_level}"| tr '[:lower:]' '[:upper:]')
        local _log_message="${_log_level}"

        if [ -n "${SESSION_ID}" ]; then
            local _step_id=""
            [ -n "${STEP_ID}" ] && _step_id=": ${STEP_ID}"
            _log_message+="\t[${SESSION_ID}${_step_id}]"
        fi

        _log_message+="\t${_message}"

        # Print to log file
        echo -e "${_timestamp}\t${_log_message}" >> "${LOG_FILE:-/dev/null}"

        # Print also to console if not 'quiet'
        if [ "${QUIET}" != "true" ]; then
            if [ "${USE_COLOURS}" == "true" ]; then
                _log_message="$(get_log_colour "${_level}")${_timestamp}\t${_log_message}${STYLE_RESET}"
            else
                _log_message="${_timestamp}\t${_log_message}"
            fi

            echo -e "${_log_message}" 2>&1
        fi
    fi

    return 0
}

# Get the colour for a logging event, based on log level.
# Arguments:
#  - level: The logging level.
get_log_colour() {
    local -r _level=${1}

    case "${_level}" in
        "fatal")    echo "${STYLE_BOLD}${COLOUR_RED}" ;;
        "error")    echo "${COLOUR_RED}" ;;
        "info")     echo "${COLOUR_CYAN}" ;;
        "warn")     echo "${COLOUR_YELLOW}" ;;
        "success")  echo "${COLOUR_GREEN}" ;;
        "debug")    echo "${COLOUR_MAGENTA}" ;;
        "header")   echo "${COLOUR_BLUE}" ;;
        *)     echo "" ;;
    esac
}

# Logging functions, which set logging level
#-------------------------------------------
fatal ()    { _log "fatal" "${*}"; }
error ()    { _log "error" "${*}"; }
info ()     { _log "info" "${*}"; }
warn ()     { _log "warn" "${*}"; }
debug ()    { [ "${VERBOSE}" == "true" ] && _log "debug" "${*}"; }
success ()  { _log "success" "${*}"; }
header()    { _log "header" "========== ${*} ==========  "; }

# Initialize logging.
# NOTE: Variable USE_COLOURS will take effect only if logging is initialized with this function.
# Arguments:
#  - use_colours: Set value to "true" to use colours.
#  - log_file: The log file's full location.
init_logging() {
    USE_COLOURS=${1:-${USE_COLOURS}}
    set_log_file "${2}"

    if tty -s && [ "${USE_COLOURS}" == "true" ]; then
        # Colours and styles for logging messages.
        readonly COLOUR_BLUE=$(tput setaf 4)
        readonly COLOUR_CYAN=$(tput setaf 6)
        readonly COLOUR_GREEN=$(tput setaf 2)
        readonly COLOUR_MAGENTA=$(tput setaf 5)
        readonly COLOUR_RED=$(tput setaf 1)
        readonly COLOUR_YELLOW=$(tput setaf 3)
        readonly STYLE_BOLD=$(tput bold)
        readonly STYLE_RESET=$(tput sgr0)
        readonly STYLE_UNDERLINE=$(tput smul)
    fi
}

# Sets the log file's location and creates its parent directory, if it does not exist.
# Arguments:
#  - log_file: The log file's full location.
set_log_file() {
    LOG_FILE=${1:-${LOG_FILE}}

    if [ -n "${LOG_FILE}" ]; then
        LOG_FILE="$(readlink -m "${LOG_FILE}")"
        mkdir -p "$(dirname "${LOG_FILE}")"
    fi
}

#==================#
# STRING FUNCTIONS #
#==================#
# Check if an array contains a string.
# Arguments:
#  - str: The string to search for
#  - array: An array of string
array_contains() {
    local _str=$1
    shift
    local _array=("$@")

    local _match=false
    for item in "${_array[@]}"; do
        if [[ ${item} = "${_str}" ]]; then
            _match=true
            break
        fi
    done

    echo ${_match}
}

# Replaces "password=..." with asterisks.
hide_password() {
    local -r _message="${1}"

    echo "${_message}"|sed -r 's|(password=).*?(\s?\|$)|\1****|g'
}

#===================#
# UTILITY FUNCTIONS #
#===================#

# Exit script with  a relevant message.
# The first argument is the exit code (to be propagated).
die() {
    rc=${1}
    shift
    fatal "${*} Exiting now..."
    exit "${rc}"
}

# Executes a function and fails the script on error.
# Arguments:
#  - func: Name of the function to execute
#  - Any remaining arguments are passed to the function to be executed
exec_func() {
    local _func=${1}
    shift

    ${_func} "${@}"
    local _rc=${?}
    [ ${_rc} != 0 ] && die ${_rc} "Failed to execute function."
}

# Extracts variable keys from a file.
extract_vars() {
    [ -f "$1" ] && grep -oP '(?<!\\)\$\{.*?\}' "$1" |sed -r 's|\$\{(.*)\}|\1|g'|sort -u
}

#==========================================#
# TRAPS                                    #
# -----------------------------------------#
# Functions for handling of trap scenarios #
#==========================================#

# Handle failures (ERR).
failed() {
    die ${?} "SCRIPT FAILURE: See error at line $LINENO."
}

# Handle interruption signals.
interrupted() {
    die ${?} "${SCRIPT_NAME}: Interrupt signal intercepted!"
}

# Perform post-execution cleanup.
cleanup() {
    rc=${1:-${?}}
    [[ "${rc}" == "${INVALID_ARGS}" ]] && echo '' && usage

    set_step cleanup

    # Delete temp files, if any
    if [ -e "${TMP_DIR}" ]; then
        debug "Deleting temporary directory [${TMP_DIR}]"
        rm -rf "${TMP_DIR}"
    fi

    unset_step

    cd "$(dirs -p -l -0)" || return
    dirs -c
}

trap 'interrupted' INT TERM QUIT
trap 'failed' ERR
trap 'cleanup' EXIT

sourced=false

if [ -n "${ZSH_EVAL_CONTEXT}" ]; then 
    case ${ZSH_EVAL_CONTEXT} in *:file:*) sourced=true;; esac
elif [ -n "${KSH_VERSION}" ]; then
    if [ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- ${0})" != "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ]; then sourced=true; fi
elif [ -n "${BASH_VERSION}" ]; then
    (return 0 2>/dev/null) && sourced=true
else # All other shells: examine ${0} for known shell binary filenames
    # Detects `sh` and `dash`; add additional shell filenames as needed.
    case ${0##*/} in sh|dash) sourced=true;; esac
fi

if [ "${sourced}" != "true" ]; then echo "This script is meant to be sourced." && exit 1; fi
