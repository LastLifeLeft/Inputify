;================================================;
; Module      : ImagePlugin (Cross platform)     ;
; Author      : Wilbert                          ;
; Date        : Sep 9, 2016                      ;
; Version     : 1.52                             ;
;                                                ;
; Implemented : ModuleImagePluginStop()          ;
;               UseSystemImageDecoder()          ;
;               UseSystemImageEncoder()          ;
;                                                ;
; *Additional requirements for Windows:          ;
;  MemoryStreamModule.pbi, gdiplus.lib           ;
;================================================;


;- Module declaration

DeclareModule ImagePlugin
	
	#SystemImagePlugin           = $737953
	#SystemImagePlugin_BMP       = $100000
	#SystemImagePlugin_JPEG      = $300100
	#SystemImagePlugin_GIF       = $200200
	#SystemImagePlugin_TIFF_LZW  = $052500
	#SystemImagePlugin_TIFF_None = $016500
	#SystemImagePlugin_PNG       = $400600
	
	Declare   ModuleImagePluginStop()
	Declare.i UseSystemImageDecoder()
	Declare.i UseSystemImageEncoder()
	
EndDeclareModule


;- Module implementation

CompilerIf #PB_Compiler_OS = #PB_OS_Windows And Not Defined(MemoryStream, #PB_Module)
	; http://www.purebasic.fr/english/viewtopic.php?f=5&t=66487
	IncludeFile "MemoryStreamModule.pbi"
CompilerEndIf

Module ImagePlugin
	
	EnableExplicit
	DisableDebugger
	
	;- Structures (all OS)
	
	Structure PB_ImageDecoder Align #PB_Structure_AlignC
		*Check
		*Decode
		*Cleanup
		ID.l
	EndStructure
	
	Structure PB_ImageDecoderGlobals Align #PB_Structure_AlignC
		*Decoder.PB_ImageDecoder
		*Filename
		*File
		*Buffer
		Length.l
		Mode.l
		Width.l
		Height.l
		Depth.l
		Flags.l
		Data.i[8]
		OriginalDepth.l
	EndStructure
	
	Structure PB_ImageEncoder Align #PB_Structure_AlignC
		ID.l
		*Encode24
		*Encode32
	EndStructure
	
	;- Imports (all OS)
	
	IsImage(0) ; make sure ImagePlugin library is available so imports won't fail
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows And #PB_Compiler_Processor = #PB_Processor_x86 
		Import ""
			PB_ImageDecoder_Register(*ImageDecoder.PB_ImageDecoder) As "_PB_ImageDecoder_Register@4"
			PB_ImageEncoder_Register(*ImageEncoder.PB_ImageEncoder) As "_PB_ImageEncoder_Register@4"
		EndImport
	CompilerElse
		ImportC "" ; ImportC can be used on all OS for PB x64
			PB_ImageDecoder_Register(*ImageDecoder.PB_ImageDecoder)
			PB_ImageEncoder_Register(*ImageEncoder.PB_ImageEncoder)
		EndImport
	CompilerEndIf
	
	; Private procedures (all OS)
	
	Procedure.i JPEGQuality(EncoderFlags.l)
		Protected Value.l = EncoderFlags & $FF
		If Value = 0
			Value = 80
		ElseIf Value > 100
			Value = 100
		EndIf
		ProcedureReturn Value
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		
		;{ >>> WINDOWS <<<
		
		;- Structures (Windows)
		
		Structure GdiplusStartupInput_
			GdiPlusVersion.i
			*DebugEventCallback
			SuppressBackgroundThread.l
			SuppressExternalCodecs.l
		EndStructure
		
		Structure BitmapData_
			Width.l
			Height.l
			Stride.l
			PixelFormat.l
			*Scan0
			*Reserved
		EndStructure
		
		Structure EncoderParameter_
			Guid.q[2]
			NumberOfValues.l
			Type.l
			*Value
		EndStructure
		
		Structure EncoderParameters_
			Count.i
			Parameter.EncoderParameter_[2]
		EndStructure
		
		;- Imports (Windows)
		
		Import "gdiplus.lib"
			GdipBitmapLockBits(bitmap, *rect, flags, format, *lockedBitmapData)
			GdipBitmapUnlockBits(bitmap, *lockedBitmapData)
			GdipCreateBitmapFromFile(filename.p-unicode, *bitmap)
			GdipCreateBitmapFromScan0(width, height, stride, format, *scan0, *bitmap)
			GdipCreateBitmapFromStream(stream, *bitmap)
			GdipDeleteGraphics(graphics)
			GdipDisposeImage(image)
			GdipDrawImageI(graphics, image, x, y)
			GdipGetImageHeight(image, *height)
			GdipGetImagePixelFormat(image, *format)
			GdipGetImageWidth(image, *width)
			GdipGetImageGraphicsContext(image, *graphics)
			GdipSaveImageToFile(image, filename.p-unicode, *clsidEncoder, *encoderParams)
			GdipSaveImageToStream(image, stream, *clsidEncoder, *encoderParams)
			GdiplusShutdown(token)
			GdiplusStartup(*token, *input, *output)
		EndImport
		
		;- Macros (Windows)
		
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			Macro rax : eax : EndMacro
			Macro rbx : ebx : EndMacro
			Macro rcx : ecx : EndMacro
			Macro rdx : edx : EndMacro
		CompilerEndIf 
		
		;- Global variables (Windows)
		
		Global Input.GdiplusStartupInput_, Token.i
		
		;- Private procedures (Windows)
		
		Procedure _PNGSizeCheck_(*MemoryAddress, MaxSize.l)
			EnableASM
			mov rdx, [p.p_MemoryAddress]
			!mov eax, [p.v_MaxSize]
			push rbx
			!lea ebx, [eax - 8]
			!xor eax, eax
			cmp dword [rdx], 0x474e5089
			!jne .l1
			cmp dword [rdx + 4], 0x0a1a0a0d
			!jne .l1
			!mov eax, 8
			!.l0:
			mov ecx, [rdx + rax]
			!bswap ecx
			lea rax, [rax + rcx + 12]
			!cmp eax, ebx
			!ja .l1
			cmp dword [rdx + rax + 4], 0x444e4549 
			!jne .l0
			!add eax, 12
			!.l1:
			pop rbx
			DisableASM
			ProcedureReturn
		EndProcedure
		
		Procedure.i _Start_()
			If Token = 0
				Input\GdiPlusVersion = 1
				GdiplusStartup(@Token, @Input, #Null)
			EndIf
			ProcedureReturn Token
		EndProcedure
		
		Procedure   _Cleanup_(*Globals.PB_ImageDecoderGlobals)
			If *Globals\Data[0]
				GdipDisposeImage(*Globals\Data[0]) : *Globals\Data[0] = #Null
			EndIf 
		EndProcedure
		
		Procedure.i _Check_(*Globals.PB_ImageDecoderGlobals)
			
			Protected Size.l, Stream.IStream
			
			If Token
				If *Globals\Mode = 0
					; File Mode
					GdipCreateBitmapFromFile(PeekS(*Globals\FileName), @*Globals\Data[0])
				Else
					; Memory Mode
					Size = _PNGSizeCheck_(*Globals\Buffer, *Globals\Length)
					If Size And Size < *Globals\Length
						*Globals\Length = Size
					EndIf
					Stream = MemoryStream::CreateMemoryStream(MemoryStream::#MemoryStream_ReadOnly, *Globals\Buffer, *Globals\Length)
					GdipCreateBitmapFromStream(Stream, @*Globals\Data[0])
					Stream\Release()
				EndIf
				If *Globals\Data[0]
					GdipGetImageWidth(*Globals\Data[0], @*Globals\Width)
					GdipGetImageHeight(*Globals\Data[0], @*Globals\Height)
					GdipGetImagePixelFormat(*Globals\Data[0], @*Globals\OriginalDepth)
					*Globals\OriginalDepth = *Globals\OriginalDepth >> 8 & $FF
					*Globals\Depth = 32
					ProcedureReturn #True
				EndIf
			EndIf
			ProcedureReturn #False
			
		EndProcedure
		
		Procedure.i _Decode_(*Globals.PB_ImageDecoderGlobals, *Buffer, Pitch.l, Flags.l)
			
			Protected Rect.Rect, BitmapData.BitmapData_
			
			Rect\right              = *Globals\Width
			Rect\bottom             = *Globals\Height
			BitmapData\Width        = *Globals\Width
			BitmapData\Height       = *Globals\Height
			If Flags & 2            ; ReverseY ?
				BitmapData\Stride     = -Pitch
				BitmapData\Scan0      = *Buffer + (*Globals\Height - 1) * Pitch
			Else
				BitmapData\Stride     = Pitch
				BitmapData\Scan0      = *Buffer
			EndIf
			BitmapData\PixelFormat  = $26200A
			GdipBitmapLockBits(*Globals\Data[0], @Rect, 5, $26200A, @BitmapData)
			GdipBitmapUnlockBits(*Globals\Data[0], @BitmapData)
			_Cleanup_(*Globals)
			ProcedureReturn #True
			
		EndProcedure
		
		Procedure.i _Encode_(PixelFormat, *Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			
			Protected.i Result, Bitmap, ImageType, TBuffer, TBitmap, Graphics, Value, Size.q, Stream.IStream
			Protected Parameters.EncoderParameters_, *Parameters = @Parameters
			Protected Dim CLSID.q(1)
			
			If Token
				If Flags & 2
					GdipCreateBitmapFromScan0(Width, Height, -LinePitch, PixelFormat, *Buffer + (Height - 1) * LinePitch, @Bitmap)
				Else
					GdipCreateBitmapFromScan0(Width, Height, LinePitch, PixelFormat, *Buffer, @Bitmap)
				EndIf
				If Bitmap
					ImageType = EncoderFlags >> 8 & 7
					If PixelFormat = $26200A And ImageType < 2
						; Try to flatten alpha channel for BMP and JPEG
						TBuffer = AllocateMemory(Width << 2 * Height, #PB_Memory_NoClear)
						If TBuffer
							FillMemory(TBuffer, Width << 2 * Height, $FFFFFFFF, #PB_Long)
							If GdipCreateBitmapFromScan0(Width, Height, Width << 2, PixelFormat, TBuffer, @TBitmap) = 0
								If GdipGetImageGraphicsContext(TBitmap, @Graphics) = 0
									GdipDrawImageI(Graphics, Bitmap, 0, 0)
									GdipDeleteGraphics(Graphics)
									GdipDisposeImage(Bitmap) : Bitmap = TBitmap
								EndIf
							EndIf
						EndIf
					EndIf
					Select ImageType
						Case 1  ; JPEG
							Value = JPEGQuality(EncoderFlags)
							Parameters\Count = 1
							Parameters\Parameter[0]\Guid[0] = $452DFA4A1D5BE4B5
							Parameters\Parameter[0]\Guid[1] = $EBE70551B35DDD9C
							Parameters\Parameter[0]\NumberOfValues = 1
							Parameters\Parameter[0]\Type = 4
							Parameters\Parameter[0]\Value = @Value
						Case 5  ; TIFF
							Value = EncoderFlags >> 12 & 7
							Parameters\Count = 2
							Parameters\Parameter[0]\Guid[0] = $44EECCD4E09D739D
							Parameters\Parameter[0]\Guid[1] = $58FCE48BBF3FBA8E
							Parameters\Parameter[0]\NumberOfValues = 1
							Parameters\Parameter[0]\Type = 4
							Parameters\Parameter[0]\Value = @Value
							Parameters\Parameter[1]\Guid[0] = $4C7CAD6666087055
							Parameters\Parameter[1]\Guid[1] = $37830B31A238189A
							Parameters\Parameter[1]\NumberOfValues = 1
							Parameters\Parameter[1]\Type = 4
							Parameters\Parameter[1]\Value = @RequestedDepth
						Default
							*Parameters = #Null
					EndSelect
					CLSID(0) = $11D31A04557CF400 + ImageType : CLSID(1) = $2EF31EF80000739A
					If *Filename
						; File Mode
						Result = Bool(GdipSaveImageToFile(Bitmap, PeekS(*Filename), @CLSID(), *Parameters) = 0)
					Else
						; Memory Mode
						If CreateStreamOnHGlobal_(#Null, #True, @Stream) = 0; Create empty stream which can grow
							If GdipSaveImageToStream(Bitmap, Stream, @CLSID(), *Parameters) = 0
								Stream\Seek(0, #STREAM_SEEK_END, @Size); Check stream size after saving to stream
								If Size > 0
									Result = AllocateMemory(Size, #PB_Memory_NoClear)
									If Result
										Stream\Seek(0, #STREAM_SEEK_SET, #Null)
										Stream\Read(Result, Size, #Null); Copy encoded image to allocated memory
									EndIf
								EndIf
							EndIf
							Stream\Release() 
						EndIf
					EndIf
					GdipDisposeImage(Bitmap) 
				EndIf
			EndIf
			If TBuffer
				FreeMemory(TBuffer) 
			EndIf
			ProcedureReturn Result
			
		EndProcedure
		
		Procedure.i _Encode24_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_($21808, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		Procedure.i _Encode32_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_($26200A, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		;}
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		
		;{ >>> MAC <<<   
		
		;- Global variables (Mac)
		
		Global.i NSImageCompressionFactor, NSImageCompressionMethod
		
		;- Imports (Mac)
		
		ImportC -framework Accelerate"
			dlsym(handle, symbol.p-utf8)
			strlen(*s)
			vImageUnpremultiplyData_RGBA8888(*src, *dest, flags)
			CFDataGetBytePtr(theData)
			CFRelease(cf)
			CFURLCreateFromFileSystemRepresentation(allocator, *buffer, bufLen, isDirectory)
			CGBitmapContextCreate(*data, width, height, bitsPerComponent, bytesPerRow, colorspace, bitmapInfo)
			CGColorSpaceCreateDeviceRGB()
			CGColorSpaceRelease(colorspace)
			CGContextDrawImage(c, xf.f, yf.f, wf.f, hf.f, image, d0.f, d1.f, d2.f, d3.f, xd.d, yd.d, wd.d, hd.d)
			CGContextRelease(context)
			CGDataProviderCopyData(provider)
			CGDataProviderCreateWithData(*info, *data, size, releaseData)
			CGDataProviderRelease(provider)
			CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, bitmapInfo, provider, *decode, shouldInterpolate, intent)
			CGImageGetBitmapInfo(image)
			CGImageGetBitsPerPixel(image)
			CGImageGetBytesPerRow(image)
			CGImageGetDataProvider(image)
			CGImageGetHeight(image)
			CGImageGetWidth(image)
			CGImageRelease(image)
			CGImageSourceCreateImageAtIndex(isrc, index, options)
			CGImageSourceCreateWithDataProvider(provider, options)
			CGImageSourceCreateWithURL(url, options)     
		EndImport
		
		;- Private procedures (Mac)
		
		ProcedureC.i _Start_()
			Static Started.i
			If Not Started
				NSImageCompressionFactor  = PeekI(dlsym(-2, "NSImageCompressionFactor"))
				NSImageCompressionMethod  = PeekI(dlsym(-2, "NSImageCompressionMethod"))
				Started = #True 
			EndIf
			ProcedureReturn #True 
		EndProcedure
		
		ProcedureC   _Cleanup_(*Globals.PB_ImageDecoderGlobals)
			If *Globals\Data[0]
				CGImageRelease(*Globals\Data[0]) : *Globals\Data[0] = #Null
			EndIf     
		EndProcedure
		
		ProcedureC.i _Check_(*Globals.PB_ImageDecoderGlobals)
			
			Protected.i BitmapInfo, Image, ImageSource, Properties, Provider, URL
			
			If *Globals\Mode = 0
				; File Mode
				URL = CFURLCreateFromFileSystemRepresentation(#Null, *Globals\Filename, strlen(*Globals\Filename), #False)
				ImageSource = CGImageSourceCreateWithURL(URL, #Null)
				CFRelease(URL)
			Else
				; Memory Mode
				Provider = CGDataProviderCreateWithData(#Null, *Globals\Buffer, *Globals\Length, #Null)
				ImageSource = CGImageSourceCreateWithDataProvider(Provider, #Null)
				CGDataProviderRelease(Provider)
			EndIf
			If ImageSource
				Image = CGImageSourceCreateImageAtIndex(ImageSource, 0, #Null)
				CFRelease(ImageSource)
				If Image
					BitmapInfo = CGImageGetBitmapInfo(Image)
					If BitmapInfo = 3 And CGImageGetBitsPerPixel(Image) = 32
						*Globals\Data[2] = CGImageGetBytesPerRow(Image)
					Else
						*Globals\Data[2] = 0
					EndIf
					BitmapInfo & $1F
					If BitmapInfo > 0 And BitmapInfo < 5
						*Globals\Data[1] = #True
						*Globals\OriginalDepth = 32
					Else
						*Globals\Data[1] = #False
						*Globals\OriginalDepth = 24
					EndIf
					*Globals\Data[0] = Image
					*Globals\Width = CGImageGetWidth(Image)
					*Globals\Height = CGImageGetHeight(Image)
					*Globals\Depth = 32
					ProcedureReturn #True
				EndIf
			EndIf
			ProcedureReturn #False
			
		EndProcedure
		
		ProcedureC.i _Decode_(*Globals.PB_ImageDecoderGlobals, *Buffer, Pitch.l, Flags.l)
			
			Protected.i ColorSpace, Context, Source
			Protected Dim vImg.i(3)
			
			If *Globals\Data[2] = Pitch
				Source = CGDataProviderCopyData(CGImageGetDataProvider(*Globals\Data[0]))
			EndIf
			If Source
				CopyMemory(CFDataGetBytePtr(Source), *Buffer, *Globals\Height * Pitch)
				CFRelease(Source)
			Else
				ColorSpace = CGColorSpaceCreateDeviceRGB()
				Context = CGBitmapContextCreate(*Buffer, *Globals\Width, *Globals\Height, 8, Pitch, ColorSpace, 1)
				CGContextDrawImage(Context, 0, 0, *Globals\Width, *Globals\Height, *Globals\Data[0], 0,0,0,0, 0, 0, *Globals\Width, *Globals\Height)
				CGContextRelease(Context)
				CGColorSpaceRelease(ColorSpace)
				If *Globals\Data[1]; Unpremultiply when original image had an alpha channel
					vImg(0) = *Buffer
					vImg(1) = *Globals\Height
					vImg(2) = *Globals\Width
					vImg(3) = Pitch
					vImageUnPremultiplyData_RGBA8888(@vImg(), @vImg(), 0)
				EndIf
			EndIf
			_Cleanup_(*Globals)
			ProcedureReturn #True
			
		EndProcedure
		
		ProcedureC.i _Encode_(Depth.l, *Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			
			Protected.i Provider, ColorSpace, Image, ImageRep, Pool, ImageType, Props, ImageData, Length, Result
			Protected FileName.s, Quality.f
			
			Provider = CGDataProviderCreateWithData(#Null, *Buffer, Height * LinePitch, #Null)
			ColorSpace = CGColorSpaceCreateDeviceRGB()
			If Depth = 32
				Image = CGImageCreate(Width, Height, 8, 32, LinePitch, ColorSpace, 3, Provider, #Null, #False, 0)
			Else
				Image = CGImageCreate(Width, Height, 8, 24, LinePitch, ColorSpace, 0, Provider, #Null, #False, 0)
			EndIf
			ImageRep = CocoaMessage(0, CocoaMessage(0, 0, "NSBitmapImageRep alloc"), "initWithCGImage:", Image)
			CGImageRelease(Image)
			CGColorSpaceRelease(ColorSpace)
			CGDataProviderRelease(Provider)
			If ImageRep
				Pool = CocoaMessage(0, 0, "NSAutoreleasePool new")
				ImageType = EncoderFlags >> 20 & 7
				Select ImageType
					Case 0  ; TIFF
						Props = CocoaMessage(0, 0, "NSDictionary dictionaryWithObject:",
						                     CocoaMessage(0, 0, "NSNumber numberWithInt:", EncoderFlags >> 16 & 7),
						                     "forKey:", NSImageCompressionMethod)
					Case 3  ; JPEG
						Quality = 0.01 * JPEGQuality(EncoderFlags)
						Props = CocoaMessage(0, 0, "NSDictionary dictionaryWithObject:",
						                     CocoaMessage(0, 0, "NSNumber numberWithFloat:@", @Quality),
						                     "forKey:", NSImageCompressionFactor)
				EndSelect
				ImageData = CocoaMessage(0, ImageRep, "representationUsingType:", ImageType, "properties:", Props)
				If ImageData
					If *Filename
						; File Mode
						FileName = PeekS(*Filename, -1, #PB_UTF8)
						Result = CocoaMessage(0, ImageData, "writeToFile:$", @FileName, "atomically:", #NO)
					Else
						; Memory Mode
						Length = CocoaMessage(0, ImageData, "length")
						Result = AllocateMemory(Length, #PB_Memory_NoClear)
						CocoaMessage(0, ImageData, "getBytes:", Result, "length:", Length)
					EndIf
				EndIf
				CocoaMessage(0, Pool, "release")
				CocoaMessage(0, ImageRep, "release")
			EndIf
			
			ProcedureReturn Result
			
		EndProcedure
		
		ProcedureC.i _Encode24_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_(24, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		ProcedureC.i _Encode32_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_(32, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		;}
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
		
		;{ >>> LINUX <<< 
		
		;- Imports (Linux)
		
		ImportC ""
			free(ptr)
			g_object_ref(object)
			g_object_unref(object)
			gdk_pixbuf_composite_color_simple(src, dest_width, dest_height, interp_type,
			                                  overall_alpha, check_size, color1, color2)
			gdk_pixbuf_copy_area(src, src_x, src_y, width, height, dest, dest_x, dest_y)
			gdk_pixbuf_get_bits_per_sample(pixbuf)
			gdk_pixbuf_get_height(pixbuf)
			gdk_pixbuf_get_n_channels(pixbuf)
			gdk_pixbuf_get_width(pixbuf)
			gdk_pixbuf_loader_close(loader, *error)
			gdk_pixbuf_loader_get_pixbuf(loader)
			gdk_pixbuf_loader_new()
			gdk_pixbuf_loader_write(loader, buf, count, *error)
			gdk_pixbuf_new_from_data(*data, colorspace, has_alpha, bits_per_sample,
			                         width, height, rowstride, destroy_fn, destroy_fn_data)
			gdk_pixbuf_new_from_file(*filename, *error)
			gdk_pixbuf_save(pixbuf, *filename, type.p-ascii, *error, param.p-ascii, value.p-ascii, null = 0)
			gdk_pixbuf_save_to_buffer(pixbuf, *buffer, *buffer_size, type.p-ascii, *error, param.p-ascii, value.p-ascii, null = 0)
		EndImport
		
		;- Global variables (Linux)
		
		Global Dim Type.s(7)
		
		;- Private procedures (Linux)
		
		ProcedureC.i _Start_()
			Static Started.i
			If Not Started
				Type(0) = "tiff" : Type(1) = "bmp" : Type(2) = "gif" : Type(3) = "jpeg" : Type(4) = "png"
				Started = #True 
			EndIf
			ProcedureReturn #True 
		EndProcedure
		
		ProcedureC   _Cleanup_(*Globals.PB_ImageDecoderGlobals)
			If *Globals\Data[0]
				g_object_unref(*Globals\Data[0]) : *Globals\Data[0] = #Null
			EndIf
		EndProcedure
		
		ProcedureC.i _Check_(*Globals.PB_ImageDecoderGlobals)
			Protected.i Loader, PixBuf
			If *Globals\Mode = 0
				; File Mode
				PixBuf = gdk_pixbuf_new_from_file(*Globals\Filename, #Null)
			Else
				; Memory Mode
				Loader = gdk_pixbuf_loader_new()
				gdk_pixbuf_loader_write(Loader, *Globals\Buffer, *Globals\length, #Null)
				gdk_pixbuf_loader_close(Loader, #Null)
				PixBuf = gdk_pixbuf_loader_get_pixbuf(Loader)
				If PixBuf : g_object_ref(PixBuf) : EndIf
				g_object_unref(Loader)
			EndIf
			If PixBuf
				*Globals\Data[0] = PixBuf
				*Globals\Width = gdk_pixbuf_get_width(PixBuf)
				*Globals\Height = gdk_pixbuf_get_height(PixBuf)
				*Globals\OriginalDepth = gdk_pixbuf_get_bits_per_sample(PixBuf) * gdk_pixbuf_get_n_channels(PixBuf)
				*Globals\Depth = 32
				ProcedureReturn #True
			EndIf
			ProcedureReturn #False
		EndProcedure
		
		ProcedureC.i _Decode_(*Globals.PB_ImageDecoderGlobals, *Buffer, Pitch, Flags)
			Protected.i Result, PixBuf
			PixBuf = gdk_pixbuf_new_from_data(*Buffer, 0, #True, 8, *Globals\Width, *Globals\Height, Pitch, #Null, 0)
			If PixBuf
				gdk_pixbuf_copy_area(*Globals\Data[0], 0, 0, *Globals\Width, *Globals\Height, PixBuf, 0, 0)
				g_object_unref(PixBuf)
				Result = #True
			EndIf
			_Cleanup_(*Globals)
			ProcedureReturn Result
		EndProcedure
		
		ProcedureC.i _Encode_(HasAlpha, *Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			Protected.i Result, PixBuf, TPixBuf, ImageType, Error, TBuffer, TBuffer_Size
			Protected.s Param, Value
			PixBuf = gdk_pixbuf_new_from_data(*Buffer, 0, HasAlpha, 8, Width, Height, LinePitch, #Null, 0)
			If PixBuf
				ImageType = EncoderFlags >> 20 & 7
				If HasAlpha And (ImageType = 1 Or ImageType = 3)
					; Try to flatten alpha channel for BMP and JPEG
					TPixBuf = gdk_pixbuf_composite_color_simple(PixBuf, Width, Height, 0, 255, 16, $FFFFFFFF, $FFFFFFFF)
					If TPixBuf
						g_object_unref(PixBuf) : PixBuf = TPixBuf
					EndIf
				EndIf
				Select ImageType
					Case 0  ; TIFF
						Param = "compression" : Value = Str(EncoderFlags >> 16 & 7)
					Case 3  ; JPEG
						Param = "quality" : Value = Str(JPEGQuality(EncoderFlags))
				EndSelect
				If *Filename
					; File mode
					Result = gdk_pixbuf_save(PixBuf, *Filename, Type(ImageType), @Error, Param, Value)
				Else
					; Memory mode
					If gdk_pixbuf_save_to_buffer(PixBuf, @TBuffer, @TBuffer_Size, Type(EncoderFlags >> 20 & 7), @Error, Param, Value)
						Result = AllocateMemory(TBuffer_Size, #PB_Memory_NoClear)
						If Result
							CopyMemory(TBuffer, Result, TBuffer_Size) 
						EndIf
						free(TBUffer)
					EndIf
				EndIf
				g_object_unref(PixBuf)
			EndIf
			ProcedureReturn Result
		EndProcedure
		
		ProcedureC.i _Encode24_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_(#False, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		ProcedureC.i _Encode32_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
			ProcedureReturn _Encode_(#True, *Filename, *Buffer, Width, Height, LinePitch, Flags, EncoderFlags, RequestedDepth)
		EndProcedure
		
		;}
		
	CompilerEndIf   
	
	;- Public procedures (all OS)
	
	Procedure ModuleImagePluginStop()
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			If Token
				GdiplusShutdown(Token) : Token = 0
			EndIf
		CompilerEndIf
	EndProcedure
	
	Procedure.i UseSystemImageDecoder()
		Static SystemImageDecoder.PB_ImageDecoder, Registered.i
		If _Start_() And Registered = #False
			SystemImageDecoder\ID       = #SystemImagePlugin
			SystemImageDecoder\Check    = @_Check_()
			SystemImageDecoder\Cleanup  = @_Cleanup_()
			SystemImageDecoder\Decode   = @_Decode_()
			PB_ImageDecoder_Register(SystemImageDecoder)
			Registered = #True
		EndIf
		ProcedureReturn Registered
	EndProcedure
	
	Procedure.i UseSystemImageEncoder()
		Static SystemImageEncoder.PB_ImageEncoder, Registered.i
		If _Start_() And Registered = #False
			SystemImageEncoder\ID       = #SystemImagePlugin
			SystemImageEncoder\Encode24 = @_Encode24_()
			SystemImageEncoder\Encode32 = @_Encode32_()
			PB_ImageEncoder_Register(SystemImageEncoder)
			Registered = #True
		EndIf
		ProcedureReturn Registered
	EndProcedure
	
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 722
; Folding = EA5BAAAg
; EnableXP