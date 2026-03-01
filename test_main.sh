main() {
    log_info "Starting AI Ethics Enforcement Toolkit installation..."
    log_info "Repository: $GITHUB_REPO"
    log_info "Operating System: $(detect_os)"

    # Check prerequisites
    if ! command_exists git; then
        log_error "Git is required but not installed."
        exit 1
    fi

    # Install components
    install_python_deps
    install_git_hooks
    install_vscode_extension
    install_intellij_plugin
    install_xcode_extension
    install_shell_integration
    install_ci_integration
    install_language_integrations
    install_system_hooks
    install_browser_extensions

    log_success "AI Ethics Enforcement Toolkit installation completed!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Restart your IDE/editor"
    log_info "2. Run 'ai-check --help' for CLI usage"
    log_info "3. Check documentation for advanced configuration"
    log_info ""
    log_info "Installed components:"
    log_info "  ✓ Python core library"
    log_info "  ✓ Git hooks"
    log_info "  ✓ VSCode extension"
    log_info "  ✓ IntelliJ plugin structure"
    log_info "  ✓ Xcode extension structure"
    log_info "  ✓ Shell integration"
    log_info "  ✓ CI/CD workflows"
    log_info "  ✓ Language-specific hooks"
    log_info "  ✓ System hooks"
    log_info "  ✓ Browser extensions"
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi</content>
