VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "DI Ad remover"
   ClientHeight    =   2970
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4575
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   2970
   ScaleWidth      =   4575
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.CommandButton cmdDebug 
      Caption         =   "Get"
      Height          =   255
      Left            =   3960
      TabIndex        =   5
      Top             =   2640
      Width           =   615
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   0
      TabIndex        =   4
      Top             =   2640
      Width           =   3855
   End
   Begin VB.Frame Frame1 
      Caption         =   "List of rules"
      Height          =   2535
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   4575
      Begin VB.Timer Timer1 
         Enabled         =   0   'False
         Interval        =   1000
         Left            =   3960
         Top             =   1560
      End
      Begin VB.CommandButton cmdRemove 
         Caption         =   "Remove"
         Height          =   255
         Left            =   2520
         TabIndex        =   3
         Top             =   2160
         Width           =   1935
      End
      Begin VB.ListBox List1 
         Height          =   1815
         Left            =   120
         TabIndex        =   2
         Top             =   240
         Width           =   4335
      End
      Begin VB.CommandButton cmdAdd 
         Caption         =   "Add"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   2160
         Width           =   1935
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Start watching"
      Height          =   2535
      Left            =   0
      TabIndex        =   6
      Top             =   0
      Width           =   4575
      Begin VB.CommandButton cmdStart 
         Caption         =   "Start"
         Height          =   1335
         Left            =   840
         TabIndex        =   7
         Top             =   600
         Width           =   2775
      End
   End
   Begin VB.Menu cmmenu 
      Caption         =   "menu"
      Visible         =   0   'False
      Begin VB.Menu cmmenu1 
         Caption         =   "Settings"
         Index           =   1
      End
      Begin VB.Menu cmmenu1 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu cmmenu1 
         Caption         =   "Exit"
         Index           =   3
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdAdd_Click()
    Dim tmp As String
    
    tmp = InputBox("Enter title pattern:", App.Title)
    If Len(Trim(tmp)) > 0 Then
        add_to_list (Trim(tmp))
    End If
End Sub

Private Sub cmdDebug_Click()
    Text1 = get_winamp_title
End Sub

Private Sub cmdHide_Click()
    Me.Hide
End Sub

Private Sub cmdRemove_Click()
    Dim i As Integer
    
    i = List1.ListIndex
    If i = -1 Then Exit Sub
    
    remove_from_list i
End Sub

Private Sub cmdStart_Click()
    init_process
End Sub

Private Sub cmmenu1_Click(Index As Integer)
    Select Case Index
        Case 1
            Me.Show
        Case 3
            Unload Me
    End Select
End Sub

Private Sub Form_Load()
    prev = SetWindowLong(Me.hWnd, GWL_WNDPROC, AddressOf WinProc)
    
    ShowTray Me, App.Title, Me.Icon
    
    load_list
    init_process
    
    'Me.Show
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    KillTray Me
End Sub

Private Sub Form_Resize()
    If Me.WindowState = vbMinimized Then
        Me.Hide
        Me.WindowState = vbNormal
    End If
End Sub

Private Sub Timer1_Timer()
    Static prev_tmp As String
    
    Dim tmp As String
    Dim inlist As Boolean
    
    tmp = get_winamp_title()
    If Len(tmp) = 0 Then Exit Sub
    
    If tmp = prev_tmp Then Exit Sub
    
    inlist = check_in_list(tmp)
    
    If hold_mode Then
        If Not inlist Then _
            mute_winamp False
    Else
        If inlist Then _
            mute_winamp True
    End If
    
    prev_tmp = tmp
End Sub
