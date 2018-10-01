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

#include "slikenet/BitStream.h"
#include "slikenet/peerinterface.h"
#include "slikenet/types.h"
#include "slikenet/version.h"
#include "slikenet/Rand.h"
#include "slikenet/GetTime.h"
#include "slikenet/statistics.h"
#include "slikenet/PacketPriority.h"
#include "slikenet/MessageIdentifiers.h"
#include "slikenet/NetworkIDManager.h"


class MaxSystemAddress;
class MaxSocketDescriptor;

extern "C" {

#include "brl.mod/blitz.mod/blitz.h"

	BBArray * slk_slikenet_TSlkRakNetSocket__array(int);
	void slk_slikenet_TSlkRakNetSocket__insert(BBArray *, int, SLNet::RakNetSocket2 *);
	BBObject * slk_slikenet_TSlkSystemAddress__create(MaxSystemAddress *);

	SLNet::RakPeerInterface * bmx_slk_RakPeerInterface_GetInstance();
	void bmx_slk_RakPeerInterface_DestroyInstance(SLNet::RakPeerInterface * peer);

	int bmx_slk_RakPeer_Startup(SLNet::RakPeerInterface * peer, int maxConnections, BBArray * descriptors, int threadPriority);
	void bmx_slk_RakPeer_PingHost(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, bool onlyReplyOnAcceptingConnections, int connectionSocketIndex);
	SLNet::Packet * bmx_slk_RakPeer_Receive(SLNet::RakPeerInterface * peer);
	void bmx_slk_RakPeer_DeallocatePacket(SLNet::RakPeerInterface * peer, SLNet::Packet * packet);
	int bmx_slk_RakPeer_InitializeSecurity(SLNet::RakPeerInterface * peer, char * publicKey, char * privateKey, int requireClientKey);
	void bmx_slk_RakPeer_DisableSecurity(SLNet::RakPeerInterface * peer);
	void bmx_slk_RakPeer_AddToSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip);
	void bmx_slk_RakPeer_RemoveFromSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip);
	int bmx_slk_RakPeer_IsInSecurityExceptionList(SLNet::RakPeerInterface * peer, BBString * ip);
	void bmx_slk_RakPeer_SetMaximumIncomingConnections(SLNet::RakPeerInterface * peer, int numberAllowed);
	int bmx_slk_RakPeer_GetMaximumIncomingConnections(SLNet::RakPeerInterface * peer);
	int bmx_slk_RakPeer_Connect(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, BBString * passwordData, SLNet::PublicKey * publicKey, int connectionSocketIndex, int sendConnectionAttemptCount, int timeBetweenSendConnectionAttemptsMS, int timeoutTime);
	int bmx_slk_RakPeer_ConnectWithSocket(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, BBString * passwordData, SLNet::RakNetSocket2 * socket, SLNet::PublicKey * publicKey, int sendConnectionAttemptCount, int timeBetweenSendConnectionAttemptsMS, int timeoutTime);
	int bmx_slk_RakPeer_NumberOfConnections(SLNet::RakPeerInterface * peer);
	void bmx_slk_RakPeer_SetIncomingPassword(SLNet::RakPeerInterface * peer, BBString * passwordData);
	BBString * bmx_slk_RakPeer_GetIncomingPassword(SLNet::RakPeerInterface * peer);
	void bmx_slk_RakPeer_Shutdown(SLNet::RakPeerInterface * peer, int blockDuration, int orderingChannel, int disconnectionNotificationPriority);
	int bmx_slk_RakPeer_IsActive(SLNet::RakPeerInterface * peer);
	int bmx_slk_RakPeer_GetNextSendReceipt(SLNet::RakPeerInterface * peer);
	int bmx_slk_RakPeer_IncrementNextSendReceipt(SLNet::RakPeerInterface * peer);
	int bmx_slk_RakPeer_GetMaximumNumberOfPeers(SLNet::RakPeerInterface * peer);
	MaxSystemAddress * bmx_slk_RakPeer_GetSystemAddressFromIndex(SLNet::RakPeerInterface * peer, int index);
	void bmx_slk_RakPeer_CloseConnection(SLNet::RakPeerInterface * peer, MaxSystemAddress * target, int sendDisconnectionNotification, int orderingChannel);
	int bmx_slk_RakPeer_GetConnectionState(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	int bmx_slk_RakPeer_GetIndexFromSystemAddress(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	void bmx_slk_RakPeer_AddToBanList(SLNet::RakPeerInterface * peer, BBString * ip, int milliseconds);
	void bmx_slk_RakPeer_RemoveFromBanList(SLNet::RakPeerInterface * peer, BBString * ip);
	void bmx_slk_RakPeer_ClearBanList(SLNet::RakPeerInterface * peer);
	int bmx_slk_RakPeer_IsBanned(SLNet::RakPeerInterface * peer, BBString * ip);
	void bmx_slk_RakPeer_Ping(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	int bmx_slk_RakPeer_GetAveragePing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	int bmx_slk_RakPeer_GetLastPing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	int bmx_slk_RakPeer_GetLowestPing(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	void bmx_slk_RakPeer_SetOccasionalPing(SLNet::RakPeerInterface * peer, int doPing);
	void bmx_slk_RakPeer_SetOfflinePingResponse(SLNet::RakPeerInterface * peer, char * data, int length);
	BBArray * bmx_slk_RakPeer_GetOfflinePingResponse(SLNet::RakPeerInterface * peer);
	void bmx_slk_RakPeer_SetTimeoutTime(SLNet::RakPeerInterface * peer, int timeMS, MaxSystemAddress * target);
	int bmx_slk_RakPeer_GetMTUSize(SLNet::RakPeerInterface * peer, MaxSystemAddress * target);
	int bmx_slk_RakPeer_GetNumberOfAddresses(SLNet::RakPeerInterface * peer);
	BBString * bmx_slk_RakPeer_GetLocalIP(SLNet::RakPeerInterface * peer, int index);
	int bmx_slk_RakPeer_IsLocalIP(SLNet::RakPeerInterface * peer, BBString * ip);
	void bmx_slk_RakPeer_AllowConnectionResponseIPMigration(SLNet::RakPeerInterface * peer, int allow);
	void bmx_slk_RakPeer_SetSplitMessageProgressInterval(SLNet::RakPeerInterface * peer, int interval);
	void bmx_slk_RakPeer_SetUnreliableTimeout(SLNet::RakPeerInterface * peer, int timeoutMS);
	int bmx_slk_RakPeer_SendBitStream(SLNet::RakPeerInterface * peer, SLNet::BitStream * bitStream, int priority, int reliability, int orderingChannel, MaxSystemAddress * systemIdentifier, int broadcast, int forceReceiptNumber);
	int bmx_slk_RakPeer_Send(SLNet::RakPeerInterface * peer, char * data, int length, int priority, int reliability, int orderingChannel, MaxSystemAddress * systemIdentifier, int broadcast, int forceReceiptNumber);
	SLNet::RakNetGUID * bmx_slk_RakPeer_GetGuidFromSystemAddress(SLNet::RakPeerInterface * peer, MaxSystemAddress * systemAddress);
	SLNet::RakNetStatistics * bmx_slk_RakPeer_GetStatistics(SLNet::RakPeerInterface * peer, MaxSystemAddress * addr);
	BBArray * bmx_slk_RakPeer_GetSockets(SLNet::RakPeerInterface * peer);
	MaxSystemAddress * bmx_slk_RakPeer_GetInternalID(SLNet::RakPeerInterface * peer, MaxSystemAddress * systemAddress, int index);
	int bmx_slk_RakPeer_GetConnectionList(SLNet::RakPeerInterface * peer, BBArray * remoteSystems, int * connections);
	void bmx_slk_RakPeer_AttachPlugin(SLNet::RakPeerInterface * peer, SLNet::PluginInterface2 * plugin);
	void bmx_slk_RakPeer_DetachPlugin(SLNet::RakPeerInterface * peer, SLNet::PluginInterface2 * plugin);
	SLNet::RakNetGUID * bmx_slk_RakPeer_GetMyGUID(SLNet::RakPeerInterface * peer);
	MaxSystemAddress * bmx_slk_RakPeer_GetSystemAddressFromGuid(SLNet::RakPeerInterface * peer, SLNet::RakNetGUID * guid);
	void bmx_slk_RakPeer_SetPerConnectionOutgoingBandwidthLimit(SLNet::RakPeerInterface * peer, int maxBitsPerSecond);
	int bmx_slk_RakPeer_AdvertiseSystem(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, const char * data, int dataLength, int connectionSocketIndex);
	void bmx_slk_RakPeer_SendTTL(SLNet::RakPeerInterface * peer, BBString * host, int remotePort, int ttl, int connectionSocketIndex);
	void bmx_slk_RakPeer_PushBackPacket(SLNet::RakPeerInterface * peer, SLNet::Packet * packet, int pushAtHead);
	SLNet::Packet * bmx_slk_RakPeer_AllocatePacket(SLNet::RakPeerInterface * peer, int dataSize);

	SLNet::BitStream * bmx_slk_BitStream_Create();
	SLNet::BitStream * bmx_slk_BitStream_CreateFromData(unsigned char * data, unsigned int size, int copy);
	void bmx_slk_BitStream_Delete(SLNet::BitStream * stream);
	void bmx_slk_BitStream_Reset(SLNet::BitStream * stream);
	int bmx_slk_BitStream_SerializeByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value);
	int bmx_slk_BitStream_SerializeShort(SLNet::BitStream * stream, int writeToBitstream, short * value);
	int bmx_slk_BitStream_SerializeInt(SLNet::BitStream * stream, int writeToBitstream, int * value);
	int bmx_slk_BitStream_SerializeUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value);
	int bmx_slk_BitStream_SerializeUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value);
	int bmx_slk_BitStream_SerializeFloat(SLNet::BitStream * stream, int writeToBitstream, float * value);
	int bmx_slk_BitStream_SerializeDouble(SLNet::BitStream * stream, int writeToBitstream, double * value);
	int bmx_slk_BitStream_SerializeDeltaLastByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue, unsigned char lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue, short lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue, int lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue, unsigned short lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue, unsigned int lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue, float lastValue);
	int bmx_slk_BitStream_SerializeDeltaLastDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue, double lastValue);
	int bmx_slk_BitStream_SerializeDeltaByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value);
	int bmx_slk_BitStream_SerializeDeltaShort(SLNet::BitStream * stream, int writeToBitstream, short * value);
	int bmx_slk_BitStream_SerializeDeltaInt(SLNet::BitStream * stream, int writeToBitstream, int * value);
	int bmx_slk_BitStream_SerializeDeltaUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value);
	int bmx_slk_BitStream_SerializeDeltaUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value);
	int bmx_slk_BitStream_SerializeDeltaFloat(SLNet::BitStream * stream, int writeToBitstream, float * value);
	int bmx_slk_BitStream_SerializeDeltaDouble(SLNet::BitStream * stream, int writeToBitstream, double * value);

	int bmx_slk_BitStream_SerializeCompressedByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * value);
	int bmx_slk_BitStream_SerializeCompressedShort(SLNet::BitStream * stream, int writeToBitstream, short * value);
	int bmx_slk_BitStream_SerializeCompressedInt(SLNet::BitStream * stream, int writeToBitstream, int * value);
	int bmx_slk_BitStream_SerializeCompressedUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * value);
	int bmx_slk_BitStream_SerializeCompressedUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * value);
	int bmx_slk_BitStream_SerializeCompressedFloat(SLNet::BitStream * stream, int writeToBitstream, float * value);
	int bmx_slk_BitStream_SerializeCompressedDouble(SLNet::BitStream * stream, int writeToBitstream, double * value);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue, unsigned char lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue, short lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue, int lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue, unsigned short lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue, unsigned int lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue, float lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaLastDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue, double lastValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaByte(SLNet::BitStream * stream, int writeToBitstream, unsigned char * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaShort(SLNet::BitStream * stream, int writeToBitstream, short * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaInt(SLNet::BitStream * stream, int writeToBitstream, int * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaUShort(SLNet::BitStream * stream, int writeToBitstream, unsigned short * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaUInt(SLNet::BitStream * stream, int writeToBitstream, unsigned int * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaFloat(SLNet::BitStream * stream, int writeToBitstream, float * currentValue);
	int bmx_slk_BitStream_SerializeCompressedDeltaDouble(SLNet::BitStream * stream, int writeToBitstream, double * currentValue);
	int bmx_slk_BitStream_ReadDeltaBool(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedBool(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedDeltaBool(SLNet::BitStream * stream, int * value);

	int bmx_slk_BitStream_ReadBit(SLNet::BitStream * stream);
	int bmx_slk_BitStream_ReadByte(SLNet::BitStream * stream, unsigned char * value);
	int bmx_slk_BitStream_ReadShort(SLNet::BitStream * stream, short * value);
	int bmx_slk_BitStream_ReadInt(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadUShort(SLNet::BitStream * stream, unsigned short * value);
	int bmx_slk_BitStream_ReadUInt(SLNet::BitStream * stream, unsigned int * value);
	int bmx_slk_BitStream_ReadFloat(SLNet::BitStream * stream, float * value);
	int bmx_slk_BitStream_ReadDouble(SLNet::BitStream * stream, double * value);
	int bmx_slk_BitStream_ReadLong(SLNet::BitStream * stream, BBInt64 * value);
	int bmx_slk_BitStream_ReadTime(SLNet::BitStream * stream, BBInt64 * value);
	BBString * bmx_slk_BitStream_ReadString(SLNet::BitStream * stream);
	BBString * bmx_slk_BitStream_ReadCompressedString(SLNet::BitStream * stream);

	int bmx_slk_BitStream_ReadDeltaByte(SLNet::BitStream * stream, unsigned char * value);
	int bmx_slk_BitStream_ReadDeltaShort(SLNet::BitStream * stream, short * value);
	int bmx_slk_BitStream_ReadDeltaInt(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadDeltaUShort(SLNet::BitStream * stream, unsigned short * value);
	int bmx_slk_BitStream_ReadDeltaUInt(SLNet::BitStream * stream, unsigned int * value);
	int bmx_slk_BitStream_ReadDeltaFloat(SLNet::BitStream * stream, float * value);
	int bmx_slk_BitStream_ReadDeltaDouble(SLNet::BitStream * stream, double * value);
	int bmx_slk_BitStream_ReadCompressedByte(SLNet::BitStream * stream, unsigned char * value);
	int bmx_slk_BitStream_ReadCompressedShort(SLNet::BitStream * stream, short * value);
	int bmx_slk_BitStream_ReadCompressedInt(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedUShort(SLNet::BitStream * stream, unsigned short * value);
	int bmx_slk_BitStream_ReadCompressedUInt(SLNet::BitStream * stream, unsigned int * value);
	int bmx_slk_BitStream_ReadCompressedFloat(SLNet::BitStream * stream, float * value);
	int bmx_slk_BitStream_ReadCompressedDouble(SLNet::BitStream * stream, double * value);
	int bmx_slk_BitStream_ReadCompressedDeltaByte(SLNet::BitStream * stream, unsigned char * value);
	int bmx_slk_BitStream_ReadCompressedDeltaShort(SLNet::BitStream * stream, short * value);
	int bmx_slk_BitStream_ReadCompressedDeltaInt(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedDeltaUShort(SLNet::BitStream * stream, unsigned short * value);
	int bmx_slk_BitStream_ReadCompressedDeltaUInt(SLNet::BitStream * stream, unsigned int * value);
	int bmx_slk_BitStream_ReadCompressedDeltaFloat(SLNet::BitStream * stream, float * value);
	int bmx_slk_BitStream_ReadCompressedDeltaDouble(SLNet::BitStream * stream, double * value);

	int bmx_slk_BitStream_ReadDeltaint(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedint(SLNet::BitStream * stream, int * value);
	int bmx_slk_BitStream_ReadCompressedDeltaint(SLNet::BitStream * stream, int * value);

	void bmx_slk_BitStream_WriteByte(SLNet::BitStream * stream, unsigned char * value);
	void bmx_slk_BitStream_WriteShort(SLNet::BitStream * stream, short * value);
	void bmx_slk_BitStream_WriteInt(SLNet::BitStream * stream, int * value);
	void bmx_slk_BitStream_WriteFloat(SLNet::BitStream * stream, float * value);
	void bmx_slk_BitStream_WriteDouble(SLNet::BitStream * stream, double * value);
	void bmx_slk_BitStream_WriteLong(SLNet::BitStream * stream, BBInt64 * value);
	void bmx_slk_BitStream_WriteTime(SLNet::BitStream * stream, BBInt64 * value);
	void bmx_slk_BitStream_AssertStreamEmpty(SLNet::BitStream * stream);
	void bmx_slk_BitStream_IgnoreBits(SLNet::BitStream * stream, int numberOfBits);
	void bmx_slk_BitStream_IgnoreBytes(SLNet::BitStream * stream, int numberOfBytes);
	void bmx_slk_BitStream_SetWriteOffset(SLNet::BitStream * stream, int offset);
	void bmx_slk_BitStream_Write0(SLNet::BitStream * stream);
	void bmx_slk_BitStream_Write1(SLNet::BitStream * stream);
	void bmx_slk_BitStream_WriteUShort(SLNet::BitStream * stream, unsigned short * value);
	void bmx_slk_BitStream_WriteUInt(SLNet::BitStream * stream, unsigned int * value);
	void bmx_slk_BitStream_WriteString(SLNet::BitStream * stream, BBString * value);

	int bmx_slk_BitStream_GetNumberOfBitsUsed(SLNet::BitStream * stream);
	int bmx_slk_BitStream_GetWriteOffset(SLNet::BitStream * stream);
	int bmx_slk_BitStream_GetNumberOfBytesUsed(SLNet::BitStream * stream);
	int bmx_slk_BitStream_GetReadOffset(SLNet::BitStream * stream);
	void bmx_slk_BitStream_SetReadOffset(SLNet::BitStream * stream, int offset);
	int bmx_slk_BitStream_GetNumberOfUnreadBits(SLNet::BitStream * stream);
	void bmx_slk_BitStream_WriteBits(SLNet::BitStream * stream, const unsigned char * data, int numberOfBitsToWrite, int rightAlignedBits);
	void bmx_slk_BitStream_WriteCompressedByte(SLNet::BitStream * stream, char * b);
	void bmx_slk_BitStream_WriteCompressedShort(SLNet::BitStream * stream, short * value);
	void bmx_slk_BitStream_WriteCompressedUShort(SLNet::BitStream * stream, short * value);
	void bmx_slk_BitStream_WriteCompressedInt(SLNet::BitStream * stream, int * value);
	void bmx_slk_BitStream_WriteCompressedUInt(SLNet::BitStream * stream, int * value);
	void bmx_slk_BitStream_WriteCompressedFloat(SLNet::BitStream * stream, float * value);
	void bmx_slk_BitStream_WriteCompressedDouble(SLNet::BitStream * stream, double * value);
	void bmx_slk_BitStream_WriteCompressedLong(SLNet::BitStream * stream, BBInt64 * value);
	void bmx_slk_BitStream_WriteDeltaByte(SLNet::BitStream * stream, char * b, char lastValue);
	void bmx_slk_BitStream_WriteDeltaShort(SLNet::BitStream * stream, short * currentValue, short lastValue);
	void bmx_slk_BitStream_WriteDeltaUShort(SLNet::BitStream * stream, short * currentValue, short lastValue);
	void bmx_slk_BitStream_WriteDeltaInt(SLNet::BitStream * stream, int * currentValue, int lastValue);
	void bmx_slk_BitStream_WriteDeltaUInt(SLNet::BitStream * stream, int * currentValue, int lastValue);
	void bmx_slk_BitStream_WriteDeltaFloat(SLNet::BitStream * stream, float * currentValue, float lastValue);
	void bmx_slk_BitStream_WriteDeltaDouble(SLNet::BitStream * stream, double * currentValue, double lastValue);
	void bmx_slk_BitStream_WriteDeltaLong(SLNet::BitStream * stream, BBInt64 * currentValue, BBInt64 lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaByte(SLNet::BitStream * stream, char * b, char lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaShort(SLNet::BitStream * stream, short * currentValue, short lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaUShort(SLNet::BitStream * stream, short * currentValue, short lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaInt(SLNet::BitStream * stream, int * currentValue, int lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaUInt(SLNet::BitStream * stream, int * currentValue, int lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaFloat(SLNet::BitStream * stream, float * currentValue, float lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaDouble(SLNet::BitStream * stream, double * currentValue, double lastValue);
	void bmx_slk_BitStream_WriteCompressedDeltaLong(SLNet::BitStream * stream, BBInt64 * currentValue, BBInt64 lastValue);
	void bmx_slk_BitStream_WriteCompressedString(SLNet::BitStream * stream, BBString * value);

	void bmx_slk_SystemAddress_delete(MaxSystemAddress * address);
	MaxSystemAddress * bmx_slk_SystemAddress_unassigned();
	int bmx_slk_SystemAddress_Equals(MaxSystemAddress * address, MaxSystemAddress * other);
	BBString * bmx_slk_SystemAddress_ToString(MaxSystemAddress * address);
	void * bmx_slk_SystemAddress_GetAddress(MaxSystemAddress * address);
	int bmx_slk_SystemAddress_GetPort(MaxSystemAddress * address);
	MaxSystemAddress * bmx_slk_SystemAddress_create();
	void bmx_slk_SystemAddress_SetBinaryAddress(MaxSystemAddress * address, BBString * addr);
	void bmx_slk_SystemAddress_SetPort(MaxSystemAddress * address, int port);
	int bmx_slk_SystemAddress_IsLoopback(MaxSystemAddress * address);
	int bmx_slk_SystemAddress_IsLANAddress(MaxSystemAddress * address);
	int bmx_slk_SystemAddress_GetPortNetworkOrder(MaxSystemAddress * address);
	void bmx_slk_SystemAddress_SetPortHostOrder(MaxSystemAddress * address, int s);
	void bmx_slk_SystemAddress_SetPortNetworkOrder(MaxSystemAddress * address, int s);

	MaxSocketDescriptor * bmx_slk_SocketDescriptor_new(int port, BBString * hostAddress);
	void bmx_slk_SocketDescriptor_delete(MaxSocketDescriptor * desc);
	void bmx_slk_SocketDescriptor_setport(MaxSocketDescriptor * desc, int port);
	int bmx_slk_SocketDescriptor_getport(MaxSocketDescriptor * desc);
	void bmx_slk_SocketDescriptor_sethostaddress(MaxSocketDescriptor * desc, BBString * hostAddress);
	BBString * bmx_slk_SocketDescriptor_gethostaddress(MaxSocketDescriptor * desc);
	void bmx_slk_SocketDescriptor_setsocketfamily(MaxSocketDescriptor * desc, int family);
	int bmx_slk_SocketDescriptor_getsocketfamily(MaxSocketDescriptor * desc);
	void bmx_slk_SocketDescriptor_setblockingsocket(MaxSocketDescriptor * desc, int blocking);
	int bmx_slk_SocketDescriptor_getblockingsocket(MaxSocketDescriptor * desc);
	void bmx_slk_SocketDescriptor_setextrasocketoptions(MaxSocketDescriptor * desc, int options);
	int bmx_slk_SocketDescriptor_getextrasocketoptions(MaxSocketDescriptor * desc);

	void bmx_slk_net_seedMT(unsigned int seed);
	int bmx_slk_net_gettimems();
	void bmx_slk_net_gettimens(BBInt64 * v);
	unsigned int bmx_slk_net_randomMT();
	float bmx_slk_net_frandomMT();
	void bmx_slk_net_fillBufferMT(void * buffer, unsigned int size);
	int bmx_slk_net_getversion();
	BBString * bmx_slk_net_getversionstring();
	int bmx_slk_net_getprotocolversion();
	BBString * bmx_slk_net_getdate();

	BBString * bmx_slk_RakNetStatistics_ToStringLevel(SLNet::RakNetStatistics * stats, int verbosityLevel);
	void bmx_slk_RakNetStatistics_valueOverLastSecond(SLNet::RakNetStatistics * stats, int perSecondMetrics, BBInt64 * v);
	void bmx_slk_RakNetStatistics_runningTotal(SLNet::RakNetStatistics * stats, int perSecondMetrics, BBInt64 * v);
	void bmx_slk_RakNetStatistics_connectionStartTime(SLNet::RakNetStatistics * stats, BBInt64 * v);
	int bmx_slk_RakNetStatistics_isLimitedByCongestionControl(SLNet::RakNetStatistics * stats);
	void bmx_slk_RakNetStatistics_BPSLimitByCongestionControl(SLNet::RakNetStatistics * stats, BBInt64 * v);
	int bmx_slk_RakNetStatistics_isLimitedByOutgoingBandwidthLimit(SLNet::RakNetStatistics * stats);
	void bmx_slk_RakNetStatistics_BPSLimitByOutgoingBandwidthLimit(SLNet::RakNetStatistics * stats, BBInt64 * v);
	int bmx_slk_RakNetStatistics_messageInSendBuffer(SLNet::RakNetStatistics * stats, int priority);
	double bmx_slk_RakNetStatistics_bytesInSendBuffer(SLNet::RakNetStatistics * stats, int priority);
	int bmx_slk_RakNetStatistics_messagesInResendBuffer(SLNet::RakNetStatistics * stats);
	void bmx_slk_RakNetStatistics_BytesInResendBuffer(SLNet::RakNetStatistics * stats, BBInt64 * v);
	float bmx_slk_RakNetStatistics_packetlossLastSecond(SLNet::RakNetStatistics * stats);
	float bmx_slk_RakNetStatistics_packetlossTotal(SLNet::RakNetStatistics * stats);

	unsigned char * bmx_slk_Packet_GetData(SLNet::Packet * packet);
	unsigned int bmx_slk_Packet_GetBitSize(SLNet::Packet * packet);
	MaxSystemAddress * bmx_slk_Packet_GetSystemAddress(SLNet::Packet * packet);
	int bmx_slk_Packet_GetPacketIdentifier(SLNet::Packet * packet);
	SLNet::RakNetGUID * bmx_slk_Packet_GetGuid(SLNet::Packet * packet);
	int bmx_slk_Packet_GetLength(SLNet::Packet * packet);

	BBString * bmx_slk_RakNetGUID_ToString(SLNet::RakNetGUID * guid);
	void bmx_slk_RakNetGUID_delete(SLNet::RakNetGUID * guid);
	const SLNet::RakNetGUID * bmx_slk_RakNetGUID_unassigned();
	int bmx_slk_RakNetGUID_Equals(SLNet::RakNetGUID * guid, SLNet::RakNetGUID * other);

	SLNet::NetworkIDManager * bmx_slk_NetworkIDManager_create();
	void bmk_slk_NetworkIDManager_Clear(SLNet::NetworkIDManager * manager);
	SLNet::NetworkIDObject * bmk_slk_NetworkIDManager_GET_BASE_OBJECT_FROM_ID(SLNet::NetworkIDManager * manager, BBInt64 networkID);

	int bmx_slk_RakNetSocket_GetSocketType(SLNet::RakNetSocket2 * socket);
	int bmx_slk_RakNetSocket_IsBerkleySocket(SLNet::RakNetSocket2 * socket);
	MaxSystemAddress * bmx_slk_RakNetSocket_GetBoundAddress(SLNet::RakNetSocket2 * socket);
	int bmx_slk_RakNetSocket_GetUserConnectionSocketIndex(SLNet::RakNetSocket2 * socket);

	int bmx_slk_MAXIMUM_NUMBER_OF_INTERNAL_IDS();
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class MaxSystemAddress
{
public:
	MaxSystemAddress(const SLNet::SystemAddress & a);
	MaxSystemAddress();
	~MaxSystemAddress();
	SLNet::SystemAddress & Address();

private:
	SLNet::SystemAddress systemAddress;

};

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class MaxSocketDescriptor
{
public:
	MaxSocketDescriptor(const SLNet::SocketDescriptor d);
	MaxSocketDescriptor(unsigned short port, const char *hostAddress);
	~MaxSocketDescriptor();
	SLNet::SocketDescriptor & Descriptor();

private:
	SLNet::SocketDescriptor descriptor;

};
