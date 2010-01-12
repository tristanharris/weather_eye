// IoConS.h: interface for the IoConS class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IOCONS_H__7E0E8B9D_0C4E_4DEE_B454_FC9B6D5804FF__INCLUDED_)
#define AFX_IOCONS_H__7E0E8B9D_0C4E_4DEE_B454_FC9B6D5804FF__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
//#pragma  comment(lib ,"toydll.lib")

extern HANDLE FindHandle(int ppVID,int ppPID);
extern bool ReadData(HANDLE m_HidHandle,LPVOID lpBuffer);
extern bool WriteData(HANDLE m_HidHandle,LPVOID lpBuffer);
extern bool CheckHandle(HANDLE m_HidHandle);


class IoConS
{
public:
	bool DevInfo;
	IoConS();
	virtual ~IoConS();

	bool FindDevice(int	usbvid,int usbpid);
	bool CheckDevice();
    bool Output(LPVOID IoData);
    bool InputData(LPVOID lpBuffer);
protected:
	
	char IoDataSave;
	HANDLE m_HidHandle;
};


#endif // !defined(AFX_IOCONS_H__7E0E8B9D_0C4E_4DEE_B454_FC9B6D5804FF__INCLUDED_)
