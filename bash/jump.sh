#!/usr/bin/env bash

JUMP_INSTALL_DIR="${HOME}/.local/share/cli-toolbox"
JUMP_INSTALL_FILE="${JUMP_INSTALL_DIR}/jump.sh"

JUMP_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/jump"
JUMP_BOOKMARKS_FILE="${JUMP_CONFIG_DIR}/bookmarks.tsv"

JUMP_BASHRC="${HOME}/.bashrc"

JUMP_MARKER_START="# >>> CLI-Toolbox jump >>>"
JUMP_MARKER_END="# <<< CLI-Toolbox jump <<<"


_jump_usage() {
    cat <<'EOF'
Usage:
  jump <name>              Jump to a saved directory
  jump add <name> [path]   Save a directory (current directory by default)
  jump remove <name>       Remove a bookmark
  jump list                List bookmarks
  jump help                Show this help

Examples:
  jump add toolbox
  jump add downloads ~/Downloads
  jump toolbox
  jump list
  jump remove toolbox
EOF
}


_jump_ensure_store() {
    mkdir -p "${JUMP_CONFIG_DIR}"
    touch "${JUMP_BOOKMARKS_FILE}"
}


_jump_validate_name() {
    local name="$1"

    if [[ ! "${name}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid bookmark name: ${name}" >&2
        echo "Use only letters, numbers, '.', '_' and '-'." >&2
        return 1
    fi

    case "${name}" in
        add|remove|list|help)
            echo "'${name}' is a reserved command name." >&2
            return 1
            ;;
    esac
}


_jump_get_path() {
    local name="$1"
    local key
    local path

    [[ -f "${JUMP_BOOKMARKS_FILE}" ]] || return 1

    while IFS=$'\t' read -r key path; do
        if [[ "${key}" == "${name}" ]]; then
            printf '%s\n' "${path}"
            return 0
        fi
    done < "${JUMP_BOOKMARKS_FILE}"

    return 1
}


_jump_add() {
    local name="${1:-}"
    local path="${2:-${PWD}}"

    if [[ -z "${name}" ]]; then
        echo "Usage: jump add <name> [path]" >&2
        return 1
    fi

    _jump_validate_name "${name}" || return 1

    if [[ ! -d "${path}" ]]; then
        echo "Directory does not exist: ${path}" >&2
        return 1
    fi

    # Convert path to an absolute path.
    path="$(cd "${path}" && pwd -P)" || return 1

    _jump_ensure_store

    if _jump_get_path "${name}" >/dev/null; then
        echo "Bookmark '${name}' already exists." >&2
        echo "Remove it first with: jump remove ${name}" >&2
        return 1
    fi

    printf '%s\t%s\n' "${name}" "${path}" >> "${JUMP_BOOKMARKS_FILE}"

    echo "Added: ${name} -> ${path}"
}


_jump_remove() {
    local name="${1:-}"
    local key
    local path
    local tmpfile
    local found=0

    if [[ -z "${name}" ]]; then
        echo "Usage: jump remove <name>" >&2
        return 1
    fi

    if [[ ! -f "${JUMP_BOOKMARKS_FILE}" ]]; then
        echo "No bookmarks found." >&2
        return 1
    fi

    tmpfile="$(mktemp)"

    while IFS=$'\t' read -r key path; do
        if [[ "${key}" == "${name}" ]]; then
            found=1
            continue
        fi

        printf '%s\t%s\n' "${key}" "${path}" >> "${tmpfile}"
    done < "${JUMP_BOOKMARKS_FILE}"

    if (( found == 0 )); then
        rm -f "${tmpfile}"
        echo "Bookmark not found: ${name}" >&2
        return 1
    fi

    mv "${tmpfile}" "${JUMP_BOOKMARKS_FILE}"

    echo "Removed: ${name}"
}


_jump_list() {
    local key
    local path

    if [[ ! -s "${JUMP_BOOKMARKS_FILE}" ]]; then
        echo "No bookmarks saved."
        return 0
    fi

    printf "%-20s %s\n" "NAME" "PATH"
    printf "%-20s %s\n" "--------------------" "----"

    while IFS=$'\t' read -r key path; do
        printf "%-20s %s\n" "${key}" "${path}"
    done < "${JUMP_BOOKMARKS_FILE}"
}


_jump_go() {
    local name="$1"
    local path

    if ! path="$(_jump_get_path "${name}")"; then
        echo "Unknown bookmark: ${name}" >&2
        echo "Run 'jump list' to see available bookmarks." >&2
        return 1
    fi

    if [[ ! -d "${path}" ]]; then
        echo "Bookmark '${name}' points to a directory that no longer exists:" >&2
        echo "  ${path}" >&2
        return 1
    fi

    builtin cd -- "${path}"
}


jump() {
    local command="${1:-help}"

    case "${command}" in
        add)
            shift
            _jump_add "$@"
            ;;

        remove|rm)
            shift
            _jump_remove "$@"
            ;;

        list|ls)
            _jump_list
            ;;

        help|-h|--help)
            _jump_usage
            ;;

        *)
            _jump_go "${command}"
            ;;
    esac
}


_jump_self_path() {
    local source_file="${BASH_SOURCE[0]}"
    local source_dir

    source_dir="$(cd "$(dirname "${source_file}")" && pwd -P)" || return 1

    printf '%s/%s\n' \
        "${source_dir}" \
        "$(basename "${source_file}")"
}


_jump_install() {
    local source_file

    source_file="$(_jump_self_path)"

    mkdir -p "${JUMP_INSTALL_DIR}"

    if [[ "${source_file}" != "${JUMP_INSTALL_FILE}" ]]; then
        cp "${source_file}" "${JUMP_INSTALL_FILE}"
    fi

    chmod 644 "${JUMP_INSTALL_FILE}"

    touch "${JUMP_BASHRC}"

    if ! grep -Fqx "${JUMP_MARKER_START}" "${JUMP_BASHRC}"; then
        {
            echo ""
            echo "${JUMP_MARKER_START}"
            echo 'source "$HOME/.local/share/cli-toolbox/jump.sh"'
            echo "${JUMP_MARKER_END}"
        } >> "${JUMP_BASHRC}"
    fi

    echo "jump installed."
    echo ""
    echo "Installed script:"
    echo "  ${JUMP_INSTALL_FILE}"
    echo ""
    echo "Bookmarks:"
    echo "  ${JUMP_BOOKMARKS_FILE}"
    echo ""
    echo "Open a new terminal or run:"
    echo "  source ~/.bashrc"
}


_jump_remove_bashrc_block() {
    local tmpfile

    [[ -f "${JUMP_BASHRC}" ]] || return 0

    tmpfile="$(mktemp)"

    awk \
        -v start="${JUMP_MARKER_START}" \
        -v end="${JUMP_MARKER_END}" '
        $0 == start {
            skip = 1
            next
        }

        $0 == end {
            skip = 0
            next
        }

        !skip {
            print
        }
    ' "${JUMP_BASHRC}" > "${tmpfile}"

    mv "${tmpfile}" "${JUMP_BASHRC}"
}


_jump_uninstall() {
    _jump_remove_bashrc_block

    rm -f "${JUMP_INSTALL_FILE}"
    rmdir "${JUMP_INSTALL_DIR}" 2>/dev/null || true

    echo "jump uninstalled."
    echo "Your bookmarks were preserved in:"
    echo "  ${JUMP_BOOKMARKS_FILE}"
    echo ""
    echo "Open a new terminal or run:"
    echo "  source ~/.bashrc"
}


_jump_purge() {
    _jump_uninstall

    rm -rf "${JUMP_CONFIG_DIR}"

    echo ""
    echo "Bookmarks deleted."
}


# If the file is executed directly, behave as the installer.
# If it is sourced from .bashrc, only define the jump function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail

    case "${1:-}" in
        --install)
            _jump_install
            ;;

        --uninstall)
            _jump_uninstall
            ;;

        --purge)
            _jump_purge
            ;;

        -h|--help|"")
            cat <<'EOF'
CLI-Toolbox jump installer

Usage:
  ./jump.sh --install     Install or update jump
  ./jump.sh --uninstall   Remove jump but keep bookmarks
  ./jump.sh --purge       Remove jump and delete bookmarks
EOF
            ;;

        *)
            echo "Unknown option: ${1}" >&2
            exit 1
            ;;
    esac
fi
