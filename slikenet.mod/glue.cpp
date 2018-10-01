/*
  Copyright (c) 2007-2018 Bruce A Henderson
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/ 
#include "glue.h"

extern "C" {
	int bmx_slk_convertToAFFamily(int family) {
		switch (family) {
			case 2:
				return AF_INET;
			case 10:
				return AF_INET6;
		}
		
		// unmapped
		return family;
	}
	
	int bmx_slk_convertFromAFFamily(int family) {
		switch (family) {
			case AF_INET:
				return 2;
			case AF_INET6:
				return 10;
		}
		
		// unmapped
		return family;
	}
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MaxSystemAddress::MaxSystemAddress()
{
}

MaxSystemAddress::MaxSystemAddress(const SLNet::SystemAddress & a)
	: systemAddress(a)
{
}

MaxSystemAddress::~MaxSystemAddress() {
}

SLNet::SystemAddress & MaxSystemAddress::Address() {
	return systemAddress;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MaxSocketDescriptor::MaxSocketDescriptor(const SLNet::SocketDescriptor d)
	: descriptor(d)
{
}

MaxSocketDescriptor::MaxSocketDescriptor(unsigned short port, const char *hostAddress)
	: descriptor(port, strdup(hostAddress))
{
	
}

MaxSocketDescriptor::~MaxSocketDescriptor() {
}

SLNet::SocketDescriptor & MaxSocketDescriptor::Descriptor() {
	return descriptor;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SLNet::RakPeerInterface * bmx_slk_RakPeerInterface_GetInstance() {
	return SLNet::RakPeerInterface::GetInstance();
}

void bmx_slk_RakPeerInterface_DestroyInstance(SLNet::RakPeerInterface * peer) {
	SLNet::RakPeerInterface::DestroyInstance(peer);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int bmx_slk_RakPeer_Startup(SLNet::RakPeerInterface * peer, int maxConnections, BBArray * descriptors, int threadPriority) {
	if (descriptors != &bbEmptyArray) {
		int n = descriptors->scales[0];
		MaxSocketDescriptor **d=(MaxSocketDescriptor**)BBARRAYDATA( descriptors, descriptors->dims );
		
		SLNet::SocketDescriptor socketDesc[128];
		for (int i = 0; i < n; i++) {
			socketDesc[i] = d[i]->Descriptor();
		}

		return static_cast<int>(peer->Startup(maxConnections, socketDesc, n, threadPriority));
	} else {
		return static_cast<int>(peer->Startup(maxConnections, 0, 0, threadPriority));
	}
}

void bmx_slk_RakPeer_PingHost(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, bool onlyReplyOnAcceptingConnections, int connectionSocketIndex) {
	char * p = bbStringToUTF8String(host);
	peer->Ping(p, remotePort, static_cast<bool>(onlyReplyOnAcceptingConnections), static_cast<unsigned>(connectionSocketIndex));
	bbMemFree(p);
}

SLNet::Packet * bmx_slk_RakPeer_Receive(SLNet::RakPeerInterface * peer) {
	return peer->Receive();
}

void bmx_slk_RakPeer_DeallocatePacket(SLNet::RakPeerInterface * peer, SLNet::Packet * packet) {
	peer->DeallocatePacket(packet);
}

int bmx_slk_RakPeer_InitializeSecurity(SLNet::RakPeerInterface * peer, char * publicKey, char * privateKey, int requireClientKey) {
	return static_cast<int>(peer->InitializeSecurity(publicKey, privateKey, static_cast<bool>(requireClientKey)));
}

void bmx_slk_RakPeer_DisableSecurity(SLNet::RakPeerInterface * peer) {
	peer->DisableSecurity();
}

void bmx_slk_RakPeer_AddToSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	peer->AddToSecurityExceptionList(p);
	bbMemFree(p);
}

void bmx_slk_RakPeer_RemoveFromSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	peer->RemoveFromSecurityExceptionList(p);
	bbMemFree(p);
}

int bmx_slk_RakPeer_IsInSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	bool res = peer->IsInSecurityExceptionList(p);
	bbMemFree(p);
	return static_cast<int>(res);
}

void bmx_slk_RakPeer_SetMaximumIncomingConnections(SLNet::RakPeerInterface * peer, int numberAllowed) {
	peer->SetMaximumIncomingConnections(numberAllowed);
}

int bmx_slk_RakPeer_GetMaximumIncomingConnections(SLNet::RakPeerInterface * peer) {
	return peer->GetMaximumIncomingConnections();
}

int bmx_slk_RakPeer_Connect(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, BBString * passwordData, SLNet::PublicKey * publicKey, int connectionSocketIndex, int sendConnectionAttemptCount, int timeBetweenSendConnectionAttemptsMS, int timeoutTime) {
	char * h = bbStringToUTF8String(host);
	char * p = 0;
	int n = 0;
	if (passwordData != &bbEmptyString) {
		p = bbStringToUTF8String(passwordData);
		n = strlen(p);
	}
	SLNet::ConnectionAttemptResult res = peer->Connect(h, static_cast<unsigned short>(remotePort), p, n, publicKey, connectionSocketIndex, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime);
	bbMemFree(p);
	return static_cast<int>(res);
}

int bmx_slk_RakPeer_ConnectWithSocket(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, BBString * passwordData, SLNet::RakNetSocket2 * socket, SLNet::PublicKey * publicKey, int sendConnectionAttemptCount, int timeBetweenSendConnectionAttemptsMS, int timeoutTime) {
	char * h = bbStringToUTF8String(host);
	char * p = 0;
	int n = 0;
	if (passwordData != &bbEmptyString) {
		p = bbStringToUTF8String(passwordData);
		n = strlen(p);
	}
	SLNet::ConnectionAttemptResult res = peer->ConnectWithSocket(h, static_cast<unsigned short>(remotePort), p, n, socket, publicKey, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime);
	bbMemFree(p);
	return static_cast<int>(res);
}

int bmx_slk_RakPeer_NumberOfConnections(SLNet::RakPeerInterface * peer) {
	return static_cast<int>(peer->NumberOfConnections());
}

void bmx_slk_RakPeer_SetIncomingPassword(SLNet::RakPeerInterface * peer, BBString * passwordData) {
	char * p = 0;
	int n = 0;
	if (passwordData != &bbEmptyString) {
		p = bbStringToUTF8String(passwordData);
		n = strlen(p);
	}
	peer->SetIncomingPassword(p, n);
	bbMemFree(p);
}

BBString * bmx_slk_RakPeer_GetIncomingPassword(SLNet::RakPeerInterface * peer) {
	char p[1024];
	int length = 1024;
	peer->GetIncomingPassword(p, &length);
	if (length > 0) {
		return bbStringFromUTF8String(p);
	}
	return &bbEmptyString;
}

void bmx_slk_RakPeer_Shutdown(SLNet::RakPeerInterface * peer, int blockDuration, int orderingChannel, int disconnectionNotificationPriority) {
	peer->Shutdown(blockDuration, static_cast<unsigned char>(orderingChannel), static_cast<PacketPriority>(disconnectionNotificationPriority));
}

int bmx_slk_RakPeer_IsActive(SLNet::RakPeerInterface * peer) {
	return static_cast<int>(peer->IsActive());
}

int bmx_slk_RakPeer_GetNextSendReceipt(SLNet::RakPeerInterface * peer) {
	return peer->GetNextSendReceipt();
}

int bmx_slk_RakPeer_IncrementNextSendReceipt(SLNet::RakPeerInterface * peer) {
	return peer->IncrementNextSendReceipt();
}

int bmx_slk_RakPeer_GetMaximumNumberOfPeers(SLNet::RakPeerInterface * peer) {
	return peer->GetMaximumNumberOfPeers();
}

MaxSystemAddress * bmx_slk_RakPeer_GetSystemAddressFromIndex(SLNet::RakPeerInterface * peer, int index) {
	return new MaxSystemAddress(peer->GetSystemAddressFromIndex(index));
}

void bmx_slk_RakPeer_CloseConnection(SLNet::RakPeerInterface * peer, MaxSystemAddress * target, int sendDisconnectionNotification, int orderingChannel) {
	peer->CloseConnection(target->Address(), static_cast<bool>(sendDisconnectionNotification), static_cast<unsigned char>(orderingChannel));
}

int bmx_slk_RakPeer_GetConnectionState(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return static_cast<int>(peer->GetConnectionState(addr->Address()));
}

int bmx_slk_RakPeer_GetIndexFromSystemAddress(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return peer->GetIndexFromSystemAddress(addr->Address());
}

void bmx_slk_RakPeer_AddToBanList(SLNet::RakPeerInterface * peer, BBString * ip, int milliseconds) {
	char * p = bbStringToUTF8String(ip);
	peer->AddToBanList(p, milliseconds);
	bbMemFree(p);
}

void bmx_slk_RakPeer_RemoveFromBanList(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	peer->RemoveFromBanList(p);
	bbMemFree(p);
}

void bmx_slk_RakPeer_ClearBanList(SLNet::RakPeerInterface * peer) {
	peer->ClearBanList();
}

int bmx_slk_RakPeer_IsBanned(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	bool res = peer->IsBanned(p);
	bbMemFree(p);
	return static_cast<int>(res);
}

void bmx_slk_RakPeer_Ping(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	peer->Ping(addr->Address());
}

int bmx_slk_RakPeer_GetAveragePing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return peer->GetAveragePing(addr->Address());
}

int bmx_slk_RakPeer_GetLastPing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return peer->GetLastPing(addr->Address());
}

int bmx_slk_RakPeer_GetLowestPing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return peer->GetLowestPing(addr->Address());
}

void bmx_slk_RakPeer_SetOccasionalPing(SLNet::RakPeerInterface * peer, int doPing) {
	peer->SetOccasionalPing(static_cast<bool>(doPing));
}

void bmx_slk_RakPeer_SetOfflinePingResponse(SLNet::RakPeerInterface * peer, char * data, int length) {
	peer->SetOfflinePingResponse(data, length);
}

BBArray * bmx_slk_RakPeer_GetOfflinePingResponse(SLNet::RakPeerInterface * peer) {
	char data[2048];
	unsigned int n = 2048;
	char * d = data;
	peer->GetOfflinePingResponse(&d, &n);
	if (n > 0) {
		BBArray * arr = bbArrayNew1D("b", n);
		void ** p = (void**)(BBARRAYDATA( arr,arr->dims ));
		memcpy(p, data, n);
	}
	return &bbEmptyArray;
}

void bmx_slk_RakPeer_SetTimeoutTime(SLNet::RakPeerInterface * peer, int timeMS, MaxSystemAddress * target) {
	peer->SetTimeoutTime(timeMS, target->Address());
}

int bmx_slk_RakPeer_GetMTUSize(SLNet::RakPeerInterface * peer, MaxSystemAddress * target) {
	return peer->GetMTUSize(target->Address());
}

int bmx_slk_RakPeer_GetNumberOfAddresses(SLNet::RakPeerInterface * peer) {
	return peer->GetNumberOfAddresses();
}

BBString * bmx_slk_RakPeer_GetLocalIP(SLNet::RakPeerInterface * peer, int index) {
	return bbStringFromCString(peer->GetLocalIP(index));
}

int bmx_slk_RakPeer_IsLocalIP(SLNet::RakPeerInterface * peer, BBString * ip) {
	char * p = bbStringToUTF8String(ip);
	bool res = peer->IsLocalIP(p);
	bbMemFree(p);
	return static_cast<int>(res);
}

void bmx_slk_RakPeer_AllowConnectionResponseIPMigration(SLNet::RakPeerInterface * peer, int allow) {
	peer->AllowConnectionResponseIPMigration(static_cast<bool>(allow));
}

void bmx_slk_RakPeer_SetSplitMessageProgressInterval(SLNet::RakPeerInterface * peer, int interval) {
	peer->SetSplitMessageProgressInterval(interval);
}

void bmx_slk_RakPeer_SetUnreliableTimeout(SLNet::RakPeerInterface * peer, int timeoutMS) {
	peer->SetUnreliableTimeout(timeoutMS);
}

int bmx_slk_RakPeer_SendBitStream(SLNet::RakPeerInterface * peer, SLNet::BitStream * bitStream, int priority, int reliability, int orderingChannel, MaxSystemAddress * systemIdentifier, int broadcast, int forceReceiptNumber) {
	return peer->Send(bitStream, static_cast<PacketPriority>(priority), 
		static_cast<PacketReliability>(reliability), static_cast<char>(orderingChannel), systemIdentifier->Address(), 
		static_cast<bool>(broadcast), forceReceiptNumber);
}

int bmx_slk_RakPeer_Send(SLNet::RakPeerInterface * peer, char * data, int length, int priority, int reliability, int orderingChannel, MaxSystemAddress * systemIdentifier, int broadcast, int forceReceiptNumber) {
	return peer->Send(data, length, static_cast<PacketPriority>(priority), 
		static_cast<PacketReliability>(reliability), static_cast<char>(orderingChannel), systemIdentifier->Address(), 
		static_cast<bool>(broadcast), forceReceiptNumber);
}

SLNet::RakNetGUID * bmx_slk_RakPeer_GetGuidFromSystemAddress(SLNet::RakPeerInterface * peer, MaxSystemAddress * systemAddress) {
	return new SLNet::RakNetGUID(peer->GetGuidFromSystemAddress(systemAddress->Address()));
}

SLNet::RakNetStatistics * bmx_slk_RakPeer_GetStatistics(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr) {
	return peer->GetStatistics(addr->Address());
}

BBArray * bmx_slk_RakPeer_GetSockets(SLNet::RakPeerInterface * peer) {
	DataStructures::List< SLNet::RakNetSocket2* > sockets;
	peer->GetSockets(sockets);
	int n = sockets.Size();
	BBArray * arr = slk_slikenet_TSlkRakNetSocket__array(n);
	for (int i = 0; i < n; i++) {
		slk_slikenet_TSlkRakNetSocket__insert(arr, i, sockets[i]);
	}
	return arr;
}

MaxSystemAddress * bmx_slk_RakPeer_GetInternalID(SLNet::RakPeerInterface * peer, MaxSystemAddress * systemAddress, int index) {
	return new MaxSystemAddress(peer->GetInternalID(systemAddress->Address(), index));
}

int bmx_slk_RakPeer_GetConnectionList(SLNet::RakPeerInterface * peer, BBArray * remoteSystems, int * connections) {
	bool res = 0;
	unsigned short n = 0;
	if (remoteSystems != &bbEmptyArray) {
		n = static_cast<unsigned short>(remoteSystems->scales[0]);
		
		SLNet::SystemAddress addresses[128];

		res = peer->GetConnectionList((SLNet::SystemAddress*)&addresses, &n);
		
		BBObject  ** sa = (BBObject**)BBARRAYDATA( remoteSystems, remoteSystems->dims );
		for (int i = 0; i < n; i++) {
			sa[i] = slk_slikenet_TSlkSystemAddress__create(new MaxSystemAddress(addresses[i]));
		}
		
	} else {
		res = peer->GetConnectionList(0, &n);
	}
	
	*connections = n;

	return static_cast<int>(res);
}

void bmx_slk_RakPeer_AttachPlugin(SLNet::RakPeerInterface * peer, SLNet::PluginInterface2 * plugin) {
	peer->AttachPlugin(plugin);
}

void bmx_slk_RakPeer_DetachPlugin(SLNet::RakPeerInterface * peer, SLNet::PluginInterface2 * plugin) {
	peer->DetachPlugin(plugin);
}

SLNet::RakNetGUID * bmx_slk_RakPeer_GetMyGUID(SLNet::RakPeerInterface * peer) {
	return new SLNet::RakNetGUID(peer->GetMyGUID());
}

MaxSystemAddress * bmx_slk_RakPeer_GetSystemAddressFromGuid(SLNet::RakPeerInterface * peer, SLNet::RakNetGUID * guid) {
	return new MaxSystemAddress(peer->GetSystemAddressFromGuid(*guid));
}

void bmx_slk_RakPeer_SetPerConnectionOutgoingBandwidthLimit(SLNet::RakPeerInterface * peer, int maxBitsPerSecond) {
	peer->SetPerConnectionOutgoingBandwidthLimit(maxBitsPerSecond);
}

int bmx_slk_RakPeer_AdvertiseSystem(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, const char * data, int dataLength, int connectionSocketIndex) {
	char * p = bbStringToUTF8String(host);
	bool res = peer->AdvertiseSystem(p, static_cast<unsigned short>(remotePort), data, dataLength, static_cast<unsigned>(connectionSocketIndex));
	bbMemFree(p);
	return static_cast<int>(res);
}

void bmx_slk_RakPeer_SendTTL(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, int ttl, int connectionSocketIndex) {
	char * p = bbStringToUTF8String(host);
	peer->SendTTL(p, static_cast<unsigned short>(remotePort), ttl, static_cast<unsigned>(connectionSocketIndex));
	bbMemFree(p);
}

void bmx_slk_RakPeer_PushBackPacket(SLNet::RakPeerInterface * peer, SLNet::Packet * packet, int pushAtHead) {
	peer->PushBackPacket(packet, static_cast<bool>(pushAtHead));
}

SLNet::Packet * bmx_slk_RakPeer_AllocatePacket(SLNet::RakPeerInterface * peer, int dataSize) {
	return peer->AllocatePacket(static_cast<unsigned>(dataSize));
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SLNet::BitStream * bmx_slk_BitStream_Create() {
	return new SLNet::BitStream();
}

SLNet::BitStream * bmx_slk_BitStream_CreateFromData(unsigned char * data, unsigned int size, int copy) {
	return new SLNet::BitStream(data, size, static_cast<bool>(copy));
}

void bmx_slk_BitStream_Delete(SLNet::BitStream * stream) {
	delete stream;
}

void bmx_slk_BitStream_Reset(SLNet::BitStream * stream) {
	stream->Reset();
}

int bmx_slk_BitStream_SerializeByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeShort(SLNet::BitStream * stream, int writeToBitstream, short * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeInt(SLNet::BitStream * stream, int writeToBitstream, int * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeFloat(SLNet::BitStream * stream, int writeToBitstream, float * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDouble(SLNet::BitStream * stream, int writeToBitstream, double * value) {
	return static_cast<int>(stream->Serialize(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaLastByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue, unsigned char lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue, short lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue, int lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue, unsigned short lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue, unsigned int lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue, float lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaLastDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue, double lastValue) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeDeltaByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaShort(SLNet::BitStream * stream, int writeToBitstream, short * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaInt(SLNet::BitStream * stream, int writeToBitstream, int * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaFloat(SLNet::BitStream * stream, int writeToBitstream, float * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeDeltaDouble(SLNet::BitStream * stream, int writeToBitstream, double * value) {
	return static_cast<int>(stream->SerializeDelta(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedShort(SLNet::BitStream * stream, int writeToBitstream, short * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedInt(SLNet::BitStream * stream, int writeToBitstream, int * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedFloat(SLNet::BitStream * stream, int writeToBitstream, float * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedDouble(SLNet::BitStream * stream, int writeToBitstream, double * value) {
	return static_cast<int>(stream->SerializeCompressed(static_cast<bool>(writeToBitstream), value));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue, unsigned char lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue, short lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue, int lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue, unsigned short lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue, unsigned int lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue, float lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaLastDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue, double lastValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), *currentValue, lastValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_SerializeCompressedDeltaDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue) {
	return static_cast<int>(stream->SerializeCompressedDelta(static_cast<bool>(writeToBitstream), currentValue));
}

int bmx_slk_BitStream_ReadByte(SLNet::BitStream * stream, unsigned char * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadShort(SLNet::BitStream * stream, short * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadInt(SLNet::BitStream * stream, int * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadUShort(SLNet::BitStream * stream, unsigned short * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadUInt(SLNet::BitStream * stream, unsigned int * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadFloat(SLNet::BitStream * stream, float * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadDouble(SLNet::BitStream * stream, double * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadLong(SLNet::BitStream * stream, BBInt64 * value) {
	return static_cast<int>(stream->Read(*value));
}

int bmx_slk_BitStream_ReadTime(SLNet::BitStream * stream, BBInt64 * value) {
#ifdef __GET_TIME_64BIT
	return static_cast<int>(stream->Read(value));
#else
	RakNetTime time;
	int ret = stream->Read(time);
	*value = static_cast<BBInt64>(time);
	return static_cast<int>(ret));
#endif
}

BBString * bmx_slk_BitStream_ReadString(SLNet::BitStream * stream) {
	//SLNet::RakString s;
	//int ret = stream->Read(s);
	short n;
	bool ret = stream->Read(n);
	char buff[2048];
	stream->Read(buff, n);
	buff[n+1]=0;

	if (!ret || n == 0) {
		return &bbEmptyString;
	} else {
		return bbStringFromUTF8String(buff);
	}
}

BBString * bmx_slk_BitStream_ReadCompressedString(SLNet::BitStream * stream) {
	SLNet::RakString s;
	int ret = stream->ReadCompressed(s);

	if (!ret) {
		return &bbEmptyString;
	} else {
		return bbStringFromUTF8String(s.C_String());
	}
}

int bmx_slk_BitStream_ReadDeltaByte(SLNet::BitStream * stream, unsigned char * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaShort(SLNet::BitStream * stream, short * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaInt(SLNet::BitStream * stream, int * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaUShort(SLNet::BitStream * stream, unsigned short * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaUInt(SLNet::BitStream * stream, unsigned int * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaFloat(SLNet::BitStream * stream, float * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadDeltaDouble(SLNet::BitStream * stream, double * value) {
	return static_cast<int>(stream->ReadDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedByte(SLNet::BitStream * stream, unsigned char * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedShort(SLNet::BitStream * stream, short * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedInt(SLNet::BitStream * stream, int * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedUShort(SLNet::BitStream * stream, unsigned short * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedUInt(SLNet::BitStream * stream, unsigned int * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedFloat(SLNet::BitStream * stream, float * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedDouble(SLNet::BitStream * stream, double * value) {
	return static_cast<int>(stream->ReadCompressed(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaByte(SLNet::BitStream * stream, unsigned char * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaShort(SLNet::BitStream * stream, short * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaInt(SLNet::BitStream * stream, int * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaUShort(SLNet::BitStream * stream, unsigned short * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaUInt(SLNet::BitStream * stream, unsigned int * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaFloat(SLNet::BitStream * stream, float * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadCompressedDeltaDouble(SLNet::BitStream * stream, double * value) {
	return static_cast<int>(stream->ReadCompressedDelta(*value));
}

int bmx_slk_BitStream_ReadBit(SLNet::BitStream * stream) {
	return static_cast<int>(stream->ReadBit());
}

int bmx_slk_BitStream_ReadDeltaBool(SLNet::BitStream * stream, int * value) {
	bool v;
	bool * pv = &v;
	int res = stream->ReadDelta(pv);
	*value = static_cast<int>(v);
	return static_cast<int>(res);
}

int bmx_slk_BitStream_ReadCompressedBool(SLNet::BitStream * stream, int * value) {
	bool v;
	bool * pv = &v;
	int res = stream->ReadCompressed(pv);
	*value = static_cast<int>(v);
	return static_cast<int>(res);
}

int bmx_slk_BitStream_ReadCompressedDeltaBool(SLNet::BitStream * stream, int * value) {
	bool v;
	bool * pv = &v;
	int res = stream->ReadCompressedDelta(pv);
	*value = static_cast<int>(v);
	return static_cast<int>(res);
}

void bmx_slk_BitStream_WriteByte(SLNet::BitStream * stream, unsigned char * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteShort(SLNet::BitStream * stream, short * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteInt(SLNet::BitStream * stream, int * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteFloat(SLNet::BitStream * stream, float * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteDouble(SLNet::BitStream * stream, double * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteLong(SLNet::BitStream * stream, BBInt64 * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteTime(SLNet::BitStream * stream, BBInt64 * value) {
#ifdef __GET_TIME_64BIT
	stream->Write(*value);
#else
	stream->Write(static_cast<RakNetTime>(*value));
#endif
}

void bmx_slk_BitStream_Write0(SLNet::BitStream * stream) {
	stream->Write0();
}

void bmx_slk_BitStream_Write1(SLNet::BitStream * stream) {
	stream->Write1();
}
	
void bmx_slk_BitStream_WriteUShort(SLNet::BitStream * stream, unsigned short * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteUInt(SLNet::BitStream * stream, unsigned int * value) {
	stream->Write(*value);
}

void bmx_slk_BitStream_WriteString(SLNet::BitStream * stream, BBString * value) {
	char * v = bbStringToUTF8String(value);
	int n = strlen(v);
	stream->Write(static_cast<short>(n));
	stream->Write(v, n);
	//stream->Write(SLNet::RakString::NonVariadic(v));
	bbMemFree(v);
}


void bmx_slk_BitStream_AssertStreamEmpty(SLNet::BitStream * stream) {
	stream->AssertStreamEmpty();
}

void bmx_slk_BitStream_IgnoreBits(SLNet::BitStream * stream, int numberOfBits) {
	stream->IgnoreBits(numberOfBits);
}

void bmx_slk_BitStream_IgnoreBytes(SLNet::BitStream * stream, int numberOfBytes) {
	stream->IgnoreBytes(numberOfBytes);
}

void bmx_slk_BitStream_SetWriteOffset(SLNet::BitStream * stream, int offset) {
	stream->SetWriteOffset(offset);
}

int bmx_slk_BitStream_GetNumberOfBitsUsed(SLNet::BitStream * stream) {
	return static_cast<int>(stream->GetNumberOfBitsUsed());
}

int bmx_slk_BitStream_GetWriteOffset(SLNet::BitStream * stream) {
	return static_cast<int>(stream->GetWriteOffset());
}

int bmx_slk_BitStream_GetNumberOfBytesUsed(SLNet::BitStream * stream) {
	return static_cast<int>(stream->GetNumberOfBytesUsed());
}

int bmx_slk_BitStream_GetReadOffset(SLNet::BitStream * stream) {
	return static_cast<int>(stream->GetReadOffset());
}

void bmx_slk_BitStream_SetReadOffset(SLNet::BitStream * stream, int offset) {
	stream->SetReadOffset(static_cast<uint32_t>(offset));
}

int bmx_slk_BitStream_GetNumberOfUnreadBits(SLNet::BitStream * stream) {
	return static_cast<int>(stream->GetNumberOfUnreadBits());
}

void bmx_slk_BitStream_WriteBits(SLNet::BitStream * stream, const unsigned char * data, int numberOfBitsToWrite, int rightAlignedBits) {
	stream->WriteBits(data, static_cast<int>(numberOfBitsToWrite), static_cast<int>(rightAlignedBits));
}

void bmx_slk_BitStream_WriteCompressedByte(SLNet::BitStream * stream, char * b) {
	stream->WriteCompressed(*b);
}

void bmx_slk_BitStream_WriteCompressedShort(SLNet::BitStream * stream, short * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedUShort(SLNet::BitStream * stream, short * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedInt(SLNet::BitStream * stream, int * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedUInt(SLNet::BitStream * stream, int * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedFloat(SLNet::BitStream * stream, float * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedDouble(SLNet::BitStream * stream, double * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteCompressedLong(SLNet::BitStream * stream, BBInt64 * value) {
	stream->WriteCompressed(*value);
}

void bmx_slk_BitStream_WriteDeltaByte(SLNet::BitStream * stream, char * b, char lastValue) {
	stream->WriteDelta(*b, lastValue);
}

void bmx_slk_BitStream_WriteDeltaShort(SLNet::BitStream * stream, short * currentValue, short lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaUShort(SLNet::BitStream * stream, short * currentValue, short lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaInt(SLNet::BitStream * stream, int * currentValue, int lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaUInt(SLNet::BitStream * stream, int * currentValue, int lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaFloat(SLNet::BitStream * stream, float * currentValue, float lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaDouble(SLNet::BitStream * stream, double * currentValue, double lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteDeltaLong(SLNet::BitStream * stream, BBInt64 * currentValue, BBInt64 lastValue) {
	stream->WriteDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaByte(SLNet::BitStream * stream, char * b, char lastValue) {
	stream->WriteCompressedDelta(*b, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaShort(SLNet::BitStream * stream, short * currentValue, short lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaUShort(SLNet::BitStream * stream, short * currentValue, short lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaInt(SLNet::BitStream * stream, int * currentValue, int lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaUInt(SLNet::BitStream * stream, int * currentValue, int lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaFloat(SLNet::BitStream * stream, float * currentValue, float lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaDouble(SLNet::BitStream * stream, double * currentValue, double lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedDeltaLong(SLNet::BitStream * stream, BBInt64 * currentValue, BBInt64 lastValue) {
	stream->WriteCompressedDelta(*currentValue, lastValue);
}

void bmx_slk_BitStream_WriteCompressedString(SLNet::BitStream * stream, BBString * value) {
	char * v = bbStringToUTF8String(value);
	stream->WriteCompressed(SLNet::RakString::NonVariadic(v));
	bbMemFree(v);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MaxSocketDescriptor * bmx_slk_SocketDescriptor_new(int port, BBString * hostAddress) {
	char * s = 0;
	if (hostAddress != &bbEmptyString) {
		s = bbStringToUTF8String(hostAddress);
	}
	MaxSocketDescriptor * descriptor = new MaxSocketDescriptor(static_cast<unsigned short>(port), s);
	if (s) bbMemFree(s);
	return descriptor;
}

void bmx_slk_SocketDescriptor_delete(MaxSocketDescriptor * descriptor) {
	delete descriptor;
}

void bmx_slk_SocketDescriptor_setport(MaxSocketDescriptor * desc, int port) {
	desc->Descriptor().port = static_cast<unsigned short>(port);
}

int bmx_slk_SocketDescriptor_getport(MaxSocketDescriptor * desc) {
	return static_cast<int>(desc->Descriptor().port);
}

void bmx_slk_SocketDescriptor_sethostaddress(MaxSocketDescriptor * desc, BBString * hostAddress) {
	char * a = 0;
	if (hostAddress != &bbEmptyString) {
		a = bbStringToUTF8String(hostAddress);
	}

	if (a) {
		strcpy(desc->Descriptor().hostAddress, a);
		bbMemFree(a);
	} else {
		desc->Descriptor().hostAddress[0] = 0;
	}
	
}

BBString * bmx_slk_SocketDescriptor_gethostaddress(MaxSocketDescriptor * desc) {
	return bbStringFromCString(desc->Descriptor().hostAddress);
}

void bmx_slk_SocketDescriptor_setsocketfamily(MaxSocketDescriptor * desc, int family) {
	desc->Descriptor().socketFamily = static_cast<short>(bmx_slk_convertToAFFamily(family));
}

int bmx_slk_SocketDescriptor_getsocketfamily(MaxSocketDescriptor * desc) {
	return bmx_slk_convertToAFFamily(static_cast<int>(desc->Descriptor().socketFamily));
}

void bmx_slk_SocketDescriptor_setblockingsocket(MaxSocketDescriptor * desc, int blocking) {
	desc->Descriptor().blockingSocket = static_cast<bool>(blocking);
}

int bmx_slk_SocketDescriptor_getblockingsocket(MaxSocketDescriptor * desc) {
	return static_cast<int>(desc->Descriptor().blockingSocket);
}

void bmx_slk_SocketDescriptor_setextrasocketoptions(MaxSocketDescriptor * desc, int options) {
	desc->Descriptor().extraSocketOptions = options;
}

int bmx_slk_SocketDescriptor_getextrasocketoptions(MaxSocketDescriptor * desc) {
	return desc->Descriptor().extraSocketOptions;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void bmx_slk_net_seedMT(unsigned int seed) {
	seedMT(seed);
}

unsigned int bmx_slk_net_randomMT() {
	return randomMT();
}

float bmx_slk_net_frandomMT() {
	return frandomMT();
}

void bmx_slk_net_fillBufferMT(void * buffer, unsigned int size) {
	fillBufferMT(buffer, size);
}

int bmx_slk_net_gettimems() {
	return SLNet::GetTimeMS();
}

void bmx_slk_net_gettimens(BBInt64 * v) {
	*v = SLNet::GetTimeUS();
}

int bmx_slk_net_getversion() {
	return RAKNET_VERSION_NUMBER * 1000;
}

BBString * bmx_slk_net_getversionstring() {
	return bbStringFromCString(RAKNET_VERSION);
}

int bmx_slk_net_getprotocolversion() {
	return RAKNET_PROTOCOL_VERSION;
}

BBString * bmx_slk_net_getdate() {
	return bbStringFromCString(RAKNET_DATE);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_slk_RakNetStatistics_ToStringLevel(SLNet::RakNetStatistics * stats, int verbosityLevel) {
	char buffer[4096];
	SLNet::StatisticsToString(stats, buffer, verbosityLevel);
	return bbStringFromCString(buffer);
}

void bmx_slk_RakNetStatistics_valueOverLastSecond(SLNet::RakNetStatistics * stats, int perSecondMetrics, BBInt64 * v) {
	uint64_t res = stats->valueOverLastSecond[static_cast<SLNet::RNSPerSecondMetrics>(perSecondMetrics)];
	*v = res;
}

void bmx_slk_RakNetStatistics_runningTotal(SLNet::RakNetStatistics * stats, int perSecondMetrics, BBInt64 * v) {
	uint64_t res = stats->runningTotal[static_cast<SLNet::RNSPerSecondMetrics>(perSecondMetrics)];
	*v = res;
}

void bmx_slk_RakNetStatistics_connectionStartTime(SLNet::RakNetStatistics * stats, BBInt64 * v) {
	SLNet::TimeUS res = stats->connectionStartTime;
	*v = res;
}

int bmx_slk_RakNetStatistics_isLimitedByCongestionControl(SLNet::RakNetStatistics * stats) {
	return static_cast<int>(stats->isLimitedByCongestionControl);
}

void bmx_slk_RakNetStatistics_BPSLimitByCongestionControl(SLNet::RakNetStatistics * stats, BBInt64 * v) {
	uint64_t res = stats->BPSLimitByCongestionControl;
	*v = res;
}

int bmx_slk_RakNetStatistics_isLimitedByOutgoingBandwidthLimit(SLNet::RakNetStatistics * stats) {
	return static_cast<int>(stats->isLimitedByOutgoingBandwidthLimit);
}

void bmx_slk_RakNetStatistics_BPSLimitByOutgoingBandwidthLimit(SLNet::RakNetStatistics * stats, BBInt64 * v) {
	uint64_t res = stats->BPSLimitByOutgoingBandwidthLimit;
	*v = res;
}

int bmx_slk_RakNetStatistics_messageInSendBuffer(SLNet::RakNetStatistics * stats, int priority) {
	return stats->messageInSendBuffer[static_cast<PacketPriority>(priority)];
}

double bmx_slk_RakNetStatistics_bytesInSendBuffer(SLNet::RakNetStatistics * stats, int priority) {
	stats->bytesInSendBuffer[static_cast<PacketPriority>(priority)];
}

int bmx_slk_RakNetStatistics_messagesInResendBuffer(SLNet::RakNetStatistics * stats) {
	return stats->messagesInResendBuffer;
}

void bmx_slk_RakNetStatistics_BytesInResendBuffer(SLNet::RakNetStatistics * stats, BBInt64 * v) {
	uint64_t res = stats->bytesInResendBuffer;
	*v = res;
}

float bmx_slk_RakNetStatistics_packetlossLastSecond(SLNet::RakNetStatistics * stats) {
	return stats->packetlossLastSecond;
}

float bmx_slk_RakNetStatistics_packetlossTotal(SLNet::RakNetStatistics * stats) {
	return stats->packetlossTotal;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void bmx_slk_SystemAddress_delete(MaxSystemAddress * address) {
	delete address;
}

MaxSystemAddress * bmx_slk_SystemAddress_unassigned() {
	return new MaxSystemAddress(SLNet::UNASSIGNED_SYSTEM_ADDRESS);
}

int bmx_slk_SystemAddress_Equals(MaxSystemAddress * address, MaxSystemAddress * other) {
	return static_cast<int>(address->Address() == other->Address());
}

BBString * bmx_slk_SystemAddress_ToString(MaxSystemAddress * address) {
	return bbStringFromCString(address->Address().ToString(false));
}

void * bmx_slk_SystemAddress_GetAddress(MaxSystemAddress * address) {
	return &address->Address().address;
}

int bmx_slk_SystemAddress_GetPort(MaxSystemAddress * address) {
	return static_cast<int>(address->Address().GetPort());
}

MaxSystemAddress * bmx_slk_SystemAddress_create() {
	return new MaxSystemAddress();
}

void bmx_slk_SystemAddress_SetBinaryAddress(MaxSystemAddress * address, BBString * addr) {
	char * p = bbStringToUTF8String(addr);
	address->Address().SetBinaryAddress(p);
	bbMemFree(p);
}

void bmx_slk_SystemAddress_SetPort(MaxSystemAddress * address, int port) {
	address->Address().SetPortHostOrder(static_cast<unsigned short>(port));
}

int bmx_slk_SystemAddress_IsLoopback(MaxSystemAddress * address) {
	return static_cast<int>(address->Address().IsLoopback());
}

int bmx_slk_SystemAddress_IsLANAddress(MaxSystemAddress * address) {
	return static_cast<int>(address->Address().IsLANAddress());
}

int bmx_slk_SystemAddress_GetPortNetworkOrder(MaxSystemAddress * address) {
	return static_cast<int>(address->Address().GetPortNetworkOrder());
}

void bmx_slk_SystemAddress_SetPortHostOrder(MaxSystemAddress * address, int s) {
	address->Address().SetPortHostOrder(static_cast<unsigned short>(s));
}

void bmx_slk_SystemAddress_SetPortNetworkOrder(MaxSystemAddress * address, int s) {
	address->Address().SetPortNetworkOrder(static_cast<unsigned short>(s));
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

unsigned char * bmx_slk_Packet_GetData(SLNet::Packet * packet) {
	return packet->data;
}

unsigned int bmx_slk_Packet_GetBitSize(SLNet::Packet * packet) {
	return packet->bitSize;
}

MaxSystemAddress * bmx_slk_Packet_GetSystemAddress(SLNet::Packet * packet) {
	return new MaxSystemAddress(packet->systemAddress);
}

int bmx_slk_Packet_GetPacketIdentifier(SLNet::Packet * packet) {
	unsigned char id = 255;

	if ((unsigned char)packet->data[0] == ID_TIMESTAMP)
	{
		assert(packet->length > sizeof(unsigned char) + sizeof(SLNet::TimeMS));
		id = (unsigned char) packet->data[sizeof(unsigned char) + sizeof(SLNet::TimeMS)];
	}
	else {
		id = (unsigned char) packet->data[0];
	}
	return static_cast<int>(id);

}

SLNet::RakNetGUID * bmx_slk_Packet_GetGuid(SLNet::Packet * packet) {
	return &packet->guid;
}

int bmx_slk_Packet_GetLength(SLNet::Packet * packet) {
	return packet->length;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_slk_RakNetGUID_ToString(SLNet::RakNetGUID * guid) {
	return bbStringFromCString(guid->ToString());
}

void bmx_slk_RakNetGUID_delete(SLNet::RakNetGUID * guid) {
	delete guid;
}

const SLNet::RakNetGUID * bmx_slk_RakNetGUID_unassigned() {
	return &SLNet::UNASSIGNED_RAKNET_GUID;
}

int bmx_slk_RakNetGUID_Equals(SLNet::RakNetGUID * guid, SLNet::RakNetGUID * other) {
	return static_cast<int>(*guid == *other);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SLNet::NetworkIDManager * bmx_slk_NetworkIDManager_create() {
	return new SLNet::NetworkIDManager;
}

void bmk_slk_NetworkIDManager_Clear(SLNet::NetworkIDManager * manager) {
	manager->Clear();
}

SLNet::NetworkIDObject * bmk_slk_NetworkIDManager_GET_BASE_OBJECT_FROM_ID(SLNet::NetworkIDManager * manager, BBInt64 networkID) {
	return manager->GET_BASE_OBJECT_FROM_ID(static_cast<SLNet::NetworkID>(networkID));
}


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int bmx_slk_RakNetSocket_GetSocketType(SLNet::RakNetSocket2 * socket) {
	return static_cast<int>(socket->GetSocketType());
}

int bmx_slk_RakNetSocket_IsBerkleySocket(SLNet::RakNetSocket2 * socket) {
	return static_cast<int>(socket->IsBerkleySocket());
}

MaxSystemAddress * bmx_slk_RakNetSocket_GetBoundAddress(SLNet::RakNetSocket2 * socket) {
	return new MaxSystemAddress(socket->GetBoundAddress());
}

int bmx_slk_RakNetSocket_GetUserConnectionSocketIndex(SLNet::RakNetSocket2 * socket) {
	return static_cast<int>(socket->GetUserConnectionSocketIndex());
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int bmx_slk_MAXIMUM_NUMBER_OF_INTERNAL_IDS() {
	return MAXIMUM_NUMBER_OF_INTERNAL_IDS;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

