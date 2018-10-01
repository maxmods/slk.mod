SuperStrict

Import brl.max2d

Type TConsole

	Field blinktimer:Int
	Field blinkRate:Int = 500
	Field show:Int
	
	Field x:Int
	Field y:Int
	Field height:Int = 11
	
	Field lines:String[]
	Field first:Int
	Field last:Int = 1
	
	Field inputPrefix:String
	Field textChars:String
	Field inputText:String
	Field wantsInput:Int
	
	Method Create:TConsole(x:Int, y:Int, maxLines:Int = 40)
		Self.x = x
		Self.y = y
		lines = New String[maxLines]
		
		Return Self
	End Method
	
	Method Print(text:String)
	
		Local parts:String[] = text.Split("~n")
		
		For Local s:String = EachIn parts
			lines[last] = s

			Local previous:Int = last
			
			last :+ 1
			If last = lines.length Then
				last = 0
			End If
			
			If first = previous Then
				first :+ 1
				If first = lines.length
					first = 0
				End If
			End If

		Next
	End Method
	
	Method Input(text:String)
		inputPrefix = text
		wantsInput = True
	End Method

	Method Update:String(gotInput:Int Var)
	
		If Not blinktimer Then
			blinktimer = MilliSecs() 
		EndIf
	
		If wantsInput Then
			Local key:Int = GetChar()
		
			If key > 0 Then
				blinktimer = 0
				show = False	
				
				If key = 13 Then
					inputText = textChars
					textChars = Null
					gotInput = True
				Else If key = 8 Or key = 4 Then
					If textChars Then
						textChars = textChars[..textChars.length-1]
					End If
				Else
					textChars :+ Chr(key)
				EndIf
				
			EndIf
		End If
	
		If blinkRate > 0 Then
			If MilliSecs() > blinktimer + blinkRate Then
				If show	Then
					show = False
					blinktimer = MilliSecs() 
				Else
					show = True
					blinktimer = MilliSecs() 
				End If
			End If
		End If
	
		Local s:String = inputText
		inputText = Null
		Return s
	
	End Method
	
	Method Render()
		Local line:Int = first
		For Local i:Int = 0 Until lines.length
			
			Local s:String = lines[line]
			If s Then
				DrawText s, x, y + i * height
			End If
			
			line :+ 1
			If line = lines.length Then
				line = 0
			End If
		Next
		
		If wantsInput Then
			If show = True
				DrawText inputPrefix + textChars + "|", x, y + lines.length * height
			Else
				DrawText inputPrefix + textChars , x, y + lines.length * height
			End If
		End If
		
	End Method

End Type

Type TConsoleRenderer

	Field console:TConsole
	
	Method Create:TConsoleRenderer(x:Int, y:Int, maxLines:Int = 40)
		console = New TConsole.Create(x, y, maxLines)
		
		Init()
		Return Self
	End Method
	
	Method Update() Abstract
	
	Method Init()
	End Method
	
	Method Render()
		Cls
	
		console.Render()
	
		Flip
	End Method

End Type


