Option Explicit
Dim wordApp, doc, i, output, report, stream
If WScript.Arguments.Count <> 3 Then WScript.Quit 2
Set wordApp = CreateObject("Word.Application")
wordApp.Visible = False
wordApp.DisplayAlerts = 0
Set doc = wordApp.Documents.Open(WScript.Arguments(0), False, False, False)
doc.Fields.Update
For i = 1 To doc.TablesOfContents.Count
  doc.TablesOfContents(i).Update
Next
doc.Repaginate
doc.Fields.Update
doc.Save
doc.ExportAsFixedFormat WScript.Arguments(1), 17
doc.Save
Set stream = CreateObject("ADODB.Stream")
stream.Type = 2
stream.Charset = "utf-8"
stream.Open
stream.WriteText "PAGES=" & doc.ComputeStatistics(2) & vbCrLf
stream.WriteText "TOC=" & doc.TablesOfContents.Count & vbCrLf
stream.WriteText "TABLES=" & doc.Tables.Count & vbCrLf
stream.WriteText "FIGURES=" & doc.InlineShapes.Count & vbCrLf
stream.SaveToFile WScript.Arguments(2), 2
stream.Close
doc.Close False
wordApp.Quit
WScript.Echo "NATIVE_WORD_RENDER_COMPLETE"
