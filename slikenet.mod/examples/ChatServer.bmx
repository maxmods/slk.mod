SuperStrict

Framework slk.slikenet
Import brl.standardio
Import brl.glmax2d

Import "example_helper.bmx"

Graphics 800, 600, 0

Const DEFAULT_LISTEN_PORT:String = "60001"
Const DEFAULT_IP:String = "127.0.0.1"
'Const DEFAULT_SERVER_PORT:String = "60001"

Local server:TChatServer = TChatServer(New TChatServer.Create(10, 10))

While Not KeyDown(key_escape)

	server.Update()
	
	server.Render()

Wend

End


Type TChatServer Extends TConsoleRenderer

	Const STATE_START:Int = 0
	Const STATE_SERVER_PORT:Int = 1
	Const STATE_RUNNING:Int = 2
	Const STATE_FINISHED:Int = 3
	Const STATE_BAN:Int = 4

	Field state:Int

	' Holds packets
	Field packet:TSlkPacket
	Field packetIdentifier:Int
	Field server:TSlkRakPeerInterface = TSlkRakPeerInterface.GetInstance()
	'Field intServerPort:Int
	Field ip:String
	Field serverPort:String
	Field socketDescriptors:TSlkSocketDescriptor[2]
	Field clientID:TSlkSystemAddress = UNASSIGNED_SYSTEM_ADDRESS 

	Method Init()
		server.SetIncomingPassword("Rumpelstiltskin")
		server.SetTimeoutTime(30000, UNASSIGNED_SYSTEM_ADDRESS)
	End Method

	Method Update()

		Local gotInput:Int
		Local inputText:String = console.Update(gotInput)
	
		Select state
			Case STATE_START
				console.Print "This is a sample implementation of a text based chat server."
				console.Print "Connect to the project 'ChatClient'."
				console.Print "Difficulty: Beginner~n"
				
				console.Input "Enter the server port to listen on [" + DEFAULT_LISTEN_PORT + "] > "
				
				state = STATE_SERVER_PORT
			Case STATE_SERVER_PORT
			
				If gotInput Then
					serverPort = inputText
				
					If Not serverPort Then
						serverPort = DEFAULT_LISTEN_PORT
					End If

					Local intServerPort:Int = serverPort.ToInt()

					If intServerPort < 0 Or intServerPort > $FFFFFF Then
						console.Print "Specified server port " + serverPort + " is outside valid bounds [0, " + $FFFFFF + "]"
						state = STATE_FINISHED
						Return
					End If

					console.Print "Starting server."

					Local socketDescriptor:TSlkSocketDescriptor = TSlkSocketDescriptor.CreateSocketDescriptor(intServerPort)
					socketDescriptor.SetSocketFamily(AF_INET_)

					socketDescriptors[0] = socketDescriptor

					socketDescriptor = TSlkSocketDescriptor.CreateSocketDescriptor(intServerPort)
					socketDescriptor.SetSocketFamily(AF_INET6_)

					socketDescriptors[1] = socketDescriptor

					Local res:Int = server.Startup(4, socketDescriptors)

					If res <> RAKNET_STARTED Then
						console.Print "Failed to start dual IPV4 and IPV6 ports. Trying IPV4 only."
						
						' Try again, but leave out IPV6
						
					End If

					server.SetMaximumIncomingConnections(4)

					server.SetOccasionalPing(True)
					server.SetUnreliableTimeout(1000)

					Local sockets:TSlkRakNetSocket[] = server.GetSockets()
					console.Print "Socket addresses used by RakNet:"
					For Local i:Int = 0 Until sockets.length
						console.Print i + ". " + sockets[i].GetBoundAddress().ToString()
					Next

					console.Print "~nMy IP addresses:"
					
					For Local i:Int = 0 Until server.GetNumberOfAddresses()
						Local sa:TSlkSystemAddress = server.GetInternalID(UNASSIGNED_SYSTEM_ADDRESS, i)
						console.Print i + ". " + sa.ToString() + " (LAN=" + sa.IsLANAddress() + ")"
					Next
					
					console.Print "~nMy GUID is "', server->GetGuidFromSystemAddress(SLNet::UNASSIGNED_SYSTEM_ADDRESS).ToString());
					console.Print "'quit' to quit. 'stat' to show stats. 'ping' to ping.~n'pingip' to ping an ip address~n'ban' to ban an IP from connecting.~n'kick to kick the first connected player.~nType to talk."

					console.Input "> "
					
					state = STATE_RUNNING
				End If			
			
			Case STATE_RUNNING
		
				Delay 30
		
				If gotInput And inputText
				
					Local message:String = inputText

					Select message
						Case "quit"
							Console.Print "Quitting."
							state = STATE_FINISHED
							Return
							
						Case "stat"
						
							Local stats:TSlkRakNetStatistics = server.GetStatistics(server.GetSystemAddressFromIndex(0))
							Console.Print stats.ToVerboseString(2)
							Console.Print "Ping=" + server.GetAveragePing(server.GetSystemAddressFromIndex(0))
						
							Return
							
						Case "ping"
						
							server.Ping(clientID)
							
							Return
						
						Case "pingip"
						
							'If Not UNASSIGNED_SYSTEM_ADDRESS.Equals(client.GetSystemAddressFromIndex(0)) Then
							'	console.Print "Last ping is " + client.GetLastPing(client.GetSystemAddressFromIndex(0))
							'End If
							
							Return
							
						Case "kick"
						
							server.CloseConnection(clientID, True, 0)
							
							Return
							
						Case "getconnectionlist"
						
							Local systems:TSlkSystemAddress[10]
							Local numConnections:Int
							server.GetConnectionList(systems, numConnections)
							
							For Local i:Int = 0 Until numConnections
								console.Print i + ". " + systems[i].ToString()
							Next
						
							Return
							
						Case "ban"
						
							console.Print "Enter IP to ban.  You can use * as a wildcard."
							
							state = STATE_BAN
						
							Return
						Default
						
							' Message now holds what we want to broadcast
							' Append Server: to the message so clients know that it ORIGINATED from the server
							' All messages to all clients come from the server either directly or by being
							' relayed from other clients
							message = "Server: " + message

							' strlen(data)+1 is to send the null terminator
							' HIGH_PRIORITY doesn't actually matter here because we don't use any other priority
							' RELIABLE_ORDERED means make sure the message arrives in the right order
							' We arbitrarily pick 0 for the ordering stream
							' UNASSIGNED_SYSTEM_ADDRESS means don't exclude anyone from the broadcast
							' True means broadcast the message to everyone connected
							Local data:Byte Ptr = message.ToUTF8String()
							Local size:Int = strlen_(data) + 1
							server.Send(data, size, PACKET_HIGH_PRIORITY, PACKET_RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, True)
					End Select
				End If
		
				' Get a packet from either the server or the client
				packet = server.Receive()
				While packet
				
					' We got a packet, get the identifier with our handy function
					packetIdentifier = GetPacketIdentifier(packet)
					
					Select packetIdentifier
						Case ID_DISCONNECTION_NOTIFICATION
							' Connection lost normally
							console.Print "ID_DISCONNECTION_NOTIFICATION from " + packet.GetSystemAddress().ToString()
						Case ID_NEW_INCOMING_CONNECTION
							' Somebody connected.  We have their IP now
							console.Print "ID_NEW_INCOMING_CONNECTION from " + packet.GetSystemAddress().ToString() + " with GUID " + packet.GetGuid().ToString()
							' Record the player ID of the client
							clientID = packet.GetSystemAddress()
							
							console.Print "Remote internal IDs:"
							
							For Local i:Int = 0 Until MAXIMUM_NUMBER_OF_INTERNAL_IDS
								Local internalId:TSlkSystemAddress = server.GetInternalID(packet.GetSystemAddress(), i)
								
								If Not UNASSIGNED_SYSTEM_ADDRESS.Equals(internalId) Then
									console.Print (i + 1) + ". " + internalId.ToString()
								End If
							Next
							
						Case ID_INCOMPATIBLE_PROTOCOL_VERSION
							console.Print "ID_INCOMPATIBLE_PROTOCOL_VERSION"
						Case ID_CONNECTION_LOST
							' Couldn't deliver a reliable packet - i.e. the other system was abnormally terminated
							console.Print "ID_CONNECTION_LOST"
						Case ID_CONNECTED_PING, ID_UNCONNECTED_PING
						
							console.Print "Ping from " + packet.GetSystemAddress().ToString()
						Default
							' 
							Local data:Byte Ptr = packet.GetData()
							Local message:String = String.FromUTF8String(data)
							console.Print message
							
							Local size:Int = strlen_(data) + 1
							' Relay the message
							server.Send(data, size, PACKET_HIGH_PRIORITY, PACKET_RELIABLE_ORDERED, 0, packet.GetSystemAddress(), True)
					End Select
				
					server.DeallocatePacket(packet)	
					packet = server.Receive()
				Wend
'End Rem
			Case STATE_FINISHED
			
				' Be nice And let the server know we quit.
				server.Shutdown(300)
				
				TSlkRakPeerInterface.DestroyInstance(server)
	
				Delay 1000
				End
			
			Case STATE_BAN
			
				If gotInput Then
					
					server.AddToBanList(inputText);
					console.Print "IP " + inputText + " added to ban list."
								
					state = STATE_RUNNING 
					
				End If
Rem			
			Case STATE_CONNECT_PORT

				If gotInput Then
				
					serverPort = inputText
				
					If Not serverPort Then
						serverPort = "60001"
					End If
					
					Local intServerPort:Int = serverPort.ToInt()
					
					If intServerPort < 0 Or intServerPort > $FFFFFF Then
						console.Print "Specified server port " + serverPort + " is outside valid bounds [0, " + $FFFFFF + "]"
						state = STATE_FINISHED
						Return
					End If

					Local res:Int = client.Connect(ip, intServerPort, "Rumpelstiltskin")
					
					If res <> CONNECTION_ATTEMPT_STARTED Then
						console.Print "Connection attempt failed."
						state = STATE_FINISHED
						Return
					End If

					console.Input "> "
					state = STATE_RUNNING
				
				End If
				
			Case STATE_DISCONNECT
			
				If gotInput
					
					Local index:Int
					
					If inputText Then
						index = inputText.ToInt()
					End If
					
					client.CloseConnection(client.GetSystemAddressFromIndex(index), False)
					
					console.Print "Disconnecting."
					
					state = STATE_RUNNING
					
				End If
End Rem
		End Select

	
	End Method

	'  If the first byte is ID_TIMESTAMP, then we want the 6th byte, Otherwise we want the 1st byte
	Function GetPacketIdentifier:Int(packet:TSlkPacket)
		If Not packet Then
			Return 255
		End If
		
		Local data:Byte Ptr = packet.GetData()
		If data[0] = ID_TIMESTAMP Then
			Return data[5]
		Else
			Return data[0]
		End If
	End Function

End Type

