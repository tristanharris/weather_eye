// TEST VCDlg.cpp : implementation file
//

#include "stdafx.h"
#include "TEST VC.h"
#include "TEST VCDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTESTVCDlg dialog

CTESTVCDlg::CTESTVCDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CTESTVCDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTESTVCDlg)
	m_address = _T("");
	m_data = _T("");
	m_message = _T("");

	UsbDeviceVid=0x1941;
	UsbDevicePid=0x8021;

	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CTESTVCDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTESTVCDlg)
	DDX_Control(pDX, IDC_Picture, m_picture);
	DDX_Text(pDX, IDC_Address, m_address);
	DDX_Text(pDX, IDC_Data, m_data);
	DDX_Text(pDX, IDC_Message, m_message);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CTESTVCDlg, CDialog)
	//{{AFX_MSG_MAP(CTESTVCDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_TIMER()
	ON_WM_CANCELMODE()
	ON_BN_CLICKED(IDC_Read, OnRead)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTESTVCDlg message handlers

BOOL CTESTVCDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	SetTimer(0,100,0);
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CTESTVCDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CTESTVCDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CTESTVCDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CTESTVCDlg::OnTimer(UINT nIDEvent) 
{
	// TODO: Add your message handler code here and/or call default
	

	if(!nIDEvent){
	   CBitmap m_bitmap;
	   if(IoConSys.DevInfo == false)
	   {

		    if(IoConSys.FindDevice(UsbDeviceVid,UsbDevicePid)==true)	
			{
			IoConSys.DevInfo = true;
            m_bitmap.LoadBitmap(IDB_USBConnected);
			m_picture.SetBitmap(m_bitmap);
			UpdateData(false);
			}
		    else
			{
			m_bitmap.LoadBitmap(IDB_USBNOTConnected);
			m_picture.SetBitmap(m_bitmap);
			}
   		}
	  else
		{
		    if(IoConSys.CheckDevice()==false)	
			{
			IoConSys.DevInfo = false;
			m_bitmap.LoadBitmap(IDB_USBNOTConnected);
			m_picture.SetBitmap(m_bitmap);
			}
			else
			{
            m_bitmap.LoadBitmap(IDB_USBConnected);
			m_picture.SetBitmap(m_bitmap);
			}

		}
	}
	

	CDialog::OnTimer(nIDEvent);
}

void CTESTVCDlg::OnCancelMode() 
{
	CDialog::OnCancelMode();
	
	// TODO: Add your message handler code here
	
}

void CTESTVCDlg::OnRead() 
{
	// TODO: Add your control notification handler code here
	
		FILE *stream;

	unsigned char buf[8];
	unsigned char buf0[8];
	unsigned int m_int; 
	
	signed int temp_c;
	unsigned int temp_d;

	address=0x100;

	if( (stream  = fopen( "data.txt", "a+b" )) == NULL )
      m_message="The file 'data.txt' was not opened\n"; 
    else
      m_message= "The file 'data.txt' was opened\n" ;

	SetDlgItemText(IDC_Message,m_message);

repeat:

	buf[0]=0xa1;
	buf[3]=0x20;
	buf[4]=0xa1;
	buf[7]=0x20;
	
	buf[2]=LOBYTE(address);	
	buf[1]=HIBYTE(address);	
	buf[5]=buf[1];
	buf[6]=buf[2];

	temp_d=4;

	if(IoConSys.Output(buf)==false) return;

repeat1:
	temp_c=0;
	do
	{ 
		temp_c = temp_c++;
		if (temp_c>10000) break;
	}
	while	(IoConSys.InputData(buf0)==false);

	if (temp_c>10000) goto repeat;
	
	temp_c=fwrite(buf0,sizeof(char),8,stream);
	//	printf("%s",buf0[0]);	//,sizeof(char),8,stream);

	if (temp_c != 8) 
		goto repeat	;
	data=buf0[0];

	temp_d=temp_d--;
	if (temp_d!=0)  goto repeat1;

advance:
	address=address+0x20;
	//addres=address;
	m_data.Format("%02x %02x %02x %02x %02x %02x %02x %02x",buf0[0],buf0[1],buf0[2],buf0[3],buf0[4],buf0[5],buf0[6],buf0[7]);
	SetDlgItemText(IDC_Data,m_data);
	m_address.Format("%04x",address);
	SetDlgItemText(IDC_Address,m_address);
	ShowWindow(1);
	UpdateWindow();	
	
	UpdateData(false);
	

	if (address < 0x10000) 
		goto repeat;

	fclose(stream); 


}
