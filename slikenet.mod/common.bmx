' Copyright (c) 2007-2018 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Import "source.bmx"

?win32
Import "-liphlpapi"
?

Extern

	Function bmx_slk_RakPeerInterface_GetInstance:Byte Ptr()
	Function bmx_slk_RakPeerInterface_DestroyInstance(handle:Byte Ptr)

	Function bmx_slk_RakPeer_Startup:Int(handle:Byte Ptr, maxConnections:Int, descriptors:Byte Ptr[], threadPriority:Int)
	Function bmx_slk_RakPeer_PingHost(handle:Byte Ptr, host:String, remotePort:Int, onlyReplyOnAcceptingConnections:Int, connectionSocketIndex:Int)
	Function bmx_slk_RakPeer_Receive:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_RakPeer_DeallocatePacket(handle:Byte Ptr, packet:Byte Ptr)
	Function bmx_slk_RakPeer_InitializeSecurity:Int(handle:Byte Ptr, publicKey:Byte Ptr, privateKey:Byte Ptr, requireClientKey:Int)
	Function bmx_slk_RakPeer_DisableSecurity(handle:Byte Ptr)
	Function bmx_slk_RakPeer_AddToSecurityExceptionList(handle:Byte Ptr, ip:String)
	Function bmx_slk_RakPeer_RemoveFromSecurityExceptionList(handle:Byte Ptr, ip:String)
	Function bmx_slk_RakPeer_IsInSecurityExceptionList:Int(handle:Byte Ptr, ip:String)		
	Function bmx_slk_RakPeer_SetMaximumIncomingConnections(handle:Byte Ptr, numberAllowed:Int)
	Function bmx_slk_RakPeer_GetMaximumIncomingConnections:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_NumberOfConnections:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_SetIncomingPassword(handle:Byte Ptr, passwordData:String)
	Function bmx_slk_RakPeer_GetIncomingPassword:String(handle:Byte Ptr)
	Function bmx_slk_RakPeer_Connect:Int(handle:Byte Ptr, host:String, remotePort:Int, passwordData:String, publicKey:Byte Ptr, connectionSocketIndex:Int, sendConnectionAttemptCount:Int, timeBetweenSendConnectionAttemptsMS:Int, timeoutTime:Int)
	Function bmx_slk_RakPeer_ConnectWithSocket:Int(handle:Byte Ptr, host:String, remotePort:Int, passwordData:String, socket:Byte Ptr, publicKey:Byte Ptr, sendConnectionAttemptCount:Int, timeBetweenSendConnectionAttemptsMS:Int, timeoutTime:Int)
	Function bmx_slk_RakPeer_Shutdown(handle:Byte Ptr, blockDuration:Int, orderingChannel:Int, disconnectionNotificationPriority:Int)
	Function bmx_slk_RakPeer_IsActive:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetNextSendReceipt:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_IncrementNextSendReceipt:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetMaximumNumberOfPeers:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_CloseConnection(handle:Byte Ptr, target:Byte Ptr, sendDisconnectionNotification:Int, orderingChannel:Int, disconnectionNotificationPriority:Int)
	Function bmx_slk_RakPeer_GetConnectionState:Int(handle:Byte Ptr, addr:Byte Ptr)
	Function bmx_slk_RakPeer_GetIndexFromSystemAddress:Int(handle:Byte Ptr, systemAddress:Byte Ptr)
	Function bmx_slk_RakPeer_GetSystemAddressFromIndex:Byte Ptr(handle:Byte Ptr, index:Int)
	Function bmx_slk_RakPeer_AddToBanList(handle:Byte Ptr, ip:String, milliseconds:Int)
	Function bmx_slk_RakPeer_RemoveFromBanList(handle:Byte Ptr, ip:String)
	Function bmx_slk_RakPeer_ClearBanList(handle:Byte Ptr)
	Function bmx_slk_RakPeer_IsBanned:Int(handle:Byte Ptr, ip:String)
	Function bmx_slk_RakPeer_Ping(handle:Byte Ptr, addr:Byte Ptr)		
	Function bmx_slk_RakPeer_GetAveragePing:Int(handle:Byte Ptr, addr:Byte Ptr)		
	Function bmx_slk_RakPeer_GetLastPing:Int(handle:Byte Ptr, addr:Byte Ptr)		
	Function bmx_slk_RakPeer_GetLowestPing:Int(handle:Byte Ptr, addr:Byte Ptr)		
	Function bmx_slk_RakPeer_SetOccasionalPing(handle:Byte Ptr, doPing:Int)		
	Function bmx_slk_RakPeer_SetOfflinePingResponse(handle:Byte Ptr, data:Byte Ptr, length:Int)
	Function bmx_slk_RakPeer_GetOfflinePingResponse:Byte[](handle:Byte Ptr)
	Function bmx_slk_RakPeer_SetTimeoutTime(handle:Byte Ptr, timeMS:Int, target:Byte Ptr)	
	Function bmx_slk_RakPeer_GetMTUSize:Int(handle:Byte Ptr, target:Byte Ptr)
	Function bmx_slk_RakPeer_GetNumberOfAddresses:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetLocalIP:String(handle:Byte Ptr, index:Int)
	Function bmx_slk_RakPeer_IsLocalIP:Int(handle:Byte Ptr, ip:String)
	Function bmx_slk_RakPeer_AllowConnectionResponseIPMigration(handle:Byte Ptr, allow:Int)
	Function bmx_slk_RakPeer_SetSplitMessageProgressInterval(handle:Byte Ptr, interval:Int)
	Function bmx_slk_RakPeer_SetUnreliableTimeout(handle:Byte Ptr, timeoutMS:Int)
	Function bmx_slk_RakPeer_SendBitStream:Int(handle:Byte Ptr, bitStream:Byte Ptr, priority:Int, reliability:Int, orderingChannel:Int, systemIdentifier:Byte Ptr, broadcast:Int, forceReceiptNumber:Int)
	Function bmx_slk_RakPeer_Send:Int(handle:Byte Ptr, data:Byte Ptr, length:Int, priority:Int, reliability:Int, orderingChannel:Int, systemIdentifier:Byte Ptr, broadcast:Int, forceReceiptNumber:Int)
	Function bmx_slk_RakPeer_GetGuidFromSystemAddress:Byte Ptr(handle:Byte Ptr, systemAddress:Byte Ptr)
	Function bmx_slk_RakPeer_GetStatistics:Byte Ptr(handle:Byte Ptr, addr:Byte Ptr)
	Function bmx_slk_RakNetSocket_GetSocketType:Int(handle:Byte Ptr)
	Function bmx_slk_RakNetSocket_IsBerkleySocket:Int(handle:Byte Ptr)
	Function bmx_slk_RakNetSocket_GetBoundAddress:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_RakNetSocket_GetUserConnectionSocketIndex:Int(handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetInternalID:Byte Ptr(handle:Byte Ptr, systemAddress:Byte Ptr, index:Int)
	Function bmx_slk_RakPeer_AttachPlugin(handle:Byte Ptr, plugin:Byte Ptr)
	Function bmx_slk_RakPeer_DetachPlugin(handle:Byte Ptr, plugin:Byte Ptr)
	Function bmx_slk_RakPeer_GetMyGUID:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetSystemAddressFromGuid:Byte Ptr(handle:Byte Ptr, guid:Byte Ptr)
	Function bmx_slk_RakPeer_SetPerConnectionOutgoingBandwidthLimit(handle:Byte Ptr, maxBitsPerSecond:Int)
	Function bmx_slk_RakPeer_AdvertiseSystem:Int(handle:Byte Ptr, host:String, remotePort:Int, data:Byte Ptr, dataLength:Int, connectionSocketIndex:Int)
	Function bmx_slk_RakPeer_SendTTL(handle:Byte Ptr, host:String, remotePort:Int, ttl:Int, connectionSocketIndex:Int)
	Function bmx_slk_RakPeer_PushBackPacket(handle:Byte Ptr, packet:Byte Ptr, pushAtHead:Int)
	Function bmx_slk_RakPeer_AllocatePacket:Byte Ptr(handle:Byte Ptr, dataSize:Int)
	
	Function bmx_slk_BitStream_Create:Byte Ptr()
	Function bmx_slk_BitStream_CreateFromData:Byte Ptr(data:Byte Ptr, size:Int, copy:Int)
	Function bmx_slk_BitStream_Delete(handle:Byte Ptr)
	Function bmx_slk_BitStream_Reset(handle:Byte Ptr)
	Function bmx_slk_BitStream_SerializeByte:Int(handle:Byte Ptr, writeToBitstream:Int, value:Byte Ptr)
	Function bmx_slk_BitStream_SerializeShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeUShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeUInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeFloat:Int(handle:Byte Ptr, writeToBitstream:Int, value:Float Ptr)
	Function bmx_slk_BitStream_SerializeDouble:Int(handle:Byte Ptr, writeToBitstream:Int, value:Double Ptr)
	Function bmx_slk_BitStream_SerializeDeltaLastByte:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Byte Ptr, lastValue:Byte)
	Function bmx_slk_BitStream_SerializeDeltaLastShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_SerializeDeltaLastInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_SerializeDeltaLastUShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_SerializeDeltaLastUInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_SerializeDeltaLastFloat:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Float Ptr, lastValue:Float)
	Function bmx_slk_BitStream_SerializeDeltaLastDouble:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Double Ptr, lastValue:Double)
	Function bmx_slk_BitStream_SerializeDeltaByte:Int(handle:Byte Ptr, writeToBitstream:Int, value:Byte Ptr)
	Function bmx_slk_BitStream_SerializeDeltaShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeDeltaInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeDeltaUShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeDeltaUInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeDeltaFloat:Int(handle:Byte Ptr, writeToBitstream:Int, value:Float Ptr)
	Function bmx_slk_BitStream_SerializeDeltaDouble:Int(handle:Byte Ptr, writeToBitstream:Int, value:Double Ptr)
	Function bmx_slk_BitStream_SerializeCompressedByte:Int(handle:Byte Ptr, writeToBitstream:Int, value:Byte Ptr)
	Function bmx_slk_BitStream_SerializeCompressedShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeCompressedInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeCompressedUShort:Int(handle:Byte Ptr, writeToBitstream:Int, value:Short Ptr)
	Function bmx_slk_BitStream_SerializeCompressedUInt:Int(handle:Byte Ptr, writeToBitstream:Int, value:Int Ptr)
	Function bmx_slk_BitStream_SerializeCompressedFloat:Int(handle:Byte Ptr, writeToBitstream:Int, value:Float Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDouble:Int(handle:Byte Ptr, writeToBitstream:Int, value:Double Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastByte:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Byte Ptr, lastValue:Byte)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastUShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastUInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastFloat:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Float Ptr, lastValue:Float)
	Function bmx_slk_BitStream_SerializeCompressedDeltaLastDouble:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Double Ptr, lastValue:Double)
	Function bmx_slk_BitStream_SerializeCompressedDeltaByte:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Byte Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaUShort:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Short Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaUInt:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Int Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaFloat:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Float Ptr)
	Function bmx_slk_BitStream_SerializeCompressedDeltaDouble:Int(handle:Byte Ptr, writeToBitstream:Int, currentValue:Double Ptr)
	Function bmx_slk_BitStream_ReadBit:Int(handle:Byte Ptr)
	Function bmx_slk_BitStream_ReadByte:Int(handle:Byte Ptr, value:Byte Ptr)
	Function bmx_slk_BitStream_ReadShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadUShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadUInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadFloat:Int(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_ReadDouble:Int(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_ReadLong:Int(handle:Byte Ptr, value:Long Ptr)
	Function bmx_slk_BitStream_ReadTime:Int(handle:Byte Ptr, value:Long Ptr)
	Function bmx_slk_BitStream_ReadString:String(handle:Byte Ptr)
	Function bmx_slk_BitStream_ReadCompressedString:String(handle:Byte Ptr)
	Function bmx_slk_BitStream_ReadDeltaByte:Int(handle:Byte Ptr, value:Byte Ptr)
	Function bmx_slk_BitStream_ReadDeltaShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadDeltaInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadDeltaUShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadDeltaUInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadDeltaFloat:Int(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_ReadDeltaDouble:Int(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_ReadCompressedByte:Int(handle:Byte Ptr, value:Byte Ptr)
	Function bmx_slk_BitStream_ReadCompressedShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadCompressedInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedUShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadCompressedUInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedFloat:Int(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_ReadCompressedDouble:Int(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaByte:Int(handle:Byte Ptr, value:Byte Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaUShort:Int(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaUInt:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaFloat:Int(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaDouble:Int(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_WriteByte(handle:Byte Ptr, value:Byte Ptr)
	Function bmx_slk_BitStream_WriteShort(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_WriteInt(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_WriteFloat(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_WriteDouble(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_WriteLong(handle:Byte Ptr, value:Long Ptr)
	Function bmx_slk_BitStream_WriteTime(handle:Byte Ptr, value:Long Ptr)
	Function bmx_slk_BitStream_Write0(handle:Byte Ptr)
	Function bmx_slk_BitStream_Write1(handle:Byte Ptr)
	Function bmx_slk_BitStream_WriteUShort(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_WriteUInt(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_WriteString(handle:Byte Ptr, value:String)

	Function bmx_slk_BitStream_ReadDeltaBool:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedBool:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_ReadCompressedDeltaBool:Int(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_AssertStreamEmpty(handle:Byte Ptr)
	Function bmx_slk_BitStream_IgnoreBits(handle:Byte Ptr, numberOfBits:Int)
	Function bmx_slk_BitStream_IgnoreBytes(handle:Byte Ptr, numberOfBytes:Int)
	Function bmx_slk_BitStream_SetWriteOffset(handle:Byte Ptr, offset:Int)
	Function bmx_slk_BitStream_GetNumberOfBitsUsed:Int(handle:Byte Ptr)
	Function bmx_slk_BitStream_GetWriteOffset:Int(handle:Byte Ptr)
	Function bmx_slk_BitStream_GetNumberOfBytesUsed:Int(handle:Byte Ptr)
	Function bmx_slk_BitStream_GetReadOffset:Int(handle:Byte Ptr)
	Function bmx_slk_BitStream_SetReadOffset(handle:Byte Ptr, offset:Int)
	Function bmx_slk_BitStream_GetNumberOfUnreadBits:Int(handle:Byte Ptr)

	Function bmx_slk_BitStream_WriteBits(handle:Byte Ptr, data:Byte Ptr, numberOfBitsToWrite:Int, rightAlignedBits:Int)
	Function bmx_slk_BitStream_WriteCompressedByte(handle:Byte Ptr, b:Byte Ptr)
	Function bmx_slk_BitStream_WriteCompressedShort(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_WriteCompressedUShort(handle:Byte Ptr, value:Short Ptr)
	Function bmx_slk_BitStream_WriteCompressedInt(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_WriteCompressedUInt(handle:Byte Ptr, value:Int Ptr)
	Function bmx_slk_BitStream_WriteCompressedFloat(handle:Byte Ptr, value:Float Ptr)
	Function bmx_slk_BitStream_WriteCompressedDouble(handle:Byte Ptr, value:Double Ptr)
	Function bmx_slk_BitStream_WriteCompressedLong(handle:Byte Ptr, value:Long Ptr)
	Function bmx_slk_BitStream_WriteDeltaByte(handle:Byte Ptr, b:Byte Ptr, lastValue:Byte)
	Function bmx_slk_BitStream_WriteDeltaShort(handle:Byte Ptr, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_WriteDeltaUShort(handle:Byte Ptr, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_WriteDeltaInt(handle:Byte Ptr, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_WriteDeltaUInt(handle:Byte Ptr, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_WriteDeltaFloat(handle:Byte Ptr, currentValue:Float Ptr, lastValue:Float)
	Function bmx_slk_BitStream_WriteDeltaDouble(handle:Byte Ptr, currentValue:Double Ptr, lastValue:Double)
	Function bmx_slk_BitStream_WriteDeltaLong(handle:Byte Ptr, currentValue:Long Ptr, lastValue:Long)
	Function bmx_slk_BitStream_WriteCompressedDeltaByte(handle:Byte Ptr, b:Byte Ptr, lastValue:Byte)
	Function bmx_slk_BitStream_WriteCompressedDeltaShort(handle:Byte Ptr, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_WriteCompressedDeltaUShort(handle:Byte Ptr, currentValue:Short Ptr, lastValue:Short)
	Function bmx_slk_BitStream_WriteCompressedDeltaInt(handle:Byte Ptr, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_WriteCompressedDeltaUInt(handle:Byte Ptr, currentValue:Int Ptr, lastValue:Int)
	Function bmx_slk_BitStream_WriteCompressedDeltaFloat(handle:Byte Ptr, currentValue:Float Ptr, lastValue:Float)
	Function bmx_slk_BitStream_WriteCompressedDeltaDouble(handle:Byte Ptr, currentValue:Double Ptr, lastValue:Double)
	Function bmx_slk_BitStream_WriteCompressedDeltaLong(handle:Byte Ptr, currentValue:Long Ptr, lastValue:Long)
	Function bmx_slk_BitStream_WriteCompressedString(handle:Byte Ptr, value:String)

	Function bmx_slk_SystemAddress_delete(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_unassigned:Byte Ptr()
	Function bmx_slk_SystemAddress_Equals:Int(handle:Byte Ptr, address:Byte Ptr)
	Function bmx_slk_SystemAddress_ToString:String(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_GetAddress:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_GetPort:Int(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_create:Byte Ptr()
	Function bmx_slk_SystemAddress_SetBinaryAddress(handle:Byte Ptr, address:String)
	Function bmx_slk_SystemAddress_SetPort(handle:Byte Ptr, port:Int)
	Function bmx_slk_SystemAddress_IsLoopback:Int(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_IsLANAddress:Int(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_GetPortNetworkOrder:Int(handle:Byte Ptr)
	Function bmx_slk_SystemAddress_SetPortHostOrder(handle:Byte Ptr, s:Int)
	Function bmx_slk_SystemAddress_SetPortNetworkOrder(handle:Byte Ptr, s:Int)

	Function bmx_slk_SocketDescriptor_new:Byte Ptr(port:Int, hostAddress:String)
	Function bmx_slk_SocketDescriptor_delete(handle:Byte Ptr)
	Function bmx_slk_SocketDescriptor_setport(handle:Byte Ptr, port:Int)
	Function bmx_slk_SocketDescriptor_getport:Int(handle:Byte Ptr)
	Function bmx_slk_SocketDescriptor_sethostaddress(handle:Byte Ptr, hostAddress:String)
	Function bmx_slk_SocketDescriptor_gethostaddress:String(handle:Byte Ptr)
	Function bmx_slk_SocketDescriptor_setsocketfamily(handle:Byte Ptr, family:Int)
	Function bmx_slk_SocketDescriptor_getsocketfamily:Int(handle:Byte Ptr)
	Function bmx_slk_SocketDescriptor_setblockingsocket(handle:Byte Ptr, blocking:Int)
	Function bmx_slk_SocketDescriptor_getblockingsocket:Int(handle:Byte Ptr)
	Function bmx_slk_SocketDescriptor_setextrasocketoptions(handle:Byte Ptr, options:Int)
	Function bmx_slk_SocketDescriptor_getextrasocketoptions:Int(handle:Byte Ptr)

	Function bmx_slk_net_seedMT(seed:Int)
	Function bmx_slk_net_gettimems:Int()
	Function bmx_slk_net_gettimens(v:Long Ptr)
	Function bmx_slk_net_randomMT:Int()
	Function bmx_slk_net_frandomMT:Float()
	Function bmx_slk_net_fillBufferMT(buffer:Byte Ptr, size:Int)
	Function bmx_slk_net_getversion:Int()
	Function bmx_slk_net_getversionstring:String()
	Function bmx_slk_net_getprotocolversion:Int()
	Function bmx_slk_net_getdate:String()

	Function bmx_slk_RakNetStatistics_ToStringLevel:String(handle:Byte Ptr, verbosityLevel:Int)
	Function bmx_slk_RakNetStatistics_valueOverLastSecond(handle:Byte Ptr, perSecondMetrics:Int, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_runningTotal(handle:Byte Ptr, perSecondMetrics:Int, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_connectionStartTime(handle:Byte Ptr, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_isLimitedByCongestionControl:Int(handle:Byte Ptr)
	Function bmx_slk_RakNetStatistics_BPSLimitByCongestionControl(handle:Byte Ptr, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_isLimitedByOutgoingBandwidthLimit:Int(handle:Byte Ptr)
	Function bmx_slk_RakNetStatistics_BPSLimitByOutgoingBandwidthLimit(handle:Byte Ptr, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_messageInSendBuffer:Int(handle:Byte Ptr, priority:Int)
	Function bmx_slk_RakNetStatistics_bytesInSendBuffer:Double(handle:Byte Ptr, priority:Int)
	Function bmx_slk_RakNetStatistics_messagesInResendBuffer:Int(handle:Byte Ptr)
	Function bmx_slk_RakNetStatistics_BytesInResendBuffer(handle:Byte Ptr, v:Long Ptr)
	Function bmx_slk_RakNetStatistics_packetlossLastSecond:Float(handle:Byte Ptr)
	Function bmx_slk_RakNetStatistics_packetlossTotal:Float(handle:Byte Ptr)

	Function bmx_slk_Packet_GetData:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_Packet_GetBitSize:Int(handle:Byte Ptr)
	Function bmx_slk_Packet_GetSystemAddress:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_Packet_GetPacketIdentifier:Int(handle:Byte Ptr)
	Function bmx_slk_Packet_GetGuid:Byte Ptr(handle:Byte Ptr)
	Function bmx_slk_Packet_GetLength:Int(handle:Byte Ptr)

	Function bmx_slk_RakNetGUID_ToString:String(handle:Byte Ptr)
	Function bmx_slk_RakNetGUID_delete(handle:Byte Ptr)
	Function bmx_slk_RakNetGUID_unassigned:Byte Ptr()
	Function bmx_slk_RakNetGUID_Equals:Int(handle:Byte Ptr, other:Byte Ptr)

	Function bmx_slk_NetworkIDManager_create:Byte Ptr()
	Function bmk_slk_NetworkIDManager_Clear(handle:Byte Ptr)
	Function bmk_slk_NetworkIDManager_GET_BASE_OBJECT_FROM_ID:Byte Ptr(handle:Byte Ptr, networkID:Long)
	
	Function bmx_slk_MAXIMUM_NUMBER_OF_INTERNAL_IDS:Int()
	
End Extern


Const PACKET_IMMEDIATE_PRIORITY:Int = 0
Const PACKET_HIGH_PRIORITY:Int = 1
Const PACKET_MEDIUM_PRIORITY:Int = 2
Const PACKET_LOW_PRIORITY:Int = 3


Const PACKET_UNRELIABLE:Int = 0
Const PACKET_UNRELIABLE_SEQUENCED:Int = 1
Const PACKET_RELIABLE:Int = 2
Const PACKET_RELIABLE_ORDERED:Int = 3
Const PACKET_RELIABLE_SEQUENCED:Int = 4
Const PACKET_UNRELIABLE_WITH_ACK_RECEIPT:Int = 5
Const PACKET_RELIABLE_WITH_ACK_RECEIPT:Int = 6
Const PACKET_RELIABLE_ORDERED_WITH_ACK_RECEIPT:Int = 7


Rem
bbdoc:  Ping from a connected system.  Update timestamps (internal use only)
End Rem
Const ID_CONNECTED_PING:Int = 0
Rem
bbdoc:  Ping from an unconnected system.  Reply but do not update timestamps. (internal use only)
End Rem
Const ID_UNCONNECTED_PING:Int = 1
Rem
bbdoc:  Ping from an unconnected system.  Only reply if we have open connections. Do not update timestamps. (internal use only)
End Rem
Const ID_UNCONNECTED_PING_OPEN_CONNECTIONS:Int = 2
Rem
bbdoc:  Pong from a connected system.  Update timestamps (internal use only)
End Rem
Const ID_CONNECTED_PONG:Int = 3
Rem
bbdoc:  A reliable packet to detect lost connections (internal use only)
End Rem
Const ID_DETECT_LOST_CONNECTIONS:Int = 4
Rem
bbdoc:  C2S: Initial query: Header(1), OfflineMesageID(16), Protocol number(1), Pad(toMTU), sent with no fragment set.
about: If protocol fails on server, returns ID_INCOMPATIBLE_PROTOCOL_VERSION to client
End Rem
Const ID_OPEN_CONNECTION_REQUEST_1:Int = 5
Rem
bbdoc:  S2C: Header(1), OfflineMesageID(16), server GUID(8), HasSecurity(1), Cookie(4, if HasSecurity), public key (if do security is true), MTU(2). 
about: If public key fails on client, returns ID_PUBLIC_KEY_MISMATCH
End Rem
Const ID_OPEN_CONNECTION_REPLY_1:Int = 6
Rem
bbdoc:  C2S: Header(1), OfflineMesageID(16), Cookie(4, if HasSecurity is true on the server), clientSupportsSecurity(1 bit), handshakeChallenge (if has security on both server and client), remoteBindingAddress(6), MTU(2), client GUID(8)
about: 	Connection slot allocated if cookie is valid, server is not full, GUID and IP not already in use.
End Rem
Const ID_OPEN_CONNECTION_REQUEST_2:Int = 7
Rem
bbdoc:  S2C: Header(1), OfflineMesageID(16), server GUID(8), mtu(2), doSecurity(1 bit), handshakeAnswer (if do security is true)
End Rem
Const ID_OPEN_CONNECTION_REPLY_2:Int = 8
Rem
bbdoc:  C2S: Header(1), GUID(8), Timestamp, HasSecurity(1), Proof(32)
End Rem
Const ID_CONNECTION_REQUEST:Int = 9
Rem
bbdoc:  RakPeer - Remote system requires secure connections, pass a public key to RakPeerInterface::Connect()
End Rem
Const ID_REMOTE_SYSTEM_REQUIRES_PUBLIC_KEY:Int = 10
Rem
bbdoc:  RakPeer - We passed a public key to RakPeerInterface::Connect(), but the other system did not have security turned on
End Rem
Const ID_OUR_SYSTEM_REQUIRES_SECURITY:Int = 11
Rem
bbdoc:  RakPeer - Wrong public key passed to RakPeerInterface::Connect()
End Rem
Const ID_PUBLIC_KEY_MISMATCH:Int = 12
Rem
bbdoc:  RakPeer - Same as ID_ADVERTISE_SYSTEM, but intended for internal use rather than being passed to the user.
about: 	Second byte indicates type. Used currently for NAT punchthrough for receiver port advertisement. See ID_NAT_ADVERTISE_RECIPIENT_PORT
End Rem
Const ID_OUT_OF_BAND_INTERNAL:Int = 13
Rem
bbdoc:  If RakPeerInterface::Send() is called where PacketReliability contains _WITH_ACK_RECEIPT, then on a later call to RakPeerInterface::Receive() you will get ID_SND_RECEIPT_ACKED or ID_SND_RECEIPT_LOSS
about: The message will be 5 bytes long,
and bytes 1-4 inclusive will contain a number in native order containing a number that identifies this message.
This number will be returned by RakPeerInterface::Send() or RakPeerInterface::SendList(). ID_SND_RECEIPT_ACKED means that
the message arrived
End Rem
Const ID_SND_RECEIPT_ACKED:Int = 14
Rem
bbdoc:  If RakPeerInterface::Send() is called where PacketReliability contains UNRELIABLE_WITH_ACK_RECEIPT, then on a later call to RakPeerInterface::Receive() you will get ID_SND_RECEIPT_ACKED or ID_SND_RECEIPT_LOSS.
about: The message will be 5 bytes long,
and bytes 1-4 inclusive will contain a number in native order containing a number that identifies this message. This number
will be returned by RakPeerInterface::Send() or RakPeerInterface::SendList(). ID_SND_RECEIPT_LOSS means that an ack for the
message did not arrive (it may or may not have been delivered, probably not). On disconnect or shutdown, you will not get
ID_SND_RECEIPT_LOSS for unsent messages, you should consider those messages as all lost.
End Rem
Const ID_SND_RECEIPT_LOSS:Int = 15
	
'
' USER TYPES - DO NOT CHANGE THESE
'
Rem
bbdoc:  RakPeer - In a client/server environment, our connection request to the server has been accepted.
End Rem
Const ID_CONNECTION_REQUEST_ACCEPTED:Int = 16
Rem
bbdoc:  RakPeer - Sent to the player when a connection request cannot be completed due to inability to connect. 
End Rem
Const ID_CONNECTION_ATTEMPT_FAILED:Int = 17
Rem
bbdoc:  RakPeer - Sent a connect request to a system we are currently connected to.
End Rem
Const ID_ALREADY_CONNECTED:Int = 18
Rem
bbdoc:  RakPeer - A remote system has successfully connected.
End Rem
Const ID_NEW_INCOMING_CONNECTION:Int = 19
Rem
bbdoc:  RakPeer - The system we attempted to connect to is not accepting new connections.
End Rem
Const ID_NO_FREE_INCOMING_CONNECTIONS:Int = 20
Rem
bbdoc:  RakPeer - The system specified in Packet::systemAddress has disconnected from us.
about: For the client, this would mean the server has shutdown. 
End Rem
Const ID_DISCONNECTION_NOTIFICATION:Int = 21
Rem
bbdoc:  RakPeer - Reliable packets cannot be delivered to the system specified in Packet::systemAddress.
about: The connection to that system has been closed. 
End Rem
Const ID_CONNECTION_LOST:Int = 22
Rem
bbdoc:  RakPeer - We are banned from the system we attempted to connect to.
End Rem
Const ID_CONNECTION_BANNED:Int = 23
Rem
bbdoc:  RakPeer - The remote system is using a password and has refused our connection because we did not set the correct password.
End Rem
Const ID_INVALID_PASSWORD:Int = 24
Rem
bbdoc:  RAKNET_PROTOCOL_VERSION in version.h does not match on the remote system what we have on our system
about: This means the two systems cannot communicate.
The 2nd byte of the message contains the value of RAKNET_PROTOCOL_VERSION for the remote system
End Rem
Const ID_INCOMPATIBLE_PROTOCOL_VERSION:Int = 25
Rem
bbdoc:  Means that this IP address connected recently, and can't connect again as a security measure.
about: See RakPeer::SetLimitIPConnectionFrequency()
End Rem 
Const ID_IP_RECENTLY_CONNECTED:Int = 26
Rem
bbdoc:  RakPeer - The sizeof(RakNetTime) bytes following this byte represent a value which is automatically modified by the difference in system times between the sender and the recipient. 
about: Requires that you call SetOccasionalPing.
End Rem
Const ID_TIMESTAMP:Int = 27
Rem
bbdoc: RakPeer - Pong from an unconnected system.  First byte is ID_UNCONNECTED_PONG, second sizeof(SLNet::TimeMS) bytes is the ping,
	/// following bytes is system specific enumeration data.
	/// Read using bitstreams
End rem
Const ID_UNCONNECTED_PONG:Int = 28
Rem
bbdoc: RakPeer - Inform a remote system of our IP/Port. On the recipient, all data past ID_ADVERTISE_SYSTEM is whatever was passed to
	/// the data parameter
	end rem
Const ID_ADVERTISE_SYSTEM:Int = 29
Rem
bbdoc: RakPeer - Downloading a large message. Format is ID_DOWNLOAD_PROGRESS (MessageID), partCount (unsigned int),
	///  partTotal (unsigned int),
	/// partLength (unsigned int), first part data (length <= MAX_MTU_SIZE). See the three parameters partCount, partTotal
	///  and partLength in OnFileProgress in FileListTransferCBInterface.h
end rem
Const ID_DOWNLOAD_PROGRESS:Int = 30
Rem
bbdoc: ConnectionGraph2 plugin - In a client/server environment, a client other than ourselves has disconnected gracefully.
	///   Packet::systemAddress is modified to reflect the systemAddress of this client.
end rem
Const ID_REMOTE_DISCONNECTION_NOTIFICATION:Int = 31
Rem
bbdoc: ConnectionGraph2 plugin - In a client/server environment, a client other than ourselves has been forcefully dropped.
	///  Packet::systemAddress is modified to reflect the systemAddress of this client.
end rem
Const ID_REMOTE_CONNECTION_LOST:Int = 32
Rem
bbdoc:  ConnectionGraph2 plugin: Bytes 1-4 = count. for (count items) contains {SystemAddress, RakNetGUID, 2 byte ping}
End Rem
Const ID_REMOTE_NEW_INCOMING_CONNECTION:Int = 33

Rem
bbdoc:  FileListTransfer plugin - Setup data
End Rem
Const ID_FILE_LIST_TRANSFER_HEADER:Int = 34
Rem
bbdoc:  FileListTransfer plugin - A file
End Rem
Const ID_FILE_LIST_TRANSFER_FILE:Int = 35
Rem
bbdoc: Ack For reference push, To send more of the file
End Rem
Const ID_FILE_LIST_REFERENCE_PUSH_ACK:Int = 36

Rem
bbdoc:  DirectoryDeltaTransfer plugin - Request from a remote system for a download of a directory
End Rem
Const ID_DDT_DOWNLOAD_REQUEST:Int = 37
	
Rem
bbdoc:  RakNetTransport plugin - Transport provider message, used for remote console
End Rem
Const ID_TRANSPORT_STRING:Int = 38

 Rem
bbdoc:  ReplicaManager plugin - Create an object
End Rem
Const ID_REPLICA_MANAGER_CONSTRUCTION:Int = 39
 Rem
bbdoc:  ReplicaManager plugin - Changed scope of an object
End Rem
 Const ID_REPLICA_MANAGER_SCOPE_CHANGE:Int = 40
 Rem
bbdoc:  ReplicaManager plugin - Serialized data of an object
End Rem
Const ID_REPLICA_MANAGER_SERIALIZE:Int = 41
 Rem
bbdoc:  ReplicaManager plugin - New connection, about to send all world objects
End Rem
Const ID_REPLICA_MANAGER_DOWNLOAD_STARTED:Int = 42
 Rem
bbdoc:  ReplicaManager plugin - Finished downloading all serialized objects
End Rem
Const ID_REPLICA_MANAGER_DOWNLOAD_COMPLETE:Int = 43

Rem
bbdoc:  RakVoice plugin - Open a communication channel
End Rem
Const ID_RAKVOICE_OPEN_CHANNEL_REQUEST:Int = 44
Rem
bbdoc:  RakVoice plugin - Communication channel accepted
End Rem
Const ID_RAKVOICE_OPEN_CHANNEL_REPLY:Int = 45
Rem
bbdoc:  RakVoice plugin - Close a communication channel
End Rem
Const ID_RAKVOICE_CLOSE_CHANNEL:Int = 46
Rem
bbdoc:  RakVoice plugin - Voice data
End Rem
Const ID_RAKVOICE_DATA:Int = 47

Rem
bbdoc:  Autopatcher plugin - Get a list of files that have changed since a certain date
End Rem
Const ID_AUTOPATCHER_GET_CHANGELIST_SINCE_DATE:Int = 48
Rem
bbdoc:  Autopatcher plugin - A list of files to create
End Rem
Const ID_AUTOPATCHER_CREATION_LIST:Int = 49
Rem
bbdoc:  Autopatcher plugin - A list of files to delete
End Rem
Const ID_AUTOPATCHER_DELETION_LIST:Int = 50
Rem
bbdoc:  Autopatcher plugin - A list of files to get patches for
End Rem
Const ID_AUTOPATCHER_GET_PATCH:Int = 51
Rem
bbdoc:  Autopatcher plugin - A list of patches for a list of files
End Rem
Const ID_AUTOPATCHER_PATCH_LIST:Int = 52
Rem
bbdoc:  Autopatcher plugin - Returned to the user: An error from the database repository for the autopatcher.
End Rem
Const ID_AUTOPATCHER_REPOSITORY_FATAL_ERROR:Int = 53
Rem
bbdoc:  Autopatcher plugin - Returned to the user: The server does not allow downloading unmodified game files.
End Rem
Const ID_AUTOPATCHER_CANNOT_DOWNLOAD_ORIGINAL_UNMODIFIED_FILES:Int = 54
Rem
bbdoc:  Autopatcher plugin - Finished getting all files from the autopatcher
End Rem
Const ID_AUTOPATCHER_FINISHED_INTERNAL:Int = 55
Const ID_AUTOPATCHER_FINISHED:Int = 56
Rem
bbdoc:  Autopatcher plugin - Returned to the user: You must restart the application to finish patching.
End Rem
Const ID_AUTOPATCHER_RESTART_APPLICATION:Int = 57

Rem
bbdoc:  NATPunchthrough plugin: internal
End Rem
Const ID_NAT_PUNCHTHROUGH_REQUEST:Int = 58
Rem
bbdoc:  NATPunchthrough plugin: internal
End Rem
Const ID_NAT_CONNECT_AT_TIME:Int = 59
Rem
bbdoc:  NATPunchthrough plugin: internal
End Rem
Const ID_NAT_GET_MOST_RECENT_PORT:Int = 60
Rem
bbdoc:  NATPunchthrough plugin: internal
End Rem
Const ID_NAT_CLIENT_READY:Int = 61

Rem
bbdoc: NATPunchthrough plugin: Destination system is not connected to the server. Bytes starting at offset 1 contains the
	///  RakNetGUID destination field of NatPunchthroughClient::OpenNAT().
end rem
Const ID_NAT_TARGET_NOT_CONNECTED:Int = 62
Rem
bbdoc: NATPunchthrough plugin: Destination system is not responding to ID_NAT_GET_MOST_RECENT_PORT. Possibly the plugin is not installed.
	///  Bytes starting at offset 1 contains the RakNetGUID  destination field of NatPunchthroughClient::OpenNAT().
end rem
Const ID_NAT_TARGET_UNRESPONSIVE:Int = 63
Rem
bbdoc: NATPunchthrough plugin: The server lost the connection to the destination system while setting up punchthrough.
	///  Possibly the plugin is not installed. Bytes starting at offset 1 contains the RakNetGUID  destination
	///  field of NatPunchthroughClient::OpenNAT().
end rem
Const ID_NAT_CONNECTION_TO_TARGET_LOST:Int = 64
Rem
bbdoc: NATPunchthrough plugin: This punchthrough is already in progress. Possibly the plugin is not installed.
	///  Bytes starting at offset 1 contains the RakNetGUID destination field of NatPunchthroughClient::OpenNAT().
end rem
Const ID_NAT_ALREADY_IN_PROGRESS:Int = 65
Rem
bbdoc: NATPunchthrough plugin: This message is generated on the local system, and does not come from the network.
	///  packet::guid contains the destination field of NatPunchthroughClient::OpenNAT(). Byte 1 contains 1 if you are the sender, 0 if not
end rem
Const ID_NAT_PUNCHTHROUGH_FAILED:Int = 66
Rem
bbdoc: NATPunchthrough plugin: Punchthrough succeeded. See packet::systemAddress and packet::guid. Byte 1 contains 1 if you are the sender,
	///  0 if not. You can now use RakPeer::Connect() or other calls to communicate with this system.
end rem
Const ID_NAT_PUNCHTHROUGH_SUCCEEDED:Int = 67

Rem
bbdoc: ReadyEvent plugin - Set the ready state for a particular system
	/// First 4 bytes after the message contains the id
end rem
Const ID_READY_EVENT_SET:Int = 68
Rem
bbdoc: ReadyEvent plugin - Unset the ready state for a particular system
	/// First 4 bytes after the message contains the id
end rem
Const ID_READY_EVENT_UNSET:Int = 69
Rem
bbdoc: All systems are in state ID_READY_EVENT_SET
	/// First 4 bytes after the message contains the id
end rem
Const ID_READY_EVENT_ALL_SET:Int = 70
Rem
bbdoc: \internal, do not process in your game
	/// ReadyEvent plugin - Request of ready event state - used for pulling data when newly connecting
end rem
Const ID_READY_EVENT_QUERY:Int = 71

Rem
bbdoc:  Lobby packets. Second byte indicates type.
End Rem
Const ID_LOBBY_GENERAL:Int = 72

Rem
bbdoc:  RPC3, RPC4 error
End Rem
Const ID_RPC_REMOTE_ERROR:Int = 73
Rem
bbdoc:  Plugin based replacement for RPC system
End Rem
Const ID_RPC_PLUGIN:Int = 74

Rem
bbdoc:  FileListTransfer transferring large files in chunks that are read only when needed, to save memory
End Rem
Const ID_FILE_LIST_REFERENCE_PUSH:Int = 75
Rem
bbdoc:  Force the ready event to all set
End Rem
Const ID_READY_EVENT_FORCE_ALL_SET:Int = 76

' Rooms function
Const ID_ROOMS_EXECUTE_FUNC:Int = 77
Const ID_ROOMS_LOGON_STATUS:Int = 78
Const ID_ROOMS_HANDLE_CHANGE:Int = 79

' Lobby2 message
Const ID_LOBBY2_SEND_MESSAGE:Int = 80
Const ID_LOBBY2_SERVER_ERROR:Int = 81

Rem
bbdoc: Informs user of a new host GUID. Packet::Guid contains this new host RakNetGuid. The old host can be read out using BitStream->Read(RakNetGuid) starting on byte 1
	/// This is not returned until connected to a remote system
	/// If the oldHost is UNASSIGNED_RAKNET_GUID, then this is the first time the host has been determined
end rem
Const ID_FCM2_NEW_HOST:Int = 82
Rem
bbdoc:  \internal For FullyConnectedMesh2 plugin
End Rem
Const ID_FCM2_REQUEST_FCMGUID:Int = 83
Rem
bbdoc:  \internal For FullyConnectedMesh2 plugin
End Rem
Const ID_FCM2_RESPOND_CONNECTION_COUNT:Int = 84
Rem
bbdoc:  \internal For FullyConnectedMesh2 plugin
End Rem
Const ID_FCM2_INFORM_FCMGUID:Int = 85
Rem
bbdoc:  \internal For FullyConnectedMesh2 plugin
End Rem
Const ID_FCM2_UPDATE_MIN_TOTAL_CONNECTION_COUNT:Int = 86
Rem
bbdoc: A remote system (not necessarily the host) called FullyConnectedMesh2::StartVerifiedJoin() with our system as the client
rem
bbdoc: Use FullyConnectedMesh2::GetVerifiedJoinRequiredProcessingList() to read systems
	/// For each system, attempt NatPunchthroughClient::OpenNAT() and/or RakPeerInterface::Connect()
	/// When this has been done for all systems, the remote system will automatically be informed of the results
	/// \note Only the designated client gets this message
	/// \note You won't get this message if you are already connected to all target systems
	/// \note If you fail to connect to a system, this does not automatically mean you will get ID_FCM2_VERIFIED_JOIN_FAILED as that system may have been shutting down from the host too
	/// \sa FullyConnectedMesh2::StartVerifiedJoin()
End Rem
Const ID_FCM2_VERIFIED_JOIN_START:Int = 87
Rem
bbdoc: \internal The client has completed processing for all systems designated in ID_FCM2_VERIFIED_JOIN_START
end rem
Const ID_FCM2_VERIFIED_JOIN_CAPABLE:Int = 88
Rem
bbdoc: Client failed to connect to a required systems notified via FullyConnectedMesh2::StartVerifiedJoin()
	/// RakPeerInterface::CloseConnection() was automatically called for all systems connected due to ID_FCM2_VERIFIED_JOIN_START 
	/// Programmer should inform the player via the UI that they cannot join this session, and to choose a different session
	/// \note Server normally sends us this message, however if connection to the server was lost, message will be returned locally
	/// \note Only the designated client gets this message
end rem
Const ID_FCM2_VERIFIED_JOIN_FAILED:Int = 89
Rem
bbdoc: The system that called StartVerifiedJoin() got ID_FCM2_VERIFIED_JOIN_CAPABLE from the client and then called RespondOnVerifiedJoinCapable() with true
	/// AddParticipant() has automatically been called for this system
	/// Use GetVerifiedJoinAcceptedAdditionalData() to read any additional data passed to RespondOnVerifiedJoinCapable()
	/// \note All systems in the mesh get this message
	/// \sa RespondOnVerifiedJoinCapable()
end rem
Const ID_FCM2_VERIFIED_JOIN_ACCEPTED:Int = 90
Rem
bbdoc: The system that called StartVerifiedJoin() got ID_FCM2_VERIFIED_JOIN_CAPABLE from the client and then called RespondOnVerifiedJoinCapable() with false
	/// CloseConnection() has been automatically called for each system connected to since ID_FCM2_VERIFIED_JOIN_START.
	/// The connection is NOT automatically closed to the original host that sent StartVerifiedJoin()
	/// Use GetVerifiedJoinRejectedAdditionalData() to read any additional data passed to RespondOnVerifiedJoinCapable()
	/// \note Only the designated client gets this message
	/// \sa RespondOnVerifiedJoinCapable()
end rem
Const ID_FCM2_VERIFIED_JOIN_REJECTED:Int = 91

Rem
bbdoc:  UDP proxy messages. Second byte indicates type.
End Rem
Const ID_UDP_PROXY_GENERAL:Int = 92

Rem
bbdoc:  SQLite3Plugin - execute
End Rem
Const ID_SQLite3_EXEC:Int = 93
Rem
bbdoc:  SQLite3Plugin - Remote database is unknown
End Rem
Const ID_SQLite3_UNKNOWN_DB:Int = 94
Rem
bbdoc:  Events happening with SQLiteClientLoggerPlugin
End Rem
Const ID_SQLLITE_LOGGER:Int = 95

Rem
bbdoc:  Sent to NatTypeDetectionServer
End Rem
Const ID_NAT_TYPE_DETECTION_REQUEST:Int = 96
Rem
bbdoc:  Sent to NatTypeDetectionClient. Byte 1 contains the type of NAT detected.
End Rem
Const ID_NAT_TYPE_DETECTION_RESULT:Int = 97

Rem
bbdoc:  Used by the router2 plugin
End Rem
Const ID_ROUTER_2_INTERNAL:Int = 98
Rem
bbdoc: No path is available or can be established to the remote system
	/// Packet::guid contains the endpoint guid that we were trying to reach
end rem
Const ID_ROUTER_2_FORWARDING_NO_PATH:Int = 99
Rem
bbdoc: \brief You can now call connect, ping, or other operations to the destination system.
	///
	/// Connect as follows:
	///
	/// SLNet::BitStream bs(packet->data, packet->length, false);
	/// bs.IgnoreBytes(sizeof(MessageID));
	/// RakNetGUID endpointGuid;
	/// bs.Read(endpointGuid);
	/// unsigned short sourceToDestPort;
	/// bs.Read(sourceToDestPort);
	/// char ipAddressString[32];
	/// packet->systemAddress.ToString(false, ipAddressString);
	/// rakPeerInterface->Connect(ipAddressString, sourceToDestPort, 0,0);
end rem
Const ID_ROUTER_2_FORWARDING_ESTABLISHED:Int = 100
Rem
bbdoc: The IP address for a forwarded connection has changed
	/// Read endpointGuid and port as per ID_ROUTER_2_FORWARDING_ESTABLISHED
end rem
Const ID_ROUTER_2_REROUTED:Int = 101

Rem
bbdoc: \internal Used by the team balancer plugin
end rem
Const ID_TEAM_BALANCER_INTERNAL:Int = 102
Rem
bbdoc: Cannot switch to the desired team because it is full. However, if someone on that team leaves, you will
	///  get ID_TEAM_BALANCER_TEAM_ASSIGNED later.
	/// For TeamBalancer: Byte 1 contains the team you requested to join. Following bytes contain NetworkID of which member
end rem
Const ID_TEAM_BALANCER_REQUESTED_TEAM_FULL:Int = 103
Rem
bbdoc: Cannot switch to the desired team because all teams are locked. However, if someone on that team leaves,
	///  you will get ID_TEAM_BALANCER_SET_TEAM later.
	/// For TeamBalancer: Byte 1 contains the team you requested to join.
end rem
Const ID_TEAM_BALANCER_REQUESTED_TEAM_LOCKED:Int = 104
Const ID_TEAM_BALANCER_TEAM_REQUESTED_CANCELLED:Int = 105
Rem
bbdoc: Team balancer plugin informing you of your team. Byte 1 contains the team you requested to join. Following bytes contain NetworkID of which member.
end rem
Const ID_TEAM_BALANCER_TEAM_ASSIGNED:Int = 106

Rem
bbdoc: Gamebryo Lightspeed integration
end rem
Const ID_LIGHTSPEED_INTEGRATION:Int = 107

Rem
bbdoc: XBOX integration
end rem
Const ID_XBOX_LOBBY:Int = 108

Rem
bbdoc: The password we used to challenge the other system passed, meaning the other system has called TwoWayAuthentication::AddPassword() with the same password we passed to TwoWayAuthentication::Challenge()
	/// You can read the identifier used to challenge as follows:
	/// SLNet::BitStream bs(packet->data, packet->length, false); bs.IgnoreBytes(sizeof(SLNet::MessageID)); SLNet::RakString password; bs.Read(password);
end rem
Const ID_TWO_WAY_AUTHENTICATION_INCOMING_CHALLENGE_SUCCESS:Int = 109
Const ID_TWO_WAY_AUTHENTICATION_OUTGOING_CHALLENGE_SUCCESS:Int = 110
Rem
bbdoc: A remote system sent us a challenge using TwoWayAuthentication::Challenge(), and the challenge failed.
	/// If the other system must pass the challenge to stay connected, you should call RakPeer::CloseConnection() to terminate the connection to the other system. 
end rem
Const ID_TWO_WAY_AUTHENTICATION_INCOMING_CHALLENGE_FAILURE:Int = 111
Rem
bbdoc: The other system did not add the password we used to TwoWayAuthentication::AddPassword()
	/// You can read the identifier used to challenge as follows:
	/// SLNet::BitStream bs(packet->data, packet->length, false); bs.IgnoreBytes(sizeof(MessageID)); SLNet::RakString password; bs.Read(password);
end rem
Const ID_TWO_WAY_AUTHENTICATION_OUTGOING_CHALLENGE_FAILURE:Int = 112
Rem
bbdoc: The other system did not respond within a timeout threshhold. Either the other system is not running the plugin or the other system was blocking on some operation for a long time.
	/// You can read the identifier used to challenge as follows:
	/// SLNet::BitStream bs(packet->data, packet->length, false); bs.IgnoreBytes(sizeof(MessageID)); SLNet::RakString password; bs.Read(password);
end rem
Const ID_TWO_WAY_AUTHENTICATION_OUTGOING_CHALLENGE_TIMEOUT:Int = 113
' \internal
Const ID_TWO_WAY_AUTHENTICATION_NEGOTIATION:Int = 114

' CloudClient / CloudServer
Const ID_CLOUD_POST_REQUEST:Int = 115
Const ID_CLOUD_RELEASE_REQUEST:Int = 116
Const ID_CLOUD_GET_REQUEST:Int = 117
Const ID_CLOUD_GET_RESPONSE:Int = 118
Const ID_CLOUD_UNSUBSCRIBE_REQUEST:Int = 119
Const ID_CLOUD_SERVER_TO_SERVER_COMMAND:Int = 120
Const ID_CLOUD_SUBSCRIPTION_NOTIFICATION:Int = 121

' LibVoice
Const ID_LIB_VOICE:Int = 122

Const ID_RELAY_PLUGIN:Int = 123
Const ID_NAT_REQUEST_BOUND_ADDRESSES:Int = 124
Const ID_NAT_RESPOND_BOUND_ADDRESSES:Int = 125
Const ID_FCM2_UPDATE_USER_CONTEXT:Int = 126
Const ID_RESERVED_3:Int = 127
Const ID_RESERVED_4:Int = 128
Const ID_RESERVED_5:Int = 129
Const ID_RESERVED_6:Int = 130
Const ID_RESERVED_7:Int = 131
Const ID_RESERVED_8:Int = 132
Const ID_RESERVED_9:Int = 133

Rem
bbdoc: For the user to use.  Start your first enumeration at this value.
end rem
Const ID_USER_PACKET_ENUM:Int = 134


Const RAKNET_STARTED:Int = 0
Const RAKNET_ALREADY_STARTED:Int = 1
Const INVALID_SOCKET_DESCRIPTORS:Int = 2
Const INVALID_MAX_CONNECTIONS:Int = 3
Const SOCKET_FAMILY_NOT_SUPPORTED:Int = 4
Const SOCKET_PORT_ALREADY_IN_USE:Int = 5
Const SOCKET_FAILED_TO_BIND:Int = 6
Const SOCKET_FAILED_TEST_SEND:Int = 7
Const PORT_CANNOT_BE_ZERO:Int = 8
Const FAILED_TO_CREATE_NETWORK_THREAD:Int = 9
Const COULD_NOT_GENERATE_GUID:Int = 10
Const STARTUP_OTHER_FAILURE:Int = 11

Const CONNECTION_ATTEMPT_STARTED:Int = 0
Const INVALID_PARAMETER:Int = 1
Const CANNOT_RESOLVE_DOMAIN_NAME:Int = 2
Const ALREADY_CONNECTED_TO_ENDPOINT:Int = 3
Const CONNECTION_ATTEMPT_ALREADY_IN_PROGRESS:Int = 4
Const SECURITY_INITIALIZATION_FAILED:Int = 5

