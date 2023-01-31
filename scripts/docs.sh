#!/usr/bin/env bash
#=============================================================================================================
# HEADER
#=============================================================================================================

#% SYNOPSIS
#+   ${SCRIPT_NAME} -s <dbPassword> -u <dbUsername> -e <sdkVersion> [-d <logsDir] [-l <logFile>] [-o <dbHost>]
#+     [-n <dbName>] [-p <dbPort>] [-r sourceDir>] [-t <targetDir>] [-chiqv] ACTION
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
#%              - generate_site: Generates a local documentation site using Antora.
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
#%  - Generate Asciidoc using defaults: ${SCRIPT_NAME} -u myuser -s mypassword -e 1.1.0 process_templates
#%  - Generate Asciidoc using database "dramempe.cc.cec.eu.int:3306":
#%    ${SCRIPT_NAME} -o dramempe.cc.cec.eu.int -p 3306 -u myuser -s mypassword -e 1.1.0 process_templates
#%  - Generate Asciidoc specifying input and output folder:
#%    ${SCRIPT_NAME} -o dramempe.cc.cec.eu.int -p 3306 -u myuser -s mypassword -e 1.1.0 -r source_dir -t build process_templates
#%  - Generate local documentation site using defaults:
#%    ${SCRIPT_NAME} -u myuser -s mypassword -e 1.1.0 generate_site
#%  - Generate local documentation site with a live preview using defaults:
#%    ${SCRIPT_NAME} -u myuser -s mypassword -e 1.1.0 preview
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
readonly NODE_DIR="${PREVIEW_DIR}/.node"

SESSION_ID=$(date +%s)

# Configuration variables
#------------------------
readonly script_opts="cd:e:hil:o:n:p:r:s:qt:u:v"

# Option variables
#-----------------
USE_MVNW=${USE_MVNW:-true}

LOGS_DIR="logs"

ACTION=""
DB_HOST=localhost
DB_PORT=3306
DB_NAME=tedcvsrepo
DB_USERNAME=""
DB_PASSWORD=""
EFORMS_VERSION=""
EFORMS_VERSION_MAJOR=""
EFORMS_VERSION_MINOR=""
EFORMS_VERSION_PATCH=""

SOURCE_DIR="${SCRIPT_DIR}/../content"
TARGET_DIR="${SCRIPT_DIR}/../build/asciidoc"

# Miscellaneous variables
#------------------------

MVN_EXEC="${SCRIPT_DIR}/mvnw"

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
        "generate_site"|"process_templates"|"preview") ;;
        *) die "${INVALID_ARGS}" "Unknown action [${ACTION}]. Accepted values: [generate_site, process_templates, preview]." ;;
    esac

    [ -z "${TARGET_DIR}" ] && die "${INVALID_ARGS}" "Undefined target directory."
    validate_version "${EFORMS_VERSION}"

    IFS='.' read -ra _version_parts <<< "${EFORMS_VERSION}"
    EFORMS_VERSION_MAJOR=${_version_parts[0]}
    EFORMS_VERSION_MINOR=${_version_parts[1]:-0}
    EFORMS_VERSION_PATCH=${_version_parts[2]:-0}

    # Set defaults for undefined properties
    export BASE_DIR="${SCRIPT_DIR}" # Used by mvnw

    [ "${USE_MVNW}" == "false" ] && [ -n "$(command -v mvn)" ] && MVN_EXEC=mvn

    # Set derived properties
    SOURCE_DIR="$(readlink -m "${SOURCE_DIR}")"
    TARGET_DIR="$(readlink -m "${TARGET_DIR}")"
}

# Validates a version string.
# A valid version follows the format <major>.<minor>.<patch>, where "major" and "minor" are numbers and "patch" an alphanumeric sequence.
validate_version() {
  local _version="${1}"

  [ -z "${_version}" ] && die "${INVALID_ARGS}" "Undefined version string."
  local _regexp='^([0-9]+)(\.[0-9]+)?(\.[a-zA-Z0-9_-]+)?$'

  [[ ! ${_version} =~ ${_regexp} ]] && die "${INVALID_ARGS}" "[${_version}] is not a valid version. It should follow the format <major>.<minor>.<patch>"
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

    local _cmd="${MVN_EXEC} exec:exec@run-processor \
        -f ${SCRIPT_DIR} \
        -Dasciidoc.templates.dir=${SOURCE_DIR} \
        -Dasciidoc.target.dir=${TARGET_DIR} \
        -Ddb.host=${DB_HOST} -Ddb.port=${DB_PORT} -Ddb.name=${DB_NAME} -Ddb.username=${DB_USERNAME} -Ddb.password=${DB_PASSWORD} \
        -DskipTests"

    debug "Command: used: $(hide_password "${_cmd}")"

    ${_cmd}

    _rc=${?}
    [ "${_rc}" != "0" ] && die "${RUNTIME_ERROR}" "Failed to process templates"

    info "Setting eForms SDK version to ${EFORMS_VERSION}."
    cat "${SOURCE_DIR}/antora.yml"|sed "s|@EFORMS_VERSION_MAJOR@|${EFORMS_VERSION_MAJOR}|g;s|@EFORMS_VERSION_MINOR@|${EFORMS_VERSION_MINOR}|g;s|@EFORMS_VERSION_PATCH@|${EFORMS_VERSION_PATCH}|g" > "${TARGET_DIR}/antora.yml"

    unset_step
}

# Installs Yarn and package dependencies
install_yarn() {
    set_step yarn-install

    info "Installing Yarn"

    pushd "${PREVIEW_DIR}" 1>/dev/null || return

    # Install corepack
    npm install --prefix "${NODE_DIR}" corepack

    # Enable corepack
    "${NODE_DIR}/node_modules/.bin/corepack" enable --install-directory .node

    # Install dependencies
    "${NODE_DIR}/yarn" install --immutable

    info "Successfully installed Yarn"

    popd 1>/dev/null || return

    unset_step
}

# Generates a documentation site from the target folder.
generate_site() {
    set_step site-generate

    info "Generating documentation from [${TARGET_DIR}]"

    debug "Copying Antora resources and scripts to [${PREVIEW_DIR}]"
    mkdir -p "${PREVIEW_DIR}/content"

    cp -pR "${SCRIPT_DIR}/antora/"{*,.*} "${PREVIEW_DIR}"
    cp -pR "${TARGET_DIR}/"* "${PREVIEW_DIR}/content"
    git -C "${PREVIEW_DIR}" init
    cat <<EOM > "${PREVIEW_DIR}/.gitignore"
node_modules
site
EOM
    git -C "${PREVIEW_DIR}" add --all
    git -C "${PREVIEW_DIR}" commit -q -m 'Updated content'

    pushd "${PREVIEW_DIR}" 1>/dev/null || return

    install_yarn "${PREVIEW_DIR}"

    SITE_DIR="${PREVIEW_SITE_DIR}" "${NODE_DIR}/yarn" run build

    info "Successfully generated documentation site under [${PREVIEW_SITE_DIR}]"

    popd 1>/dev/null || return

    unset_step
}

# Starts a HTTP server serving the generated documentation site.
live_preview() {
    set_step site-preview

    info "Starting HTTP server to preview the generated documentation site."

    pushd "${PREVIEW_DIR}" 1>/dev/null || return
    TEMPLATES_SOURCE_DIR="${TARGET_DIR}" SITE_DIR="${PREVIEW_SITE_DIR}" "${NODE_DIR}/yarn" run live-preview
    popd 1>/dev/null || return

    unset_step
}

# Main workflow
main() {
    header "EFORMS TEMPLATES PROCESSOR"

    case ${ACTION} in
        process_templates) process_templates ;;
        generate_site)
            process_templates
            generate_site
            ;;
        preview)
            process_templates
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
