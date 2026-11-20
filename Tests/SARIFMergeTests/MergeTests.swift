import Foundation
import SARIF
import SARIFMerge
import SARIFTestUtilities
import Testing

private func loadSARIFLog(named name: String, sink: any ValidationSink) throws
  -> SARIFLog
{
  let log = try SARIFLog(
    from: try Bundle.module.loadResource(named: name), sink: sink)

  // Strip `defaultConfiguration` because we don't support merging it properly yet.
  for run in log.runs {
    for toolComponent in run.tool.allToolComponents {
      for rule in toolComponent.rules {
        rule.defaultConfiguration = nil
      }
    }
  }

  return log
}

@Test
func mergeSingleFile() throws {
  let sink = StdOutValidationSink()

  let outputLog = SARIFLog()
  var merger = SARIFLogMerger(into: outputLog, sink: sink)

  let inputLog = try loadSARIFLog(named: "test.sarif", sink: sink)
  try merger.merge(from: inputLog)

  expectJSON(expected: inputLog, actual: outputLog)
}

@Test
func mergeDuplicateFiles() throws {
  let sink = StdOutValidationSink()

  let outputLog = SARIFLog()
  var merger = SARIFLogMerger(into: outputLog, sink: sink)

  let inputLog1 = try loadSARIFLog(named: "test.sarif", sink: sink)
  try merger.merge(from: inputLog1)
  let inputLog2 = try loadSARIFLog(named: "test.sarif", sink: sink)
  try merger.merge(from: inputLog2)

  expectJSON(expected: inputLog1, actual: outputLog)
}
