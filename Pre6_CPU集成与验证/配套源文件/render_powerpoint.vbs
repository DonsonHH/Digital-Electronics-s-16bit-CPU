Option Explicit
Dim app,pres,slide,shape,charts,tables,series,stream,oldAlerts,ownsApp,initialCount,fso,privatePath,probeWidth,probeText
If WScript.Arguments.Count <> 4 Then WScript.Quit 2
On Error Resume Next
ownsApp=False
Set app=GetObject(,"PowerPoint.Application")
If Err.Number<>0 Then
  Err.Clear
  Set app=CreateObject("PowerPoint.Application")
  ownsApp=True
End If
CheckError "connect application"
initialCount=app.Presentations.Count
oldAlerts=app.DisplayAlerts
app.DisplayAlerts=1
Set fso=CreateObject("Scripting.FileSystemObject")
privatePath=fso.BuildPath(WScript.Arguments(1),fso.GetTempName & ".pptx")
fso.CopyFile WScript.Arguments(0),privatePath,False
CheckError "make private editability copy"
Set pres=app.Presentations.Open(privatePath,0,0,0)
CheckError "open private copy"
charts=0:tables=0:series=0
For Each slide In pres.Slides
  For Each shape In slide.Shapes
    If shape.HasChart Then
      charts=charts+1
      probeWidth=shape.Width
      shape.Width=probeWidth-2
      shape.Width=probeWidth
      series=series+shape.Chart.SeriesCollection.Count
      CheckError "edit native chart"
    End If
    If shape.HasTable Then
      tables=tables+1
      probeText=shape.Table.Cell(1,1).Shape.TextFrame.TextRange.Text
      shape.Table.Cell(1,1).Shape.TextFrame.TextRange.Text=probeText
      CheckError "edit native table"
    End If
  Next
Next
pres.Save
CheckError "save private copy"
pres.Close
Set pres=Nothing
Set pres=app.Presentations.Open(privatePath,-1,0,0)
CheckError "reopen saved private copy"
For Each slide In pres.Slides
  slide.Export WScript.Arguments(1) & "\slide-" & Right("0" & slide.SlideIndex,2) & ".png","PNG",1920,1080
  CheckError "render slide " & slide.SlideIndex
Next
pres.SaveAs WScript.Arguments(2),32
CheckError "export PDF"
Set stream=CreateObject("ADODB.Stream")
stream.Type=2:stream.Charset="utf-8":stream.Open
stream.WriteText "SLIDES=" & pres.Slides.Count & vbCrLf & "NATIVE_CHARTS=" & charts & vbCrLf & "NATIVE_TABLES=" & tables & vbCrLf & "CHART_SERIES=" & series & vbCrLf & "PRIVATE_COPY_SAVE_REOPEN=PASS" & vbCrLf
stream.SaveToFile WScript.Arguments(3),2:stream.Close
CheckError "write render receipt"
Cleanup
WScript.Echo "NATIVE_POWERPOINT_RENDER_COMPLETE"
WScript.Quit 0

Sub CheckError(stage)
  Dim code,description
  If Err.Number<>0 Then
    code=Err.Number:description=Err.Description
    Err.Clear
    WScript.Echo "FAILED " & stage & ": " & code & " " & description
    Cleanup
    WScript.Quit 1
  End If
End Sub

Sub Cleanup
  On Error Resume Next
  If Not pres Is Nothing Then pres.Close
  app.DisplayAlerts=oldAlerts
  If ownsApp And initialCount=0 Then
    If app.Presentations.Count=0 Then app.Quit
  End If
End Sub
