Attribute VB_Name = "modMain"
Option Explicit

Public Type NOTIFYICONDATA
   cbSize As Long
   hWnd As Long
   uID As Long
   uFlags As Long
   uCallbackMessage As Long
   hIcon As Long
   szTip As String * 128
   dwState As Long
   dwStateMask As Long
   szInfo As String * 256
   uTimeout As Long
   szInfoTitle As String * 64
   dwInfoFlags As Long
End Type

Public Const NIM_ADD = &H0&
Public Const NIM_MODIFY = &H1&
Public Const NIM_DELETE = &H2&

Public Const NIF_MESSAGE = &H1&
Public Const NIF_ICON = &H2&
Public Const NIF_TIP = &H4&
Public Const NIF_INFO = &H10

Public Const NIIF_ERROR = &H3

Public Const WM_RBUTTONDOWN = &H204
Public Const WM_LBUTTONDBLCLK = &H203
Public Const WM_USER = &H400
Public Const TRAY_BACK = (WM_USER + 200)

Public Const GWL_WNDPROC = (-4&)

Private Const SETTINGS_FILE = "list.txt"

Declare Function Shell_NotifyIcon Lib "shell32.dll" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, lpData As NOTIFYICONDATA) As Long
Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hWnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Public prev As Long
Public winamp_hwmd As Long
Public hold_mode As Boolean
Public CPath As String
Public ad_list As New Collection

Public Sub Main()
    CPath = App.Path
    If Right(CPath, 1) <> "\" Then CPath = CPath & "\"
    
    Load frmMain
End Sub

Public Sub init_process()
    winamp_hwmd = get_winamp_hwnd
    If winamp_hwmd > 0 Then
        frmMain.Timer1.Enabled = True
        frmMain.Frame1.Visible = True
        frmMain.Frame2.Visible = False
        hold_mode = False
    End If
End Sub

Public Sub disable_process()
    frmMain.Timer1.Enabled = False
    frmMain.Frame1.Visible = False
    frmMain.Frame2.Visible = True
End Sub

Public Function get_winamp_title() As String
    Dim m_str As String
    Dim rez As Long, i As Long
    
    get_winamp_title = vbNullString
    
    m_str = String(255, " ")
    rez = GetWindowText(winamp_hwmd, m_str, 255)
    
    If rez = 0 Then
        disable_process
        Exit Function
    End If
    
    m_str = Left(m_str, rez)
    i = InStr(1, m_str, ". ")
    
    get_winamp_title = Mid(m_str, i + 2)
End Function

Public Function get_winamp_hwnd() As Long
    Const WINAMP_CLASS = "Winamp v1.x"
    
    get_winamp_hwnd = FindWindow(WINAMP_CLASS, vbNullString)
End Function

Public Sub mute_winamp(do_mute As Boolean)
    Dim rez As Long

    Static prev_volume As Long
    
    Const GET_VOLUME = -666
    Const WINAMP_VOLUME = 122
    
    If do_mute Then
        prev_volume = SendMessage(winamp_hwmd, WM_USER, GET_VOLUME, WINAMP_VOLUME)
        Call SendMessage(winamp_hwmd, WM_USER, 0, WINAMP_VOLUME)
        hold_mode = True
    Else
        Call SendMessage(winamp_hwmd, WM_USER, prev_volume, WINAMP_VOLUME)
        hold_mode = False
    End If
End Sub

Public Function check_in_list(m_str) As Boolean
    Dim tmp As String, i As Integer
    
    For i = 1 To ad_list.Count
        tmp = Left(m_str, Len(ad_list(i)))
        If tmp = ad_list(i) Then
            check_in_list = True
            Exit Function
        End If
    Next
    
    check_in_list = False
End Function

Public Sub add_to_list(m_str)
    ad_list.Add m_str
    frmMain.List1.AddItem m_str
    save_list
End Sub

Public Sub remove_from_list(indx As Integer)
    ad_list.Remove indx + 1
    frmMain.List1.RemoveItem indx
    save_list
End Sub

Private Sub save_list()
    Dim i As Long
    
    Open CPath & SETTINGS_FILE For Output As #1
    
    For i = 1 To ad_list.Count
        Print #1, ad_list.Item(i)
    Next
    
    Close #1
End Sub

Public Sub load_list()
    Dim tmp As String
    
    Open CPath & SETTINGS_FILE For Input As #1
    While Not EOF(1)
        Line Input #1, tmp
        If Len(Trim(tmp)) > 0 Then
            ad_list.Add tmp
            frmMain.List1.AddItem tmp
        End If
    Wend
    Close #1
End Sub

Public Function WinProc(ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    Select Case Msg
        Case TRAY_BACK
            If lParam = WM_RBUTTONDOWN Then
                frmMain.PopupMenu frmMain.cmmenu
            End If
            If lParam = WM_LBUTTONDBLCLK Then
                frmMain.Show
            End If
    End Select
    
    WinProc = CallWindowProc(prev, hWnd, Msg, wParam, lParam)
End Function

Public Sub ShowTray(frm As Form, szTip As String, hIcon As Long)
    Dim NID As NOTIFYICONDATA
    With NID
        .cbSize = Len(NID)
        .hIcon = hIcon
        .hWnd = frm.hWnd
        .szTip = szTip & vbNullChar
        .uCallbackMessage = TRAY_BACK
        .uFlags = NIF_MESSAGE Or NIF_ICON Or NIF_TIP
        .uID = 1&
    End With
    Shell_NotifyIcon NIM_ADD, NID
End Sub

Public Sub KillTray(frm As Form)
    Dim NID As NOTIFYICONDATA
    With NID
        .cbSize = Len(NID)
        .hWnd = frm.hWnd
        .uID = 1&
    End With
    Shell_NotifyIcon NIM_DELETE, NID
End Sub
