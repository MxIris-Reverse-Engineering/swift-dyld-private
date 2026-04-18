#if canImport(Darwin)
enum ForbiddenSymbolList {
    static let names: [String] = [
        "dyld_shared_cache_file_path",
        "_dyld_get_shared_cache_range",
        "dyld_image_header_containing_address",
        "dyld_image_path_containing_address",
        "/usr/lib/system/libdyld.dylib",
        "libdyld.dylib",
        "macho_dylib_install_name",
        "macho_for_each_dependent_dylib",
        "macho_for_each_imported_symbol",
        "macho_for_each_exported_symbol",
        "macho_for_each_defined_rpath",
        "macho_source_version",
        "macho_for_each_runnable_arch_name",
        "_dyld_process_info_create",
        "_dyld_process_info_release",
        "_dyld_process_info_retain",
        "_dyld_process_info_get_state",
        "_dyld_process_info_get_cache",
        "_dyld_process_info_get_aot_cache",
        "_dyld_process_info_for_each_image",
        "_dyld_process_info_for_each_aot_image",
        "_dyld_process_info_for_each_segment",
        "_dyld_process_info_get_platform",
        "_dyld_process_info_notify",
        "_dyld_process_info_notify_main",
        "_dyld_process_info_notify_release",
        "_dyld_process_info_notify_retain",
    ]
}
#endif
