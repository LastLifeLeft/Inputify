;===================================================;
; Module    : MemoryStream (IStream implementation) ;
; Author    : Wilbert                               ;
; Date      : Sep 6, 2016                           ;
; Version   : 1.03                                  ;
; OS        : Windows                               ;
;===================================================;

;- Module declaration

DeclareModule MemoryStream
 
  #MemoryStream_ReadOnly  = 0
  #MemoryStream_ReadWrite = 1
 
  Declare.i CreateMemoryStream(AccessMode, *MemoryBuffer, Size.q = $7FFFFFFF)
 
EndDeclareModule


;- Module implementation

Module MemoryStream
 
  EnableExplicit
  DisableDebugger
 
  ;- Structures
 
  Structure MStream_Object
    *vtable.IStream
    refcount.l
    accessmode.l
    *buffer
    bufsize.q
    bufpos.q
  EndStructure
 
  CompilerIf Not Defined(STATSTG, #PB_Structure)
    Structure STATSTG Align #PB_Structure_AlignC
      *pwcsName
      type.l
      cbSize.q
      mtime.q
      ctime.q
      atime.q
      grfMode.l
      grfLocksSupported.l
      clsid.b[16]
      grfStateBits.l
      reserved.l
    EndStructure
  CompilerEndIf
 
 
  ;- Object creation procedure
 
  Procedure.i CreateMemoryStream(AccessMode, *MemoryBuffer, Size.q = $7FFFFFFF)
    Protected *MStream.MStream_Object = AllocateMemory(SizeOf(MStream_Object))
    *MStream\vtable = ?MStream_vtable
    *MStream\refcount = 1
    *MStream\accessmode = AccessMode
    *MStream\buffer = *MemoryBuffer
    *MStream\bufsize = Size
    ProcedureReturn *MStream
  EndProcedure
 
 
  ;- Interface implementation
 
  Procedure.i MStream_QueryInterface(*this.MStream_Object, *iid, *ppvObject.Integer)
   
    Protected *iidCompare.Quad = *iid
    *ppvObject\i = #Null
   
    ; Compare iid as two quads
    Select *iidCompare\q
      Case 0, $C:               ; IUnknown / IStream ?
        *iidCompare + 8
        If *iidCompare\q <> $46000000000000C0
          ProcedureReturn #E_NOINTERFACE
        EndIf
      Case $11CE2A1C0C733A30:   ; ISequentialStream ?
        *iidCompare + 8
        If *iidCompare\q <> $3D774400AA00E5AD
          ProcedureReturn #E_NOINTERFACE
        EndIf
      Default:
        ProcedureReturn #E_NOINTERFACE
    EndSelect
   
    *this\vtable\AddRef()
    *ppvObject\i = *this
    ProcedureReturn #S_OK
   
  EndProcedure
 
   
  Procedure.i MStream_AddRef(*this.MStream_Object)
    ; InterlockedIncrement of *this\refcount
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !mov edx, [p.p_this]
      !lock inc dword [edx + 4]
    CompilerElse
      !mov rdx, [p.p_this]
      !lock inc dword [rdx + 8]
    CompilerEndIf
    ProcedureReturn *this\refcount
  EndProcedure
 
 
  Procedure.i MStream_Release(*this.MStream_Object)
    ; InterlockedDecrement of *this\refcount
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !mov edx, [p.p_this]
      !lock dec dword [edx + 4]
    CompilerElse
      !mov rdx, [p.p_this]
      !lock dec dword [rdx + 8]
    CompilerEndIf
    ; Free memory if refcount = 0
    If *this\refcount = 0
      FreeMemory(*this)
      ProcedureReturn 0
    EndIf
    ProcedureReturn *this\refcount
  EndProcedure
 
 
  Procedure.i MStream_Read(*this.MStream_Object, *pv, cb.l, *pcbRead.Long)
   
    Protected status.i; Initial value = #S_OK
   
    If *pv = 0
      cb = 0
      status = #STG_E_INVALIDPOINTER
    ElseIf cb
      If *this\bufpos => *this\bufsize
        cb = 0
        status = #S_FALSE
      Else
        If *this\bufpos + cb > *this\bufsize
          cb = *this\bufsize - *this\bufpos
        EndIf
        CopyMemory(*this\buffer + *this\bufpos, *pv, cb)
        *this\bufpos + cb
      EndIf 
    EndIf
   
    If *pcbRead
      *pcbRead\l = cb
    EndIf
   
    ProcedureReturn status
   
  EndProcedure
 
 
  Procedure.i MStream_Write(*this.MStream_Object, *pv, cb.l, *pcbWritten.Long)
   
    Protected status.i; Initial value = #S_OK
   
    If *this\accessmode = 0
      cb = 0
      status = #STG_E_ACCESSDENIED
    ElseIf *pv = 0
      cb = 0
      status = #STG_E_INVALIDPOINTER
    ElseIf cb
      If *this\bufpos >= *this\bufsize
        cb = 0
        status = #STG_E_MEDIUMFULL
      Else
        If *this\bufpos + cb > *this\bufsize
          cb = *this\bufsize - *this\bufpos
          status = #STG_E_MEDIUMFULL
        EndIf
        CopyMemory(*pv, *this\buffer + *this\bufpos, cb)
        *this\bufpos + cb
      EndIf
    EndIf
   
    If *pcbWritten
      *pcbWritten\l = cb
    EndIf
   
    ProcedureReturn status
   
  EndProcedure
 
 
  Procedure.i MStream_Seek(*this.MStream_Object, dlibMove.q, dwOrigin.l, *plibNewPosition.Quad)
   
    Protected newpos.q
   
    Select dwOrigin
      Case #STREAM_SEEK_SET:
        newpos = dlibMove
      Case #STREAM_SEEK_CUR:
        newpos = *this\bufpos + dlibMove     
      Case #STREAM_SEEK_END:
        newpos = *this\bufsize + dlibMove
      Default:
        ProcedureReturn #STG_E_INVALIDFUNCTION
    EndSelect
   
    If newpos < 0
      ProcedureReturn #STG_E_INVALIDFUNCTION
    EndIf
   
    *this\bufpos = newpos
   
    If *plibNewPosition
      *plibNewPosition\q = *this\bufpos
    EndIf
   
    ProcedureReturn #S_OK
   
  EndProcedure
 
 
  Procedure.i MStream_SetSize(*this.MStream_Object, libNewSize.q)
    ProcedureReturn #E_NOTIMPL
  EndProcedure
 
 
  Procedure.i MStream_CopyTo(*this.MStream_Object, *pstm.IStream, cb.q, *pcbRead.Quad, *pcbWritten.Quad)
   
    ; Implemented by calling *pstm\Write so max cb supported is 4GB
   
    If *pcbRead     : *pcbRead\q    = 0 : EndIf
    If *pcbWritten  : *pcbWritten\q = 0 : EndIf
   
    If *pstm = 0
      ProcedureReturn #STG_E_INVALIDPOINTER
    ElseIf *this\bufpos + cb > *this\bufsize
      cb = *this\bufsize - *this\bufpos
      If cb < 0
        cb = 0
      EndIf
    EndIf
   
    If *pcbRead
      *pcbRead\q = cb
    EndIf
   
    *this\bufpos + cb
    ProcedureReturn *pstm\Write(*this\buffer + *this\bufpos - cb, cb, *pcbWritten)
   
  EndProcedure
 
 
  Procedure.i MStream_Commit(*this.MStream_Object, grfCommitFlags.l)
    ProcedureReturn #E_NOTIMPL 
  EndProcedure
 
  Procedure.i MStream_Revert(*this.MStream_Object)
    ProcedureReturn #E_NOTIMPL 
  EndProcedure 
 
  Procedure.i MStream_LockRegion(*this.MStream_Object, libOffset.q, cb.q, dwLockType.l)
    ProcedureReturn #E_NOTIMPL 
  EndProcedure
 
  Procedure.i MStream_UnlockRegion(*this.MStream_Object, libOffset.q, cb.q, dwLockType.l)
    ProcedureReturn #E_NOTIMPL 
  EndProcedure
 
 
  Procedure.i MStream_Stat(*this.MStream_Object, *pstatstg.STATSTG, grfStatFlag.l)
   
    If *pstatstg = 0
      ProcedureReturn #STG_E_INVALIDPOINTER
    EndIf
   
    FillMemory(*pstatstg, SizeOf(STATSTG))
    *pstatstg\type = #STGTY_STREAM
    *pstatstg\cbSize = *this\bufsize
    If *this\accessmode = 0
      *pstatstg\grfMode = #STGM_READ
    Else
      *pstatstg\grfMode = #STGM_READWRITE
    EndIf
     
    ProcedureReturn #S_OK
   
  EndProcedure
 
 
  Procedure.i MStream_Clone(*this.MStream_Object, *ppstm.Integer)
   
    Protected *MStream.MStream_Object
   
    If *ppstm = 0
      ProcedureReturn #STG_E_INVALIDPOINTER
    EndIf
   
    *MStream.MStream_Object = AllocateMemory(SizeOf(MStream_Object))
    CopyMemory(*this, *MStream, SizeOf(MStream_Object))
    *MStream\refcount = 1
   
    *ppstm\i = *MStream
   
    ProcedureReturn #S_OK
   
  EndProcedure
 
 
  ;- Virtual table
 
  DataSection
    MStream_vtable:
    Data.i @MStream_QueryInterface()
    Data.i @MStream_AddRef(), @MStream_Release()
    Data.i @MStream_Read(), @MStream_Write()
    Data.i @MStream_Seek()
    Data.i @MStream_SetSize()
    Data.i @MStream_CopyTo()
    Data.i @MStream_Commit(), @MStream_Revert()
    Data.i @MStream_LockRegion(), @MStream_UnlockRegion()
    Data.i @MStream_Stat()
    Data.i @MStream_Clone()
  EndDataSection
 
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 324
; FirstLine = 248
; Folding = ----
; EnableXP