import Nimble

@objcMembers
public class AssertionRecord: NSObject {
    var record: Nimble.AssertionRecord

    init(record: Nimble.AssertionRecord) {
        self.record = record
    }

    public var fileName: String {
        return record.location.file
    }

    public var lineNumber: UInt {
        return record.location.line
    }

    public var message: String {
        return record.message.userDescription ?? record.message.stringValue
    }

}

@objcMembers
public class RecordAssertions: NSObject {

    public func record(_ block: () -> Void) -> [AssertionRecord] {
        let oldHandler = NimbleAssertionHandler
        let recorder = AssertionRecorder()
        NimbleAssertionHandler = recorder
        block()
        NimbleAssertionHandler = oldHandler
        return recorder.assertions.filter { !$0.success }.map(AssertionRecord.init)
    }

}
