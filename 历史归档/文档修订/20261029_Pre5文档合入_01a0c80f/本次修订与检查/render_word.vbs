Option Explicit
Dim app,doc,toc,p,stream,fso,root,line,count
Set fso=CreateObject("Scripting.FileSystemObject")
root=fso.GetParentFolderName(WScript.ScriptFullName)
Set app=CreateObject("Word.Application")
app.Visible=False
app.DisplayAlerts=0
app.AutomationSecurity=3
Set doc=app.Documents.Open(root & "\candidate.docx",False,False,False)
doc.Repaginate
doc.Fields.Update
For Each toc In doc.TablesOfContents
 toc.Update
Next
doc.Repaginate
For Each toc In doc.TablesOfContents
 toc.UpdatePageNumbers
Next
doc.Fields.Update
doc.Repaginate
doc.Save
doc.ExportAsFixedFormat root & "\candidate.pdf",17,False,0,0
Set stream=CreateObject("ADODB.Stream")
stream.Type=2
stream.Charset="utf-8"
stream.Open
stream.WriteText "level" & vbTab & "number" & vbTab & "heading" & vbTab & "page" & vbCrLf
count=0
For Each p In doc.Paragraphs
 If p.OutlineLevel>=1 And p.OutlineLevel<=3 Then
  line=Replace(Replace(p.Range.Text,vbCr,""),Chr(7),"")
  stream.WriteText p.OutlineLevel & vbTab & p.Range.ListFormat.ListString & vbTab & line & vbTab & p.Range.Information(3) & vbCrLf
  count=count+1
 End If
Next
stream.SaveToFile root & "\headings_pages.tsv",2
stream.Close
WScript.Echo "WORD_RENDER_COMPLETE pages=" & doc.ComputeStatistics(2) & " headings=" & count & " toc=" & doc.TablesOfContents.Count
doc.Close 0
app.Quit 0
