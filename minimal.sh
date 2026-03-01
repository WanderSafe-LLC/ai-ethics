#!/bin/bash

log_info() {
    echo "INFO: $1"
}

main() {
    log_info "Test"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
