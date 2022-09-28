#!/usr/bin/env bash
#=============================================================================================================
# HEADER
#=============================================================================================================

#% SYNOPSIS
#+   ${SCRIPT_NAME} -s dbPassword -u <dbUsername> -e <sdkVersion> [-d <logsDir] [-l <logFile>] [-o <dbHost>]
#+     [-n <dbName>] [-p dbPort] [-r sourceDir>] [-t <targetDir>] [-chiqv] ACTION
#%
#% DESCRIPTION
#%   Processes a folder with Asciidoc files and Freemarker templates using Metadata Converter and a database.
#%   The Medatata Converter executable is downloaded as a Maven dependency.
#%   The output is a folder with:
#%     - The ".adoc" files kept intact
#%     - ".adoc" files generated from Freemarker the templates ("*.ftl") and populated
#%       with information from the database.
#%
#% OPTIONS
#=============================================================================================================
#%   ACTION     The action to perform. Accepted values:
#%              - process_templates: Processes the source folder and generates Asciidoc with values from database.
#%              - preview: Generates a local documentation site using Antora and starts a live preview server.
#%   -c         Enables usage of colours in logging.
#%   -d DIR     Define the directory for logs (default: "logs"). Ignored if option -l is used.
#%   -e STRING  Target eForms SDK version.
#%   -h         Print this help.
#%   -i         Print script information
#%   -l FILE    Log messages to FILE. If not set, a time-based log is used.
#%   -n STRING  Database name.
#%              Default value: tedcvsrepo
#%   -o STRING  Database host.
#%              Default value: localhost
#%   -p INTEGER Database port.
#%              Default value: 3306
#%   -q         Don't print messages to standard output.
#%   -r DIR     Source directory for documentation.
#%              Default: ${SCRIPT_DIR}/../content
#%   -s         Database password.
#%   -t DIR     Target directory for generated documentation.
#%              Default: ${SCRIPT_DIR}/../build/asciidoc
#%   -u STRING  Database username
#%   -v         Be verbose.
#%
#% EXAMPLES
#%  - Process using defaults: ${SCRIPT_NAME} -u myuser -s mypassword
#%  - Process using database "dramempe.cc.cec.eu.int:3306":
#%    ${SCRIPT_NAME} -o dramempe.cc.cec.eu.int -p 3306 -u myuser -s mypassword
#%  - Process specifying input and output folder:
#%    ${SCRIPT_NAME} -o dramempe.cc.cec.eu.int -p 3306 -u myuser -s mypassword -r source_dir -t build
#%
#=============================================================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 1.0.0
#-
#=============================================================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#=============================================================================================================
# END_OF_HEADER
#=============================================================================================================

#============
# VARIABLES #
#============

# Exit codes
#-----------
readonly BUILD_ERROR=5
readonly RUNTIME_ERROR=6

# Global variables
#------------------
readonly SCRIPT_DIR="$(dirname "$(readlink -f "${0}")")"

readonly PROJECT_DIR="${SCRIPT_DIR}/.."
readonly PREVIEW_DIR="${PROJECT_DIR}/build/preview"
readonly PREVIEW_SITE_DIR="${PREVIEW_DIR}/site"

SESSION_ID=$(date +%s)

# Configuration variables
#------------------------
readonly script_opts="cd:e:hil:o:n:p:r:s:qt:u:v"

# Option variables
#-----------------
LOGS_DIR="logs"

ACTION=""
DB_HOST=localhost
DB_PORT=3306
DB_NAME=tedcvsrepo
DB_USERNAME=""
DB_PASSWORD=""
EFORMS_VERSION=""
SOURCE_DIR="${SCRIPT_DIR}/../content"
TARGET_DIR="${SCRIPT_DIR}/../build/asciidoc"

# Miscellaneous variables
#------------------------

#==============#
# SOURCE FILES #
#==============#
. "${SCRIPT_DIR}/generic_functions.sh"

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
            e) EFORMS_VERSION=${OPTARG} ;;
            h) usagefull; exit 0 ;;
            i) scriptinfo; exit 0 ;;
            l) LOG_FILE=${OPTARG} ;;
            n) DB_NAME=${OPTARG:-${DB_NAME}} ;;
            o) DB_HOST=${OPTARG:-${DB_HOST}} ;;
            p) DB_PORT=${OPTARG:-${DB_PORT}} ;;
            r) SOURCE_DIR=${OPTARG:-${SOURCE_DIR}} ;;
            s) DB_PASSWORD=${OPTARG-${DB_PASSWORD}} ;;
            t) TARGET_DIR=${OPTARG:-${TARGET_DIR}} ;;
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
        "process_templates"|"preview") ;;
        *) die "${INVALID_ARGS}" "Unknown action [${ACTION}]. Accepted values: [process_templates, preview]." ;;
    esac

    [ -z "${TARGET_DIR}" ] && die "${INVALID_ARGS}" "Undefined target directory."

    # Set defaults for undefined properties
    export BASE_DIR="${SCRIPT_DIR}" # Used by mvnw

    # Set derived properties
    SOURCE_DIR="$(readlink -m "${SOURCE_DIR}")"
    TARGET_DIR="$(readlink -m "${TARGET_DIR}")"
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

# Process folder with Asciidoc files and Freemarker templates.
process_templates() {
    set_step templates-process

    info "Processing folder [${SOURCE_DIR}]. Output folder: [${TARGET_DIR}]"

    [ ! -d "${SOURCE_DIR}" ] && die "${INVALID_ARGS}" "Source directory [${SOURCE_DIR}] not found."
    [ -z "${DB_HOST}" ] && die "${INVALID_ARGS}" "Undefined database host."
    [ -z "${DB_NAME}" ] && die "${INVALID_ARGS}" "Undefined database name."
    [ -z "${DB_PORT}" ] && die "${INVALID_ARGS}" "Undefined database port."
    [ -z "${DB_USERNAME}" ] && die "${INVALID_ARGS}" "Undefined database username."
    [ -z "${DB_PASSWORD}" ] && die "${INVALID_ARGS}" "Undefined database password."
    [ -z "${EFORMS_VERSION}" ] && die "${INVALID_ARGS}" "Undefined eForms SDK version."

    local _cmd="${SCRIPT_DIR}/mvnw exec:exec@run-processor \
        -f ${SCRIPT_DIR} \
        -Dasciidoc.templates.dir=${SOURCE_DIR} \
        -Dasciidoc.target.dir=${TARGET_DIR} \
        -Ddb.host=${DB_HOST} -Ddb.port=${DB_PORT} -Ddb.name=${DB_NAME} -Ddb.username=${DB_USERNAME} -Ddb.password=${DB_PASSWORD}"

    debug "Command: used: $(hide_password "${_cmd}")"

    ${_cmd}

    _rc=${?}
    [ "${_rc}" != "0" ] && die "${RUNTIME_ERROR}" "Failed to process templates"

    info "Setting eForms SDK version to ${EFORMS_VERSION}."
    cat "${SOURCE_DIR}/antora.yml"|sed "s|@EFORMS_VERSION@|${EFORMS_VERSION}|g" > "${TARGET_DIR}/antora.yml"

    unset_step
}

# Generates a documentation site from the target folder.
generate_site() {
    set_step site-generate

    info "Generating documentation from [${TARGET_DIR}]"

    debug "Copying Antora resources and scripts to [${PREVIEW_DIR}]"
    mkdir -p "${PREVIEW_DIR}/content"

    cp -pR "${SCRIPT_DIR}/antora/"* "${PREVIEW_DIR}"
    cp -pR "${TARGET_DIR}/"* "${PREVIEW_DIR}/content"
    git -C "${PREVIEW_DIR}" init
    cat <<EOM > "${PREVIEW_DIR}/.gitignore"
    node_modules
    site
EOM
    git -C "${PREVIEW_DIR}" add --all
    git -C "${PREVIEW_DIR}" commit -q -m 'Updated content'

    pushd "${PREVIEW_DIR}" 1>/dev/null || return

    npm install

    SITE_DIR="${PREVIEW_SITE_DIR}" npm run build

    info "Successfully generated documentation site under [${PREVIEW_SITE_DIR}]"

    popd 1>/dev/null || return

    unset_step
}

# Starts a HTTP server serving the generated documentation site.
live_preview() {
    set_step site-preview

    info "Starting HTTP server to preview the generated documentation site."

    pushd "${PREVIEW_DIR}" 1>/dev/null || return
    LIVERELOAD=true TEMPLATES_SOURCE_DIR="${TARGET_DIR}" SITE_DIR="${PREVIEW_SITE_DIR}" npm run live-preview
    popd 1>/dev/null || return

    unset_step
}

# Main workflow
main() {
    header "EFORMS TEMPLATES PROCESSOR"

    case ${ACTION} in
        process_templates) process_templates ;;
        preview)
            generate_site
            live_preview
            ;;
    esac

    success "Successfully executed script."
}

trap cleanup EXIT

trap 'on_exit' EXIT

init "$@"

main
