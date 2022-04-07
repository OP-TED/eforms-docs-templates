#!/usr/bin/env bash
#============================================================================================================
# HEADER
#============================================================================================================

#% SYNOPSIS
#+   ${SCRIPT_NAME} -r <sqlDir> [-d <logsDir] [-l <logFile>] [-n <dbName>] [-p dbPort] [-s <dbPassword>]
#+     [-u <dbUsername>] [-chiqv] ACTION
#%
#% DESCRIPTION
#%   Starts/Stops a local MySQL Docker container, populated using provided SQL scripts.
#%
#% OPTIONS
#============================================================================================================
#%   ACTION     The action to perform. Accepted values: restart, start, stop
#%   -c         Enables usage of colours in logging.
#%   -d DIR     Define the directory for logs (default: "logs"). Ignored if option -l is used.
#%   -h         Print this help.
#%   -i         Print script information
#%   -l FILE    Log messages to FILE. If not set, a time-based log is used.
#%   -n STRING  Database name.
#%              Default value: tedcvsrepo
#%   -p INTEGER Database port.
#%              Default value: 3306
#%   -q         Don't print messages to standard output.
#%   -r DIR     Location of SQL scripts.
#%              They will be executed during database initialization in alphabetical order.
#%   -s STRING  Database password.
#%   -u STRING  Database username.
#%              Default: tedefo
#%   -v         Be verbose.
#%
#% EXAMPLES
#%  - Start the database using defaults: ${SCRIPT_NAME} start
#%  - Stop the database using: ${SCRIPT_NAME} start
#%  - Start the database listening on port 6000 with username=tester and password=tester:
#%    ${SCRIPT_NAME} -p 6000 -u tester -s tester start
#%
#============================================================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 1.0.0
#-
#============================================================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#============================================================================================================
# END_OF_HEADER
#============================================================================================================

#============
# VARIABLES #
#============

# Exit codes
#-----------
readonly BUILD_ERROR=5
readonly RUNTIME_ERROR=6

# Global variables
#------------------
readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")

readonly DOCKER_COMPOSE_FILE="${SCRIPT_DIR}/docker/compose.yml"

SESSION_ID=$(date +%s)

# Configuration variables
#------------------------
readonly script_opts="cd:hil:n:p:qr:s:u:v"

# Option variables
#-----------------
ACTION=""
LOGS_DIR="logs"
SQL_DIR=""

DB_PORT=3306
DB_NAME=tedcvsrepo
DB_USERNAME="tedefo"
DB_PASSWORD="tedefo"

# Miscellaneous variables
#------------------------
DB_HOST=localhost
MYSQL_CONF_DIR="${SCRIPT_DIR}/provisioning/mysql/conf"

#==============#
# SOURCE FILES #
#==============#
. "${SCRIPT_DIR}/generic_functions.sh"
. "${SCRIPT_DIR}/docker/.env"

#===========#
# FUNCTIONS #
#===========#

# Script initialization and cleanup functions
# -------------------------------------------

# Loads arguments.
load_args() {
    # Read the options and set variables 
    while getopts "${script_opts}" o; do
        case "$o" in
            c) USE_COLOURS=true ;;
            d) LOGS_DIR=${OPTARG} ;;
            h) usagefull; exit 0 ;;
            i) scriptinfo; exit 0 ;;
            l) LOG_FILE=${OPTARG} ;;
            n) DB_NAME=${OPTARG:-${DB_NAME}} ;;
            p) DB_PORT=${OPTARG:-${DB_PORT}} ;;
            r) SQL_DIR=${OPTARG:-${SQL_DIR}} ;;
            s) DB_PASSWORD=${OPTARG-${DB_PASSWORD}} ;;
            q) QUIET=true ;;
            u) DB_USERNAME=${OPTARG-${DB_USERNAME}} ;;
            v) VERBOSE=true ;;
            \?) die "${INVALID_ARGS}" "Invalid option: [-${OPTARG}]." ;;
            :) die "${INVALID_ARGS}" "Option [-${OPTARG}] requires an argument." ;;
        esac
    done

    shift $((OPTIND-1))

    ACTION="${1}"
}

# Loads configuration properties, performs sanity checks and initializes variables.
load_verify_props() {
    # Check input arguments
    case ${ACTION} in
        "restart"|"start"|"stop") ;;
        *) die "${INVALID_ARGS}" "Unknown action [${ACTION}]." ;;
    esac

    [ -z "${DB_NAME}" ] && die "${INVALID_ARGS}" "Undefined database name."
    [ -z "${DB_PORT}" ] && die "${INVALID_ARGS}" "Undefined database port."
    [ -z "${DB_USERNAME}" ] && die "${INVALID_ARGS}" "Undefined database username."
    [ -z "${DB_PASSWORD}" ] && die "${INVALID_ARGS}" "Undefined database password."
    [ ! -d "${SQL_DIR}" ] && die "${INVALID_ARGS}" "SQL Directory [${SQL_DIR}] not found."

    # Set defaults for undefined properties

    # Set derived properties
    SQL_DIR="$(readlink -f "${SQL_DIR}")"
}

# Tasks to execute when script exits.
on_exit() {
    rc=${?}
    cleanup ${rc}

    show_execution_time
}

# Script initialization.
init() {
    set_step init-load_args
    load_args "$@"
    unset_step

    set_step init-dirs
    mkdir -p "${LOGS_DIR}"
    unset_step

    set_step init-logging
    init_logging ${USE_COLOURS} "${LOG_FILE:-${LOGS_DIR}/$(date +%Y%m%d)_${SCRIPT_NAME}.log}"
    unset_step

    set_step init-load_verify_props
    load_verify_props
    unset_step
}

# Tasks and utilities
# -------------------

# Starts a database container
start_db() {
    set_step db-start

    info "Starting database container using SQL scripts at ${SQL_DIR}."
    DB_PORT=${DB_PORT} DB_NAME=${DB_NAME} DB_USERNAME=${DB_USERNAME} DB_PASSWORD=${DB_PASSWORD} \
    SQL_DIR="${SQL_DIR}" MYSQL_CONF_DIR="${MYSQL_CONF_DIR}" \
    sg docker "docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} up -d" || die ${RUNTIME_ERROR} "Failed to start database container."

    cat<<EOM
A database has been successfully started and can be accessed using the following:
  - url: ${DB_HOST}:${DB_PORT}
  - username: ${DB_USERNAME}
  - password: ${DB_PASSWORD}
EOM

    unset_step
}

# Stop the running database container
stop_db() {
    set_step db-stop

    info "Stopping database container."
    sg docker "docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} down" || die ${RUNTIME_ERROR} "Failed to stop database container."

    unset_step
}

# Main workflow
main() {
    header "EFORMS ASCIIDOC PROCESSOR"

    case ${ACTION} in
        restart) stop_db && start_db ;;
        start) start_db ;;
        stop) stop_db ;;
    esac

    success "Successfully executed script."
}

trap cleanup EXIT

trap 'on_exit' EXIT

init "$@"

main
