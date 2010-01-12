// TEST VCDlg.h : header file
//

#if !defined(AFX_TESTVCDLG_H__F96249FE_1CA5_4FC8_B6CD_8FF1C9E50944__INCLUDED_)
#define AFX_TESTVCDLG_H__F96249FE_1CA5_4FC8_B6CD_8FF1C9E50944__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "IoConS.h"



/////////////////////////////////////////////////////////////////////////////
// CTESTVCDlg dialog

class CTESTVCDlg : public CDialog
{
// Construction
public:
	CTESTVCDlg(CWnd* pParent = NULL);	// standard constructor

	int address;
	int data;
	int UsbDeviceVid;
	int UsbDevicePid;

// Dialog Data
	//{{AFX_DATA(CTESTVCDlg)
	enum { IDD = IDD_TESTVC_DIALOG };
	CStatic	m_picture;
	CString	m_address;
	CString	m_data;
	CString	m_message;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTESTVCDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
	IoConS IoConSys;

	// Generated message map functions
	//{{AFX_MSG(CTESTVCDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnCancelMode();
	afx_msg void OnRead();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TESTVCDLG_H__F96249FE_1CA5_4FC8_B6CD_8FF1C9E50944__INCLUDED_)
