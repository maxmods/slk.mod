SuperStrict

Framework slk.slikenet
Import brl.standardio
Import brl.glmax2d

Import "example_helper.bmx"

Graphics 800, 600, 0

Const DEFAULT_LISTEN_PORT:String = "0"
Const DEFAULT_IP:String = "127.0.0.1"
Const DEFAULT_SERVER_PORT:String = "60001"

Local client:TChatClient = TChatClient(New TChatClient.Create(10, 10))

While Not KeyDown(key_escape)

	client.Update()
	
	client.Render()

Wend

End


Type TChatClient Extends TConsoleRenderer

	Const STATE_START:Int = 0
	Const STATE_CLIENT_PORT:Int = 1
	Const STATE_IP:Int = 2
	Const STATE_SERVER_PORT:Int = 3
	Const STATE_RUNNING:Int = 4
	Const STATE_FINISHED:Int = 5
	Const STATE_CONNECT_IP:Int = 6
	Const STATE_CONNECT_PORT:Int = 7
	Const STATE_DISCONNECT:Int = 8

	Field state:Int

	' Holds packets
	Field packet:TSlkPacket
	Field packetIdentifier:Int
	Field client:TSlkRakPeerInterface = TSlkRakPeerInterface.GetInstance()
	Field clientPort:String
	Field intClientPort:Int
	Field ip:String
	Field serverPort:String
	Field socketDescriptor:TSlkSocketDescriptor

	Method Update()

		Local gotInput:Int
		Local inputText:String = console.Update(gotInput)
	
		Select state
			Case STATE_START
				console.Print "This is a sample implementation of a text based chat client."
				console.Print "Connect to the project 'ChatServer'."
				console.Print "Difficulty: Beginner~n"
				
				console.Input "Enter the client port to listen on [" + DEFAULT_LISTEN_PORT + "] > "
				
				state = STATE_CLIENT_PORT
			Case STATE_CLIENT_PORT
			
				If gotInput Then
					clientPort = inputText
				
					If Not clientPort Then
						clientPort = DEFAULT_LISTEN_PORT
					End If

					Local intClientPort:Int = clientPort.ToInt()

					If intClientPort < 0 Or intClientPort > $FFFFFF Then
						console.Print "Specified client port " + clientPort + " is outside valid bounds [0, " + $FFFFFF + "]"
						state = STATE_FINISHED
						Return
					End If

					console.Input "Enter IP to connect to [" + DEFAULT_IP + "] > "

					state = STATE_IP
				End If
			
			Case STATE_IP
			
				If gotInput Then
					ip = inputText

					If Not ip Then
						ip = DEFAULT_IP
					End If
					
					client.AllowConnectionResponseIPMigration(False)

					console.Input "Enter the port to connect to [" + DEFAULT_SERVER_PORT + "] > "

					state = STATE_SERVER_PORT
				End If
			
			Case STATE_SERVER_PORT
			
				If gotInput Then
				
					serverPort = inputText
				
					If Not serverPort Then
						serverPort = DEFAULT_SERVER_PORT
					End If
					
					Local intServerPort:Int = serverPort.ToInt()
					
					If intServerPort < 0 Or intServerPort > $FFFFFF Then
						console.Print "Specified server port " + serverPort + " is outside valid bounds [0, " + $FFFFFF + "]"
						state = STATE_FINISHED
						Return
					End If
					
					
					socketDescriptor = TSlkSocketDescriptor.CreateSocketDescriptor(intClientPort)
					socketDescriptor.SetSocketFamily(AF_INET_)
					
					client.Startup(1, [socketDescriptor], 1)
					client.SetOccasionalPing(True)
					
					Local res:Int = client.Connect(ip, intServerPort, "Rumpelstiltskin")
					
					If res <> CONNECTION_ATTEMPT_STARTED Then
						console.Print "Connection attempt failed."
						state = STATE_FINISHED
						Return
					End If
					
					
					console.Print "My IP Addresses:"
					
					For Local i:Int = 0 Until client.GetNumberOfAddresses()
						console.Print i + ". " + client.GetLocalIP(i)
					Next
					
					console.Print "My GUID is " + client.GetGuidFromSystemAddress(UNASSIGNED_SYSTEM_ADDRESS).ToString()
					
					console.Print "'quit' to quit. 'stat' to show stats. 'ping' to ping.~n'disconnect' to disconnect. 'connect' to reconnnect. Type to talk."
					
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
						
							Local stats:TSlkRakNetStatistics = client.GetStatistics(client.GetSystemAddressFromIndex(0))
							console.Print stats.ToVerboseString(2)
							console.Print "Ping=" + client.GetAveragePing(client.GetSystemAddressFromIndex(0))
						
							Return
							
						Case "disconnect"
						
							console.Input "Enter index to disconnect: "
							
							state = STATE_DISCONNECT
						
							Return
						
						Case "shutdown"
							client.Shutdown(100)
							console.Print "Shutdown."
							Return
						
						Case "startup"
						
							Local res:Int = client.Startup(8, [socketDescriptor],1)
							
							If res = RAKNET_STARTED Then
								console.Print "Started."
							Else
								console.Print "Startup failed."
							End If
							
							Return
							
						Case "connect"
						
							state = STATE_CONNECT_IP
							
							console.Input "Enter server ip: "
						
							Return
						
						Case "ping"
						
							If Not UNASSIGNED_SYSTEM_ADDRESS.Equals(client.GetSystemAddressFromIndex(0)) Then
								client.Ping(client.GetSystemAddressFromIndex(0))
							End If
							
							Return
						
						Case "getlastping"
						
							If Not UNASSIGNED_SYSTEM_ADDRESS.Equals(client.GetSystemAddressFromIndex(0)) Then
								console.Print "Last ping is " + client.GetLastPing(client.GetSystemAddressFromIndex(0))
							End If
							
							Return
						
						Default
						
							' message is the data to send
							' strlen(message)+1 is to send the null terminator
							' HIGH_PRIORITY doesn't actually matter here because we don't use any other priority
							' RELIABLE_ORDERED means make sure the message arrives in the right order
							Local data:Byte Ptr = message.ToUTF8String()
							Local size:Int = strlen_(data) + 1
							client.Send(data, size, PACKET_HIGH_PRIORITY, PACKET_RELIABLE_ORDERED, 0, UNASSIGNED_SYSTEM_ADDRESS, True)
					End Select
				End If
		
				' Get a packet from either the server or the client
				packet = client.Receive()
				While packet
				
					' We got a packet, get the identifier with our handy function
					packetIdentifier = GetPacketIdentifier(packet)
					
					Select packetIdentifier
						Case ID_DISCONNECTION_NOTIFICATION
							' Connection lost normally
							console.Print "ID_DISCONNECTION_NOTIFICATION"
						Case ID_ALREADY_CONNECTED
							console.Print "ID_ALREADY_CONNECTED with guid " + "<GUID>"
						Case ID_INCOMPATIBLE_PROTOCOL_VERSION
							console.Print "ID_INCOMPATIBLE_PROTOCOL_VERSION"
						Case ID_REMOTE_DISCONNECTION_NOTIFICATION
							' Server telling the clients of another client disconnecting gracefully.  You can manually broadcast this in a peer to peer enviroment if you want.
							console.Print "ID_REMOTE_DISCONNECTION_NOTIFICATION"
						Case ID_REMOTE_CONNECTION_LOST
							' Server telling the clients of another client disconnecting forcefully.  You can manually broadcast this in a peer to peer enviroment if you want.
							console.Print "ID_REMOTE_CONNECTION_LOST"
						Case ID_REMOTE_NEW_INCOMING_CONNECTION
							' Server telling the clients of another client connecting.  You can manually broadcast this in a peer to peer enviroment if you want.
							console.Print "ID_REMOTE_NEW_INCOMING_CONNECTION"
						Case ID_CONNECTION_BANNED
							' Banned from this server
							console.Print "We are banned from this server."
						Case ID_CONNECTION_ATTEMPT_FAILED
							console.Print "Connection attempt failed"
						Case ID_NO_FREE_INCOMING_CONNECTIONS
							' Sorry, the server is full.  I don't do anything here but a real app should tell the user
							console.Print "ID_NO_FREE_INCOMING_CONNECTIONS"
						Case ID_INVALID_PASSWORD
							console.Print "ID_INVALID_PASSWORD"
						Case ID_CONNECTION_LOST
							' Couldn't deliver a reliable packet - i.e. the other system was abnormally terminated
							console.Print "ID_CONNECTION_LOST"
						Case ID_CONNECTION_REQUEST_ACCEPTED
							' This tells the client they have connected
							console.Print "ID_CONNECTION_REQUEST_ACCEPTED to %s with GUID %s\n"', packet.GetSystemAddress.ToString(True), p->guid.ToString());
							console.Print "My external address is %s\n"', client->GetExternalID(p->systemAddress).ToString(True));
			
						Case ID_CONNECTED_PING, ID_UNCONNECTED_PING
						
							console.Print "Incoming ping from "
						Default
							' It's a client, so just show the message
							console.Print String.FromUTF8String(packet.GetData())
					End Select
				
					client.DeallocatePacket(packet)	
					packet = client.Receive()
				Wend
		
			Case STATE_FINISHED
			
				' Be nice And let the server know we quit.
				client.Shutdown(300)
				
				TSlkRakPeerInterface.DestroyInstance(client)
	
				Delay 1000
				End
			
			Case STATE_CONNECT_IP
			
				If gotInput Then
					
					ip = inputText
					
					If Not ip Then
						ip = "127.0.0.1"
					End If
					
					console.Input "Enter server port: "
					
					state = STATE_CONNECT_PORT 
					
				End If
			
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


