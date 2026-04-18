#if canImport(Darwin)
import ConfidentialKit

enum ObfuscatedDyldSymbols {
    static #Obfuscate {
        let sharedCacheFilePath = "dyld_shared_cache_file_path"
        let sharedCacheRange = "_dyld_get_shared_cache_range"
        let imageHeaderContainingAddress = "dyld_image_header_containing_address"
        let imagePathContainingAddress = "dyld_image_path_containing_address"
        let libdyldPath = "/usr/lib/system/libdyld.dylib"
    }
}

enum ObfuscatedMachOUtilsSymbols {
    static #Obfuscate {
        let machoDylibInstallName = "macho_dylib_install_name"
        let machoForEachDependentDylib = "macho_for_each_dependent_dylib"
        let machoForEachImportedSymbol = "macho_for_each_imported_symbol"
        let machoForEachExportedSymbol = "macho_for_each_exported_symbol"
        let machoForEachDefinedRpath = "macho_for_each_defined_rpath"
        let machoSourceVersion = "macho_source_version"
        let machoForEachRunnableArchName = "macho_for_each_runnable_arch_name"
    }
}

enum ObfuscatedDyldProcessInfoSymbols {
    static #Obfuscate {
        let processInfoCreate = "_dyld_process_info_create"
        let processInfoRelease = "_dyld_process_info_release"
        let processInfoRetain = "_dyld_process_info_retain"
        let processInfoGetState = "_dyld_process_info_get_state"
        let processInfoGetCache = "_dyld_process_info_get_cache"
        let processInfoGetAotCache = "_dyld_process_info_get_aot_cache"
        let processInfoForEachImage = "_dyld_process_info_for_each_image"
        let processInfoForEachAotImage = "_dyld_process_info_for_each_aot_image"
        let processInfoForEachSegment = "_dyld_process_info_for_each_segment"
        let processInfoGetPlatform = "_dyld_process_info_get_platform"
        let processInfoNotify = "_dyld_process_info_notify"
        let processInfoNotifyMain = "_dyld_process_info_notify_main"
        let processInfoNotifyRelease = "_dyld_process_info_notify_release"
        let processInfoNotifyRetain = "_dyld_process_info_notify_retain"
    }
}
#endif
