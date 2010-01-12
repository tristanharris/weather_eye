// IoConS.cpp: implementation of the IoConS class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "IoConS.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

IoConS::IoConS()
{
	DevInfo=false;
	IoDataSave=0;
	m_HidHandle=INVALID_HANDLE_VALUE;
}

IoConS::~IoConS()
{

}

bool IoConS::Output(LPVOID IoData)
{
	if(m_HidHandle==INVALID_HANDLE_VALUE)
		{
		return false;
		}

	if(WriteData(m_HidHandle,IoData)==false)
		{
		return false;
		}
	return true;
}



bool IoConS::InputData(LPVOID lpBuffer)
{

	if(ReadData(m_HidHandle,lpBuffer)==false)
		{
		return	false;
		}
	return	true;	
}


bool IoConS::FindDevice(int	usbvid,int usbpid)
{
	m_HidHandle = FindHandle(usbvid,usbpid);
	if(m_HidHandle==INVALID_HANDLE_VALUE)
		return	false;
	else
		return	true;
}

bool IoConS::CheckDevice()
{
	if(CheckHandle(m_HidHandle)==false)
		{
		m_HidHandle = INVALID_HANDLE_VALUE;
		return	false;
		}
	else
		{
		return	true;
		}
}