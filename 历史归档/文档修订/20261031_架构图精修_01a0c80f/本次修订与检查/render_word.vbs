Option Explicit
Dim app,doc,toc,p,stream,fso,root,line,count,rng,lev,sty,pos
Set fso=CreateObject("Scripting.FileSystemObject")
root=fso.GetParentFolderName(WScript.ScriptFullName)
Set app=CreateObject("Word.Application")
app.Visible=False
app.DisplayAlerts=0
app.AutomationSecurity=3
app.Options.BackgroundSave=False
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
doc.Saved=False
doc.Save
Set stream=CreateObject("ADODB.Stream")
stream.Type=2
stream.Charset="utf-8"
stream.Open
stream.WriteText "level" & vbTab & "number" & vbTab & "heading" & vbTab & "page" & vbTab & "position" & vbCrLf
count=0
For lev=1 To 3
 Set rng=doc.Content.Duplicate
 With rng.Find
  .ClearFormatting
  .Text=""
  .Style=doc.Styles(-1-lev)
  .Forward=True
  .Wrap=0
  .Format=True
 End With
 Do While rng.Find.Execute
  line=Replace(Replace(rng.Text,vbCr,""),Chr(7),"")
  stream.WriteText lev & vbTab & rng.ListFormat.ListString & vbTab & line & vbTab & rng.Information(3) & vbTab & rng.Start & vbCrLf
  count=count+1
  pos=rng.End
  rng.SetRange pos,doc.Content.End
 Loop
Next
stream.SaveToFile root & "\headings_pages.tsv",2
stream.Close
WScript.Echo "WORD_RENDER_COMPLETE pages=" & doc.ComputeStatistics(2) & " headings=" & count & " toc=" & doc.TablesOfContents.Count & " sections=" & doc.Sections.Count
doc.Close 0
app.Quit 0
