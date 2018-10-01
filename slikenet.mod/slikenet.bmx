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


Rem
bbdoc: 
End Rem
Module slk.slikenet

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: RakNet - 2014, Oculus VR, Inc"
ModuleInfo "Copyright: SLikeNet - 2016-2017 SLikeSoft"
ModuleInfo "Copyright: Wrapper - 2007-2018 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

?win32
ModuleInfo "CC_OPTS: -D_WIN32_WINNT=0x0600"
?

ModuleInfo "CC_OPTS: -DRAKNET_SUPPORT_IPV6 -D_USE_RAK_MEMORY_OVERRIDE=1"

Import "common.bmx"


Rem
bbdoc: Miscellaneous SlikeNet Functions.
End Rem
Type TSlkNet

	Rem
	bbdoc: Initialise seed for Random Generator.
	about: Parameters: 
	<ul>
	<li><b>seed</b> : The seed value for the random number generator.</li>
	</ul>
	End Rem
	Function SeedMT(seed:Int)
		bmx_slk_net_seedMT(seed)
	End Function
	
	Rem
	bbdoc: Gets a random int.
	End Rem
	Function RandomMT:Int()
		Return bmx_slk_net_randomMT()
	End Function
	
	Rem
	bbdoc: Gets a random float.
	End Rem
	Function FRandomMT:Float()
		Return bmx_slk_net_frandomMT()
	End Function
	
	Rem
	bbdoc: Randomizes a buffer.
	End Rem
	Function FillBufferMT(buffer:Byte Ptr, size:Int)
		bmx_slk_net_fillBufferMT(buffer, size)
	End Function
	
	Rem
	bbdoc: Returns the time, in milliseconds.
	End Rem
	Function GetTimeMS:Int()
		Return bmx_slk_net_gettimems()
	End Function
	
	Rem
	bbdoc: Returns the time, in nanoseconds.
	End Rem
	Function GetTimeNS:Long()
		Local v:Long
		bmx_slk_net_gettimens(Varptr v)
		Return v
	End Function
	
	Rem
	bbdoc: Returns the current version number multiplied by 1000.
	about: So, version 3.717 would be returned as 3717.
	End Rem
	Function GetVersion:Int()
		Return bmx_slk_net_getversion()
	End Function
	
	Rem
	bbdoc: Returns the current version number as a String.
	about: Unlike #GetVersion, this returns the actual value.
	End Rem
	Function GetVersionString:String()
		Return bmx_slk_net_getversionstring()
	End Function
	
	Rem
	bbdoc: Returns the compatible protocol version RakNet is using.
	about: When this value changes, it indicates this version of RakNet cannot connection to an older version. 
	ID_INCOMPATIBLE_PROTOCOL_VERSION will be returned on connection attempt in this case
	End Rem
	Function GetProtocolVersion:Int()
		Return bmx_slk_net_getprotocolversion()
	End Function
	
	Rem
	bbdoc: Returns the version release date.
	End Rem
	Function GetDate:String()
		Return bmx_slk_net_getdate()
	End Function
	
End Type

Rem
bbdoc: The main interface for network communications.
about: Abstract. See TSlkRakPeer for implementation.
End Rem
Type TSlkRakPeerInterface

	Field rakPeerPtr:Byte Ptr
	
	Function GetInstance:TSlkRakPeerInterface()
		Return TSlkRakPeer._create(bmx_slk_RakPeerInterface_GetInstance())
	End Function
	
	Function DestroyInstance(instance:TSlkRakPeerInterface)
		bmx_slk_RakPeerInterface_DestroyInstance(instance.rakPeerPtr)
	End Function
	
	Method Startup:Int(maxConnections:Int, descriptors:TSlkSocketDescriptor[] = Null, threadPriority:Int = -99999) Abstract
	Method InitializeSecurity:Int(publicKey:Byte Ptr, privateKey:Byte Ptr, bRequireClientKey:Int = False) Abstract
	Method DisableSecurity() Abstract
	Method AddToSecurityExceptionList(ip:String) Abstract
	Method RemoveFromSecurityExceptionList(ip:String) Abstract
	Method IsInSecurityExceptionList:Int(ip:String) Abstract
	Method SetMaximumIncomingConnections(numberAllowed:Int) Abstract
	Method GetMaximumIncomingConnections:Int() Abstract
	Method NumberOfConnections:Int() Abstract
	Method SetIncomingPassword(passwordData:String) Abstract
	Method GetIncomingPassword:String() Abstract
	Method Connect:Int(host:String, remotePort:Int, passwordData:String = Null, publicKey:TSlkPublicKey = Null, connectionSocketIndex:Int = 0, sendConnectionAttemptCount:Int = 6, timeBetweenSendConnectionAttemptsMS:Int = 1000, timeoutTime:Int = 0) Abstract
	Method ConnectWithSocket:Int(host:String, remotePort:Int, passwordData:String = Null, socket:TSlkRakNetSocket, publicKey:TSlkPublicKey = Null, sendConnectionAttemptCount:Int = 6, timeBetweenSendConnectionAttemptsMS:Int = 1000, timeoutTime:Int = 0) Abstract

	Method Shutdown(blockDuration:Int, orderingChannel:Int = 0, disconnectionNotificationPriority:Int = PACKET_LOW_PRIORITY) Abstract
	Method IsActive:Int() Abstract
	Method GetNextSendReceipt:Int() Abstract
	Method IncrementNextSendReceipt:Int() Abstract
	
	Method Receive:TSlkPacket() Abstract
	Method DeallocatePacket(p:TSlkPacket) Abstract
	Method GetMaximumNumberOfPeers:Int() Abstract

	Method CloseConnection(target:TSlkSystemAddress, sendDisconnectionNotification:Int, orderingChannel:Int = 0, disconnectionNotificationPriority:Int = PACKET_LOW_PRIORITY) Abstract
	Method GetConnectionState:Int(addr:TSlkSystemAddress) Abstract
	Method GetIndexFromSystemAddress:Int(addr:TSlkSystemAddress) Abstract
	Method GetSystemAddressFromIndex:TSlkSystemAddress(index:Int) Abstract
	Method AddToBanList(ip:String, milliseconds:Int = 0) Abstract
	Method RemoveFromBanList(ip:String) Abstract
	Method ClearBanList() Abstract
	Method IsBanned:Int(ip:String) Abstract
	Method Ping(addr:TSlkSystemAddress) Abstract
	Method GetAveragePing:Int(addr:TSlkSystemAddress) Abstract
	Method GetLastPing:Int(addr:TSlkSystemAddress) Abstract
	Method GetLowestPing:Int(addr:TSlkSystemAddress) Abstract
	Method SetOccasionalPing(doPing:Int) Abstract
	Method SetOfflinePingResponse(data:Byte[]) Abstract
	Method GetOfflinePingResponse:Byte[]() Abstract
	
	Method SendBitStream:Int( bitStream:TSlkBitStream, priority:Int, reliability:Int, orderingChannel:Int, systemAddress:TSlkSystemAddress, broadcast:Int,forceReceiptNumber:Int = 0) Abstract
	Method Send:Int(data:Byte Ptr, length:Int, priority:Int, reliability:Int, orderingChannel:Int, systemAddress:TSlkSystemAddress, broadcast:Int, forceReceiptNumber:Int = 0) Abstract
	
	Method SetPerConnectionOutgoingBandwidthLimit(maxBitsPerSecond:Int) Abstract
	
	' Statistics methods
	Method GetStatistics:TSlkRakNetStatistics(addr:TSlkSystemAddress) Abstract

	Method AttachPlugin(plugin:TSlkPluginInterface) Abstract
	Method DetachPlugin(plugin:TSlkPluginInterface) Abstract

	Method GetInternalID:TSlkSystemAddress(systemAddress:TSlkSystemAddress = Null, index:Int = 0) Abstract
	Method GetExternalID:TSlkSystemAddress(target:TSlkSystemAddress) Abstract
	Method SetTimeoutTime(timeMS:Int, target:TSlkSystemAddress) Abstract
	Method GetMTUSize:Int(target:TSlkSystemAddress) Abstract
	Method GetNumberOfAddresses:Int() Abstract
	Method GetLocalIP:String(index:Int) Abstract
	Method IsLocalIP:Int(ip:String) Abstract
	Method AllowConnectionResponseIPMigration(allow:Int) Abstract
	Method AdvertiseSystem:Int(host:String, remotePort:Int, data:Byte Ptr, dataLength:Int, connectionSocketIndex:Int = 0) Abstract
	Method SetSplitMessageProgressInterval(interval:Int) Abstract
	Method SetUnreliableTimeout(timeoutMS:Int) Abstract
	Method SendTTL(host:String, remotePort:Int, ttl:Int, connectionSocketIndex:Int = 0) Abstract
	Method GetGuidFromSystemAddress:TSlkRakNetGUID(systemAddress:TSlkSystemAddress) Abstract

	Method PushBackPacket(packet:TSlkPacket, pushAtHead:Int) Abstract
	Method AllocatePacket:TSlkPacket(dataSize:Int) Abstract
	Method PingHost(host:String, remotePort:Int, onlyReplyOnAcceptingConnections:Int, connectionSocketIndex:Int = 0) Abstract

	Method GetSockets:TSlkRakNetSocket[]() Abstract
	Method GetConnectionList:Int(remoteSystems:TSlkSystemAddress[], connections:Int Var) Abstract
	Method GetMyGUID:TSlkRakNetGUID() Abstract
	Method GetSystemAddressFromGuid:TSlkSystemAddress(guid:TSlkRakNetGUID) Abstract
	
End Type

Rem
bbdoc: 
End Rem
Type TSlkRakPeer Extends TSlkRakPeerInterface

	Function _create:TSlkRakPeer(rakPeerPtr:Byte Ptr)
		If rakPeerPtr Then
			Local this:TSlkRakPeer = New TSlkRakPeer
			this.rakPeerPtr = rakPeerPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: 
	End Rem
	Method Startup:Int(maxConnections:Int, descriptors:TSlkSocketDescriptor[] = Null, threadPriority:Int = -99999)
		If descriptors Then
			Local d:Byte Ptr[descriptors.length]
			For Local i:Int = 0 Until descriptors.length
				d[i] = descriptors[i].socketDescriptorPtr
			Next
			Return bmx_slk_RakPeer_Startup(rakPeerPtr, maxConnections, d, threadPriority)
		Else
			Return bmx_slk_RakPeer_Startup(rakPeerPtr, maxConnections, Null, threadPriority)
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method InitializeSecurity:Int(publicKey:Byte Ptr, privateKey:Byte Ptr, requireClientKey:Int = False)
		If publicKey Then
			If privateKey Then
				Return bmx_slk_RakPeer_InitializeSecurity(rakPeerPtr, publicKey, privateKey, requireClientKey)
			Else
				Return bmx_slk_RakPeer_InitializeSecurity(rakPeerPtr, publicKey, Null, requireClientKey)
			End If
		Else
			If privateKey Then
				Return bmx_slk_RakPeer_InitializeSecurity(rakPeerPtr, Null, privateKey, requireClientKey)
			Else
				Return bmx_slk_RakPeer_InitializeSecurity(rakPeerPtr, Null, Null, requireClientKey)
			End If
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method DisableSecurity()
		bmx_slk_RakPeer_DisableSecurity(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method AddToSecurityExceptionList(ip:String)
		bmx_slk_RakPeer_AddToSecurityExceptionList(rakPeerPtr, ip)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method RemoveFromSecurityExceptionList(ip:String)
		bmx_slk_RakPeer_RemoveFromSecurityExceptionList(rakPeerPtr, ip)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method IsInSecurityExceptionList:Int(ip:String)
		Return bmx_slk_RakPeer_IsInSecurityExceptionList(rakPeerPtr, ip)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetMaximumIncomingConnections(numberAllowed:Int)
		bmx_slk_RakPeer_SetMaximumIncomingConnections(rakPeerPtr, numberAllowed)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetMaximumIncomingConnections:Int()
		Return bmx_slk_RakPeer_GetMaximumIncomingConnections(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method NumberOfConnections:Int()
		Return bmx_slk_RakPeer_NumberOfConnections(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetIncomingPassword(passwordData:String)
		bmx_slk_RakPeer_SetIncomingPassword(rakPeerPtr, passwordData)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetIncomingPassword:String()
		Return bmx_slk_RakPeer_GetIncomingPassword(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method Connect:Int(host:String, remotePort:Int, passwordData:String = Null, publicKey:TSlkPublicKey = Null, connectionSocketIndex:Int = 0, sendConnectionAttemptCount:Int = 6, timeBetweenSendConnectionAttemptsMS:Int = 1000, timeoutTime:Int = 0)
		If publicKey Then
			Return bmx_slk_RakPeer_Connect(rakPeerPtr, host, remotePort, passwordData, publicKey.publicKeyPtr, connectionSocketIndex, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime)
		Else
			Return bmx_slk_RakPeer_Connect(rakPeerPtr, host, remotePort, passwordData, Null, connectionSocketIndex, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime)
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ConnectWithSocket:Int(host:String, remotePort:Int, passwordData:String = Null, socket:TSlkRakNetSocket, publicKey:TSlkPublicKey = Null, sendConnectionAttemptCount:Int = 6, timeBetweenSendConnectionAttemptsMS:Int = 1000, timeoutTime:Int = 0)
		If publicKey Then
			Return bmx_slk_RakPeer_ConnectWithSocket(rakPeerPtr, host, remotePort, passwordData, socket.socketPtr, publicKey.publicKeyPtr, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime)
		Else
			Return bmx_slk_RakPeer_ConnectWithSocket(rakPeerPtr, host, remotePort, passwordData, socket.socketPtr, Null, sendConnectionAttemptCount, timeBetweenSendConnectionAttemptsMS, timeoutTime)
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method Shutdown(blockDuration:Int, orderingChannel:Int = 0, disconnectionNotificationPriority:Int = PACKET_LOW_PRIORITY)
		bmx_slk_RakPeer_Shutdown(rakPeerPtr, blockDuration, orderingChannel, disconnectionNotificationPriority)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method IsActive:Int()
		Return bmx_slk_RakPeer_IsActive(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetNextSendReceipt:Int()
		Return bmx_slk_RakPeer_GetNextSendReceipt(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method IncrementNextSendReceipt:Int()
		Return bmx_slk_RakPeer_IncrementNextSendReceipt(rakPeerPtr)
	End Method

	
	Rem
	bbdoc: 
	End Rem
	Method Receive:TSlkPacket()
		Return TSlkPacket._create(bmx_slk_RakPeer_Receive(rakPeerPtr))
	End Method
	
	Rem
	bbdoc: Call this to deallocate a message returned by Receive() when you are done handling it.
	about: Parameters: 
	<ul>
	<li><b>packet</b> : The message to deallocate.</li>
	</ul>
	End Rem
	Method DeallocatePacket(packet:TSlkPacket)
		If packet Then ' handle null - for the lazy folks :-p
			bmx_slk_RakPeer_DeallocatePacket(rakPeerPtr, packet.packetPtr)
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetMaximumNumberOfPeers:Int()
		Return bmx_slk_RakPeer_GetMaximumNumberOfPeers(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method CloseConnection(target:TSlkSystemAddress, sendDisconnectionNotification:Int, orderingChannel:Int = 0, disconnectionNotificationPriority:Int = PACKET_LOW_PRIORITY)
		bmx_slk_RakPeer_CloseConnection(rakPeerPtr, target.systemAddressPtr, sendDisconnectionNotification, orderingChannel, disconnectionNotificationPriority)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetConnectionState:Int(addr:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetConnectionState(rakPeerPtr, addr.systemAddressPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetIndexFromSystemAddress:Int(addr:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetIndexFromSystemAddress(rakPeerPtr, addr.systemAddressPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetSystemAddressFromIndex:TSlkSystemAddress(index:Int)
		Return TSlkSystemAddress._create(bmx_slk_RakPeer_GetSystemAddressFromIndex(rakPeerPtr, index))
	End Method

	Rem
	bbdoc: 
	End Rem
	Method AddToBanList(ip:String, milliseconds:Int = 0)
		bmx_slk_RakPeer_AddToBanList(rakPeerPtr, ip, milliseconds)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method RemoveFromBanList(ip:String)
		bmx_slk_RakPeer_RemoveFromBanList(rakPeerPtr, ip)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ClearBanList()
		bmx_slk_RakPeer_ClearBanList(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method IsBanned:Int(ip:String)
		Return bmx_slk_RakPeer_IsBanned(rakPeerPtr, ip)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method Ping(addr:TSlkSystemAddress)
		bmx_slk_RakPeer_Ping(rakPeerPtr, addr.systemAddressPtr)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetAveragePing:Int(addr:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetAveragePing(rakPeerPtr, addr.systemAddressPtr)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetLastPing:Int(addr:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetLastPing(rakPeerPtr, addr.systemAddressPtr)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetLowestPing:Int(addr:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetLowestPing(rakPeerPtr, addr.systemAddressPtr)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetOccasionalPing(doPing:Int)
		bmx_slk_RakPeer_SetOccasionalPing(rakPeerPtr, doPing)		
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetOfflinePingResponse(data:Byte[])
		If data Then
			bmx_slk_RakPeer_SetOfflinePingResponse(rakPeerPtr, data, data.length)
		Else
			bmx_slk_RakPeer_SetOfflinePingResponse(rakPeerPtr, Null, 0)
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetOfflinePingResponse:Byte[]()
		Return bmx_slk_RakPeer_GetOfflinePingResponse(rakPeerPtr)
	End Method

	
	Rem
	bbdoc: 
	End Rem
	Method SendBitStream:Int( bitStream:TSlkBitStream, priority:Int, reliability:Int, orderingChannel:Int, systemIdentifier:TSlkSystemAddress, broadcast:Int, forceReceiptNumber:Int = 0)
		Return bmx_slk_RakPeer_SendBitStream(rakPeerPtr, bitStream.bitStreamPtr, priority, reliability, orderingChannel, systemIdentifier.systemAddressPtr, broadcast, forceReceiptNumber)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method Send:Int(data:Byte Ptr, length:Int, priority:Int, reliability:Int, orderingChannel:Int, systemIdentifier:TSlkSystemAddress, broadcast:Int, forceReceiptNumber:Int = 0)
		Return bmx_slk_RakPeer_Send(rakPeerPtr, data,length, priority, reliability, orderingChannel, systemIdentifier.systemAddressPtr, broadcast, forceReceiptNumber)
	End Method


	Rem
	bbdoc: 
	End Rem
	Method SetPerConnectionOutgoingBandwidthLimit(maxBitsPerSecond:Int)
		bmx_slk_RakPeer_SetPerConnectionOutgoingBandwidthLimit(rakPeerPtr, maxBitsPerSecond)
	End Method
	
	' Statistics methods
	Rem
	bbdoc: 
	End Rem
	Method GetStatistics:TSlkRakNetStatistics(addr:TSlkSystemAddress)
		Return TSlkRakNetStatistics._create(bmx_slk_RakPeer_GetStatistics(rakPeerPtr, addr.systemAddressPtr))
	End Method


	Method AttachPlugin(plugin:TSlkPluginInterface)
		bmx_slk_RakPeer_AttachPlugin(rakPeerPtr, plugin.pluginPtr)
	End Method

	Method DetachPlugin(plugin:TSlkPluginInterface)
		bmx_slk_RakPeer_DetachPlugin(rakPeerPtr, plugin.pluginPtr)
	End Method


	Rem
	bbdoc: 
	End Rem
	Method GetInternalID:TSlkSystemAddress(systemAddress:TSlkSystemAddress = Null, index:Int = 0)
		If systemAddress Then
			Return TSlkSystemAddress._create(bmx_slk_RakPeer_GetInternalID(rakPeerPtr, systemAddress.systemAddressPtr, index))
		Else
			Return TSlkSystemAddress._create(bmx_slk_RakPeer_GetInternalID(rakPeerPtr, UNASSIGNED_SYSTEM_ADDRESS.systemAddressPtr, index))
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetExternalID:TSlkSystemAddress(target:TSlkSystemAddress)
		' TODO
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetTimeoutTime(timeMS:Int, target:TSlkSystemAddress)
		bmx_slk_RakPeer_SetTimeoutTime(rakPeerPtr, timeMS, target.systemAddressPtr)	
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetMTUSize:Int(target:TSlkSystemAddress)
		Return bmx_slk_RakPeer_GetMTUSize(rakPeerPtr, target.systemAddressPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetNumberOfAddresses:Int()
		Return bmx_slk_RakPeer_GetNumberOfAddresses(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetLocalIP:String(index:Int)
		Return bmx_slk_RakPeer_GetLocalIP(rakPeerPtr, index)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method IsLocalIP:Int(ip:String)
		Return bmx_slk_RakPeer_IsLocalIP(rakPeerPtr, ip)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method AllowConnectionResponseIPMigration(allow:Int)
		bmx_slk_RakPeer_AllowConnectionResponseIPMigration(rakPeerPtr, allow)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method AdvertiseSystem:Int(host:String, remotePort:Int, data:Byte Ptr, dataLength:Int, connectionSocketIndex:Int = 0)
		Return bmx_slk_RakPeer_AdvertiseSystem(rakPeerPtr, host, remotePort, data, dataLength, connectionSocketIndex)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetSplitMessageProgressInterval(interval:Int)
		bmx_slk_RakPeer_SetSplitMessageProgressInterval(rakPeerPtr, interval)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetUnreliableTimeout(timeoutMS:Int)
		bmx_slk_RakPeer_SetUnreliableTimeout(rakPeerPtr, timeoutMS)
	End Method

	Rem
	bbdoc: Sends a message to a host, with the IP socket option TTL set to 3.
	about: This message will not reach the host, but will open the router.
	Used for NAT-Punchthrough.
	End Rem
	Method SendTTL(host:String, remotePort:Int, ttl:Int, connectionSocketIndex:Int = 0)
		bmx_slk_RakPeer_SendTTL(rakPeerPtr, host, remotePort, ttl, connectionSocketIndex)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetGuidFromSystemAddress:TSlkRakNetGUID(systemAddress:TSlkSystemAddress)
		Return TSlkRakNetGUID._create(bmx_slk_RakPeer_GetGuidFromSystemAddress(rakPeerPtr, systemAddress.systemAddressPtr))
	End Method


	Rem
	bbdoc: Puts a message back in the receive queue in case you don't want to deal with it immediately.
	End Rem
	Method PushBackPacket(packet:TSlkPacket, pushAtHead:Int)
		bmx_slk_RakPeer_PushBackPacket(rakPeerPtr, packet.packetPtr, pushAtHead)
	End Method

	Rem
	bbdoc: Returns a packet for you to write to if you want to create a Packet for some reason.
	Bout: You can add it to the receive buffer with #PushBackPacket.
	End Rem
	Method AllocatePacket:TSlkPacket(dataSize:Int)
		Return TSlkPacket._create(bmx_slk_RakPeer_AllocatePacket(rakPeerPtr, dataSize))
	End Method

	Rem
	bbdoc: 
	End Rem
	Method PingHost(host:String, remotePort:Int, onlyReplyOnAcceptingConnections:Int, connectionSocketIndex:Int = 0)
		bmx_slk_RakPeer_PingHost(rakPeerPtr, host, remotePort, onlyReplyOnAcceptingConnections, connectionSocketIndex)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetSockets:TSlkRakNetSocket[]()
		Return bmx_slk_RakPeer_GetSockets(rakPeerPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetConnectionList:Int(remoteSystems:TSlkSystemAddress[], connections:Int Var)
		Return bmx_slk_RakPeer_GetConnectionList(rakPeerPtr, remoteSystems, Varptr connections)
	End Method

	Method GetMyGUID:TSlkRakNetGUID()
		Return TSlkRakNetGUID._create(bmx_slk_RakPeer_GetMyGUID(rakPeerPtr))
	End Method

	Method GetSystemAddressFromGuid:TSlkSystemAddress(guid:TSlkRakNetGUID)
		Return TSlkSystemAddress._create(bmx_slk_RakPeer_GetSystemAddressFromGuid(rakPeerPtr, guid.guidPtr))
	End Method

End Type

Extern
	Function bmx_slk_RakPeer_GetSockets:TSlkRakNetSocket[](handle:Byte Ptr)
	Function bmx_slk_RakPeer_GetConnectionList:Int(handle:Byte Ptr, remoteSystems:TSlkSystemAddress[], connections:Int Ptr)

End Extern

Rem
bbdoc: 
End Rem
Type TSlkSocketDescriptor

	Field socketDescriptorPtr:Byte Ptr

	Rem
	bbdoc: Creates a new SocketDescriptor.
	about: Parameters: 
	<ul>
	<li><b>port</b> : The local port to bind to. Pass 0 to have the OS autoassign a port.</li>
	<li><b>hostAddress</b> : The local network card address to bind to, such as "127.0.0.1". Pass an empty string to use INADDR_ANY.</li>
	</ul>
	End Rem
	Function CreateSocketDescriptor:TSlkSocketDescriptor(port:Int = 0, hostAddress:String = "")
		Return New TSlkSocketDescriptor.Create(port, hostAddress)
	End Function
	
	Rem
	bbdoc: Creates a new SocketDescriptor.
	about: Parameters: 
	<ul>
	<li><b>port</b> : The local port to bind to. Pass 0 to have the OS autoassign a port.</li>
	<li><b>hostAddress</b> : The local network card address to bind to, such as "127.0.0.1". Pass an empty string to use INADDR_ANY.</li>
	</ul>
	End Rem
	Method Create:TSlkSocketDescriptor(port:Int = 0, hostAddress:String = Null)
		socketDescriptorPtr = bmx_slk_SocketDescriptor_new(port, hostAddress)
		Return Self
	End Method
	
	Rem
	bbdoc: Sets the local port to bind to.
	about: Set to 0 to have the OS autoassign a port.
	End Rem
	Method SetPort(port:Int)
		bmx_slk_SocketDescriptor_setport(socketDescriptorPtr, port)
	End Method
	
	Rem
	bbdoc: Returns the local bound port.
	End Rem
	Method GetPort:Int()
		Return bmx_slk_SocketDescriptor_getport(socketDescriptorPtr)
	End Method
	
	Rem
	bbdoc: Sets the local network card address to bind to, such as "127.0.0.1".
	about: Set to an empty string to use INADDR_ANY
	End Rem
	Method SetHostAddress(hostAddress:String)
		If hostAddress.length > 32 Then
			hostAddress = hostAddress[..32]
		End If
		bmx_slk_SocketDescriptor_sethostaddress(socketDescriptorPtr, hostAddress)
	End Method
	
	Rem
	bbdoc: Returns the local bound network address.
	End Rem
	Method GetHostAddress:String()
		Return bmx_slk_SocketDescriptor_gethostaddress(socketDescriptorPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetSocketFamily(family:Int)
		bmx_slk_SocketDescriptor_setsocketfamily(socketDescriptorPtr, family)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetSocketFamily:Int()
		Return bmx_slk_SocketDescriptor_getsocketfamily(socketDescriptorPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetBlockingSocket(blocking:Int)
		bmx_slk_SocketDescriptor_setblockingsocket(socketDescriptorPtr, blocking)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetBlockingSocket:Int()
		Return bmx_slk_SocketDescriptor_getblockingsocket(socketDescriptorPtr)
	End Method
		
	Rem
	bbdoc: 
	End Rem
	Method SetExtraSocketOptions(options:Int)
		bmx_slk_SocketDescriptor_setextrasocketoptions(socketDescriptorPtr, options)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetExtraSocketOptions:Int()
		Return bmx_slk_SocketDescriptor_getextrasocketoptions(socketDescriptorPtr)
	End Method
	
	Method Delete()
		If socketDescriptorPtr Then
			bmx_slk_SocketDescriptor_delete(socketDescriptorPtr)
			socketDescriptorPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: 
End Rem
Type TSlkPublicKey

	Field publicKeyPtr:Byte Ptr
	
	Function _create:TSlkPublicKey(publicKeyPtr:Byte Ptr)
		If publicKeyPtr Then
			Local this:TSlkPublicKey = New TSlkPublicKey
			this.publicKeyPtr = publicKeyPtr
			Return this
		End If
	End Function

End Type

Rem
bbdoc: 
End Rem
Type TSlkRakNetSocket

	Field socketPtr:Byte Ptr
	
	Function _create:TSlkRakNetSocket(socketPtr:Byte Ptr)
		If socketPtr Then
			Local this:TSlkRakNetSocket = New TSlkRakNetSocket
			this.socketPtr = socketPtr
			Return this
		End If
	End Function
	
	Function _array:TSlkRakNetSocket[](size:Int) { nomangle }
		Return New TSlkRakNetSocket[size]
	End Function
	
	Function _insert(arr:TSlkRakNetSocket[], index:Int, socketPtr:Byte Ptr) { nomangle }
		arr[index] = _create(socketPtr)
	End Function
	
	Rem
	bbdoc: 
	End Rem
	Method GetSocketType:Int()
		Return bmx_slk_RakNetSocket_GetSocketType(socketPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method IsBerkleySocket:Int()
		Return bmx_slk_RakNetSocket_IsBerkleySocket(socketPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetBoundAddress:TSlkSystemAddress()
		Return TSlkSystemAddress._create(bmx_slk_RakNetSocket_GetBoundAddress(socketPtr))
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetUserConnectionSocketIndex:Int()
		Return bmx_slk_RakNetSocket_GetUserConnectionSocketIndex(socketPtr)
	End Method

End Type

Rem
bbdoc: This represents a user message from another system.
End Rem
Type TSlkPacket

	Field packetPtr:Byte Ptr

	Function _create:TSlkPacket(packetPtr:Byte Ptr)
		If packetPtr Then
			Local this:TSlkPacket = New TSlkPacket
			this.packetPtr = packetPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: The data from the sender.
	End Rem
	Method GetData:Byte Ptr()
		Return bmx_slk_Packet_GetData(packetPtr)
	End Method
	
	Rem
	bbdoc: The length of the data in bits.
	End Rem
	Method GetBitSize:Int()
		Return bmx_slk_Packet_GetBitSize(packetPtr)
	End Method
	
	Rem
	bbdoc: The length of the data, in bytes.
	End Rem
	Method GetLength:Int()
		Return bmx_slk_Packet_GetLength(packetPtr)
	End Method
	
	Rem
	bbdoc: The system that send this packet.
	End Rem
	Method GetSystemAddress:TSlkSystemAddress()
		Return TSlkSystemAddress._create(bmx_slk_Packet_GetSystemAddress(packetPtr))
	End Method
	
	Rem
	bbdoc: A unique identifier for the system that sent this packet, regardless of IP address (internal / external / remote system).
	about: Only valid once a connection has been established (ID_CONNECTION_REQUEST_ACCEPTED, or ID_NEW_INCOMING_CONNECTION).
	Until that time, will be UNASSIGNED_RAKNET_GUID
	End Rem
	Method GetGuid:TSlkRakNetGUID()
		Return TSlkRakNetGUID._create(bmx_slk_Packet_GetGuid(packetPtr), False)
	End Method

	Rem
	bbdoc: The packet identifier. eg. ID_NEW_INCOMING_CONNECTION.
	End Rem
	Method GetPacketIdentifier:Int()
		Return bmx_slk_Packet_GetPacketIdentifier(packetPtr)
	End Method

End Type

Rem
bbdoc: This type is simply used to generate a unique number for a group of instances of NetworkIDObject.
about:  An instance of this class is required to use the ObjectID to pointer lookup system You should have one instance of this
type per game instance. Call SetIsNetworkIDAuthority before using any methods of this type, or of NetworkIDObject.
End Rem
Type TSlkNetworkIDManager

	Field managerPtr:Byte Ptr
	
	Function CreateManager:TSlkNetworkIDManager()
		Return New TSlkNetworkIDManager.Create()
	End Function
	
	Method Create:TSlkNetworkIDManager()
		managerPtr = bmx_slk_NetworkIDManager_create()
		Return Self
	End Method
	
	Function _create:TSlkNetworkIDManager(managerPtr:Byte Ptr)
		If managerPtr Then
			Local this:TSlkNetworkIDManager = New TSlkNetworkIDManager
			this.managerPtr = managerPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: 
	End Rem
	Method Clear()
		bmk_slk_NetworkIDManager_Clear(managerPtr)
	End Method
	
	Rem
	bbdoc: Returns the parent object, or this instance if you don't use a parent.
	about: You must first call SetNetworkIDManager before using this method.
	End Rem
	Method GET_BASE_OBJECT_FROM_ID:TSlkNetworkIDObject(networkID:Long)
		Return TSlkNetworkIDObject._create(bmk_slk_NetworkIDManager_GET_BASE_OBJECT_FROM_ID(managerPtr, networkID))
	End Method

End Type

Rem
bbdoc: 
End Rem
Type TSlkNetworkIDObject

	Field networkObjectPtr:Byte Ptr
	
	Function _create:TSlkNetworkIDObject(networkObjectPtr:Byte Ptr)
		If networkObjectPtr Then
			Local this:TSlkNetworkIDObject = New TSlkNetworkIDObject
			this.networkObjectPtr = networkObjectPtr
			Return this
		End If
	End Function

End Type


Type TSlkRPCParameters
End Type

Rem
bbdoc: This Type allows you to write and read native types as a string of bits.
about: TSlkBitStream is used extensively throughout RakNet and is designed to be used by users as well.
End Rem
Type TSlkBitStream

	Field bitStreamPtr:Byte Ptr
	
	Field owner:Int

	Function _create:TSlkBitStream(bitStreamPtr:Byte Ptr)
		If bitStreamPtr Then
			Local this:TSlkBitStream = New TSlkBitStream
			this.bitStreamPtr = bitStreamPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: 
	End Rem
	Function CreateBitStream:TSlkBitStream()
		Return New TSlkBitStream.Create()
	End Function

	Rem
	bbdoc: 
	End Rem
	Method Create:TSlkBitStream()
		owner = True
		bitStreamPtr = bmx_slk_BitStream_Create()
		Return Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Function CreateFromData:TSlkBitStream(data:Byte Ptr, size:Int, copy:Int)
		If data Then
			Local this:TSlkBitStream = New TSlkBitStream
			this.owner = True
			this.bitStreamPtr = bmx_slk_BitStream_CreateFromData(data, size, copy)
			Return this
		End If
	End Function
	
	Rem
	bbdoc: Resets the bitstream for reuse.
	End Rem
	Method Reset()
		bmx_slk_BitStream_Reset(bitStreamPtr)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of a Byte to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeByte:Int(writeToBitstream:Int, value:Byte Var)
		Return bmx_slk_BitStream_SerializeByte(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of a Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeShort:Int(writeToBitstream:Int, value:Short Var)
		Return bmx_slk_BitStream_SerializeShort(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of an Unsigned Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeUShort:Int(writeToBitstream:Int, value:Short Var)
		Return bmx_slk_BitStream_SerializeUShort(bitStreamPtr, writeToBitstream, Varptr value)
	End Method
	
	Rem
	bbdoc: Bidirectional serialize/deserialize of an Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeInt:Int(writeToBitstream:Int, value:Int Var)
		Return bmx_slk_BitStream_SerializeInt(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of an Unsigned Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeUInt:Int(writeToBitstream:Int, value:Int Var)
		Return bmx_slk_BitStream_SerializeUInt(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of a Float to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeFloat:Int(writeToBitstream:Int, value:Float Var)
		Return bmx_slk_BitStream_SerializeFloat(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize of a Double to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	End Rem
	Method SerializeDouble:Int(writeToBitstream:Int, value:Double Var)
		Return bmx_slk_BitStream_SerializeDouble(bitStreamPtr, writeToBitstream, Varptr value)
	End Method
	
	Rem
	bbdoc: Bidirectional serialize/deserialize a Byte to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastByte:Int(writeToBitstream:Int, currentValue:Byte Var, lastValue:Byte)
		Return bmx_slk_BitStream_SerializeDeltaLastByte(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastShort:Int(writeToBitstream:Int, currentValue:Short Var, lastValue:Short)
		Return bmx_slk_BitStream_SerializeDeltaLastShort(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastUShort:Int(writeToBitstream:Int, currentValue:Short Var, lastValue:Short)
		Return bmx_slk_BitStream_SerializeDeltaLastUShort(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastInt:Int(writeToBitstream:Int, currentValue:Int Var, lastValue:Int)
		Return bmx_slk_BitStream_SerializeDeltaLastInt(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastUInt:Int(writeToBitstream:Int, currentValue:Int Var, lastValue:Int)
		Return bmx_slk_BitStream_SerializeDeltaLastUInt(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Float to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastFloat:Int(writeToBitstream:Int, currentValue:Float Var, lastValue:Float)
		Return bmx_slk_BitStream_SerializeDeltaLastFloat(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Double to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeDeltaLastDouble:Int(writeToBitstream:Int, currentValue:Double Var, lastValue:Double)
		Return bmx_slk_BitStream_SerializeDeltaLastDouble(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastByte when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaByte:Int(writeToBitstream:Int, currentValue:Byte Var)
		Return bmx_slk_BitStream_SerializeDeltaByte(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastShort when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaShort:Int(writeToBitstream:Int, currentValue:Short Var)
		Return bmx_slk_BitStream_SerializeDeltaShort(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastUShort when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaUShort:Int(writeToBitstream:Int, currentValue:Short Var)
		Return bmx_slk_BitStream_SerializeDeltaUShort(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastInt when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaInt:Int(writeToBitstream:Int, currentValue:Int Var)
		Return bmx_slk_BitStream_SerializeDeltaInt(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastUInt when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaUInt:Int(writeToBitstream:Int, currentValue:Int Var)
		Return bmx_slk_BitStream_SerializeDeltaUInt(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastFloat when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaFloat:Int(writeToBitstream:Int, currentValue:Float Var)
		Return bmx_slk_BitStream_SerializeDeltaFloat(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeDeltaLastDouble when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	End Rem
	Method SerializeDeltaDouble:Int(writeToBitstream:Int, currentValue:Double Var)
		Return bmx_slk_BitStream_SerializeDeltaDouble(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method
	
	Rem
	bbdoc: Bidirectional serialize/deserialize a Byte to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Byte.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedByte:Int(writeToBitstream:Int, value:Byte Var)
		Return bmx_slk_BitStream_SerializeCompressedByte(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Short to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Short.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedShort:Int(writeToBitstream:Int, value:Short Var)
		Return bmx_slk_BitStream_SerializeCompressedShort(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Short to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Unsigned Short.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedUShort:Int(writeToBitstream:Int, value:Short Var)
		Return bmx_slk_BitStream_SerializeCompressedUShort(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Int to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Int.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedInt:Int(writeToBitstream:Int, value:Int Var)
		Return bmx_slk_BitStream_SerializeCompressedInt(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Int to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Unsigned Int.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedUInt:Int(writeToBitstream:Int, value:Int Var)
		Return bmx_slk_BitStream_SerializeCompressedUInt(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Float to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossy, using 2 bytes for the Float. The range must be between -1 and +1.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedFloat:Int(writeToBitstream:Int, value:Float Var)
		Return bmx_slk_BitStream_SerializeCompressedFloat(bitStreamPtr, writeToBitstream, Varptr value)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Double to/from a bitstream, using compression.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossy, using 4 bytes for the Double. The range must be between -1 and +1.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> value </b> : The value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDouble:Int(writeToBitstream:Int, value:Double Var)
		Return bmx_slk_BitStream_SerializeCompressedDouble(bitStreamPtr, writeToBitstream, Varptr value)
	End Method
	
	Rem
	bbdoc: Bidirectional serialize/deserialize a Byte to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossless, but only has benefit if you use less than half the range of the Byte.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastByte:Int(writeToBitstream:Int, currentValue:Byte Var, lastValue:Byte)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastByte(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossless, but only has benefit if you use less than half the range of the Short.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastShort:Int(writeToBitstream:Int, currentValue:Short Var, lastValue:Short)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastShort(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Short to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossless, but only has benefit if you use less than half the range of the Unsigned Short.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastUShort:Int(writeToBitstream:Int, currentValue:Short Var, lastValue:Short)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastUShort(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossless, but only has benefit if you use less than half the range of the Int.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastInt:Int(writeToBitstream:Int, currentValue:Int Var, lastValue:Int)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastInt(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize an Unsigned Int to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossless, but only has benefit if you use less than half the range of the Unsigned Int.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastUInt:Int(writeToBitstream:Int, currentValue:Int Var, lastValue:Int)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastUInt(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Float to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossy, using 2 bytes for the Float. The range must be between -1 and +1.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastFloat:Int(writeToBitstream:Int, currentValue:Float Var, lastValue:Float)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastFloat(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional serialize/deserialize a Double to/from a bitstream.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: If the current value is different from the last value the current value will be written. Otherwise, a single bit will be written.
	<p>
	This is lossy, using 4 bytes for the Double. The range must be between -1 and +1.
	</p>
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	<li><b> lastValue </b> : The last value to compare against. Only used if @writeToBitstream is True.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaLastDouble:Int(writeToBitstream:Int, currentValue:Double Var, lastValue:Double)
		Return bmx_slk_BitStream_SerializeCompressedDeltaLastDouble(bitStreamPtr, writeToBitstream, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastByte when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Byte.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaByte:Int(writeToBitstream:Int, currentValue:Byte Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaByte(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastShort when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Short.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaShort:Int(writeToBitstream:Int, currentValue:Short Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaShort(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastUShort when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Unsigned Short.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaUShort:Int(writeToBitstream:Int, currentValue:Short Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaUShort(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastInt when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Int.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaInt:Int(writeToBitstream:Int, currentValue:Int Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaInt(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastUInt when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossless, but only has benefit if you use less than half the range of the Unsigned Int.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaUInt:Int(writeToBitstream:Int, currentValue:Int Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaUInt(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastFloat when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossy, using 2 bytes for the Float. The range must be between -1 and +1.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaFloat:Int(writeToBitstream:Int, currentValue:Float Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaFloat(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method

	Rem
	bbdoc: Bidirectional version of #SerializeCompressedDeltaLastDouble when you don't know what the last value is, or there is no last value.
	returns: True if @writeToBitstream is True. True if @writeToBitstream is False and the read was successful. False if @writeToBitstream is False and the read was not successful.
	about: This is lossy, using 4 bytes for the Double. The range must be between -1 and +1.
	<p>Parameters: 
	<ul>
	<li><b> writeToBitstream </b> : True to write from your data to this bitstream. False to read from this bitstream and write to your data.</li>
	<li><b> currentValue </b> : The current value to write.</li>
	</ul>
	</p>
	End Rem
	Method SerializeCompressedDeltaDouble:Int(writeToBitstream:Int, currentValue:Double Var)
		Return bmx_slk_BitStream_SerializeCompressedDeltaDouble(bitStreamPtr, writeToBitstream, Varptr currentValue)
	End Method
	
	Rem
	bbdoc: Reads 1 bit and returns True if that bit is 1 and False if it is 0.
	End Rem
	Method ReadBit:Int()
		Return bmx_slk_BitStream_ReadBit(bitStreamPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadByte:Int(value:Byte Var)
		Return bmx_slk_BitStream_ReadByte(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadUShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadUShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadUInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadFloat:Int(value:Float Var)
		Return bmx_slk_BitStream_ReadFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDouble:Int(value:Double Var)
		Return bmx_slk_BitStream_ReadDouble(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadLong:Int(value:Long Var)
		Return bmx_slk_BitStream_ReadLong(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadTime:Int(value:Long Var)
		Return bmx_slk_BitStream_ReadTime(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadString:String()
		Return bmx_slk_BitStream_ReadString(bitStreamPtr)
	End Method

	Method ReadCompressedString:String()
		Return bmx_slk_BitStream_ReadCompressedString(bitStreamPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaByte:Int(value:Byte Var)
		Return bmx_slk_BitStream_ReadDeltaByte(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaBool:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadDeltaBool(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadDeltaShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaUShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadDeltaUShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadDeltaInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaUInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadDeltaUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaFloat:Int(value:Float Var)
		Return bmx_slk_BitStream_ReadDeltaFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadDeltaDouble:Int(value:Double Var)
		Return bmx_slk_BitStream_ReadDeltaDouble(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedByte:Int(value:Byte Var)
		Return bmx_slk_BitStream_ReadCompressedByte(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadCompressedShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedUShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadCompressedUShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedUInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedBool:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedBool(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedFloat:Int(value:Float Var)
		Return bmx_slk_BitStream_ReadCompressedFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDouble:Int(value:Double Var)
		Return bmx_slk_BitStream_ReadCompressedDouble(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaByte:Int(value:Byte Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaByte(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaUShort:Int(value:Short Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaUShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaUInt:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaBool:Int(value:Int Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaBool(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaFloat:Int(value:Float Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method ReadCompressedDeltaDouble:Int(value:Double Var)
		Return bmx_slk_BitStream_ReadCompressedDeltaDouble(bitStreamPtr, Varptr value)
	End Method
	
	Rem
	bbdoc: Write a 0. 
	End Rem
	Method Write0()
		bmx_slk_BitStream_Write0(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: Write a 1. 
	End Rem
	Method Write1()
		bmx_slk_BitStream_Write1(bitStreamPtr)
	End Method

	Rem
	bbdoc: Writes a 1 if True, 0 if False.
	End Rem
	Method WriteBool(value:Int)
		If value Then
			Write1()
		Else
			Write0()
		End If
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteByte(value:Byte)
		Local b:Byte = value
		bmx_slk_BitStream_WriteByte(bitStreamPtr, Varptr b)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteShort(value:Short Var)
		bmx_slk_BitStream_WriteShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteUShort(value:Short Var)
		bmx_slk_BitStream_WriteUShort(bitStreamPtr, Varptr value)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteInt(value:Int Var)
		bmx_slk_BitStream_WriteInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteUInt(value:Int Var)
		bmx_slk_BitStream_WriteUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteFloat(value:Float Var)
		bmx_slk_BitStream_WriteFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDouble(value:Double Var)
		bmx_slk_BitStream_WriteDouble(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteLong(value:Long Var)
		bmx_slk_BitStream_WriteLong(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteTime(value:Long Var)
		bmx_slk_BitStream_WriteTime(bitStreamPtr, Varptr value)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteBits(data:Byte Ptr, numberOfBitsToWrite:Int, rightAlignedBits:Int = True)
		bmx_slk_BitStream_WriteBits(bitStreamPtr, data, numberOfBitsToWrite, rightAlignedBits)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteString(value:String)
		bmx_slk_BitStream_WriteString(bitStreamPtr, value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedByte(value:Byte)
		Local b:Byte = value
		bmx_slk_BitStream_WriteCompressedByte(bitStreamPtr, Varptr b)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedShort(value:Short Var)
		bmx_slk_BitStream_WriteCompressedShort(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedUShort(value:Short Var)
		bmx_slk_BitStream_WriteCompressedUShort(bitStreamPtr, Varptr value)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedInt(value:Int Var)
		bmx_slk_BitStream_WriteCompressedInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedUInt(value:Int Var)
		bmx_slk_BitStream_WriteCompressedUInt(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedFloat(value:Float Var)
		bmx_slk_BitStream_WriteCompressedFloat(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDouble(value:Double Var)
		bmx_slk_BitStream_WriteCompressedDouble(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedLong(value:Long Var)
		bmx_slk_BitStream_WriteCompressedLong(bitStreamPtr, Varptr value)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaByte(currentValue:Byte, lastValue:Byte)
		Local b:Byte = currentValue
		bmx_slk_BitStream_WriteDeltaByte(bitStreamPtr, Varptr b, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaShort(currentValue:Short Var, lastValue:Short)
		bmx_slk_BitStream_WriteDeltaShort(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaUShort(currentValue:Short Var, lastValue:Short)
		bmx_slk_BitStream_WriteDeltaUShort(bitStreamPtr, Varptr currentValue, lastValue)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaInt(currentValue:Int Var, lastValue:Int)
		bmx_slk_BitStream_WriteDeltaInt(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaUInt(currentValue:Int Var, lastValue:Int)
		bmx_slk_BitStream_WriteDeltaUInt(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaFloat(currentValue:Float Var, lastValue:Float)
		bmx_slk_BitStream_WriteDeltaFloat(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaDouble(currentValue:Double Var, lastValue:Double)
		bmx_slk_BitStream_WriteDeltaDouble(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteDeltaLong(currentValue:Long Var, lastValue:Long)
		bmx_slk_BitStream_WriteDeltaLong(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaByte(currentValue:Byte, lastValue:Byte)
		Local b:Byte = currentValue
		bmx_slk_BitStream_WriteCompressedDeltaByte(bitStreamPtr, Varptr b, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaShort(currentValue:Short Var, lastValue:Short)
		bmx_slk_BitStream_WriteCompressedDeltaShort(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaUShort(currentValue:Short Var, lastValue:Short)
		bmx_slk_BitStream_WriteCompressedDeltaUShort(bitStreamPtr, Varptr currentValue, lastValue)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaInt(currentValue:Int Var, lastValue:Int)
		bmx_slk_BitStream_WriteCompressedDeltaInt(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaUInt(currentValue:Int Var, lastValue:Int)
		bmx_slk_BitStream_WriteCompressedDeltaUInt(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaFloat(currentValue:Float Var, lastValue:Float)
		bmx_slk_BitStream_WriteCompressedDeltaFloat(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaDouble(currentValue:Double Var, lastValue:Double)
		bmx_slk_BitStream_WriteCompressedDeltaDouble(bitStreamPtr, Varptr currentValue, lastValue)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method WriteCompressedDeltaLong(currentValue:Long Var, lastValue:Long)
		bmx_slk_BitStream_WriteCompressedDeltaLong(bitStreamPtr, Varptr currentValue, lastValue)
	End Method
	
	Method WriteCompressedString(value:String)
		bmx_slk_BitStream_WriteCompressedString(bitStreamPtr, value)
	End Method

	Rem
	bbdoc: This is good to call when you are done with the stream to make sure you don't have any data left over.
	End Rem
	Method AssertStreamEmpty()
		bmx_slk_BitStream_AssertStreamEmpty(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: Ignore data we don't intend to read.
	about: Parameters: 
	<ul>
	<li><b> numberOfBits </b> : The number of bits to ignore </li>
	</ul>
	End Rem
	Method IgnoreBits(numberOfBits:Int)
		bmx_slk_BitStream_IgnoreBits(bitStreamPtr, numberOfBits)
	End Method
	
	Rem
	bbdoc: Ignore data we don't intend to read.
	about: Parameters: 
	<ul>
	<li><b> numberOfBytes </b> : The number of bytes to ignore </li>
	</ul>
	End Rem
	Method IgnoreBytes(numberOfBytes:Int)
		bmx_slk_BitStream_IgnoreBytes(bitStreamPtr, numberOfBytes)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetWriteOffset(offset:Int)
		bmx_slk_BitStream_SetWriteOffset(bitStreamPtr, offset)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetNumberOfBitsUsed:Int()
		Return bmx_slk_BitStream_GetNumberOfBitsUsed(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetWriteOffset:Int()
		Return bmx_slk_BitStream_GetWriteOffset(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetNumberOfBytesUsed:Int()
		Return bmx_slk_BitStream_GetNumberOfBytesUsed(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetReadOffset:Int()
		Return bmx_slk_BitStream_GetReadOffset(bitStreamPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetReadOffset(offset:Int)
		bmx_slk_BitStream_SetReadOffset(bitStreamPtr, offset)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetNumberOfUnreadBits:Int()
		Return bmx_slk_BitStream_GetNumberOfUnreadBits(bitStreamPtr)
	End Method

	Method Delete()
		If bitStreamPtr And owner Then
			bmx_slk_BitStream_Delete(bitStreamPtr)
			bitStreamPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: Unique identifier for a system.
about: Corresponds to a network address.
End Rem
Type TSlkSystemAddress

	Field systemAddressPtr:Byte Ptr

	Function _create:TSlkSystemAddress(systemAddressPtr:Byte Ptr) { nomangle }
		If systemAddressPtr Then
			Local this:TSlkSystemAddress = New TSlkSystemAddress
			this.systemAddressPtr = systemAddressPtr
			Return this
		End If
	End Function
	
	Rem
	bbdoc: Creates a new TSlkSystemAddress object.
	End Rem
	Method Create:TSlkSystemAddress()
		systemAddressPtr = bmx_slk_SystemAddress_create()
		Return Self
	End Method
	
	Rem
	bbdoc: The peer address from inet_addr.
	End Rem
	Method GetAddress:Byte Ptr()
		Return bmx_slk_SystemAddress_GetAddress(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetBinaryAddress(address:String)
		bmx_slk_SystemAddress_SetBinaryAddress(systemAddressPtr, address)
	End Method
	
	Rem
	bbdoc: Returns the port in host order (this is what you normally use)
	End Rem
	Method GetPort:Int()
		Return bmx_slk_SystemAddress_GetPort(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: Sets the port number.
	about: The same as #SetPortHostOrder.
	End Rem
	Method SetPort(port:Int)
		bmx_slk_SystemAddress_SetPort(systemAddressPtr, port)
	End Method
	
	Rem
	bbdoc: Returns True if the two addresses are equal.
	End Rem
	Method Equals:Int(address:TSlkSystemAddress)
		Return bmx_slk_SystemAddress_Equals(systemAddressPtr, address.systemAddressPtr)
	End Method

	Rem
	bbdoc: Returns a String representation of the TSlkSystemAddress.
	End Rem
	Method ToString:String()
		Return bmx_slk_SystemAddress_ToString(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method IsLoopback:Int()
		Return bmx_slk_SystemAddress_IsLoopback(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method IsLANAddress:Int()
		Return bmx_slk_SystemAddress_IsLANAddress(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetPortNetworkOrder:Int()
		Return bmx_slk_SystemAddress_GetPortNetworkOrder(systemAddressPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetPortHostOrder(s:Int)
		bmx_slk_SystemAddress_SetPortHostOrder(systemAddressPtr, s)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetPortNetworkOrder(s:Int)
		bmx_slk_SystemAddress_SetPortNetworkOrder(systemAddressPtr, s)
	End Method
	
	Method Delete()
		If systemAddressPtr Then
			bmx_slk_SystemAddress_delete(systemAddressPtr)
			systemAddressPtr = Null
		End If
	End Method
	
End Type


Rem
bbdoc: Stores Statistics information related to network usage.
End Rem
Type TSlkRakNetStatistics

	Field statsPtr:Byte Ptr

	Function _create:TSlkRakNetStatistics(statsPtr:Byte Ptr)
		If statsPtr Then
			Local this:TSlkRakNetStatistics = New TSlkRakNetStatistics
			this.statsPtr = statsPtr
			Return this
		End If
	End Function
	
	Rem
	bbdoc: Returns a String representation of the TSlkRakNetStatistics.
	about: Equivalent to ToVerboseString(0).
	End Rem
	Method ToString:String()
		Return ToVerboseString(0)
	End Method

	Rem
	bbdoc: Returns a String representation of the TSlkRakNetStatistics, for a specified @verbosityLevel.
	End Rem
	Method ToVerboseString:String(verbosityLevel:Int)
		Return bmx_slk_RakNetStatistics_ToStringLevel(statsPtr, verbosityLevel)
	End Method

	Rem
	bbdoc: For each type in RNSPerSecondMetrics, what is the value over the last 1 second?
	End Rem
	Method ValueOverLastSecond:Long(perSecondMetrics:Int)
		Local v:Long
		bmx_slk_RakNetStatistics_valueOverLastSecond(statsPtr, perSecondMetrics, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: For each type in RNSPerSecondMetrics, what is the total value over the lifetime of the connection?
	End Rem
	Method RunningTotal:Long(perSecondMetrics:Int)
		Local v:Long
		bmx_slk_RakNetStatistics_runningTotal(statsPtr, perSecondMetrics, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method ConnectionStartTime:Long()
		Local v:Long
		bmx_slk_RakNetStatistics_connectionStartTime(statsPtr, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method IsLimitedByCongestionControl:Int()
		Return bmx_slk_RakNetStatistics_isLimitedByCongestionControl(statsPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method BPSLimitByCongestionControl:Long()
		Local v:Long
		bmx_slk_RakNetStatistics_BPSLimitByCongestionControl(statsPtr, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: Returns whether our current send rate throttled by a call to RakPeer::SetPerConnectionOutgoingBandwidthLimit()
	End Rem
	Method IsLimitedByOutgoingBandwidthLimit:Int()
		Return bmx_slk_RakNetStatistics_isLimitedByOutgoingBandwidthLimit(statsPtr)
	End Method
	
	Rem
	bbdoc: Returns the limit, in bytes per second, if IsLimitedByOutgoingBandwidthLimit() is true;
	End Rem
	Method BPSLimitByOutgoingBandwidthLimit:Long()
		Local v:Long
		bmx_slk_RakNetStatistics_BPSLimitByOutgoingBandwidthLimit(statsPtr, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: Number of Messages in the send Buffer (high, medium, low priority)
	End Rem
	Method MessageInSendBuffer:Int(priority:Int)
		Return bmx_slk_RakNetStatistics_messageInSendBuffer(statsPtr, priority)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method BytesInSendBuffer:Double(priority:Int)
		Return bmx_slk_RakNetStatistics_bytesInSendBuffer(statsPtr, priority)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method MessagesInResendBuffer:Int()
		Return bmx_slk_RakNetStatistics_messagesInResendBuffer(statsPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method BytesInResendBuffer:Long()
		Local v:Long
		bmx_slk_RakNetStatistics_BytesInResendBuffer(statsPtr, Varptr v)
		Return v
	End Method
		
	Rem
	bbdoc: 
	End Rem
	Method PacketlossLastSecond:Float()
		Return bmx_slk_RakNetStatistics_packetlossLastSecond(statsPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method PacketlossTotal:Float()
		Return bmx_slk_RakNetStatistics_packetlossTotal(statsPtr)
	End Method

End Type

Rem
bbdoc: 
End Rem
Global UNASSIGNED_RAKNET_GUID:TSlkRakNetGUID = TSlkRakNetGUID._create(bmx_slk_RakNetGUID_unassigned(), False)

Rem
bbdoc: Uniquely identifies an instance of RakPeer.
about: Use TSlkRakPeer::GetGuidFromSystemAddress() and TSlkRakPeer::GetSystemAddressFromGuid() to go between TSlkSystemAddress and TSlkRakNetGUID
<p>
Use TSlkRakPeer::GetGuidFromSystemAddress(UNASSIGNED_SYSTSEM_ADDRESS) to get your own GUID
</p>
End Rem
Type TSlkRakNetGUID

	Field guidPtr:Byte Ptr
	Field owner:Int

	Function _create:TSlkRakNetGUID(guidPtr:Byte Ptr, owner:Int = True)
		If guidPtr Then
			Local this:TSlkRakNetGUID = New TSlkRakNetGUID
			this.guidPtr = guidPtr
			this.owner = owner
			Return this
		End If
	End Function

	Rem
	bbdoc: Returns the string representation of this TRKRakNetGUID.
	End Rem
	Method ToString:String()
		Return bmx_slk_RakNetGUID_ToString(guidPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Equals:Int(other:TSlkRakNetGUID)
		Return bmx_slk_RakNetGUID_Equals(guidPtr, other.guidPtr)
	End Method

	Method Delete()
		If guidPtr And owner Then
			bmx_slk_RakNetGUID_delete(guidPtr)
			guidPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: 
End Rem
Type TSlkConsoleServer

	Function _create:TSlkConsoleServer(csPtr:Byte Ptr)
		' TODO
	End Function
	
End Type

Type TSlkReplicaManager

	Function _create:TSlkReplicaManager(rmPtr:Byte Ptr)
	End Function
	
End Type

Rem
bbdoc: 
End Rem
Type TSlkLogCommandParser

	Field logCommandParserPtr:Byte Ptr

	Function _create:TSlkLogCommandParser(logCommandParserPtr:Byte Ptr)
		If logCommandParserPtr Then
			Local this:TSlkLogCommandParser = New TSlkLogCommandParser
			this.logCommandParserPtr = logCommandParserPtr
			Return this
		End If
	End Function

End Type

Rem
bbdoc: 
End Rem
Type TSlkPacketLogger

	Field packetLoggerPtr:Byte Ptr

	Function _create:TSlkPacketLogger(packetLoggerPtr:Byte Ptr)
		If packetLoggerPtr Then
			Local this:TSlkPacketLogger = New TSlkPacketLogger
			this.packetLoggerPtr = packetLoggerPtr
			Return this
		End If
	End Function

End Type

Rem
bbdoc: 
End Rem
Type TSlkRakNetTransport

	Field rakNetTransportPtr:Byte Ptr

	Function _create:TSlkRakNetTransport(rakNetTransportPtr:Byte Ptr)
		If rakNetTransportPtr Then
			Local this:TSlkRakNetTransport = New TSlkRakNetTransport
			this.rakNetTransportPtr = rakNetTransportPtr
			Return this
		End If
	End Function

End Type

Rem
bbdoc: 
End Rem
Type TSlkRakNetCommandParser

	Field rakNetCommandParserPtr:Byte Ptr

	Function _create:TSlkRakNetCommandParser(rakNetCommandParserPtr:Byte Ptr)
		If rakNetCommandParserPtr Then
			Local this:TSlkRakNetCommandParser = New TSlkRakNetCommandParser
			this.rakNetCommandParserPtr = rakNetCommandParserPtr
			Return this
		End If
	End Function

End Type

Type TSlkTelnetTransport

	Field telnetTransportPtr:Byte Ptr

	Function _create:TSlkTelnetTransport(telnetTransportPtr:Byte Ptr)
		If telnetTransportPtr Then
			Local this:TSlkTelnetTransport = New TSlkTelnetTransport
			this.telnetTransportPtr = telnetTransportPtr
			Return this
		End If
	End Function

End Type

Type TSlkPacketConsoleLogger

	Field packetConsoleLoggerPtr:Byte Ptr

	Function _create:TSlkPacketConsoleLogger(packetConsoleLoggerPtr:Byte Ptr)
		If packetConsoleLoggerPtr Then
			Local this:TSlkPacketConsoleLogger = New TSlkPacketConsoleLogger
			this.packetConsoleLoggerPtr = packetConsoleLoggerPtr
			Return this
		End If
	End Function

End Type

Type TSlkPacketFileLogger

	Field packetFileLoggerPtr:Byte Ptr

	Function _create:TSlkPacketFileLogger(packetFileLoggerPtr:Byte Ptr)
		If packetFileLoggerPtr Then
			Local this:TSlkPacketFileLogger = New TSlkPacketFileLogger
			this.packetFileLoggerPtr = packetFileLoggerPtr
			Return this
		End If
	End Function

End Type

Type TSlkRouter

	Field routerPtr:Byte Ptr

	Function _create:TSlkRouter(routerPtr:Byte Ptr)
		If routerPtr Then
			Local this:TSlkRouter = New TSlkRouter
			this.routerPtr = routerPtr
			Return this
		End If
	End Function

End Type

Type TSlkConnectionGraph

	Field connectionGraphPtr:Byte Ptr

	Function _create:TSlkConnectionGraph(connectionGraphPtr:Byte Ptr)
		If connectionGraphPtr Then
			Local this:TSlkConnectionGraph = New TSlkConnectionGraph
			this.connectionGraphPtr = connectionGraphPtr
			Return this
		End If
	End Function

End Type

Rem
bbdoc: 
End Rem
Type TSlkPluginInterface

	Field pluginPtr:Byte Ptr

End Type

Rem
bbdoc: An invalid/Null system address.
End Rem
Global UNASSIGNED_SYSTEM_ADDRESS:TSlkSystemAddress = TSlkSystemAddress._create(bmx_slk_SystemAddress_unassigned())

Rem
bbdoc: 
End Rem
Global MAXIMUM_NUMBER_OF_INTERNAL_IDS:Int = bmx_slk_MAXIMUM_NUMBER_OF_INTERNAL_IDS()
