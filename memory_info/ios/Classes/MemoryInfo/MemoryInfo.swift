enum MemoryInfo {
    public enum Unit: Double {
        // For going from byte to -
        case byte = 1
        case kilobyte = 1024
        case megabyte = 1048576
        case gigabyte = 1073741824
    }

    fileprivate static func getHostBasicInfo() -> host_basic_info? {
        let host_port: host_t = mach_host_self()

        var size: mach_msg_type_number_t =
            UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)

        var returnedData = host_basic_info.init()

        let status = withUnsafeMutablePointer(to: &returnedData) {
            (p: UnsafeMutablePointer<host_basic_info>) -> Bool in p.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                (pp: UnsafeMutablePointer<integer_t>) -> Bool in
                let retvalue = host_info(host_port, HOST_BASIC_INFO, pp, &size)

                return retvalue == KERN_SUCCESS
            }
        }
        return status ? returnedData : nil
    }

    /// Wraps `host_statistics64`, and provides info on virtual memory
    ///
    /// - Returns: a `vm_statistics64`, or nil if the kernel reported an error
    ///
    /// Relevant: https://opensource.apple.com/source/xnu/xnu-3789.51.2/osfmk/mach/vm_statistics.h.auto.html
    fileprivate static func getVMStatistics64() -> vm_statistics64? {
        // the port number of the host (the current machine)  http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_host_self.html
        let host_port: host_t = mach_host_self()

        // size of a vm_statistics_data in integer_t's
        var host_size = mach_msg_type_number_t(UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size))

        var returnData = vm_statistics64.init()
        let succeeded = withUnsafeMutablePointer(to: &returnData) {
            (p: UnsafeMutablePointer<vm_statistics64>) -> Bool in

            // host_statistics64() gives us a vm_statistics64 value, but it
            // returns this via an out pointer of type integer_t, so we need to rebind our
            // UnsafeMutablePointer<vm_statistics64> in order to use the function
            p.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                (pp: UnsafeMutablePointer<integer_t>) -> Bool in

                let retvalue = host_statistics64(host_port, HOST_VM_INFO64,
                                                 pp, &host_size)
                return retvalue == KERN_SUCCESS
            }
        }

        return succeeded ? returnData : nil
    }

    /// Wrapper for `host_page_size`
    ///
    /// - Returns: system's virtual page size, in bytes
    ///
    /// Reference: http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_page_size.html
    fileprivate static func getPageSize() -> UInt {
        // the port number of the host (the current machine)  http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_host_self.html
        let host_port: host_t = mach_host_self()
        // the page size of the host, in bytes http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_page_size.html
        var pagesize: vm_size_t = 0
        host_page_size(host_port, &pagesize)
        // assert: pagesize is initialized
        return UInt(pagesize)
    }

    /// Size of physical memory on this machine
    public static func physicalMemory(_ unit: Unit = .megabyte) -> Double {
        if let basicInfo = getHostBasicInfo() {
            return (Double(basicInfo.max_mem)) / unit.rawValue
        }
        return 0
    }

    public static func memoryUsage(_ unit: Unit = .megabyte) -> (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double)
    {
        guard let stats = getVMStatistics64() else {
            return (0, 0, 0, 0, 0)
        }

        let pageSizeBytes = Double(getPageSize())

        let free = Double(stats.free_count) * pageSizeBytes / unit.rawValue

        let active = Double(stats.active_count) * pageSizeBytes / unit.rawValue

        let inactive = Double(stats.inactive_count) * pageSizeBytes / unit.rawValue
        let wired = Double(stats.wire_count) * pageSizeBytes / unit.rawValue

        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * pageSizeBytes / unit.rawValue

        return (free, active, inactive, wired, compressed)
    }

    public static func memoryUsedByApp(_ unit: Unit = .megabyte) -> Double {
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return 0 }

        return Double(info.phys_footprint) / unit.rawValue
    }

    public static func diskTotalSpace(_ unit: Unit = .megabyte) -> Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space / Int64(unit.rawValue)
    }

    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    public static func diskFreeSpace(_ unit: Unit = .megabyte) -> Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space / Int64(unit.rawValue)
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
               let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            {
                return freeSpace / Int64(unit.rawValue)
            } else {
                return 0
            }
        }
    }

    public static func diskUsedSpace(_ unit: Unit = .megabyte) -> Int64 {
        return (diskTotalSpace() - diskFreeSpace()) / Int64(unit.rawValue)
    }
}
