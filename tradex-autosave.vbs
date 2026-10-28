Option Explicit

' Task Scheduler uses wscript.exe so no console is created before PowerShell hides.
Dim shell, files, scriptPath, powershellPath, command, argument
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
scriptPath = files.BuildPath(files.GetParentFolderName(WScript.ScriptFullName), "tradex-autosave.ps1")
powershellPath = shell.ExpandEnvironmentStrings("%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe")

If WScript.Arguments.Count < 1 Or WScript.Arguments.Count > 2 Then
    WScript.Quit 2
End If
argument = WScript.Arguments(0)
If InStr(argument, Chr(34)) > 0 Then WScript.Quit 2

command = Chr(34) & powershellPath & Chr(34) & _
    " -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File " & _
    Chr(34) & scriptPath & Chr(34) & " -GitExecutable " & Chr(34) & argument & Chr(34)
If WScript.Arguments.Count = 2 Then
    If WScript.Arguments(1) <> "-CheckOnly" Then WScript.Quit 2
    command = command & " -CheckOnly"
End If

WScript.Quit shell.Run(command, 0, True)
