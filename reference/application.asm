; Application image (0x86E0-0xC24F) - MC9S08AW32 LIN slave
; Generated annotated disassembly (HCS08). Addresses are absolute.
; Symbol names are the reverse-engineering labels used in the C sources.


;---------------------------------------------------------------
; Flash_BurstProgram   [0x8620]   <- 8C4E, 8C6F, 8C8B
;---------------------------------------------------------------
  8620:  a6aa         lda    #$AA
  8622:  c71800       sta    SRS
  8625:  b6a8         lda    $A8
  8627:  b7a2         sta    $A2
  8629:  b6a9         lda    $A9
  862B:  b7a3         sta    $A3
  862D:  a630         lda    #$30
  862F:  c71825       sta    FSTAT
  8632:  6e40a5       mov    #$40, $A5
  8635:  95           tsx    
  8636:  35a6         sthx   $A6
  8638:  458683       ldhx   #$8683
L863B:
  863B:  f6           lda    ,x
  863C:  87           psha   
  863D:  afff         aix    #$FF
  863F:  3ba5f9       dbnz   $A5, L863B
  8642:  95           tsx    
  8643:  fc           jmp    ,x
;   .... data/gap 8644-8684 ....

;---------------------------------------------------------------
; Flash_ErasePage   [0x8684]   <- 8C2A
;---------------------------------------------------------------
  8684:  074afd       brclr  3, ICGS1, Flash_ErasePage
  8687:  c61825       lda    FSTAT
  868A:  aa10         ora    #$10
  868C:  c71825       sta    FSTAT
  868F:  a64c         lda    #$4C
  8691:  c71820       sta    FCDIV
  8694:  a655         lda    #$55
  8696:  c71800       sta    SRS
  8699:  b6a8         lda    $A8
  869B:  b7a2         sta    $A2
  869D:  b6a9         lda    $A9
  869F:  b7a3         sta    $A3
  86A1:  a630         lda    #$30
  86A3:  c71825       sta    FSTAT
  86A6:  6e24a5       mov    #$24, $A5
  86A9:  95           tsx    
  86AA:  35a6         sthx   $A6
  86AC:  4586db       ldhx   #$86DB
L86AF:
  86AF:  f6           lda    ,x
  86B0:  87           psha   
  86B1:  afff         aix    #$FF
  86B3:  3ba5f9       dbnz   $A5, L86AF
  86B6:  95           tsx    
  86B7:  fc           jmp    ,x
;   .... data/gap 86B8-86E0 ....

;---------------------------------------------------------------
; App_Startup   [0x86E0]   <- 87D4
;---------------------------------------------------------------
  86E0:  45086f       ldhx   #$086F
  86E3:  94           txs    
  86E4:  45c17d       ldhx   #$C17D
L86E7:
  86E7:  e601         lda    1,x
  86E9:  87           psha   
  86EA:  f6           lda    ,x
  86EB:  87           psha   
L86EC:
  86EC:  e602         lda    2,x
  86EE:  2749         beq    L8739
  86F0:  a560         bit    #$60
  86F2:  2606         bne    L86FA
  86F4:  a702         ais    #$02
  86F6:  af05         aix    #$05
  86F8:  20ed         bra    L86E7
L86FA:
  86FA:  89           pshx   
  86FB:  8b           pshh   
  86FC:  e606         lda    6,x
  86FE:  e001         sub    1,x
  8700:  87           psha   
  8701:  e605         lda    5,x
  8703:  f2           sbc    ,x
  8704:  9e6d01       tst    1,s
  8707:  2701         beq    L870A
  8709:  4c           inca   
L870A:
  870A:  87           psha   
  870B:  e603         lda    3,x
  870D:  87           psha   
  870E:  ee04         ldx    4,x
  8710:  8a           pulh   
L8711:
  8711:  89           pshx   
  8712:  8b           pshh   
  8713:  9eee07       ldx    7,s
  8716:  89           pshx   
  8717:  8a           pulh   
  8718:  9eee08       ldx    8,s
  871B:  9e6c08       inc    8,s
  871E:  2603         bne    L8723
  8720:  9e6c07       inc    7,s
L8723:
  8723:  f6           lda    ,x
  8724:  8a           pulh   
  8725:  88           pulx   
  8726:  f7           sta    ,x
  8727:  af01         aix    #$01
  8729:  9e6b02e4     dbnz   2,s, L8711
  872D:  9e6b01e0     dbnz   1,s, L8711
  8731:  a702         ais    #$02
  8733:  8a           pulh   
  8734:  88           pulx   
  8735:  af05         aix    #$05
  8737:  20b3         bra    L86EC
L8739:
  8739:  a702         ais    #$02
  873B:  4501a0       ldhx   #$01A0
  873E:  2003         bra    L8743
L8740:
  8740:  7f           clr    ,x
  8741:  af01         aix    #$01
L8743:
  8743:  6502ee       cphx   #$02EE
  8746:  26f8         bne    L8740
  8748:  cd874d       jsr    main
L874B:
  874B:  20fe         bra    L874B

;---------------------------------------------------------------
; main   [0x874D]   <- 8748
;---------------------------------------------------------------
  874D:  ad1e         bsr    App_InitAll
  874F:  4f           clra   
  8750:  c701a0       sta    g_tickCount
  8753:  c701a4       sta    g_tickSnapshot
  8756:  c701a3       sta    g_slot10
  8759:  c701a1       sta    g_tickFlag
  875C:  c71808       sta    SRTISC
L875F:
  875F:  c601a1       lda    g_tickFlag
  8762:  4bfb         dbnza  L875F
  8764:  cd8835       jsr    Scheduler_Run
  8767:  4f           clra   
  8768:  c701a1       sta    g_tickFlag
  876B:  20f2         bra    L875F

;---------------------------------------------------------------
; App_InitAll   [0x876D]   <- main, App_InitAll_tail
;---------------------------------------------------------------
  876D:  cdb7b8       jsr    EnterCritical
  8770:  cd8967       jsr    Clock_Init
  8773:  cd8986       jsr    SysOpt_Init
  8776:  cd89d0       jsr    COP_Feed
  8779:  cdb415       jsr    Ports_Init
  877C:  cd8a85       jsr    Nvm_Init
  877F:  cdbec2       jsr    Adc_Init
  8782:  cdb84d       jsr    Inputs_Init
  8785:  cd8a60       jsr    Tpm2_Init
  8788:  cd89d0       jsr    COP_Feed
  878B:  cdbc54       jsr    Outputs_Init
  878E:  cd8a29       jsr    Tpm1_Init
  8791:  cda99e       jsr    Motor_Init
  8794:  cda12e       jsr    Ctrl_Init
  8797:  cdb5a3       jsr    Diag_Init
  879A:  cdac81       jsr    LinSignals_Init
  879D:  cdaa10       jsr    Fault_Init
  87A0:  cda0e6       jsr    Sensor_Init
  87A3:  cdb932       jsr    Supply_Init
  87A6:  c60299       lda    g_featureFlags
  87A9:  a404         and    #$04
  87AB:  270b         beq    L87B8
  87AD:  c602ea       lda    g_testMode
  87B0:  2606         bne    L87B8
  87B2:  cda6f9       jsr    MotorPos_Init
  87B5:  cda1e6       jsr    Ctrl_Start
L87B8:
  87B8:  c60299       lda    g_featureFlags
  87BB:  a402         and    #$02
  87BD:  2708         beq    L87C7
  87BF:  c602ea       lda    g_testMode
  87C2:  2603         bne    L87C7
  87C4:  cdb7d9       jsr    Heater_Init
L87C7:
  87C7:  cd8e10       jsr    LinApp_Reset
  87CA:  cdacb7       jsr    LinSignals_Refresh
  87CD:  ccb7c5       jmp    ExitCritical

;---------------------------------------------------------------
; Isr_Default   [0x87D0]
;---------------------------------------------------------------
  87D0:  8b           pshh   
  87D1:  b6c6         lda    g_mulDiv_tmp
  87D3:  87           psha   
  87D4:  cd86e0       jsr    App_Startup
  87D7:  86           pula   
  87D8:  b7c6         sta    g_mulDiv_tmp
  87DA:  8a           pulh   
  87DB:  80           rti    

;---------------------------------------------------------------
; Sleep_Process   [0x87DC]   <- 893E
;---------------------------------------------------------------
  87DC:  c60100       lda    g_sleepState
  87DF:  a402         and    #$02
  87E1:  2703         beq    L87E6
  87E3:  cd8954       jsr    Sleep_Enter
L87E6:
  87E6:  c602ae       lda    g_linAppFlags
  87E9:  a401         and    #$01
  87EB:  2717         beq    L8804
  87ED:  c60101       lda    g_sleepPrepared
  87F0:  2612         bne    L8804
  87F2:  a601         lda    #$01
  87F4:  c70100       sta    g_sleepState
  87F7:  cd8b39       jsr    Nvm_RequestSave
  87FA:  5f           clrx   
  87FB:  4f           clra   
  87FC:  cdaa0c       jsr    Fault_Report
  87FF:  a601         lda    #$01
  8801:  c70101       sta    g_sleepPrepared
L8804:
  8804:  81           rts    

;---------------------------------------------------------------
; Nvm_SetEvent   [0x8805]   <- 8BE4, 8CAF
;---------------------------------------------------------------
  8805:  450102       ldhx   #$0102
  8808:  fa           ora    ,x
  8809:  f7           sta    ,x
  880A:  450100       ldhx   #$0100
  880D:  4b05         dbnza  L8814
  880F:  f6           lda    ,x
  8810:  aa02         ora    #$02
  8812:  2003         bra    L8817
L8814:
  8814:  f6           lda    ,x
  8815:  a4fd         and    #$FD
L8817:
  8817:  f7           sta    ,x
  8818:  81           rts    

;---------------------------------------------------------------
; TickCount_Adjust   [0x8819]   <- 89BE
;---------------------------------------------------------------
  8819:  87           psha   
  881A:  89           pshx   
  881B:  cdb7b8       jsr    EnterCritical
  881E:  95           tsx    
  881F:  e601         lda    1,x
  8821:  4501a0       ldhx   #$01A0
  8824:  fb           add    ,x
  8825:  f7           sta    ,x
  8826:  ae64         ldx    #$64
  8828:  8c           clrh   
  8829:  52           div    
  882A:  8b           pshh   
  882B:  86           pula   
  882C:  c701a0       sta    g_tickCount
  882F:  cdb7c5       jsr    ExitCritical
  8832:  a702         ais    #$02
  8834:  81           rts    

;---------------------------------------------------------------
; Scheduler_Run   [0x8835]   <- 8764
;---------------------------------------------------------------
  8835:  c601a0       lda    g_tickCount
  8838:  c701a4       sta    g_tickSnapshot
  883B:  a501         bit    #$01
  883D:  2605         bne    L8844
  883F:  ad4c         bsr    Task_2Ticks
  8841:  c601a4       lda    g_tickSnapshot
L8844:
  8844:  3fc6         clr    g_mulDiv_tmp
  8846:  8c           clrh   
  8847:  ae05         ldx    #$05
  8849:  cdc06c       jsr    muls8
  884C:  4d           tsta   
  884D:  2606         bne    L8855
  884F:  3dc6         tst    g_mulDiv_tmp
  8851:  2602         bne    L8855
  8853:  ad43         bsr    Task_5Ticks
L8855:
  8855:  c601a4       lda    g_tickSnapshot
  8858:  3fc6         clr    g_mulDiv_tmp
  885A:  8c           clrh   
  885B:  ae0a         ldx    #$0A
  885D:  cdc06c       jsr    muls8
  8860:  4d           tsta   
  8861:  2606         bne    L8869
  8863:  3dc6         tst    g_mulDiv_tmp
  8865:  2602         bne    L8869
  8867:  ad38         bsr    Task_10Ticks
L8869:
  8869:  c601a4       lda    g_tickSnapshot
  886C:  3fc6         clr    g_mulDiv_tmp
  886E:  8c           clrh   
  886F:  ae19         ldx    #$19
  8871:  cdc06c       jsr    muls8
  8874:  4d           tsta   
  8875:  2607         bne    L887E
  8877:  3dc6         tst    g_mulDiv_tmp
  8879:  2603         bne    L887E
  887B:  cd894e       jsr    Task_25Ticks
L887E:
  887E:  c601a4       lda    g_tickSnapshot
  8881:  a164         cmp    #$64
  8883:  2507         bcs    L888C
  8885:  4f           clra   
  8886:  c701a0       sta    g_tickCount
  8889:  c701a4       sta    g_tickSnapshot
L888C:
  888C:  81           rts    

;---------------------------------------------------------------
; Task_2Ticks   [0x888D]   <- 883F
;---------------------------------------------------------------
  888D:  c602ea       lda    g_testMode
  8890:  2603         bne    L8895
  8892:  cdb9fd       jsr    Supply_Task
L8895:
  8895:  cc89d0       jmp    COP_Feed

;---------------------------------------------------------------
; Task_5Ticks   [0x8898]   <- 8853
;---------------------------------------------------------------
  8898:  c602ea       lda    g_testMode
  889B:  2603         bne    L88A0
  889D:  cdaa36       jsr    Fault_Task
L88A0:
  88A0:  81           rts    

;---------------------------------------------------------------
; Task_10Ticks   [0x88A1]   <- 8867
;---------------------------------------------------------------
  88A1:  4501a3       ldhx   #$01A3
  88A4:  7c           inc    ,x
  88A5:  cd898d       jsr    NvmTask_Run
  88A8:  c60299       lda    g_featureFlags
  88AB:  a404         and    #$04
  88AD:  2708         beq    L88B7
  88AF:  c602ea       lda    g_testMode
  88B2:  2603         bne    L88B7
  88B4:  cda256       jsr    Ctrl_Task
L88B7:
  88B7:  c601a3       lda    g_slot10
  88BA:  4a           deca   
  88BB:  a10a         cmp    #$0A
  88BD:  2503         bcs    L88C2
  88BF:  cc8947       jmp    $8947
L88C2:
  88C2:  cdc0e6       jsr    switch_jump
         ; switch: 0->L88DB  1->L88E0  2->L88DB  3->L88E0  4->L88E8  5->L88E0  6->L88DB  7->L88E0  8->L8905  9->L890D
;   .... data/gap 88D9-88DB ....
L88DB:
  88DB:  cd8e35       jsr    LinApp_DecodeCommand
  88DE:  206b         bra    L894B
L88E0:
  88E0:  cda9a9       jsr    Motor_Task
  88E3:  cdbcb1       jsr    Outputs_Task
  88E6:  2063         bra    L894B
L88E8:
  88E8:  c60299       lda    g_featureFlags
  88EB:  a402         and    #$02
  88ED:  2708         beq    L88F7
  88EF:  c602ea       lda    g_testMode
  88F2:  2603         bne    L88F7
  88F4:  cdb7e8       jsr    Heater_Task
L88F7:
  88F7:  cd8e35       jsr    LinApp_DecodeCommand
  88FA:  c602b0       lda    g_testRequest
  88FD:  4b4c         dbnza  L894B
  88FF:  4f           clra   
  8900:  c702b0       sta    g_testRequest
  8903:  2046         bra    L894B
L8905:
  8905:  cd8e35       jsr    LinApp_DecodeCommand
  8908:  cdb4d7       jsr    Diag_Task
  890B:  203e         bra    L894B
L890D:
  890D:  c60299       lda    g_featureFlags
  8910:  a402         and    #$02
  8912:  2708         beq    L891C
  8914:  c602ea       lda    g_testMode
  8917:  2603         bne    L891C
  8919:  cdb7e8       jsr    Heater_Task
L891C:
  891C:  c60299       lda    g_featureFlags
  891F:  a404         and    #$04
  8921:  2715         beq    L8938
  8923:  c602b6       lda    g_supplyVoltage
  8926:  c1016c       cmp    $016C
  8929:  240d         bcc    L8938
  892B:  c1016e       cmp    $016E
  892E:  2308         bls    L8938
  8930:  c602ea       lda    g_testMode
  8933:  2603         bne    L8938
  8935:  cda5b5       jsr    MotorPos_Task
L8938:
  8938:  cda694       jsr    Ctrl_SlowTask
  893B:  cdbcb1       jsr    Outputs_Task
  893E:  cd87dc       jsr    Sleep_Process
  8941:  cd8ec7       jsr    LinApp_CountIdle
  8944:  cdb5aa       jsr    Diag_SlowTask
L8947:
  8947:  4f           clra   
  8948:  c701a3       sta    g_slot10
L894B:
  894B:  cc898d       jmp    NvmTask_Run

;---------------------------------------------------------------
; Task_25Ticks   [0x894E]   <- 887B
;---------------------------------------------------------------
  894E:  cd8e8b       jsr    LinApp_Supervise
  8951:  ccae36       jmp    Signals_Task

;---------------------------------------------------------------
; Sleep_Enter   [0x8954]   <- 87E3
;---------------------------------------------------------------
  8954:  9b           sei    
  8955:  cd8ed5       jsr    LinDrv_Disable
  8958:  cdb529       jsr    Ports_PrepareSleep
  895B:  cdb53f       jsr    Ports_AllInputs
  895E:  8e           stop   
  895F:  cd876d       jsr    App_InitAll
  8962:  4f           clra   
  8963:  c70100       sta    g_sleepState
  8966:  81           rts    

;---------------------------------------------------------------
; Clock_Init   [0x8967]   <- 8770
;---------------------------------------------------------------
  8967:  a62a         lda    #$2A
  8969:  c70048       sta    ICGC1
  896C:  a670         lda    #$70
  896E:  c70049       sta    ICGC2
L8971:
  8971:  c6004a       lda    ICGS1
  8974:  a408         and    #$08
  8976:  27f9         beq    L8971
L8978:
  8978:  c6004b       lda    ICGS2
  897B:  a501         bit    #$01
  897D:  27f9         beq    L8978
  897F:  c6ffbe       lda    $FFBE
  8982:  c7004e       sta    ICGTRM
  8985:  81           rts    

;---------------------------------------------------------------
; SysOpt_Init   [0x8986]   <- 8773
;---------------------------------------------------------------
  8986:  a6ef         lda    #$EF
  8988:  c71802       sta    SOPT
  898B:  2043         bra    COP_Feed

;---------------------------------------------------------------
; NvmTask_Run   [0x898D]   <- 88A5
;---------------------------------------------------------------
  898D:  87           psha   
  898E:  95           tsx    
  898F:  7f           clr    ,x
  8990:  ad3e         bsr    COP_Feed
  8992:  450103       ldhx   #$0103
  8995:  7c           inc    ,x
  8996:  f6           lda    ,x
  8997:  a106         cmp    #$06
  8999:  2530         bcs    L89CB
  899B:  cdb519       jsr    Ports_NvmPinLow
  899E:  cdb7b8       jsr    EnterCritical
  89A1:  cd8bea       jsr    Nvm_Process
  89A4:  95           tsx    
  89A5:  f7           sta    ,x
  89A6:  271b         beq    L89C3
  89A8:  ad26         bsr    COP_Feed
  89AA:  cdb521       jsr    Ports_NvmPinHigh
  89AD:  95           tsx    
  89AE:  f6           lda    ,x
  89AF:  ae05         ldx    #$05
  89B1:  8c           clrh   
  89B2:  52           div    
  89B3:  c70103       sta    g_nvmTaskDivider
  89B6:  95           tsx    
  89B7:  fe           ldx    ,x
  89B8:  8c           clrh   
  89B9:  af01         aix    #$01
  89BB:  9f           txa    
  89BC:  8b           pshh   
  89BD:  88           pulx   
  89BE:  cd8819       jsr    TickCount_Adjust
  89C1:  2003         bra    L89C6
L89C3:
  89C3:  c70103       sta    g_nvmTaskDivider
L89C6:
  89C6:  cdb7c5       jsr    ExitCritical
  89C9:  2003         bra    L89CE
L89CB:
  89CB:  cdb521       jsr    Ports_NvmPinHigh
L89CE:
  89CE:  8a           pulh   
  89CF:  81           rts    

;---------------------------------------------------------------
; COP_Feed   [0x89D0]   <- 8776, 8788, 8990, 89A8
;---------------------------------------------------------------
  89D0:  a655         lda    #$55
  89D2:  c71800       sta    SRS
  89D5:  48           lsla   
  89D6:  c71800       sta    SRS
  89D9:  81           rts    

;---------------------------------------------------------------
; Isr_Tpm2Ch0   [0x89DA]
;---------------------------------------------------------------
  89DA:  8b           pshh   
  89DB:  b6c6         lda    g_mulDiv_tmp
  89DD:  87           psha   
  89DE:  87           psha   
  89DF:  c60065       lda    TPM2C0SC
  89E2:  95           tsx    
  89E3:  f7           sta    ,x
  89E4:  320066       ldhx   TPM2C0VH
  89E7:  9601a7       sthx   g_tpm2NextCompare
  89EA:  450065       ldhx   #$0065
  89ED:  f6           lda    ,x
  89EE:  a47f         and    #$7F
  89F0:  f7           sta    ,x
  89F1:  c601a8       lda    $01A8
  89F4:  ab0e         add    #$0E
  89F6:  c701a8       sta    $01A8
  89F9:  c601a7       lda    g_tpm2NextCompare
  89FC:  a927         adc    #$27
  89FE:  c701a7       sta    g_tpm2NextCompare
  8A01:  c70066       sta    TPM2C0VH
  8A04:  c601a8       lda    $01A8
  8A07:  c70067       sta    TPM2C0VL
  8A0A:  450104       ldhx   #$0104
  8A0D:  7c           inc    ,x
  8A0E:  f6           lda    ,x
  8A0F:  44           lsra   
  8A10:  a101         cmp    #$01
  8A12:  260b         bne    L8A1F
  8A14:  c701a1       sta    g_tickFlag
  8A17:  7f           clr    ,x
  8A18:  cd9c31       jsr    LinTp_Timer
  8A1B:  4501a0       ldhx   #$01A0
  8A1E:  7c           inc    ,x
L8A1F:
  8A1F:  cda719       jsr    MotorPos_Isr
  8A22:  8a           pulh   
  8A23:  86           pula   
  8A24:  b7c6         sta    g_mulDiv_tmp
  8A26:  8a           pulh   
  8A27:  80           rti    
;   .... data/gap 8A28-8A29 ....

;---------------------------------------------------------------
; Tpm1_Init   [0x8A29]   <- 878E
;---------------------------------------------------------------
  8A29:  a649         lda    #$49
  8A2B:  c70020       sta    TPM1SC
  8A2E:  a6c8         lda    #$C8
  8A30:  c70023       sta    TPM1MODH
  8A33:  4f           clra   
  8A34:  c70024       sta    TPM1MODL
  8A37:  c60275       lda    g_outputVariant
  8A3A:  4b0d         dbnza  L8A49
  8A3C:  a664         lda    #$64
  8A3E:  c70029       sta    TPM1C1VH
  8A41:  4f           clra   
  8A42:  c7002a       sta    TPM1C1VL
  8A45:  a624         lda    #$24
  8A47:  2001         bra    L8A4A
L8A49:
  8A49:  4f           clra   
L8A4A:
  8A4A:  c70028       sta    TPM1C1SC
  8A4D:  a6c8         lda    #$C8
  8A4F:  c7002c       sta    TPM1C2VH
  8A52:  4f           clra   
  8A53:  c7002d       sta    TPM1C2VL
  8A56:  c7002b       sta    TPM1C2SC
  8A59:  c70025       sta    TPM1C0SC
  8A5C:  c7002e       sta    TPM1C3SC
  8A5F:  81           rts    

;---------------------------------------------------------------
; Tpm2_Init   [0x8A60]   <- 8785
;---------------------------------------------------------------
  8A60:  45270e       ldhx   #$270E
  8A63:  9601a7       sthx   g_tpm2NextCompare
  8A66:  a608         lda    #$08
  8A68:  c70060       sta    TPM2SC
  8A6B:  4f           clra   
  8A6C:  c70063       sta    TPM2MODH
  8A6F:  c70064       sta    TPM2MODL
  8A72:  a650         lda    #$50
  8A74:  c70065       sta    TPM2C0SC
  8A77:  4f           clra   
  8A78:  c70068       sta    TPM2C1SC
  8A7B:  960066       sthx   TPM2C0VH
  8A7E:  c70069       sta    TPM2C1VH
  8A81:  c7006a       sta    TPM2C1VL
  8A84:  81           rts    

;---------------------------------------------------------------
; Nvm_Init   [0x8A85]   <- 877C
;---------------------------------------------------------------
  8A85:  a7fc         ais    #$FC
  8A87:  ce807f       ldx    $807F
  8A8A:  4f           clra   
  8A8B:  cb8000       add    $8000
  8A8E:  2401         bcc    L8A91
  8A90:  5c           incx   
L8A91:
  8A91:  c701b0       sta    $01B0
  8A94:  cf01af       stx    g_nvmCounterA
  8A97:  ce827f       ldx    $827F
  8A9A:  4f           clra   
  8A9B:  cb8200       add    $8200
  8A9E:  2401         bcc    L8AA1
  8AA0:  5c           incx   
L8AA1:
  8AA1:  c701ae       sta    $01AE
  8AA4:  cf01ad       stx    g_nvmCounterB
  8AA7:  a640         lda    #$40
  8AA9:  87           psha   
  8AAA:  4f           clra   
  8AAB:  87           psha   
  8AAC:  ae80         ldx    #$80
  8AAE:  cd8d2a       jsr    Nvm_Checksum
  8AB1:  a702         ais    #$02
  8AB3:  9ee702       sta    2,s
  8AB6:  9eef01       stx    1,s
  8AB9:  a640         lda    #$40
  8ABB:  87           psha   
  8ABC:  4f           clra   
  8ABD:  87           psha   
  8ABE:  ae82         ldx    #$82
  8AC0:  cd8d2a       jsr    Nvm_Checksum
  8AC3:  a702         ais    #$02
  8AC5:  9ee704       sta    4,s
  8AC8:  9eef03       stx    3,s
  8ACB:  3201af       ldhx   g_nvmCounterA
  8ACE:  3e01ad       cphx   g_nvmCounterB
  8AD1:  2416         bcc    L8AE9
  8AD3:  651001       cphx   #$1001
  8AD6:  2411         bcc    L8AE9
  8AD8:  9efe01       ldhx   1,s
  8ADB:  65cafe       cphx   #$CAFE
  8ADE:  2609         bne    L8AE9
  8AE0:  a601         lda    #$01
  8AE2:  c701ac       sta    g_nvmBank
  8AE5:  a680         lda    #$80
  8AE7:  201c         bra    L8B05
L8AE9:
  8AE9:  3201ad       ldhx   g_nvmCounterB
  8AEC:  3e01af       cphx   g_nvmCounterA
  8AEF:  241d         bcc    L8B0E
  8AF1:  651001       cphx   #$1001
  8AF4:  2418         bcc    L8B0E
  8AF6:  9efe03       ldhx   3,s
  8AF9:  65cafe       cphx   #$CAFE
  8AFC:  2610         bne    L8B0E
  8AFE:  a602         lda    #$02
  8B00:  c701ac       sta    g_nvmBank
  8B03:  a682         lda    #$82
L8B05:
  8B05:  c701b1       sta    g_nvmPage
  8B08:  4f           clra   
  8B09:  c701b2       sta    $01B2
  8B0C:  2018         bra    L8B26
L8B0E:
  8B0E:  a603         lda    #$03
  8B10:  c701ac       sta    g_nvmBank
  8B13:  44           lsra   
  8B14:  c7029d       sta    g_cfgDefaults
  8B17:  a680         lda    #$80
  8B19:  c701b1       sta    g_nvmPage
  8B1C:  4f           clra   
  8B1D:  c701b2       sta    $01B2
  8B20:  a60e         lda    #$0E
  8B22:  c702a2       sta    g_diagState
  8B25:  4f           clra   
L8B26:
  8B26:  c701b3       sta    g_nvmState
  8B29:  cd8cbc       jsr    Nvm_Load
  8B2C:  4f           clra   
  8B2D:  c700aa       sta    $00AA
  8B30:  450120       ldhx   #$0120
  8B33:  9600a0       sthx   $00A0
  8B36:  a704         ais    #$04
  8B38:  81           rts    

;---------------------------------------------------------------
; Nvm_RequestSave   [0x8B39]   <- 87F7
;---------------------------------------------------------------
  8B39:  a7fe         ais    #$FE
  8B3B:  c602b9       lda    g_nvmSaveRequest
  8B3E:  4a           deca   
  8B3F:  2703         beq    L8B44
L8B41:
  8B41:  cc8be1       jmp    $8BE1
L8B44:
  8B44:  c601b3       lda    g_nvmState
  8B47:  26f8         bne    L8B41
  8B49:  a601         lda    #$01
  8B4B:  c701b3       sta    g_nvmState
  8B4E:  c601ac       lda    g_nvmBank
  8B51:  a101         cmp    #$01
  8B53:  263b         bne    L8B90
  8B55:  3201af       ldhx   g_nvmCounterA
  8B58:  650086       cphx   #$0086
  8B5B:  2533         bcs    L8B90
  8B5D:  afff         aix    #$FF
  8B5F:  9601af       sthx   g_nvmCounterA
  8B62:  c601af       lda    g_nvmCounterA
  8B65:  c7019f       sta    $019F
  8B68:  c601b0       lda    $01B0
  8B6B:  c70120       sta    g_cfg
  8B6E:  a6ca         lda    #$CA
  8B70:  c7017e       sta    $017E
  8B73:  a6fe         lda    #$FE
  8B75:  c7017f       sta    $017F
  8B78:  a640         lda    #$40
  8B7A:  87           psha   
  8B7B:  4f           clra   
  8B7C:  87           psha   
  8B7D:  a620         lda    #$20
  8B7F:  ae01         ldx    #$01
  8B81:  cd8d2a       jsr    Nvm_Checksum
  8B84:  a702         ais    #$02
  8B86:  cf017e       stx    $017E
  8B89:  c7017f       sta    $017F
  8B8C:  a682         lda    #$82
  8B8E:  203d         bra    L8BCD
L8B90:
  8B90:  a102         cmp    #$02
  8B92:  2642         bne    L8BD6
  8B94:  3201ad       ldhx   g_nvmCounterB
  8B97:  650086       cphx   #$0086
  8B9A:  253a         bcs    L8BD6
  8B9C:  afff         aix    #$FF
  8B9E:  9601ad       sthx   g_nvmCounterB
  8BA1:  c601ad       lda    g_nvmCounterB
  8BA4:  c7019f       sta    $019F
  8BA7:  c601ae       lda    $01AE
  8BAA:  c70120       sta    g_cfg
  8BAD:  a6ca         lda    #$CA
  8BAF:  c7017e       sta    $017E
  8BB2:  a6fe         lda    #$FE
  8BB4:  c7017f       sta    $017F
  8BB7:  a640         lda    #$40
  8BB9:  87           psha   
  8BBA:  4f           clra   
  8BBB:  87           psha   
  8BBC:  a620         lda    #$20
  8BBE:  ae01         ldx    #$01
  8BC0:  cd8d2a       jsr    Nvm_Checksum
  8BC3:  a702         ais    #$02
  8BC5:  cf017e       stx    $017E
  8BC8:  c7017f       sta    $017F
  8BCB:  a680         lda    #$80
L8BCD:
  8BCD:  c701b1       sta    g_nvmPage
  8BD0:  4f           clra   
  8BD1:  c701b2       sta    $01B2
  8BD4:  2011         bra    L8BE7
L8BD6:
  8BD6:  4f           clra   
  8BD7:  c701b3       sta    g_nvmState
  8BDA:  c702b9       sta    g_nvmSaveRequest
  8BDD:  5f           clrx   
  8BDE:  4c           inca   
  8BDF:  2003         bra    L8BE4
L8BE1:
  8BE1:  5f           clrx   
  8BE2:  a601         lda    #$01
L8BE4:
  8BE4:  cd8805       jsr    Nvm_SetEvent
L8BE7:
  8BE7:  a702         ais    #$02
  8BE9:  81           rts    

;---------------------------------------------------------------
; Nvm_Process   [0x8BEA]   <- 89A1
;---------------------------------------------------------------
  8BEA:  a7fd         ais    #$FD
  8BEC:  95           tsx    
  8BED:  6f02         clr    2,x
  8BEF:  c601b3       lda    g_nvmState
  8BF2:  2603         bne    L8BF7
  8BF4:  cc8cb6       jmp    $8CB6
L8BF7:
  8BF7:  410117       cbeqa  #$01, L8C11
  8BFA:  41022a       cbeqa  #$02, L8C27
  8BFD:  410339       cbeqa  #$03, L8C39
  8C00:  a104         cmp    #$04
  8C02:  2603         bne    L8C07
  8C04:  cc8c9a       jmp    $8C9A
L8C07:
  8C07:  a105         cmp    #$05
  8C09:  2603         bne    L8C0E
  8C0B:  cc8cac       jmp    $8CAC
L8C0E:
  8C0E:  cc8cb2       jmp    $8CB2
L8C11:
  8C11:  4f           clra   
  8C12:  c702b9       sta    g_nvmSaveRequest
  8C15:  c601b1       lda    g_nvmPage
  8C18:  5f           clrx   
  8C19:  c700a8       sta    $00A8
  8C1C:  c601b2       lda    $01B2
  8C1F:  c700a9       sta    $00A9
  8C22:  a602         lda    #$02
  8C24:  cc8cb3       jmp    $8CB3
L8C27:
  8C27:  cdb7b8       jsr    EnterCritical
  8C2A:  cd8684       jsr    Flash_ErasePage
  8C2D:  cdb7c5       jsr    ExitCritical
  8C30:  a615         lda    #$15
  8C32:  95           tsx    
  8C33:  e702         sta    2,x
  8C35:  a603         lda    #$03
  8C37:  207a         bra    L8CB3
L8C39:
  8C39:  450120       ldhx   #$0120
  8C3C:  9eff01       sthx   1,s
  8C3F:  9600a0       sthx   $00A0
  8C42:  a680         lda    #$80
  8C44:  c700a4       sta    $00A4
  8C47:  cdb7b8       jsr    EnterCritical
  8C4A:  4f           clra   
  8C4B:  c700aa       sta    $00AA
  8C4E:  cd8620       jsr    Flash_BurstProgram
  8C51:  a601         lda    #$01
  8C53:  c700aa       sta    $00AA
  8C56:  ce01b1       ldx    g_nvmPage
  8C59:  4f           clra   
  8C5A:  ab80         add    #$80
  8C5C:  2401         bcc    L8C5F
  8C5E:  5c           incx   
L8C5F:
  8C5F:  cf00a8       stx    $00A8
  8C62:  c601b2       lda    $01B2
  8C65:  ab80         add    #$80
  8C67:  c700a9       sta    $00A9
  8C6A:  a67f         lda    #$7F
  8C6C:  c700a4       sta    $00A4
  8C6F:  cd8620       jsr    Flash_BurstProgram
  8C72:  a601         lda    #$01
  8C74:  c700aa       sta    $00AA
  8C77:  c601b1       lda    g_nvmPage
  8C7A:  4c           inca   
  8C7B:  c700a8       sta    $00A8
  8C7E:  c601b2       lda    $01B2
  8C81:  ab00         add    #$00
  8C83:  c700a9       sta    $00A9
  8C86:  a6ff         lda    #$FF
  8C88:  c700a4       sta    $00A4
  8C8B:  cd8620       jsr    Flash_BurstProgram
  8C8E:  cdb7c5       jsr    ExitCritical
  8C91:  a60b         lda    #$0B
  8C93:  95           tsx    
  8C94:  e702         sta    2,x
  8C96:  a604         lda    #$04
  8C98:  2019         bra    L8CB3
L8C9A:
  8C9A:  ad57         bsr    Nvm_Verify
  8C9C:  95           tsx    
  8C9D:  e701         sta    1,x
  8C9F:  7f           clr    ,x
  8CA0:  9eae         ldhx   ,x
  8CA2:  2704         beq    L8CA8
  8CA4:  a605         lda    #$05
  8CA6:  200b         bra    L8CB3
L8CA8:
  8CA8:  a601         lda    #$01
  8CAA:  2007         bra    L8CB3
L8CAC:
  8CAC:  5f           clrx   
  8CAD:  a601         lda    #$01
  8CAF:  cd8805       jsr    Nvm_SetEvent
L8CB2:
  8CB2:  4f           clra   
L8CB3:
  8CB3:  c701b3       sta    g_nvmState
L8CB6:
  8CB6:  95           tsx    
  8CB7:  e602         lda    2,x
  8CB9:  a703         ais    #$03
  8CBB:  81           rts    

;---------------------------------------------------------------
; Nvm_Load   [0x8CBC]   <- 8B29
;---------------------------------------------------------------
  8CBC:  a7fd         ais    #$FD
  8CBE:  ad33         bsr    Nvm_Verify
  8CC0:  95           tsx    
  8CC1:  f7           sta    ,x
  8CC2:  262c         bne    L8CF0
  8CC4:  c602b9       lda    g_nvmSaveRequest
  8CC7:  2627         bne    L8CF0
  8CC9:  c601b3       lda    g_nvmState
  8CCC:  2622         bne    L8CF0
  8CCE:  3201b1       ldhx   g_nvmPage
  8CD1:  9eff02       sthx   2,s
  8CD4:  271a         beq    L8CF0
  8CD6:  95           tsx    
  8CD7:  f7           sta    ,x
L8CD8:
  8CD8:  eb02         add    2,x
  8CDA:  87           psha   
  8CDB:  4f           clra   
  8CDC:  e901         adc    1,x
  8CDE:  87           psha   
  8CDF:  8a           pulh   
  8CE0:  88           pulx   
  8CE1:  f6           lda    ,x
  8CE2:  9eee01       ldx    1,s
  8CE5:  8c           clrh   
  8CE6:  d70120       sta    g_cfg,x
  8CE9:  95           tsx    
  8CEA:  7c           inc    ,x
  8CEB:  f6           lda    ,x
  8CEC:  a180         cmp    #$80
  8CEE:  25e8         bcs    L8CD8
L8CF0:
  8CF0:  a703         ais    #$03
  8CF2:  81           rts    

;---------------------------------------------------------------
; Nvm_Verify   [0x8CF3]   <- 8C9A, 8CBE
;---------------------------------------------------------------
  8CF3:  a7fc         ais    #$FC
  8CF5:  3201b1       ldhx   g_nvmPage
  8CF8:  9eff02       sthx   2,s
  8CFB:  a601         lda    #$01
  8CFD:  95           tsx    
  8CFE:  e703         sta    3,x
  8D00:  9ece01       ldhx   1,x
  8D03:  2722         beq    L8D27
  8D05:  4f           clra   
  8D06:  95           tsx    
  8D07:  f7           sta    ,x
L8D08:
  8D08:  eb02         add    2,x
  8D0A:  87           psha   
  8D0B:  4f           clra   
  8D0C:  e901         adc    1,x
  8D0E:  87           psha   
  8D0F:  8a           pulh   
  8D10:  88           pulx   
  8D11:  f6           lda    ,x
  8D12:  9eee01       ldx    1,s
  8D15:  8c           clrh   
  8D16:  d10120       cmp    g_cfg,x
  8D19:  2703         beq    L8D1E
  8D1B:  95           tsx    
  8D1C:  6f03         clr    3,x
L8D1E:
  8D1E:  95           tsx    
  8D1F:  7c           inc    ,x
  8D20:  f6           lda    ,x
  8D21:  a180         cmp    #$80
  8D23:  25e3         bcs    L8D08
  8D25:  e603         lda    3,x
L8D27:
  8D27:  a704         ais    #$04
  8D29:  81           rts    

;---------------------------------------------------------------
; Nvm_Checksum   [0x8D2A]   <- 8AAE, 8AC0, 8B81, 8BC0
;---------------------------------------------------------------
  8D2A:  87           psha   
  8D2B:  89           pshx   
  8D2C:  a7fc         ais    #$FC
  8D2E:  95           tsx    
  8D2F:  7f           clr    ,x
  8D30:  6f01         clr    1,x
  8D32:  6f02         clr    2,x
  8D34:  6f03         clr    3,x
  8D36:  9ece02       ldhx   2,x
  8D39:  2021         bra    L8D5C
L8D3B:
  8D3B:  9efe05       ldhx   5,s
  8D3E:  9ee602       lda    2,s
  8D41:  e801         eor    1,x
  8D43:  9ee702       sta    2,s
  8D46:  9ee601       lda    1,s
  8D49:  f8           eor    ,x
  8D4A:  95           tsx    
  8D4B:  f7           sta    ,x
  8D4C:  9ece04       ldhx   4,x
  8D4F:  af02         aix    #$02
  8D51:  9eff05       sthx   5,s
  8D54:  9efe03       ldhx   3,s
  8D57:  af01         aix    #$01
  8D59:  9eff03       sthx   3,s
L8D5C:
  8D5C:  9ef309       cphx   9,s
  8D5F:  25da         bcs    L8D3B
  8D61:  95           tsx    
  8D62:  e601         lda    1,x
  8D64:  fe           ldx    ,x
  8D65:  a706         ais    #$06
  8D67:  81           rts    

;---------------------------------------------------------------
; LinApp_ResetA   [0x8D68]
;---------------------------------------------------------------
  8D68:  cdad09       jsr    $AD09
  8D6B:  cd8f6c       jsr    LinSig_BuildStatus
  8D6E:  cdae9b       jsr    $AE9B
  8D71:  4502ae       ldhx   #$02AE
  8D74:  f6           lda    ,x
  8D75:  a4fb         and    #$FB
  8D77:  f7           sta    ,x
  8D78:  4f           clra   
  8D79:  c70276       sta    g_ctrlErrFlag
  8D7C:  c701b5       sta    $01B5
  8D7F:  c701b6       sta    $01B6
  8D82:  81           rts    

;---------------------------------------------------------------
; LinApp_ResetB   [0x8D83]
;---------------------------------------------------------------
  8D83:  cd911e       jsr    LinSig_RefreshTx
  8D86:  4502ae       ldhx   #$02AE
  8D89:  f6           lda    ,x
  8D8A:  a4fb         and    #$FB
  8D8C:  f7           sta    ,x
  8D8D:  4f           clra   
  8D8E:  c701b5       sta    $01B5
  8D91:  c701b6       sta    $01B6
  8D94:  81           rts    

;---------------------------------------------------------------
; LinApp_sub_8D95   [0x8D95]
;---------------------------------------------------------------
  8D95:  4f           clra   
  8D96:  c701b5       sta    $01B5
  8D99:  c701b6       sta    $01B6
  8D9C:  81           rts    

;---------------------------------------------------------------
; LinApp_sub_8D9D   [0x8D9D]
;---------------------------------------------------------------
  8D9D:  4f           clra   
  8D9E:  c701b5       sta    $01B5
  8DA1:  c701b6       sta    $01B6
  8DA4:  81           rts    

;---------------------------------------------------------------
; Clock_TrimAdjust   [0x8DA5]
;---------------------------------------------------------------
  8DA5:  87           psha   
  8DA6:  89           pshx   
  8DA7:  c6026f       lda    $026F
  8DAA:  4b20         dbnza  L8DCC
  8DAC:  9efe01       ldhx   1,s
  8DAF:  930b         ble    L8DBC
  8DB1:  c6004e       lda    ICGTRM
  8DB4:  2716         beq    L8DCC
  8DB6:  45004e       ldhx   #$004E
  8DB9:  7a           dec    ,x
  8DBA:  2010         bra    L8DCC
L8DBC:
  8DBC:  65ffff       cphx   #$FFFF
  8DBF:  900b         bge    L8DCC
  8DC1:  c6004e       lda    ICGTRM
  8DC4:  a1ff         cmp    #$FF
  8DC6:  2404         bcc    L8DCC
  8DC8:  45004e       ldhx   #$004E
  8DCB:  7c           inc    ,x
L8DCC:
  8DCC:  a702         ais    #$02
  8DCE:  81           rts    

;---------------------------------------------------------------
; LinErr_Set   [0x8DCF]   <- 9871, 98B2, 98C1, 98FF, 9D0A, 9D35, 9D94, 9E33
;---------------------------------------------------------------
  8DCF:  4502ae       ldhx   #$02AE
  8DD2:  f6           lda    ,x
  8DD3:  aa04         ora    #$04
  8DD5:  f7           sta    ,x
  8DD6:  a650         lda    #$50
  8DD8:  c702b2       sta    $02B2
  8DDB:  81           rts    

;---------------------------------------------------------------
; LinApp_sub_8DDC   [0x8DDC]
;---------------------------------------------------------------
  8DDC:  ad32         bsr    LinApp_Reset
  8DDE:  4502ae       ldhx   #$02AE
  8DE1:  f6           lda    ,x
  8DE2:  aa02         ora    #$02
  8DE4:  f7           sta    ,x
  8DE5:  81           rts    

;---------------------------------------------------------------
; LinSig_Request   [0x8DE6]   <- 9919, 992C, 9943, 9C29
;---------------------------------------------------------------
  8DE6:  4502ae       ldhx   #$02AE
  8DE9:  f6           lda    ,x
  8DEA:  aa04         ora    #$04
  8DEC:  f7           sta    ,x
  8DED:  81           rts    

;---------------------------------------------------------------
; LinApp_sub_8DEE   [0x8DEE]   <- 99E6
;---------------------------------------------------------------
  8DEE:  4502ae       ldhx   #$02AE
  8DF1:  f6           lda    ,x
  8DF2:  a4fe         and    #$FE
  8DF4:  f7           sta    ,x
  8DF5:  cd8eda       jsr    LinSig_InitRx
  8DF8:  cd8f18       jsr    LinSig_InitTx
  8DFB:  cdac81       jsr    LinSignals_Init
  8DFE:  ccacb7       jmp    LinSignals_Refresh

;---------------------------------------------------------------
; LinApp_SetErr   [0x8E01]   <- 99CD
;---------------------------------------------------------------
  8E01:  c602ae       lda    g_linAppFlags
  8E04:  a404         and    #$04
  8E06:  2607         bne    L8E0F
  8E08:  4502ae       ldhx   #$02AE
  8E0B:  f6           lda    ,x
  8E0C:  aa01         ora    #$01
  8E0E:  f7           sta    ,x
L8E0F:
  8E0F:  81           rts    

;---------------------------------------------------------------
; LinApp_Reset   [0x8E10]   <- 87C7, LinApp_sub_8DDC
;---------------------------------------------------------------
  8E10:  87           psha   
  8E11:  cdb7b8       jsr    EnterCritical
  8E14:  cd8eda       jsr    LinSig_InitRx
  8E17:  cd8f18       jsr    LinSig_InitTx
  8E1A:  cd9843       jsr    Lin_Init
  8E1D:  4502ae       ldhx   #$02AE
  8E20:  f6           lda    ,x
  8E21:  a4fb         and    #$FB
  8E23:  f7           sta    ,x
  8E24:  4f           clra   
  8E25:  c70276       sta    g_ctrlErrFlag
  8E28:  5f           clrx   
  8E29:  a602         lda    #$02
  8E2B:  cd98a3       jsr    Lin_WakeOrReset
  8E2E:  95           tsx    
  8E2F:  f7           sta    ,x
  8E30:  cdb7c5       jsr    ExitCritical
  8E33:  8a           pulh   
  8E34:  81           rts    

;---------------------------------------------------------------
; LinApp_DecodeCommand   [0x8E35]   <- 88DB, 88F7, 8905
;---------------------------------------------------------------
  8E35:  c602ae       lda    g_linAppFlags
  8E38:  a504         bit    #$04
  8E3A:  264e         bne    L8E8A
  8E3C:  c601c8       lda    $01C8
  8E3F:  a401         and    #$01
  8E41:  c7028f       sta    $028F
  8E44:  c601c8       lda    $01C8
  8E47:  a402         and    #$02
  8E49:  44           lsra   
  8E4A:  c70290       sta    $0290
  8E4D:  c601c7       lda    $01C7
  8E50:  c7028e       sta    $028E
  8E53:  c601c5       lda    $01C5
  8E56:  a40f         and    #$0F
  8E58:  c70291       sta    $0291
  8E5B:  c601c5       lda    $01C5
  8E5E:  62           nsa    
  8E5F:  a40f         and    #$0F
  8E61:  c70292       sta    $0292
  8E64:  c601c6       lda    $01C6
  8E67:  a40f         and    #$0F
  8E69:  c70293       sta    $0293
  8E6C:  c601c6       lda    $01C6
  8E6F:  62           nsa    
  8E70:  a401         and    #$01
  8E72:  c70294       sta    $0294
  8E75:  c601c6       lda    $01C6
  8E78:  62           nsa    
  8E79:  a402         and    #$02
  8E7B:  44           lsra   
  8E7C:  c70295       sta    $0295
  8E7F:  c601c6       lda    $01C6
  8E82:  62           nsa    
  8E83:  a404         and    #$04
  8E85:  44           lsra   
  8E86:  44           lsra   
  8E87:  c70296       sta    $0296
L8E8A:
  8E8A:  81           rts    

;---------------------------------------------------------------
; LinApp_Supervise   [0x8E8B]   <- Task_25Ticks
;---------------------------------------------------------------
  8E8B:  cd98f3       jsr    Lin_Supervise
  8E8E:  ce0162       ldx    $0162
  8E91:  4f           clra   
  8E92:  cb0163       add    $0163
  8E95:  2401         bcc    L8E98
  8E97:  5c           incx   
L8E98:
  8E98:  c001b6       sub    $01B6
  8E9B:  9f           txa    
  8E9C:  c201b5       sbc    $01B5
  8E9F:  2407         bcc    L8EA8
  8EA1:  4502ae       ldhx   #$02AE
  8EA4:  f6           lda    ,x
  8EA5:  aa01         ora    #$01
  8EA7:  f7           sta    ,x
L8EA8:
  8EA8:  c60275       lda    g_outputVariant
  8EAB:  2619         bne    L8EC6
  8EAD:  c602ae       lda    g_linAppFlags
  8EB0:  a104         cmp    #$04
  8EB2:  2612         bne    L8EC6
  8EB4:  3201b5       ldhx   $01B5
  8EB7:  650028       cphx   #$0028
  8EBA:  260a         bne    L8EC6
  8EBC:  a601         lda    #$01
  8EBE:  c70276       sta    g_ctrlErrFlag
  8EC1:  a650         lda    #$50
  8EC3:  c7028e       sta    $028E
L8EC6:
  8EC6:  81           rts    

;---------------------------------------------------------------
; LinApp_CountIdle   [0x8EC7]   <- 8941
;---------------------------------------------------------------
  8EC7:  3201b5       ldhx   $01B5
  8ECA:  65ffff       cphx   #$FFFF
  8ECD:  2405         bcc    L8ED4
  8ECF:  af01         aix    #$01
  8ED1:  9601b5       sthx   $01B5
L8ED4:
  8ED4:  81           rts    

;---------------------------------------------------------------
; LinDrv_Disable   [0x8ED5]   <- 8955
;---------------------------------------------------------------
  8ED5:  4f           clra   
  8ED6:  c7003b       sta    SCI1C2
  8ED9:  81           rts    

;---------------------------------------------------------------
; LinSig_InitRx   [0x8EDA]   <- 8DF5, 8E14
;---------------------------------------------------------------
  8EDA:  c601bf       lda    $01BF
  8EDD:  a4f0         and    #$F0
  8EDF:  c701bf       sta    $01BF
  8EE2:  4f           clra   
  8EE3:  c701c0       sta    g_linStatusByte
  8EE6:  c701c1       sta    $01C1
  8EE9:  c601c2       lda    $01C2
  8EEC:  a434         and    #$34
  8EEE:  c701c2       sta    $01C2
  8EF1:  4f           clra   
  8EF2:  c701c3       sta    $01C3
  8EF5:  c60299       lda    g_featureFlags
  8EF8:  a402         and    #$02
  8EFA:  2604         bne    L8F00
  8EFC:  a6ff         lda    #$FF
  8EFE:  2002         bra    L8F02
L8F00:
  8F00:  a646         lda    #$46
L8F02:
  8F02:  c701c4       sta    $01C4
  8F05:  4f           clra   
  8F06:  c70278       sta    $0278
  8F09:  c701b7       sta    $01B7
  8F0C:  c701b5       sta    $01B5
  8F0F:  c701b6       sta    $01B6
  8F12:  c7029e       sta    $029E
  8F15:  11be         bclr   0, g_linRespErr
  8F17:  81           rts    

;---------------------------------------------------------------
; LinSig_InitTx   [0x8F18]   <- 8DF8, 8E17
;---------------------------------------------------------------
  8F18:  a7fe         ais    #$FE
  8F1A:  95           tsx    
  8F1B:  6f01         clr    1,x
  8F1D:  c6016b       lda    $016B
  8F20:  62           nsa    
  8F21:  a40f         and    #$0F
  8F23:  c701b4       sta    $01B4
  8F26:  c68604       lda    $8604
  8F29:  a030         sub    #$30
  8F2B:  f7           sta    ,x
  8F2C:  c68603       lda    $8603
  8F2F:  ae0a         ldx    #$0A
  8F31:  42           mul    
  8F32:  a0e0         sub    #$E0
  8F34:  95           tsx    
  8F35:  fb           add    ,x
  8F36:  c70297       sta    $0297
  8F39:  c801bd       eor    g_linProductId
  8F3C:  a41f         and    #$1F
  8F3E:  c801bd       eor    g_linProductId
  8F41:  c701bd       sta    g_linProductId
  8F44:  c60298       lda    g_codingByte
  8F47:  62           nsa    
  8F48:  48           lsla   
  8F49:  c801bd       eor    g_linProductId
  8F4C:  a4e0         and    #$E0
  8F4E:  c801bd       eor    g_linProductId
  8F51:  c701bd       sta    g_linProductId
  8F54:  c601b4       lda    $01B4
  8F57:  c701be       sta    g_linVariant
  8F5A:  4f           clra   
  8F5B:  c70278       sta    $0278
  8F5E:  c701b7       sta    $01B7
  8F61:  c701b5       sta    $01B5
  8F64:  c701b6       sta    $01B6
  8F67:  13be         bclr   1, g_linRespErr
  8F69:  a702         ais    #$02
  8F6B:  81           rts    

;---------------------------------------------------------------
; LinSig_BuildStatus   [0x8F6C]   <- 8D6B
;---------------------------------------------------------------
  8F6C:  c60278       lda    $0278
  8F6F:  a10f         cmp    #$0F
  8F71:  2407         bcc    L8F7A
  8F73:  450278       ldhx   #$0278
  8F76:  7c           inc    ,x
  8F77:  f6           lda    ,x
  8F78:  2004         bra    L8F7E
L8F7A:
  8F7A:  4f           clra   
  8F7B:  c70278       sta    $0278
L8F7E:
  8F7E:  c801bf       eor    $01BF
  8F81:  a40f         and    #$0F
  8F83:  c801bf       eor    $01BF
  8F86:  c701bf       sta    $01BF
  8F89:  c6029e       lda    $029E
  8F8C:  a10f         cmp    #$0F
  8F8E:  2407         bcc    L8F97
  8F90:  45029e       ldhx   #$029E
  8F93:  7c           inc    ,x
  8F94:  f6           lda    ,x
  8F95:  2004         bra    L8F9B
L8F97:
  8F97:  4f           clra   
  8F98:  c7029e       sta    $029E
L8F9B:
  8F9B:  c7027a       sta    $027A
  8F9E:  ce029e       ldx    $029E
  8FA1:  8c           clrh   
  8FA2:  d6029f       lda    $029F,x
  8FA5:  c70279       sta    $0279
  8FA8:  9f           txa    
  8FA9:  a109         cmp    #$09
  8FAB:  2614         bne    L8FC1
  8FAD:  c602b6       lda    g_supplyVoltage
  8FB0:  c1016c       cmp    $016C
  8FB3:  2405         bcc    L8FBA
  8FB5:  c1016e       cmp    $016E
  8FB8:  2207         bhi    L8FC1
L8FBA:
  8FBA:  c601c0       lda    g_linStatusByte
  8FBD:  a4f0         and    #$F0
  8FBF:  200b         bra    L8FCC
L8FC1:
  8FC1:  c60279       lda    $0279
  8FC4:  c801c0       eor    g_linStatusByte
  8FC7:  a40f         and    #$0F
  8FC9:  c801c0       eor    g_linStatusByte
L8FCC:
  8FCC:  c701c0       sta    g_linStatusByte
  8FCF:  c6027a       lda    $027A
  8FD2:  62           nsa    
  8FD3:  c801c0       eor    g_linStatusByte
  8FD6:  a4f0         and    #$F0
  8FD8:  c801c0       eor    g_linStatusByte
  8FDB:  c701c0       sta    g_linStatusByte
  8FDE:  01be02       brclr  0, g_linRespErr, L8FE3
  8FE1:  11be         bclr   0, g_linRespErr
L8FE3:
  8FE3:  c602ae       lda    g_linAppFlags
  8FE6:  410804       cbeqa  #$08, L8FED
  8FE9:  a110         cmp    #$10
  8FEB:  2620         bne    L900D
L8FED:
  8FED:  4f           clra   
  8FEE:  c701c1       sta    $01C1
  8FF1:  c601c2       lda    $01C2
  8FF4:  a434         and    #$34
  8FF6:  c701c2       sta    $01C2
  8FF9:  4f           clra   
L8FFA:
  8FFA:  c701c3       sta    $01C3
  8FFD:  c60299       lda    g_featureFlags
  9000:  a402         and    #$02
  9002:  2603         bne    L9007
  9004:  cc9118       jmp    LinSig_sub_9118
L9007:
  9007:  c6028a       lda    $028A
  900A:  cc911a       jmp    $911A
L900D:
  900D:  c602c4       lda    $02C4
  9010:  c801c1       eor    $01C1
  9013:  a401         and    #$01
  9015:  c801c1       eor    $01C1
  9018:  c701c1       sta    $01C1
  901B:  c602c2       lda    $02C2
  901E:  48           lsla   
  901F:  c801c1       eor    $01C1
  9022:  a402         and    #$02
  9024:  c801c1       eor    $01C1
  9027:  c701c1       sta    $01C1
  902A:  c602c1       lda    $02C1
  902D:  48           lsla   
  902E:  48           lsla   
  902F:  c801c1       eor    $01C1
  9032:  a404         and    #$04
  9034:  c801c1       eor    $01C1
  9037:  c701c1       sta    $01C1
  903A:  c602bf       lda    $02BF
  903D:  48           lsla   
  903E:  48           lsla   
  903F:  48           lsla   
  9040:  c801c1       eor    $01C1
  9043:  a408         and    #$08
  9045:  c801c1       eor    $01C1
  9048:  c701c1       sta    $01C1
  904B:  c6027f       lda    $027F
  904E:  62           nsa    
  904F:  c801c1       eor    $01C1
  9052:  a410         and    #$10
  9054:  c801c1       eor    $01C1
  9057:  c701c1       sta    $01C1
  905A:  c60280       lda    $0280
  905D:  62           nsa    
  905E:  48           lsla   
  905F:  c801c1       eor    $01C1
  9062:  a420         and    #$20
  9064:  c801c1       eor    $01C1
  9067:  c701c1       sta    $01C1
  906A:  c60281       lda    $0281
  906D:  62           nsa    
  906E:  48           lsla   
  906F:  48           lsla   
  9070:  c801c1       eor    $01C1
  9073:  a440         and    #$40
  9075:  c801c1       eor    $01C1
  9078:  c701c1       sta    $01C1
  907B:  c60282       lda    $0282
  907E:  46           rora   
  907F:  46           rora   
  9080:  c801c1       eor    $01C1
  9083:  a480         and    #$80
  9085:  c801c1       eor    $01C1
  9088:  c701c1       sta    $01C1
  908B:  c60299       lda    g_featureFlags
  908E:  a401         and    #$01
  9090:  271c         beq    L90AE
  9092:  c60283       lda    $0283
  9095:  c801c2       eor    $01C2
  9098:  a401         and    #$01
  909A:  c801c2       eor    $01C2
  909D:  c701c2       sta    $01C2
  90A0:  c60284       lda    $0284
  90A3:  48           lsla   
  90A4:  c801c2       eor    $01C2
  90A7:  a402         and    #$02
  90A9:  c801c2       eor    $01C2
  90AC:  2005         bra    L90B3
L90AE:
  90AE:  c601c2       lda    $01C2
  90B1:  a4fc         and    #$FC
L90B3:
  90B3:  c701c2       sta    $01C2
  90B6:  c60299       lda    g_featureFlags
  90B9:  a402         and    #$02
  90BB:  2721         beq    L90DE
  90BD:  c602c3       lda    $02C3
  90C0:  48           lsla   
  90C1:  48           lsla   
  90C2:  48           lsla   
  90C3:  c801c2       eor    $01C2
  90C6:  a408         and    #$08
  90C8:  c801c2       eor    $01C2
  90CB:  c701c2       sta    $01C2
  90CE:  c602c3       lda    $02C3
  90D1:  62           nsa    
  90D2:  48           lsla   
  90D3:  48           lsla   
  90D4:  c801c2       eor    $01C2
  90D7:  a440         and    #$40
  90D9:  c801c2       eor    $01C2
  90DC:  2005         bra    L90E3
L90DE:
  90DE:  c601c2       lda    $01C2
  90E1:  a4b7         and    #$B7
L90E3:
  90E3:  c701c2       sta    $01C2
  90E6:  c602c0       lda    $02C0
  90E9:  46           rora   
  90EA:  46           rora   
  90EB:  c801c2       eor    $01C2
  90EE:  a480         and    #$80
  90F0:  c801c2       eor    $01C2
  90F3:  c701c2       sta    $01C2
  90F6:  c602d1       lda    $02D1
  90F9:  260e         bne    L9109
  90FB:  c602d4       lda    $02D4
  90FE:  c801c3       eor    $01C3
  9101:  a40f         and    #$0F
  9103:  c801c3       eor    $01C3
  9106:  c701c3       sta    $01C3
L9109:
  9109:  c602d5       lda    $02D5
  910C:  62           nsa    
  910D:  c801c3       eor    $01C3
  9110:  a4f0         and    #$F0
  9112:  c801c3       eor    $01C3
  9115:  cc8ffa       jmp    $8FFA
L9118:
  9118:  a6ff         lda    #$FF
L911A:
  911A:  c701c4       sta    $01C4
  911D:  81           rts    

;---------------------------------------------------------------
; LinSig_RefreshTx   [0x911E]   <- LinApp_ResetB
;---------------------------------------------------------------
  911E:  a7fe         ais    #$FE
  9120:  95           tsx    
  9121:  6f01         clr    1,x
  9123:  c601b4       lda    $01B4
  9126:  c701be       sta    g_linVariant
  9129:  03be02       brclr  1, g_linRespErr, L912E
  912C:  13be         bclr   1, g_linRespErr
L912E:
  912E:  c68604       lda    $8604
  9131:  a030         sub    #$30
  9133:  f7           sta    ,x
  9134:  c68603       lda    $8603
  9137:  ae0a         ldx    #$0A
  9139:  42           mul    
  913A:  a0e0         sub    #$E0
  913C:  95           tsx    
  913D:  fb           add    ,x
  913E:  c70297       sta    $0297
  9141:  c801bd       eor    g_linProductId
  9144:  a41f         and    #$1F
  9146:  c801bd       eor    g_linProductId
  9149:  c701bd       sta    g_linProductId
  914C:  c60298       lda    g_codingByte
  914F:  62           nsa    
  9150:  48           lsla   
  9151:  c801bd       eor    g_linProductId
  9154:  a4e0         and    #$E0
  9156:  c801bd       eor    g_linProductId
  9159:  c701bd       sta    g_linProductId
  915C:  a702         ais    #$02
  915E:  81           rts    

;---------------------------------------------------------------
; Sci_Init   [0x915F]   <- 989D
;---------------------------------------------------------------
  915F:  87           psha   
  9160:  3f38         clr    SCI1BDH
  9162:  6e4139       mov    #$41, SCI1BDL
  9165:  3f3a         clr    SCI1C1
  9167:  6e0e3e       mov    #$0E, SCI1C3
  916A:  b63c         lda    SCI1S1
  916C:  9ee701       sta    1,s
  916F:  b63f         lda    SCI1D
  9171:  9ee701       sta    1,s
  9174:  6e043d       mov    #$04, SCI1S2
  9177:  6e2c3b       mov    #$2C, SCI1C2
  917A:  3fb0         clr    g_linCrit
  917C:  4f           clra   
  917D:  c701bc       sta    g_baudState
  9180:  6e0868       mov    #$08, TPM2C1SC
  9183:  8a           pulh   
  9184:  81           rts    

;---------------------------------------------------------------
; Sci_SendByte   [0x9185]   <- 9CD7, 9D11, 9DDF, 9DF9
;---------------------------------------------------------------
  9185:  87           psha   
  9186:  89           pshx   
  9187:  87           psha   
  9188:  b63c         lda    SCI1S1
  918A:  9ee701       sta    1,s
  918D:  95           tsx    
  918E:  e602         lda    2,x
  9190:  b73f         sta    SCI1D
  9192:  a703         ais    #$03
  9194:  81           rts    

;---------------------------------------------------------------
; Isr_Sci1   [0x9195]
;---------------------------------------------------------------
  9195:  8b           pshh   
  9196:  b6c6         lda    g_mulDiv_tmp
  9198:  87           psha   
  9199:  55c4         ldhx   $C4
  919B:  89           pshx   
  919C:  8b           pshh   
  919D:  55c2         ldhx   g_div_a
  919F:  89           pshx   
  91A0:  8b           pshh   
  91A1:  a7fe         ais    #$FE
  91A3:  b63c         lda    SCI1S1
  91A5:  9ee701       sta    1,s
  91A8:  b63f         lda    SCI1D
  91AA:  9ee702       sta    2,s
  91AD:  9ee601       lda    1,s
  91B0:  a50e         bit    #$0E
  91B2:  2610         bne    L91C4
  91B4:  9ee601       lda    1,s
  91B7:  a520         bit    #$20
  91B9:  273c         beq    L91F7
  91BB:  9ee602       lda    2,s
  91BE:  5f           clrx   
  91BF:  cd9d62       jsr    Lin_RxByte
  91C2:  2033         bra    L91F7
L91C4:
  91C4:  9ee601       lda    1,s
  91C7:  a502         bit    #$02
  91C9:  271a         beq    L91E5
  91CB:  9e6d02       tst    2,s
  91CE:  2621         bne    L91F1
  91D0:  5f           clrx   
  91D1:  a602         lda    #$02
  91D3:  cd9e75       jsr    Lin_TxByteOrErr
  91D6:  b668         lda    TPM2C1SC
  91D8:  9ee702       sta    2,s
  91DB:  6e4868       mov    #$48, TPM2C1SC
  91DE:  a601         lda    #$01
  91E0:  c701bc       sta    g_baudState
  91E3:  2012         bra    L91F7
L91E5:
  91E5:  9ee601       lda    1,s
  91E8:  a508         bit    #$08
  91EA:  2705         beq    L91F1
  91EC:  5f           clrx   
  91ED:  a603         lda    #$03
  91EF:  2003         bra    L91F4
L91F1:
  91F1:  5f           clrx   
  91F2:  a604         lda    #$04
L91F4:
  91F4:  cd9e75       jsr    Lin_TxByteOrErr
L91F7:
  91F7:  a702         ais    #$02
  91F9:  8a           pulh   
  91FA:  88           pulx   
  91FB:  35c2         sthx   g_div_a
  91FD:  8a           pulh   
  91FE:  88           pulx   
  91FF:  35c4         sthx   $C4
  9201:  86           pula   
  9202:  b7c6         sta    g_mulDiv_tmp
  9204:  8a           pulh   
  9205:  80           rti    

;---------------------------------------------------------------
; Isr_Tpm2Ch1_AutoBaud   [0x9206]
;---------------------------------------------------------------
  9206:  8b           pshh   
  9207:  a7fb         ais    #$FB
  9209:  b668         lda    TPM2C1SC
  920B:  c601bc       lda    g_baudState
  920E:  a101         cmp    #$01
  9210:  2612         bne    L9224
  9212:  6e4868       mov    #$48, TPM2C1SC
  9215:  be69         ldx    TPM2C1VH
  9217:  b66a         lda    TPM2C1VL
  9219:  c701bb       sta    $01BB
  921C:  cf01ba       stx    g_baudCap
  921F:  a602         lda    #$02
  9221:  cc92fe       jmp    $92FE
L9224:
  9224:  a102         cmp    #$02
  9226:  264a         bne    L9272
  9228:  be69         ldx    TPM2C1VH
  922A:  b66a         lda    TPM2C1VL
  922C:  9ee702       sta    2,s
  922F:  9eef01       stx    1,s
  9232:  9efe01       ldhx   1,s
  9235:  3e01ba       cphx   g_baudCap
  9238:  2418         bcc    L9252
  923A:  a6ff         lda    #$FF
  923C:  c001bb       sub    $01BB
  923F:  87           psha   
  9240:  a6ff         lda    #$FF
  9242:  c201ba       sbc    g_baudCap
  9245:  97           tax    
  9246:  86           pula   
  9247:  9eeb02       add    2,s
  924A:  9ee704       sta    4,s
  924D:  9f           txa    
  924E:  95           tsx    
  924F:  f9           adc    ,x
  9250:  200a         bra    L925C
L9252:
  9252:  c001bb       sub    $01BB
  9255:  95           tsx    
  9256:  e703         sta    3,x
  9258:  f6           lda    ,x
  9259:  c201ba       sbc    g_baudCap
L925C:
  925C:  e702         sta    2,x
  925E:  6e4868       mov    #$48, TPM2C1SC
  9261:  9ece02       ldhx   2,x
  9264:  9601b8       sthx   g_baudPeriod
  9267:  9efe01       ldhx   1,s
  926A:  9601ba       sthx   g_baudCap
  926D:  a603         lda    #$03
  926F:  cc92fe       jmp    $92FE
L9272:
  9272:  a103         cmp    #$03
  9274:  2703         beq    L9279
  9276:  cc92fa       jmp    $92FA
L9279:
  9279:  be69         ldx    TPM2C1VH
  927B:  b66a         lda    TPM2C1VL
  927D:  9ee702       sta    2,s
  9280:  9eef01       stx    1,s
  9283:  9efe01       ldhx   1,s
  9286:  3e01ba       cphx   g_baudCap
  9289:  2418         bcc    L92A3
  928B:  a6ff         lda    #$FF
  928D:  c001bb       sub    $01BB
  9290:  87           psha   
  9291:  a6ff         lda    #$FF
  9293:  c201ba       sbc    g_baudCap
  9296:  97           tax    
  9297:  86           pula   
  9298:  9eeb02       add    2,s
  929B:  9ee704       sta    4,s
  929E:  9f           txa    
  929F:  95           tsx    
  92A0:  f9           adc    ,x
  92A1:  200a         bra    L92AD
L92A3:
  92A3:  c001bb       sub    $01BB
  92A6:  95           tsx    
  92A7:  e703         sta    3,x
  92A9:  f6           lda    ,x
  92AA:  c201ba       sbc    g_baudCap
L92AD:
  92AD:  e702         sta    2,x
  92AF:  3201b8       ldhx   g_baudPeriod
  92B2:  affe         aix    #$FE
  92B4:  9ef303       cphx   3,s
  92B7:  2241         bhi    L92FA
  92B9:  3201b8       ldhx   g_baudPeriod
  92BC:  af02         aix    #$02
  92BE:  9ef303       cphx   3,s
  92C1:  2537         bcs    L92FA
  92C3:  c601b9       lda    $01B9
  92C6:  95           tsx    
  92C7:  eb03         add    3,x
  92C9:  c701b9       sta    $01B9
  92CC:  c601b8       lda    g_baudPeriod
  92CF:  e902         adc    2,x
  92D1:  c701b8       sta    g_baudPeriod
  92D4:  3201b8       ldhx   g_baudPeriod
  92D7:  650dd5       cphx   #$0DD5
  92DA:  251e         bcs    L92FA
  92DC:  6512b9       cphx   #$12B9
  92DF:  2419         bcc    L92FA
  92E1:  af20         aix    #$20
  92E3:  9601b8       sthx   g_baudPeriod
  92E6:  a606         lda    #$06
  92E8:  4501b8       ldhx   #$01B8
L92EB:
  92EB:  74           lsr    ,x
  92EC:  6601         ror    1,x
  92EE:  4bfb         dbnza  L92EB
  92F0:  c601b8       lda    g_baudPeriod
  92F3:  b738         sta    SCI1BDH
  92F5:  c601b9       lda    $01B9
  92F8:  b739         sta    SCI1BDL
L92FA:
  92FA:  6e0868       mov    #$08, TPM2C1SC
  92FD:  4f           clra   
L92FE:
  92FE:  c701bc       sta    g_baudState
  9301:  a705         ais    #$05
  9303:  8a           pulh   
  9304:  80           rti    
L9305:
  9305:  81           rts    

;---------------------------------------------------------------
; LinCrit_Enter   [0x9306]   <- LinTp_sub_9361, 9399, 98A6, Lin_Supervise, LinTp_Timer
;---------------------------------------------------------------
  9306:  87           psha   
  9307:  3cb0         inc    g_linCrit
  9309:  95           tsx    
  930A:  9f           txa    
  930B:  8b           pshh   
  930C:  88           pulx   
  930D:  ad2f         bsr    LinSci_DisIrq
  930F:  1b3b         bclr   5, SCI1C2
  9311:  b63e         lda    SCI1C3
  9313:  a4f1         and    #$F1
  9315:  b73e         sta    SCI1C3
  9317:  95           tsx    
  9318:  f6           lda    ,x
  9319:  5f           clrx   
  931A:  ad29         bsr    LinSci_RestIrq
  931C:  8a           pulh   
  931D:  81           rts    

;---------------------------------------------------------------
; LinCrit_Leave   [0x931E]   <- 93C2, 98EB
;---------------------------------------------------------------
  931E:  87           psha   
  931F:  3db0         tst    g_linCrit
  9321:  2702         beq    L9325
  9323:  3ab0         dec    g_linCrit
L9325:
  9325:  3db0         tst    g_linCrit
  9327:  2613         bne    L933C
  9329:  95           tsx    
  932A:  9f           txa    
  932B:  8b           pshh   
  932C:  88           pulx   
  932D:  ad0f         bsr    LinSci_DisIrq
  932F:  1a3b         bset   5, SCI1C2
  9331:  b63e         lda    SCI1C3
  9333:  aa0e         ora    #$0E
  9335:  b73e         sta    SCI1C3
  9337:  95           tsx    
  9338:  f6           lda    ,x
  9339:  5f           clrx   
  933A:  ad09         bsr    LinSci_RestIrq
L933C:
  933C:  8a           pulh   
  933D:  81           rts    

;---------------------------------------------------------------
; LinSci_DisIrq   [0x933E]   <- 930D, 932D
;---------------------------------------------------------------
  933E:  89           pshx   
  933F:  8a           pulh   
  9340:  97           tax    
  9341:  85           tpa    
  9342:  9b           sei    
  9343:  f7           sta    ,x
  9344:  81           rts    

;---------------------------------------------------------------
; LinSci_RestIrq   [0x9345]   <- 931A, 933A
;---------------------------------------------------------------
  9345:  a408         and    #$08
  9347:  2601         bne    L934A
  9349:  84           tap    
L934A:
  934A:  81           rts    
;   .... data/gap 934B-934D ....

;---------------------------------------------------------------
; LinTp_Reset   [0x934D]
;---------------------------------------------------------------
  934D:  4f           clra   
  934E:  c701d3       sta    g_tpSessionState
  9351:  c701d2       sta    g_tpPending
  9354:  c701ce       sta    $01CE
  9357:  c701cf       sta    $01CF
  935A:  c701c9       sta    $01C9
  935D:  c701ca       sta    $01CA
  9360:  81           rts    

;---------------------------------------------------------------
; LinTp_sub_9361   [0x9361]
;---------------------------------------------------------------
  9361:  cd9306       jsr    LinCrit_Enter
  9364:  3201c9       ldhx   $01C9
  9367:  272a         beq    L9393
  9369:  afff         aix    #$FF
  936B:  9601c9       sthx   $01C9
  936E:  2623         bne    L9393
  9370:  c601d3       lda    g_tpSessionState
  9373:  270d         beq    L9382
  9375:  4f           clra   
  9376:  c701d3       sta    g_tpSessionState
  9379:  c701d2       sta    g_tpPending
  937C:  4c           inca   
  937D:  cd9fd1       jsr    LinLL_OnIdle
  9380:  2011         bra    L9393
L9382:
  9382:  c601d2       lda    g_tpPending
  9385:  270c         beq    L9393
  9387:  4f           clra   
  9388:  c701d3       sta    g_tpSessionState
  938B:  c701d2       sta    g_tpPending
  938E:  5f           clrx   
  938F:  4c           inca   
  9390:  cd9fa9       jsr    LinLL_OnError
L9393:
  9393:  cc931e       jmp    LinCrit_Leave

;---------------------------------------------------------------
; LinTp_StartTimer   [0x9396]
;---------------------------------------------------------------
  9396:  87           psha   
  9397:  89           pshx   
  9398:  87           psha   
  9399:  cd9306       jsr    LinCrit_Enter
  939C:  c601d3       lda    g_tpSessionState
  939F:  261d         bne    L93BE
  93A1:  a603         lda    #$03
  93A3:  c701d3       sta    g_tpSessionState
  93A6:  a664         lda    #$64
  93A8:  c701ca       sta    $01CA
  93AB:  4f           clra   
  93AC:  c701c9       sta    $01C9
  93AF:  9efe02       ldhx   2,s
  93B2:  9601cb       sthx   $01CB
  93B5:  a60a         lda    #$0A
  93B7:  c701d0       sta    $01D0
  93BA:  95           tsx    
  93BB:  7f           clr    ,x
  93BC:  2004         bra    L93C2
L93BE:
  93BE:  a601         lda    #$01
  93C0:  95           tsx    
  93C1:  f7           sta    ,x
L93C2:
  93C2:  cd931e       jsr    LinCrit_Leave
  93C5:  95           tsx    
  93C6:  f6           lda    ,x
  93C7:  a703         ais    #$03
  93C9:  81           rts    

;---------------------------------------------------------------
; LinTp_IsActive   [0x93CA]   <- 9A86
;---------------------------------------------------------------
  93CA:  87           psha   
  93CB:  c601d3       lda    g_tpSessionState
  93CE:  410304       cbeqa  #$03, L93D5
  93D1:  a106         cmp    #$06
  93D3:  2604         bne    L93D9
L93D5:
  93D5:  a601         lda    #$01
L93D7:
  93D7:  8a           pulh   
  93D8:  81           rts    
L93D9:
  93D9:  4f           clra   
  93DA:  20fb         bra    L93D7

;---------------------------------------------------------------
; LinTp_RxFrame   [0x93DC]   <- 9B2A
;---------------------------------------------------------------
  93DC:  87           psha   
  93DD:  89           pshx   
  93DE:  a7fd         ais    #$FD
  93E0:  89           pshx   
  93E1:  8a           pulh   
  93E2:  97           tax    
  93E3:  f6           lda    ,x
  93E4:  a180         cmp    #$80
  93E6:  2503         bcs    L93EB
  93E8:  cc962e       jmp    $962E
L93EB:
  93EB:  9efe04       ldhx   4,s
  93EE:  f6           lda    ,x
  93EF:  410a07       cbeqa  #$0A, L93F9
  93F2:  a17f         cmp    #$7F
  93F4:  2703         beq    L93F9
L93F6:
  93F6:  cc9628       jmp    $9628
L93F9:
  93F9:  e601         lda    1,x
  93FB:  a4f0         and    #$F0
  93FD:  2719         beq    L9418
  93FF:  a110         cmp    #$10
  9401:  2603         bne    L9406
  9403:  cc9493       jmp    $9493
L9406:
  9406:  a120         cmp    #$20
  9408:  2603         bne    L940D
  940A:  cc9550       jmp    $9550
L940D:
  940D:  c601d2       lda    g_tpPending
  9410:  2603         bne    L9415
  9412:  cc9620       jmp    $9620
L9415:
  9415:  cc961c       jmp    $961C
L9418:
  9418:  e601         lda    1,x
  941A:  2603         bne    L941F
L941C:
  941C:  cc953e       jmp    $953E
L941F:
  941F:  a107         cmp    #$07
  9421:  24f9         bcc    L941C
  9423:  c601d2       lda    g_tpPending
  9426:  4b13         dbnza  L943B
  9428:  4f           clra   
  9429:  c701c9       sta    $01C9
  942C:  c701ca       sta    $01CA
  942F:  5f           clrx   
  9430:  4c           inca   
  9431:  cd9fa9       jsr    LinLL_OnError
  9434:  4f           clra   
  9435:  c701d3       sta    g_tpSessionState
  9438:  c701d2       sta    g_tpPending
L943B:
  943B:  c601d3       lda    g_tpSessionState
  943E:  2713         beq    L9453
  9440:  4f           clra   
  9441:  c701c9       sta    $01C9
  9444:  c701ca       sta    $01CA
  9447:  5f           clrx   
  9448:  4c           inca   
  9449:  cd9fd1       jsr    LinLL_OnIdle
  944C:  4f           clra   
  944D:  c701d3       sta    g_tpSessionState
  9450:  c701d2       sta    g_tpPending
L9453:
  9453:  9efe04       ldhx   4,s
  9456:  e601         lda    1,x
  9458:  a40f         and    #$0F
  945A:  5f           clrx   
  945B:  87           psha   
  945C:  89           pshx   
  945D:  9efe06       ldhx   6,s
  9460:  f6           lda    ,x
  9461:  5f           clrx   
  9462:  cd9f6b       jsr    LinLL_Classify
  9465:  a702         ais    #$02
  9467:  c701d1       sta    $01D1
  946A:  410104       cbeqa  #$01, L9471
  946D:  a102         cmp    #$02
  946F:  2685         bne    L93F6
L9471:
  9471:  a606         lda    #$06
  9473:  87           psha   
  9474:  4f           clra   
  9475:  87           psha   
  9476:  95           tsx    
  9477:  e606         lda    6,x
  9479:  ee05         ldx    5,x
  947B:  ab02         add    #$02
  947D:  2401         bcc    L9480
  947F:  5c           incx   
L9480:
  9480:  87           psha   
  9481:  89           pshx   
  9482:  a6e6         lda    #$E6
  9484:  ae01         ldx    #$01
  9486:  cda045       jsr    mem_copy
  9489:  a704         ais    #$04
  948B:  5f           clrx   
  948C:  4f           clra   
  948D:  cd9fa9       jsr    LinLL_OnError
  9490:  cc954b       jmp    $954B
L9493:
  9493:  e601         lda    1,x
  9495:  a40f         and    #$0F
  9497:  9ee702       sta    2,s
  949A:  e602         lda    2,x
  949C:  95           tsx    
  949D:  e702         sta    2,x
  949F:  9ece01       ldhx   1,x
  94A2:  650007       cphx   #$0007
  94A5:  2403         bcc    L94AA
  94A7:  cc953e       jmp    $953E
L94AA:
  94AA:  4f           clra   
  94AB:  c701c9       sta    $01C9
  94AE:  c701ca       sta    $01CA
  94B1:  c601d2       lda    g_tpPending
  94B4:  4b0c         dbnza  L94C2
  94B6:  4f           clra   
  94B7:  c701d3       sta    g_tpSessionState
  94BA:  c701d2       sta    g_tpPending
  94BD:  5f           clrx   
  94BE:  4c           inca   
  94BF:  cd9fa9       jsr    LinLL_OnError
L94C2:
  94C2:  c601d3       lda    g_tpSessionState
  94C5:  2713         beq    L94DA
  94C7:  4f           clra   
  94C8:  c701c9       sta    $01C9
  94CB:  c701ca       sta    $01CA
  94CE:  5f           clrx   
  94CF:  4c           inca   
  94D0:  cd9fd1       jsr    LinLL_OnIdle
  94D3:  4f           clra   
  94D4:  c701d3       sta    g_tpSessionState
  94D7:  c701d2       sta    g_tpPending
L94DA:
  94DA:  95           tsx    
  94DB:  e602         lda    2,x
  94DD:  87           psha   
  94DE:  e601         lda    1,x
  94E0:  87           psha   
  94E1:  9ece03       ldhx   3,x
  94E4:  f6           lda    ,x
  94E5:  5f           clrx   
  94E6:  cd9f6b       jsr    LinLL_Classify
  94E9:  a702         ais    #$02
  94EB:  c701d1       sta    $01D1
  94EE:  410107       cbeqa  #$01, L94F8
  94F1:  a102         cmp    #$02
  94F3:  2703         beq    L94F8
L94F5:
  94F5:  cc9628       jmp    $9628
L94F8:
  94F8:  a605         lda    #$05
  94FA:  87           psha   
  94FB:  4f           clra   
  94FC:  87           psha   
  94FD:  95           tsx    
  94FE:  e606         lda    6,x
  9500:  ee05         ldx    5,x
  9502:  ab03         add    #$03
  9504:  2401         bcc    L9507
  9506:  5c           incx   
L9507:
  9507:  87           psha   
  9508:  89           pshx   
  9509:  a6e6         lda    #$E6
  950B:  ae01         ldx    #$01
  950D:  cda045       jsr    mem_copy
  9510:  a704         ais    #$04
  9512:  a60a         lda    #$0A
  9514:  c701ca       sta    $01CA
  9517:  4f           clra   
  9518:  c701c9       sta    $01C9
  951B:  9efe02       ldhx   2,s
  951E:  affb         aix    #$FB
  9520:  9601cb       sthx   $01CB
  9523:  a605         lda    #$05
  9525:  c701cf       sta    $01CF
  9528:  4f           clra   
  9529:  c701ce       sta    $01CE
  952C:  9efe04       ldhx   4,s
  952F:  f6           lda    ,x
  9530:  c701d0       sta    $01D0
  9533:  a601         lda    #$01
  9535:  c701cd       sta    $01CD
  9538:  c701d2       sta    g_tpPending
  953B:  cc962a       jmp    $962A
L953E:
  953E:  c601d2       lda    g_tpPending
  9541:  2703         beq    L9546
  9543:  cc961c       jmp    $961C
L9546:
  9546:  c601d3       lda    g_tpSessionState
  9549:  27aa         beq    L94F5
L954B:
  954B:  a602         lda    #$02
  954D:  cc962a       jmp    $962A
L9550:
  9550:  c601d2       lda    g_tpPending
  9553:  a101         cmp    #$01
  9555:  2703         beq    L955A
  9557:  cc9616       jmp    $9616
L955A:
  955A:  e601         lda    1,x
  955C:  a40f         and    #$0F
  955E:  c101cd       cmp    $01CD
  9561:  2703         beq    L9566
  9563:  cc9601       jmp    $9601
L9566:
  9566:  3201cb       ldhx   $01CB
  9569:  650007       cphx   #$0007
  956C:  c601d1       lda    $01D1
  956F:  2446         bcc    L95B7
  9571:  4b26         dbnza  L9599
  9573:  c601cc       lda    $01CC
  9576:  87           psha   
  9577:  c601cb       lda    $01CB
  957A:  87           psha   
  957B:  95           tsx    
  957C:  e606         lda    6,x
  957E:  ee05         ldx    5,x
  9580:  ab02         add    #$02
  9582:  2401         bcc    L9585
  9584:  5c           incx   
L9585:
  9585:  87           psha   
  9586:  89           pshx   
  9587:  c601cf       lda    $01CF
  958A:  abe6         add    #$E6
  958C:  87           psha   
  958D:  c601ce       lda    $01CE
  9590:  a901         adc    #$01
  9592:  97           tax    
  9593:  86           pula   
  9594:  cda045       jsr    mem_copy
  9597:  a704         ais    #$04
L9599:
  9599:  4f           clra   
  959A:  c701cb       sta    $01CB
  959D:  c701cc       sta    $01CC
  95A0:  c701c9       sta    $01C9
  95A3:  c701ca       sta    $01CA
  95A6:  a602         lda    #$02
  95A8:  95           tsx    
  95A9:  f7           sta    ,x
  95AA:  4f           clra   
  95AB:  c701d3       sta    g_tpSessionState
  95AE:  c701d2       sta    g_tpPending
  95B1:  5f           clrx   
  95B2:  cd9fa9       jsr    LinLL_OnError
  95B5:  2079         bra    L9630
L95B7:
  95B7:  4b23         dbnza  L95DC
  95B9:  a606         lda    #$06
  95BB:  87           psha   
  95BC:  4f           clra   
  95BD:  87           psha   
  95BE:  95           tsx    
  95BF:  e606         lda    6,x
  95C1:  ee05         ldx    5,x
  95C3:  ab02         add    #$02
  95C5:  2401         bcc    L95C8
  95C7:  5c           incx   
L95C8:
  95C8:  87           psha   
  95C9:  89           pshx   
  95CA:  c601cf       lda    $01CF
  95CD:  abe6         add    #$E6
  95CF:  87           psha   
  95D0:  c601ce       lda    $01CE
  95D3:  a901         adc    #$01
  95D5:  97           tax    
  95D6:  86           pula   
  95D7:  cda045       jsr    mem_copy
  95DA:  a704         ais    #$04
L95DC:
  95DC:  3201ce       ldhx   $01CE
  95DF:  af06         aix    #$06
  95E1:  9601ce       sthx   $01CE
  95E4:  c601cd       lda    $01CD
  95E7:  4c           inca   
  95E8:  a40f         and    #$0F
  95EA:  c701cd       sta    $01CD
  95ED:  3201cb       ldhx   $01CB
  95F0:  affa         aix    #$FA
  95F2:  9601cb       sthx   $01CB
  95F5:  a60a         lda    #$0A
  95F7:  c701ca       sta    $01CA
  95FA:  4f           clra   
  95FB:  c701c9       sta    $01C9
  95FE:  4c           inca   
  95FF:  2029         bra    L962A
L9601:
  9601:  4f           clra   
  9602:  c701c9       sta    $01C9
  9605:  c701ca       sta    $01CA
  9608:  5f           clrx   
  9609:  4c           inca   
  960A:  cd9fa9       jsr    LinLL_OnError
  960D:  4f           clra   
  960E:  c701d3       sta    g_tpSessionState
  9611:  c701d2       sta    g_tpPending
  9614:  2012         bra    L9628
L9616:
  9616:  4d           tsta   
  9617:  2603         bne    L961C
  9619:  cc9546       jmp    $9546
L961C:
  961C:  a601         lda    #$01
  961E:  200a         bra    L962A
L9620:
  9620:  c601d3       lda    g_tpSessionState
  9623:  2703         beq    L9628
  9625:  cc954b       jmp    $954B
L9628:
  9628:  a603         lda    #$03
L962A:
  962A:  95           tsx    
  962B:  f7           sta    ,x
  962C:  2002         bra    L9630
L962E:
  962E:  95           tsx    
  962F:  7f           clr    ,x
L9630:
  9630:  95           tsx    
  9631:  f6           lda    ,x
  9632:  a705         ais    #$05
  9634:  81           rts    

;---------------------------------------------------------------
; LinTp_TxFrame   [0x9635]   <- 9A91
;---------------------------------------------------------------
  9635:  87           psha   
  9636:  89           pshx   
  9637:  c601d3       lda    g_tpSessionState
  963A:  a103         cmp    #$03
  963C:  2703         beq    L9641
  963E:  cc96ee       jmp    $96EE
L9641:
  9641:  4f           clra   
  9642:  c701c9       sta    $01C9
  9645:  c701ca       sta    $01CA
  9648:  c601d0       lda    $01D0
  964B:  9efe01       ldhx   1,s
  964E:  f7           sta    ,x
  964F:  3201cb       ldhx   $01CB
  9652:  650007       cphx   #$0007
  9655:  2451         bcc    L96A8
  9657:  c601cc       lda    $01CC
  965A:  9efe01       ldhx   1,s
  965D:  e701         sta    1,x
  965F:  87           psha   
  9660:  c601cb       lda    $01CB
  9663:  87           psha   
  9664:  4501e6       ldhx   #$01E6
  9667:  89           pshx   
  9668:  8b           pshh   
  9669:  9efe05       ldhx   5,s
  966C:  af02         aix    #$02
  966E:  9f           txa    
  966F:  8b           pshh   
  9670:  88           pulx   
  9671:  cda045       jsr    mem_copy
  9674:  a704         ais    #$04
  9676:  a606         lda    #$06
  9678:  c001cc       sub    $01CC
  967B:  87           psha   
  967C:  4f           clra   
  967D:  c201cb       sbc    $01CB
  9680:  87           psha   
  9681:  a6ff         lda    #$FF
  9683:  87           psha   
  9684:  4f           clra   
  9685:  87           psha   
  9686:  c601cc       lda    $01CC
  9689:  ab02         add    #$02
  968B:  95           tsx    
  968C:  eb05         add    5,x
  968E:  87           psha   
  968F:  4f           clra   
  9690:  e904         adc    4,x
  9692:  97           tax    
  9693:  86           pula   
  9694:  cd9ff7       jsr    mem_fill_down
  9697:  a704         ais    #$04
  9699:  a604         lda    #$04
  969B:  c701d3       sta    g_tpSessionState
  969E:  4f           clra   
  969F:  c701cb       sta    $01CB
  96A2:  c701cc       sta    $01CC
  96A5:  cc97a4       jmp    $97A4
L96A8:
  96A8:  c601cb       lda    $01CB
  96AB:  a40f         and    #$0F
  96AD:  aa10         ora    #$10
  96AF:  9efe01       ldhx   1,s
  96B2:  e701         sta    1,x
  96B4:  c601cc       lda    $01CC
  96B7:  e702         sta    2,x
  96B9:  a605         lda    #$05
  96BB:  87           psha   
  96BC:  4f           clra   
  96BD:  87           psha   
  96BE:  4501e6       ldhx   #$01E6
  96C1:  89           pshx   
  96C2:  8b           pshh   
  96C3:  9efe05       ldhx   5,s
  96C6:  af03         aix    #$03
  96C8:  9f           txa    
  96C9:  8b           pshh   
  96CA:  88           pulx   
  96CB:  cda045       jsr    mem_copy
  96CE:  a704         ais    #$04
  96D0:  3201cb       ldhx   $01CB
  96D3:  affb         aix    #$FB
  96D5:  9601cb       sthx   $01CB
  96D8:  a601         lda    #$01
  96DA:  c701cd       sta    $01CD
  96DD:  a605         lda    #$05
  96DF:  c701cf       sta    $01CF
  96E2:  4f           clra   
  96E3:  c701ce       sta    $01CE
  96E6:  a605         lda    #$05
  96E8:  c701d3       sta    g_tpSessionState
  96EB:  cc97a4       jmp    $97A4
L96EE:
  96EE:  a106         cmp    #$06
  96F0:  2703         beq    L96F5
  96F2:  cc97ad       jmp    $97AD
L96F5:
  96F5:  4f           clra   
  96F6:  c701c9       sta    $01C9
  96F9:  c701ca       sta    $01CA
  96FC:  c601d0       lda    $01D0
  96FF:  9efe01       ldhx   1,s
  9702:  f7           sta    ,x
  9703:  c601cd       lda    $01CD
  9706:  aa20         ora    #$20
  9708:  e701         sta    1,x
  970A:  3201cb       ldhx   $01CB
  970D:  650007       cphx   #$0007
  9710:  2456         bcc    L9768
  9712:  c601cc       lda    $01CC
  9715:  87           psha   
  9716:  c601cb       lda    $01CB
  9719:  87           psha   
  971A:  c601cf       lda    $01CF
  971D:  abe6         add    #$E6
  971F:  87           psha   
  9720:  c601ce       lda    $01CE
  9723:  a901         adc    #$01
  9725:  87           psha   
  9726:  9efe05       ldhx   5,s
  9729:  af02         aix    #$02
  972B:  9f           txa    
  972C:  8b           pshh   
  972D:  88           pulx   
  972E:  cda045       jsr    mem_copy
  9731:  a704         ais    #$04
  9733:  a606         lda    #$06
  9735:  c001cc       sub    $01CC
  9738:  5f           clrx   
  9739:  87           psha   
  973A:  89           pshx   
  973B:  a6ff         lda    #$FF
  973D:  87           psha   
  973E:  4f           clra   
  973F:  87           psha   
  9740:  c601cc       lda    $01CC
  9743:  ab02         add    #$02
  9745:  9eeb06       add    6,s
  9748:  87           psha   
  9749:  9f           txa    
  974A:  95           tsx    
  974B:  e905         adc    5,x
  974D:  97           tax    
  974E:  86           pula   
  974F:  cd9ff7       jsr    mem_fill_down
  9752:  a704         ais    #$04
  9754:  4f           clra   
  9755:  c701ce       sta    $01CE
  9758:  c701cf       sta    $01CF
  975B:  c701cb       sta    $01CB
  975E:  c701cc       sta    $01CC
  9761:  a607         lda    #$07
  9763:  c701d3       sta    g_tpSessionState
  9766:  203c         bra    L97A4
L9768:
  9768:  a606         lda    #$06
  976A:  87           psha   
  976B:  4f           clra   
  976C:  87           psha   
  976D:  c601cf       lda    $01CF
  9770:  abe6         add    #$E6
  9772:  87           psha   
  9773:  c601ce       lda    $01CE
  9776:  a901         adc    #$01
  9778:  87           psha   
  9779:  9efe05       ldhx   5,s
  977C:  af02         aix    #$02
  977E:  9f           txa    
  977F:  8b           pshh   
  9780:  88           pulx   
  9781:  cda045       jsr    mem_copy
  9784:  a704         ais    #$04
  9786:  3201ce       ldhx   $01CE
  9789:  af06         aix    #$06
  978B:  9601ce       sthx   $01CE
  978E:  3201cb       ldhx   $01CB
  9791:  affa         aix    #$FA
  9793:  9601cb       sthx   $01CB
  9796:  a607         lda    #$07
  9798:  c701d3       sta    g_tpSessionState
  979B:  c601cd       lda    $01CD
  979E:  4c           inca   
  979F:  a40f         and    #$0F
  97A1:  c701cd       sta    $01CD
L97A4:
  97A4:  a614         lda    #$14
  97A6:  c701ca       sta    $01CA
  97A9:  4f           clra   
  97AA:  c701c9       sta    $01C9
L97AD:
  97AD:  a702         ais    #$02
  97AF:  81           rts    

;---------------------------------------------------------------
; LinTp_sub_97B0   [0x97B0]   <- 9B94
;---------------------------------------------------------------
  97B0:  87           psha   
  97B1:  c601d3       lda    g_tpSessionState
  97B4:  a104         cmp    #$04
  97B6:  2618         bne    L97D0
  97B8:  4f           clra   
  97B9:  c701d3       sta    g_tpSessionState
  97BC:  c701c9       sta    $01C9
  97BF:  c701ca       sta    $01CA
  97C2:  5f           clrx   
  97C3:  cd9fd1       jsr    LinLL_OnIdle
  97C6:  95           tsx    
  97C7:  f7           sta    ,x
  97C8:  2738         beq    L9802
  97CA:  a101         cmp    #$01
  97CC:  2636         bne    L9804
  97CE:  2034         bra    L9804
L97D0:
  97D0:  a105         cmp    #$05
  97D2:  2709         beq    L97DD
  97D4:  a107         cmp    #$07
  97D6:  262a         bne    L9802
  97D8:  3201cb       ldhx   $01CB
  97DB:  2711         beq    L97EE
L97DD:
  97DD:  a606         lda    #$06
  97DF:  c701d3       sta    g_tpSessionState
  97E2:  a614         lda    #$14
  97E4:  c701ca       sta    $01CA
  97E7:  4f           clra   
  97E8:  c701c9       sta    $01C9
  97EB:  4c           inca   
  97EC:  2016         bra    L9804
L97EE:
  97EE:  4f           clra   
  97EF:  c701d3       sta    g_tpSessionState
  97F2:  c701c9       sta    $01C9
  97F5:  c701ca       sta    $01CA
  97F8:  cd9fd1       jsr    LinLL_OnIdle
  97FB:  95           tsx    
  97FC:  f7           sta    ,x
  97FD:  2703         beq    L9802
  97FF:  410102       cbeqa  #$01, L9804
L9802:
  9802:  a603         lda    #$03
L9804:
  9804:  8a           pulh   
  9805:  81           rts    

;---------------------------------------------------------------
; LinTp_sub_9806   [0x9806]   <- 9BC2, 9BD9
;---------------------------------------------------------------
  9806:  c601d3       lda    g_tpSessionState
  9809:  410407       cbeqa  #$04, L9813
  980C:  410504       cbeqa  #$05, L9813
  980F:  a107         cmp    #$07
  9811:  2613         bne    L9826
L9813:
  9813:  4f           clra   
  9814:  c701d3       sta    g_tpSessionState
  9817:  c701d2       sta    g_tpPending
  981A:  c701c9       sta    $01C9
  981D:  c701ca       sta    $01CA
  9820:  5f           clrx   
  9821:  4c           inca   
  9822:  cd9fd1       jsr    LinLL_OnIdle
L9825:
  9825:  81           rts    
L9826:
  9826:  c601d2       lda    g_tpPending
  9829:  4bfa         dbnza  L9825
  982B:  4f           clra   
  982C:  c701d3       sta    g_tpSessionState
  982F:  c701d2       sta    g_tpPending
  9832:  c701cb       sta    $01CB
  9835:  c701cc       sta    $01CC
  9838:  c701ce       sta    $01CE
  983B:  c701cf       sta    $01CF
  983E:  5f           clrx   
  983F:  4c           inca   
  9840:  cc9fa9       jmp    LinLL_OnError

;---------------------------------------------------------------
; Lin_Init   [0x9843]   <- 8E1A
;---------------------------------------------------------------
  9843:  a653         lda    #$53
  9845:  c701e2       sta    g_linConfigMagic
  9848:  a601         lda    #$01
  984A:  87           psha   
  984B:  4f           clra   
  984C:  87           psha   
  984D:  a6be         lda    #$BE
  984F:  ae00         ldx    #$00
  9851:  cda019       jsr    mem_set
  9854:  a702         ais    #$02
  9856:  a601         lda    #$01
  9858:  87           psha   
  9859:  4f           clra   
  985A:  87           psha   
  985B:  a6c0         lda    #$C0
  985D:  ae00         ldx    #$00
  985F:  cda019       jsr    mem_set
  9862:  a702         ais    #$02
  9864:  ad02         bsr    Lin_ResetState
  9866:  4f           clra   
  9867:  81           rts    

;---------------------------------------------------------------
; Lin_ResetState   [0x9868]   <- 9864
;---------------------------------------------------------------
  9868:  c601e2       lda    g_linConfigMagic
  986B:  415306       cbeqa  #$53, L9874
  986E:  5f           clrx   
  986F:  a621         lda    #$21
  9871:  cd8dcf       jsr    LinErr_Set
L9874:
  9874:  3fbd         clr    g_linDiagActive
  9876:  3fbb         clr    g_linT3
  9878:  3fba         clr    g_linT2
  987A:  3fb9         clr    g_linT1
  987C:  a602         lda    #$02
  987E:  c701d7       sta    $01D7
  9881:  6e02b8       mov    #$02, g_linFrameState
  9884:  4f           clra   
  9885:  c701e0       sta    $01E0
  9888:  cd9950       jsr    LinSig_PublishAll
  988B:  cd998b       jsr    LinSig_PublishAll2
  988E:  3fb6         clr    g_linByteCnt
  9890:  3fb4         clr    g_linCrcH
  9892:  3fb5         clr    g_linCrcL
  9894:  4f           clra   
  9895:  c701d4       sta    $01D4
  9898:  3fb1         clr    g_linTpState
  989A:  c701d5       sta    $01D5
  989D:  cd915f       jsr    Sci_Init
  98A0:  cc9cd0       jmp    LinSci_RxOff

;---------------------------------------------------------------
; Lin_WakeOrReset   [0x98A3]   <- 8E2B
;---------------------------------------------------------------
  98A3:  87           psha   
  98A4:  89           pshx   
  98A5:  87           psha   
  98A6:  cd9306       jsr    LinCrit_Enter
  98A9:  c601e2       lda    g_linConfigMagic
  98AC:  415306       cbeqa  #$53, L98B5
  98AF:  5f           clrx   
  98B0:  a621         lda    #$21
  98B2:  cd8dcf       jsr    LinErr_Set
L98B5:
  98B5:  95           tsx    
  98B6:  e602         lda    2,x
  98B8:  410109       cbeqa  #$01, L98C4
  98BB:  410206       cbeqa  #$02, L98C4
  98BE:  5f           clrx   
  98BF:  a603         lda    #$03
  98C1:  cd8dcf       jsr    LinErr_Set
L98C4:
  98C4:  a601         lda    #$01
  98C6:  95           tsx    
  98C7:  f7           sta    ,x
  98C8:  3dbd         tst    g_linDiagActive
  98CA:  261f         bne    L98EB
  98CC:  e602         lda    2,x
  98CE:  4b10         dbnza  L98E0
  98D0:  a608         lda    #$08
  98D2:  c701e1       sta    $01E1
  98D5:  6e01bc       mov    #$01, g_linDiagState
  98D8:  6e01bd       mov    #$01, g_linDiagActive
  98DB:  cd9cd4       jsr    LinSci_TxBreak
  98DE:  2009         bra    L98E9
L98E0:
  98E0:  cd9cca       jsr    LinSci_RxOn
  98E3:  cd99d8       jsr    Lin_GotoSleep
  98E6:  6e43b9       mov    #$43, g_linT1
L98E9:
  98E9:  95           tsx    
  98EA:  7f           clr    ,x
L98EB:
  98EB:  cd931e       jsr    LinCrit_Leave
  98EE:  95           tsx    
  98EF:  f6           lda    ,x
  98F0:  a703         ais    #$03
  98F2:  81           rts    

;---------------------------------------------------------------
; Lin_Supervise   [0x98F3]   <- LinApp_Supervise
;---------------------------------------------------------------
  98F3:  cd9306       jsr    LinCrit_Enter
  98F6:  c601e2       lda    g_linConfigMagic
  98F9:  415306       cbeqa  #$53, L9902
  98FC:  5f           clrx   
  98FD:  a621         lda    #$21
  98FF:  cd8dcf       jsr    LinErr_Set
L9902:
  9902:  3dba         tst    g_linT2
  9904:  272e         beq    L9934
  9906:  3bba2b       dbnz   g_linT2, L9934
  9909:  b6bd         lda    g_linDiagActive
  990B:  a101         cmp    #$01
  990D:  2611         bne    L9920
  990F:  3fbd         clr    g_linDiagActive
  9911:  a6ff         lda    #$FF
  9913:  87           psha   
  9914:  4f           clra   
  9915:  87           psha   
  9916:  5f           clrx   
  9917:  a60a         lda    #$0A
  9919:  cd8de6       jsr    LinSig_Request
  991C:  a702         ais    #$02
  991E:  2014         bra    L9934
L9920:
  9920:  a102         cmp    #$02
  9922:  2610         bne    L9934
  9924:  a6ff         lda    #$FF
  9926:  87           psha   
  9927:  4f           clra   
  9928:  87           psha   
  9929:  5f           clrx   
  992A:  a604         lda    #$04
  992C:  cd8de6       jsr    LinSig_Request
  992F:  a702         ais    #$02
  9931:  cd99c9       jsr    Lin_ClearFrameState
L9934:
  9934:  3db9         tst    g_linT1
  9936:  2712         beq    L994A
  9938:  3bb90f       dbnz   g_linT1, L994A
  993B:  a6ff         lda    #$FF
  993D:  87           psha   
  993E:  4f           clra   
  993F:  87           psha   
  9940:  5f           clrx   
  9941:  a603         lda    #$03
  9943:  cd8de6       jsr    LinSig_Request
  9946:  a702         ais    #$02
  9948:  ad7f         bsr    Lin_ClearFrameState
L994A:
  994A:  cc931e       jmp    LinCrit_Leave
;   .... data/gap 994D-9950 ....

;---------------------------------------------------------------
; LinSig_PublishAll   [0x9950]   <- 9888, 99D0, 99E1
;---------------------------------------------------------------
  9950:  87           psha   
  9951:  95           tsx    
  9952:  7f           clr    ,x
L9953:
  9953:  95           tsx    
  9954:  fe           ldx    ,x
  9955:  58           lslx   
  9956:  8c           clrh   
  9957:  9ebec1b7     ldhx   $C1B7,x
  995B:  2725         beq    L9982
  995D:  9eee01       ldx    1,s
  9960:  8c           clrh   
  9961:  d6c1b5       lda    $C1B5,x
  9964:  5f           clrx   
  9965:  87           psha   
  9966:  89           pshx   
  9967:  9eee03       ldx    3,s
  996A:  58           lslx   
  996B:  d6c1de       lda    $C1DE,x
  996E:  87           psha   
  996F:  d6c1dd       lda    $C1DD,x
  9972:  87           psha   
  9973:  9eee05       ldx    5,s
  9976:  58           lslx   
  9977:  d6c1b8       lda    $C1B8,x
  997A:  dec1b7       ldx    $C1B7,x
  997D:  cda083       jsr    mem_copy_far
  9980:  a704         ais    #$04
L9982:
  9982:  95           tsx    
  9983:  7c           inc    ,x
  9984:  fe           ldx    ,x
  9985:  a302         cpx    #$02
  9987:  25ca         bcs    L9953
  9989:  8a           pulh   
  998A:  81           rts    

;---------------------------------------------------------------
; LinSig_PublishAll2   [0x998B]   <- 988B, 99D3, 99E4
;---------------------------------------------------------------
  998B:  87           psha   
  998C:  a602         lda    #$02
  998E:  95           tsx    
  998F:  f7           sta    ,x
L9990:
  9990:  97           tax    
  9991:  58           lslx   
  9992:  8c           clrh   
  9993:  9ebec1b7     ldhx   $C1B7,x
  9997:  2727         beq    L99C0
  9999:  95           tsx    
  999A:  fe           ldx    ,x
  999B:  8c           clrh   
  999C:  d6c1af       lda    $C1AF,x
  999F:  62           nsa    
  99A0:  a40f         and    #$0F
  99A2:  5f           clrx   
  99A3:  87           psha   
  99A4:  89           pshx   
  99A5:  9eee03       ldx    3,s
  99A8:  58           lslx   
  99A9:  d6c1de       lda    $C1DE,x
  99AC:  87           psha   
  99AD:  d6c1dd       lda    $C1DD,x
  99B0:  87           psha   
  99B1:  9eee05       ldx    5,s
  99B4:  58           lslx   
  99B5:  d6c1b8       lda    $C1B8,x
  99B8:  dec1b7       ldx    $C1B7,x
  99BB:  cda083       jsr    mem_copy_far
  99BE:  a704         ais    #$04
L99C0:
  99C0:  95           tsx    
  99C1:  7c           inc    ,x
  99C2:  f6           lda    ,x
  99C3:  a104         cmp    #$04
  99C5:  25c9         bcs    L9990
  99C7:  8a           pulh   
  99C8:  81           rts    

;---------------------------------------------------------------
; Lin_ClearFrameState   [0x99C9]   <- 9931, 9948, 9B10
;---------------------------------------------------------------
  99C9:  3fbd         clr    g_linDiagActive
  99CB:  3fb9         clr    g_linT1
  99CD:  cd8e01       jsr    LinApp_SetErr
  99D0:  cd9950       jsr    LinSig_PublishAll
  99D3:  adb6         bsr    LinSig_PublishAll2
  99D5:  cc9cd0       jmp    LinSci_RxOff

;---------------------------------------------------------------
; Lin_GotoSleep   [0x99D8]   <- 98E3
;---------------------------------------------------------------
  99D8:  b6bd         lda    g_linDiagActive
  99DA:  2702         beq    L99DE
  99DC:  4b0b         dbnza  L99E9
L99DE:
  99DE:  6e02bd       mov    #$02, g_linDiagActive
  99E1:  cd9950       jsr    LinSig_PublishAll
  99E4:  ada5         bsr    LinSig_PublishAll2
  99E6:  cd8dee       jsr    LinApp_sub_8DEE
L99E9:
  99E9:  81           rts    

;---------------------------------------------------------------
; Lin_GotoSleep2   [0x99EA]   <- 9D9D, 9EA1
;---------------------------------------------------------------
  99EA:  20ec         bra    Lin_GotoSleep

;---------------------------------------------------------------
; LinSched_OnHeader   [0x99EC]   <- 9DC5
;---------------------------------------------------------------
  99EC:  87           psha   
  99ED:  89           pshx   
  99EE:  a7fd         ais    #$FD
  99F0:  a13c         cmp    #$3C
  99F2:  2604         bne    L99F8
  99F4:  a604         lda    #$04
  99F6:  2021         bra    L9A19
L99F8:
  99F8:  a17d         cmp    #$7D
  99FA:  2604         bne    L9A00
  99FC:  a605         lda    #$05
  99FE:  2019         bra    L9A19
L9A00:
  9A00:  a6ff         lda    #$FF
  9A02:  95           tsx    
  9A03:  e701         sta    1,x
  9A05:  e604         lda    4,x
  9A07:  414017       cbeqa  #$40, L9A21
  9A0A:  a604         lda    #$04
  9A0C:  f7           sta    ,x
L9A0D:
  9A0D:  7a           dec    ,x
  9A0E:  fe           ldx    ,x
  9A0F:  8c           clrh   
  9A10:  d6c1ab       lda    $C1AB,x
  9A13:  95           tsx    
  9A14:  e104         cmp    4,x
  9A16:  2606         bne    L9A1E
  9A18:  f6           lda    ,x
L9A19:
  9A19:  95           tsx    
  9A1A:  e701         sta    1,x
  9A1C:  2003         bra    L9A21
L9A1E:
  9A1E:  7d           tst    ,x
  9A1F:  26ec         bne    L9A0D
L9A21:
  9A21:  ee01         ldx    1,x
  9A23:  cf01e0       stx    $01E0
  9A26:  a3ff         cpx    #$FF
  9A28:  2607         bne    L9A31
  9A2A:  95           tsx    
  9A2B:  e602         lda    2,x
  9A2D:  a40f         and    #$0F
  9A2F:  2067         bra    L9A98
L9A31:
  9A31:  8c           clrh   
  9A32:  d6c1af       lda    $C1AF,x
  9A35:  9ee703       sta    3,s
  9A38:  9ee602       lda    2,s
  9A3B:  a104         cmp    #$04
  9A3D:  2434         bcc    L9A73
  9A3F:  9ee603       lda    3,s
  9A42:  a40c         and    #$0C
  9A44:  a108         cmp    #$08
  9A46:  2654         bne    L9A9C
  9A48:  9eee02       ldx    2,s
  9A4B:  58           lslx   
  9A4C:  9ebec1b7     ldhx   $C1B7,x
  9A50:  274a         beq    L9A9C
  9A52:  95           tsx    
  9A53:  e602         lda    2,x
  9A55:  62           nsa    
  9A56:  a40f         and    #$0F
  9A58:  5f           clrx   
  9A59:  87           psha   
  9A5A:  89           pshx   
  9A5B:  9eee04       ldx    4,s
  9A5E:  58           lslx   
  9A5F:  8c           clrh   
  9A60:  d6c1b8       lda    $C1B8,x
  9A63:  87           psha   
  9A64:  d6c1b7       lda    $C1B7,x
  9A67:  87           psha   
  9A68:  a6d8         lda    #$D8
  9A6A:  ae01         ldx    #$01
  9A6C:  cda045       jsr    mem_copy
  9A6F:  a704         ais    #$04
  9A71:  2029         bra    L9A9C
L9A73:
  9A73:  a106         cmp    #$06
  9A75:  2425         bcc    L9A9C
  9A77:  95           tsx    
  9A78:  e602         lda    2,x
  9A7A:  a40c         and    #$0C
  9A7C:  a108         cmp    #$08
  9A7E:  261c         bne    L9A9C
  9A80:  b6b8         lda    g_linFrameState
  9A82:  a103         cmp    #$03
  9A84:  2610         bne    L9A96
  9A86:  cd93ca       jsr    LinTp_IsActive
  9A89:  95           tsx    
  9A8A:  f7           sta    ,x
  9A8B:  4b09         dbnza  L9A96
  9A8D:  a6d8         lda    #$D8
  9A8F:  ae01         ldx    #$01
  9A91:  cd9635       jsr    LinTp_TxFrame
  9A94:  2006         bra    L9A9C
L9A96:
  9A96:  e602         lda    2,x
L9A98:
  9A98:  aa0c         ora    #$0C
  9A9A:  e702         sta    2,x
L9A9C:
  9A9C:  95           tsx    
  9A9D:  af02         aix    #$02
  9A9F:  f6           lda    ,x
  9AA0:  87           psha   
  9AA1:  cd9cde       jsr    LinDiag_Request
  9AA4:  8a           pulh   
  9AA5:  b6bd         lda    g_linDiagActive
  9AA7:  a102         cmp    #$02
  9AA9:  2608         bne    L9AB3
  9AAB:  6e0fbc       mov    #$0F, g_linDiagState
  9AAE:  3fba         clr    g_linT2
  9AB0:  6e03bd       mov    #$03, g_linDiagActive
L9AB3:
  9AB3:  a705         ais    #$05
  9AB5:  81           rts    

;---------------------------------------------------------------
; LinDiag_Response   [0x9AB6]   <- 9E20, 9E67
;---------------------------------------------------------------
  9AB6:  87           psha   
  9AB7:  89           pshx   
  9AB8:  a7fd         ais    #$FD
  9ABA:  4501d8       ldhx   #$01D8
  9ABD:  9eff02       sthx   2,s
  9AC0:  e608         lda    8,x
  9AC2:  95           tsx    
  9AC3:  f7           sta    ,x
  9AC4:  e604         lda    4,x
  9AC6:  4a           deca   
  9AC7:  2703         beq    L9ACC
  9AC9:  cc9b56       jmp    $9B56
L9ACC:
  9ACC:  f6           lda    ,x
  9ACD:  a104         cmp    #$04
  9ACF:  2435         bcc    L9B06
  9AD1:  97           tax    
  9AD2:  58           lslx   
  9AD3:  8c           clrh   
  9AD4:  9ebec1b7     ldhx   $C1B7,x
  9AD8:  271f         beq    L9AF9
  9ADA:  97           tax    
  9ADB:  8c           clrh   
  9ADC:  d6c1b5       lda    $C1B5,x
  9ADF:  5f           clrx   
  9AE0:  87           psha   
  9AE1:  89           pshx   
  9AE2:  9ee605       lda    5,s
  9AE5:  87           psha   
  9AE6:  9ee605       lda    5,s
  9AE9:  87           psha   
  9AEA:  9eee05       ldx    5,s
  9AED:  58           lslx   
  9AEE:  d6c1b8       lda    $C1B8,x
  9AF1:  dec1b7       ldx    $C1B7,x
  9AF4:  cda045       jsr    mem_copy
  9AF7:  a704         ais    #$04
L9AF9:
  9AF9:  95           tsx    
  9AFA:  fe           ldx    ,x
  9AFB:  8c           clrh   
  9AFC:  b6c0         lda    $C0
  9AFE:  dac1c2       ora    $C1C2,x
  9B01:  b7c0         sta    $C0
L9B03:
  9B03:  cc9b9e       jmp    $9B9E
L9B06:
  9B06:  a106         cmp    #$06
  9B08:  24f9         bcc    L9B03
  9B0A:  9efe02       ldhx   2,s
  9B0D:  7d           tst    ,x
  9B0E:  260e         bne    L9B1E
  9B10:  cd99c9       jsr    Lin_ClearFrameState
  9B13:  6e02b8       mov    #$02, g_linFrameState
  9B16:  a602         lda    #$02
  9B18:  c701d7       sta    $01D7
  9B1B:  cc9b9e       jmp    $9B9E
L9B1E:
  9B1E:  b6c0         lda    $C0
  9B20:  cac1c4       ora    $C1C4
  9B23:  b7c0         sta    $C0
  9B25:  95           tsx    
  9B26:  e602         lda    2,x
  9B28:  ee01         ldx    1,x
  9B2A:  cd93dc       jsr    LinTp_RxFrame
  9B2D:  95           tsx    
  9B2E:  f7           sta    ,x
  9B2F:  a101         cmp    #$01
  9B31:  2604         bne    L9B37
  9B33:  a603         lda    #$03
  9B35:  2012         bra    L9B49
L9B37:
  9B37:  a102         cmp    #$02
  9B39:  2608         bne    L9B43
  9B3B:  c701d7       sta    $01D7
  9B3E:  6e03b8       mov    #$03, g_linFrameState
  9B41:  205b         bra    L9B9E
L9B43:
  9B43:  a103         cmp    #$03
  9B45:  2607         bne    L9B4E
  9B47:  a602         lda    #$02
L9B49:
  9B49:  c701d7       sta    $01D7
  9B4C:  204d         bra    L9B9B
L9B4E:
  9B4E:  4f           clra   
  9B4F:  c701d7       sta    $01D7
  9B52:  3fb8         clr    g_linFrameState
  9B54:  2048         bra    L9B9E
L9B56:
  9B56:  f6           lda    ,x
  9B57:  a104         cmp    #$04
  9B59:  242c         bcc    L9B87
  9B5B:  97           tax    
  9B5C:  8c           clrh   
  9B5D:  b6be         lda    g_linRespErr
  9B5F:  dac1c6       ora    $C1C6,x
  9B62:  b7be         sta    g_linRespErr
  9B64:  9ee601       lda    1,s
  9B67:  48           lsla   
  9B68:  a004         sub    #$04
  9B6A:  97           tax    
  9B6B:  9ebec1cb     ldhx   $C1CB,x
  9B6F:  272d         beq    L9B9E
  9B71:  95           tsx    
  9B72:  f6           lda    ,x
  9B73:  5f           clrx   
  9B74:  87           psha   
  9B75:  89           pshx   
  9B76:  95           tsx    
  9B77:  e602         lda    2,x
  9B79:  48           lsla   
  9B7A:  a004         sub    #$04
  9B7C:  8c           clrh   
  9B7D:  97           tax    
  9B7E:  9ebec1cb     ldhx   $C1CB,x
  9B82:  cdc048       jsr    rotate3
  9B85:  2017         bra    L9B9E
L9B87:
  9B87:  b6be         lda    g_linRespErr
  9B89:  cac1ca       ora    $C1CA
  9B8C:  b7be         sta    g_linRespErr
  9B8E:  b6b8         lda    g_linFrameState
  9B90:  a103         cmp    #$03
  9B92:  260a         bne    L9B9E
  9B94:  cd97b0       jsr    LinTp_sub_97B0
  9B97:  a103         cmp    #$03
  9B99:  2603         bne    L9B9E
L9B9B:
  9B9B:  6e02b8       mov    #$02, g_linFrameState
L9B9E:
  9B9E:  a705         ais    #$05
  9BA0:  81           rts    

;---------------------------------------------------------------
; LinErr_Report   [0x9BA1]   <- 9C84, 9DAC, 9E04, 9E6F, 9EB7, 9EDF, 9EE7
;---------------------------------------------------------------
  9BA1:  87           psha   
  9BA2:  89           pshx   
  9BA3:  87           psha   
  9BA4:  a5f0         bit    #$F0
  9BA6:  2773         beq    L9C1B
  9BA8:  c601e0       lda    $01E0
  9BAB:  95           tsx    
  9BAC:  f7           sta    ,x
  9BAD:  a104         cmp    #$04
  9BAF:  2619         bne    L9BCA
  9BB1:  b6b8         lda    g_linFrameState
  9BB3:  410307       cbeqa  #$03, L9BBD
  9BB6:  c601d7       lda    $01D7
  9BB9:  a103         cmp    #$03
  9BBB:  2608         bne    L9BC5
L9BBD:
  9BBD:  a602         lda    #$02
  9BBF:  c701d7       sta    $01D7
  9BC2:  cd9806       jsr    LinTp_sub_9806
L9BC5:
  9BC5:  6e02b8       mov    #$02, g_linFrameState
  9BC8:  95           tsx    
  9BC9:  f6           lda    ,x
L9BCA:
  9BCA:  a105         cmp    #$05
  9BCC:  260e         bne    L9BDC
  9BCE:  b6b8         lda    g_linFrameState
  9BD0:  a103         cmp    #$03
  9BD2:  2608         bne    L9BDC
  9BD4:  a602         lda    #$02
  9BD6:  c701d7       sta    $01D7
  9BD9:  cd9806       jsr    LinTp_sub_9806
L9BDC:
  9BDC:  95           tsx    
  9BDD:  e602         lda    2,x
  9BDF:  411111       cbeqa  #$11, L9BF3
  9BE2:  41120e       cbeqa  #$12, L9BF3
  9BE5:  411313       cbeqa  #$13, L9BFB
  9BE8:  411418       cbeqa  #$14, L9C03
  9BEB:  411525       cbeqa  #$15, L9C13
  9BEE:  41161a       cbeqa  #$16, L9C0B
  9BF1:  203b         bra    L9C2E
L9BF3:
  9BF3:  f6           lda    ,x
  9BF4:  5f           clrx   
  9BF5:  87           psha   
  9BF6:  89           pshx   
  9BF7:  a608         lda    #$08
  9BF9:  202e         bra    L9C29
L9BFB:
  9BFB:  f6           lda    ,x
  9BFC:  5f           clrx   
  9BFD:  87           psha   
  9BFE:  89           pshx   
  9BFF:  a609         lda    #$09
  9C01:  2026         bra    L9C29
L9C03:
  9C03:  f6           lda    ,x
  9C04:  5f           clrx   
  9C05:  87           psha   
  9C06:  89           pshx   
  9C07:  a607         lda    #$07
  9C09:  201e         bra    L9C29
L9C0B:
  9C0B:  f6           lda    ,x
  9C0C:  5f           clrx   
  9C0D:  87           psha   
  9C0E:  89           pshx   
  9C0F:  a606         lda    #$06
  9C11:  2016         bra    L9C29
L9C13:
  9C13:  f6           lda    ,x
  9C14:  5f           clrx   
  9C15:  87           psha   
  9C16:  89           pshx   
  9C17:  a602         lda    #$02
  9C19:  200e         bra    L9C29
L9C1B:
  9C1B:  410504       cbeqa  #$05, L9C22
  9C1E:  a107         cmp    #$07
  9C20:  260c         bne    L9C2E
L9C22:
  9C22:  a6ff         lda    #$FF
  9C24:  87           psha   
  9C25:  4f           clra   
  9C26:  87           psha   
  9C27:  5f           clrx   
  9C28:  4c           inca   
L9C29:
  9C29:  cd8de6       jsr    LinSig_Request
  9C2C:  a702         ais    #$02
L9C2E:
  9C2E:  a703         ais    #$03
  9C30:  81           rts    

;---------------------------------------------------------------
; LinTp_Timer   [0x9C31]   <- 8A18
;---------------------------------------------------------------
  9C31:  cd9306       jsr    LinCrit_Enter
  9C34:  b6b1         lda    g_linTpState
  9C36:  410f20       cbeqa  #$0F, L9C59
  9C39:  411105       cbeqa  #$11, L9C41
  9C3C:  41230d       cbeqa  #$23, L9C4C
  9C3F:  201e         bra    L9C5F
L9C41:
  9C41:  c601d4       lda    $01D4
  9C44:  c701d5       sta    $01D5
  9C47:  6e10b1       mov    #$10, g_linTpState
  9C4A:  2013         bra    L9C5F
L9C4C:
  9C4C:  c601d4       lda    $01D4
  9C4F:  4501d5       ldhx   #$01D5
  9C52:  fb           add    ,x
  9C53:  f7           sta    ,x
  9C54:  6e20b1       mov    #$20, g_linTpState
  9C57:  2006         bra    L9C5F
L9C59:
  9C59:  4f           clra   
  9C5A:  c701d5       sta    $01D5
  9C5D:  3fb1         clr    g_linTpState
L9C5F:
  9C5F:  c601d5       lda    $01D5
  9C62:  2727         beq    L9C8B
  9C64:  4501d5       ldhx   #$01D5
  9C67:  7a           dec    ,x
  9C68:  f6           lda    ,x
  9C69:  2620         bne    L9C8B
  9C6B:  b6b1         lda    g_linTpState
  9C6D:  a110         cmp    #$10
  9C6F:  2605         bne    L9C76
  9C71:  5f           clrx   
  9C72:  a605         lda    #$05
  9C74:  200e         bra    L9C84
L9C76:
  9C76:  a120         cmp    #$20
  9C78:  260d         bne    L9C87
  9C7A:  5f           clrx   
  9C7B:  0fb604       brclr  7, g_linByteCnt, L9C82
  9C7E:  a615         lda    #$15
  9C80:  2002         bra    L9C84
L9C82:
  9C82:  a616         lda    #$16
L9C84:
  9C84:  cd9ba1       jsr    LinErr_Report
L9C87:
  9C87:  3fb1         clr    g_linTpState
  9C89:  ad3f         bsr    LinSci_RxOn
L9C8B:
  9C8B:  b6bc         lda    g_linDiagState
  9C8D:  410105       cbeqa  #$01, L9C95
  9C90:  410f0c       cbeqa  #$0F, L9C9F
  9C93:  200e         bra    L9CA3
L9C95:
  9C95:  c601e1       lda    $01E1
  9C98:  b7bb         sta    g_linT3
  9C9A:  6e11bc       mov    #$11, g_linDiagState
  9C9D:  2004         bra    L9CA3
L9C9F:
  9C9F:  3fbb         clr    g_linT3
  9CA1:  3fbc         clr    g_linDiagState
L9CA3:
  9CA3:  3dbb         tst    g_linT3
  9CA5:  2720         beq    L9CC7
  9CA7:  3bbb1d       dbnz   g_linT3, L9CC7
  9CAA:  b6bc         lda    g_linDiagState
  9CAC:  411108       cbeqa  #$11, L9CB7
  9CAF:  411205       cbeqa  #$12, L9CB7
  9CB2:  41130d       cbeqa  #$13, L9CC2
  9CB5:  2010         bra    L9CC7
L9CB7:
  9CB7:  3cbc         inc    g_linDiagState
  9CB9:  6e08bb       mov    #$08, g_linT3
  9CBC:  ad12         bsr    LinSci_RxOff
  9CBE:  ad14         bsr    LinSci_TxBreak
  9CC0:  2005         bra    L9CC7
L9CC2:
  9CC2:  3fbc         clr    g_linDiagState
  9CC4:  6e29ba       mov    #$29, g_linT2
L9CC7:
  9CC7:  cc931e       jmp    LinCrit_Leave

;---------------------------------------------------------------
; LinSci_RxOn   [0x9CCA]   <- 98E0, 9C89, 9D3E, 9D9A, 9DAF, 9E07, 9E0F, 9E53
;---------------------------------------------------------------
  9CCA:  6e80b7       mov    #$80, g_linRxState
  9CCD:  cc9305       jmp    LinTick_restore

;---------------------------------------------------------------
; LinSci_RxOff   [0x9CD0]   <- 9CBC
;---------------------------------------------------------------
  9CD0:  6effb7       mov    #$FF, g_linRxState
  9CD3:  81           rts    

;---------------------------------------------------------------
; LinSci_TxBreak   [0x9CD4]   <- 98DB, 9CBE
;---------------------------------------------------------------
  9CD4:  5f           clrx   
  9CD5:  a680         lda    #$80
  9CD7:  cd9185       jsr    Sci_SendByte
  9CDA:  6effb7       mov    #$FF, g_linRxState
  9CDD:  81           rts    

;---------------------------------------------------------------
; LinDiag_Request   [0x9CDE]   <- 9AA1
;---------------------------------------------------------------
  9CDE:  4501d8       ldhx   #$01D8
  9CE1:  35b2         sthx   g_linBufPtr
  9CE3:  95           tsx    
  9CE4:  e602         lda    2,x
  9CE6:  62           nsa    
  9CE7:  a40f         and    #$0F
  9CE9:  b7b6         sta    g_linByteCnt
  9CEB:  3fb4         clr    g_linCrcH
  9CED:  3fb5         clr    g_linCrcL
  9CEF:  97           tax    
  9CF0:  8c           clrh   
  9CF1:  d6c1a2       lda    $C1A2,x
  9CF4:  c701d4       sta    $01D4
  9CF7:  6e23b1       mov    #$23, g_linTpState
  9CFA:  9ee603       lda    3,s
  9CFD:  a40c         and    #$0C
  9CFF:  a108         cmp    #$08
  9D01:  2622         bne    L9D25
  9D03:  3db6         tst    g_linByteCnt
  9D05:  2606         bne    L9D0D
  9D07:  5f           clrx   
  9D08:  a60b         lda    #$0B
  9D0A:  cd8dcf       jsr    LinErr_Set
L9D0D:
  9D0D:  55b2         ldhx   g_linBufPtr
  9D0F:  f6           lda    ,x
  9D10:  5f           clrx   
  9D11:  cd9185       jsr    Sci_SendByte
  9D14:  55b2         ldhx   g_linBufPtr
  9D16:  b6b5         lda    g_linCrcL
  9D18:  fb           add    ,x
  9D19:  5f           clrx   
  9D1A:  b7b5         sta    g_linCrcL
  9D1C:  4f           clra   
  9D1D:  b9b4         adc    g_linCrcH
  9D1F:  b7b4         sta    g_linCrcH
  9D21:  6e01b7       mov    #$01, g_linRxState
  9D24:  81           rts    
L9D25:
  9D25:  9ee603       lda    3,s
  9D28:  a40c         and    #$0C
  9D2A:  a104         cmp    #$04
  9D2C:  2610         bne    L9D3E
  9D2E:  3db6         tst    g_linByteCnt
  9D30:  2606         bne    L9D38
  9D32:  5f           clrx   
  9D33:  a60b         lda    #$0B
  9D35:  cd8dcf       jsr    LinErr_Set
L9D38:
  9D38:  6e08b7       mov    #$08, g_linRxState
  9D3B:  1eb6         bset   7, g_linByteCnt
  9D3D:  81           rts    
L9D3E:
  9D3E:  ad8a         bsr    LinSci_RxOn
  9D40:  6e0fb1       mov    #$0F, g_linTpState
  9D43:  81           rts    

;---------------------------------------------------------------
; LinCrc_Fold   [0x9D44]   <- 9DF2, 9E59
;---------------------------------------------------------------
  9D44:  a7fe         ais    #$FE
  9D46:  beb4         ldx    g_linCrcH
  9D48:  9eef02       stx    2,s
  9D4B:  95           tsx    
  9D4C:  7f           clr    ,x
  9D4D:  b6b5         lda    g_linCrcL
  9D4F:  eb01         add    1,x
  9D51:  b7b5         sta    g_linCrcL
  9D53:  4f           clra   
  9D54:  f9           adc    ,x
  9D55:  b7b4         sta    g_linCrcH
  9D57:  2706         beq    L9D5F
  9D59:  55b4         ldhx   g_linCrcH
  9D5B:  af01         aix    #$01
  9D5D:  35b4         sthx   g_linCrcH
L9D5F:
  9D5F:  a702         ais    #$02
  9D61:  81           rts    

;---------------------------------------------------------------
; Lin_RxByte   [0x9D62]   <- 91BF
;---------------------------------------------------------------
  9D62:  87           psha   
  9D63:  89           pshx   
  9D64:  6e43b9       mov    #$43, g_linT1
  9D67:  b6b7         lda    g_linRxState
  9D69:  41015f       cbeqa  #$01, L9DCB
  9D6C:  a102         cmp    #$02
  9D6E:  2603         bne    L9D73
  9D70:  cc9e0f       jmp    $9E0F
L9D73:
  9D73:  a108         cmp    #$08
  9D75:  2603         bne    L9D7A
  9D77:  cc9e2a       jmp    $9E2A
L9D7A:
  9D7A:  a109         cmp    #$09
  9D7C:  2603         bne    L9D81
  9D7E:  cc9e53       jmp    $9E53
L9D81:
  9D81:  a180         cmp    #$80
  9D83:  2603         bne    L9D88
  9D85:  cc9e72       jmp    $9E72
L9D88:
  9D88:  419018       cbeqa  #$90, L9DA3
  9D8B:  41b030       cbeqa  #$B0, L9DBE
  9D8E:  41ff09       cbeqa  #$FF, L9D9A
  9D91:  5f           clrx   
  9D92:  a60b         lda    #$0B
  9D94:  cd8dcf       jsr    LinErr_Set
  9D97:  cc9e72       jmp    $9E72
L9D9A:
  9D9A:  cd9cca       jsr    LinSci_RxOn
  9D9D:  cd99ea       jsr    Lin_GotoSleep2
  9DA0:  cc9e72       jmp    $9E72
L9DA3:
  9DA3:  95           tsx    
  9DA4:  e601         lda    1,x
  9DA6:  41550f       cbeqa  #$55, L9DB8
  9DA9:  5f           clrx   
  9DAA:  a603         lda    #$03
  9DAC:  cd9ba1       jsr    LinErr_Report
  9DAF:  cd9cca       jsr    LinSci_RxOn
  9DB2:  6e0fb1       mov    #$0F, g_linTpState
  9DB5:  cc9e72       jmp    $9E72
L9DB8:
  9DB8:  6eb0b7       mov    #$B0, g_linRxState
  9DBB:  cc9e72       jmp    $9E72
L9DBE:
  9DBE:  95           tsx    
  9DBF:  e601         lda    1,x
  9DC1:  c701d6       sta    $01D6
  9DC4:  5f           clrx   
  9DC5:  cd99ec       jsr    LinSched_OnHeader
  9DC8:  cc9e72       jmp    $9E72
L9DCB:
  9DCB:  55b2         ldhx   g_linBufPtr
  9DCD:  f6           lda    ,x
  9DCE:  95           tsx    
  9DCF:  e101         cmp    1,x
  9DD1:  262e         bne    L9E01
  9DD3:  3ab6         dec    g_linByteCnt
  9DD5:  271b         beq    L9DF2
  9DD7:  55b2         ldhx   g_linBufPtr
  9DD9:  af01         aix    #$01
  9DDB:  35b2         sthx   g_linBufPtr
  9DDD:  f6           lda    ,x
  9DDE:  5f           clrx   
  9DDF:  cd9185       jsr    Sci_SendByte
  9DE2:  55b2         ldhx   g_linBufPtr
  9DE4:  b6b5         lda    g_linCrcL
  9DE6:  fb           add    ,x
  9DE7:  5f           clrx   
  9DE8:  b7b5         sta    g_linCrcL
  9DEA:  4f           clra   
  9DEB:  b9b4         adc    g_linCrcH
  9DED:  b7b4         sta    g_linCrcH
  9DEF:  cc9e72       jmp    $9E72
L9DF2:
  9DF2:  cd9d44       jsr    LinCrc_Fold
  9DF5:  b6b5         lda    g_linCrcL
  9DF7:  43           coma   
  9DF8:  5f           clrx   
  9DF9:  cd9185       jsr    Sci_SendByte
  9DFC:  6e02b7       mov    #$02, g_linRxState
  9DFF:  2071         bra    L9E72
L9E01:
  9E01:  5f           clrx   
  9E02:  a611         lda    #$11
  9E04:  cd9ba1       jsr    LinErr_Report
  9E07:  cd9cca       jsr    LinSci_RxOn
  9E0A:  6e0fb1       mov    #$0F, g_linTpState
  9E0D:  2063         bra    L9E72
L9E0F:
  9E0F:  cd9cca       jsr    LinSci_RxOn
  9E12:  6e0fb1       mov    #$0F, g_linTpState
  9E15:  b6b5         lda    g_linCrcL
  9E17:  43           coma   
  9E18:  95           tsx    
  9E19:  e101         cmp    1,x
  9E1B:  2608         bne    L9E25
  9E1D:  5f           clrx   
  9E1E:  a602         lda    #$02
  9E20:  cd9ab6       jsr    LinDiag_Response
  9E23:  204d         bra    L9E72
L9E25:
  9E25:  5f           clrx   
  9E26:  a611         lda    #$11
  9E28:  2045         bra    L9E6F
L9E2A:
  9E2A:  1fb6         bclr   7, g_linByteCnt
  9E2C:  3db6         tst    g_linByteCnt
  9E2E:  2606         bne    L9E36
  9E30:  5f           clrx   
  9E31:  a60b         lda    #$0B
  9E33:  cd8dcf       jsr    LinErr_Set
L9E36:
  9E36:  b6b5         lda    g_linCrcL
  9E38:  95           tsx    
  9E39:  eb01         add    1,x
  9E3B:  b7b5         sta    g_linCrcL
  9E3D:  4f           clra   
  9E3E:  b9b4         adc    g_linCrcH
  9E40:  b7b4         sta    g_linCrcH
  9E42:  e601         lda    1,x
  9E44:  55b2         ldhx   g_linBufPtr
  9E46:  f7           sta    ,x
  9E47:  af01         aix    #$01
  9E49:  35b2         sthx   g_linBufPtr
  9E4B:  3bb624       dbnz   g_linByteCnt, L9E72
  9E4E:  6e09b7       mov    #$09, g_linRxState
  9E51:  201f         bra    L9E72
L9E53:
  9E53:  cd9cca       jsr    LinSci_RxOn
  9E56:  6e0fb1       mov    #$0F, g_linTpState
  9E59:  cd9d44       jsr    LinCrc_Fold
  9E5C:  b6b5         lda    g_linCrcL
  9E5E:  43           coma   
  9E5F:  95           tsx    
  9E60:  e101         cmp    1,x
  9E62:  2608         bne    L9E6C
  9E64:  5f           clrx   
  9E65:  a601         lda    #$01
  9E67:  cd9ab6       jsr    LinDiag_Response
  9E6A:  2006         bra    L9E72
L9E6C:
  9E6C:  5f           clrx   
  9E6D:  a614         lda    #$14
L9E6F:
  9E6F:  cd9ba1       jsr    LinErr_Report
L9E72:
  9E72:  a702         ais    #$02
  9E74:  81           rts    

;---------------------------------------------------------------
; Lin_TxByteOrErr   [0x9E75]   <- 91D3, 91F4
;---------------------------------------------------------------
  9E75:  87           psha   
  9E76:  89           pshx   
  9E77:  6e43b9       mov    #$43, g_linT1
  9E7A:  b6b7         lda    g_linRxState
  9E7C:  410135       cbeqa  #$01, L9EB4
  9E7F:  410232       cbeqa  #$02, L9EB4
  9E82:  a108         cmp    #$08
  9E84:  2748         beq    L9ECE
  9E86:  a109         cmp    #$09
  9E88:  2744         beq    L9ECE
  9E8A:  418019       cbeqa  #$80, L9EA6
  9E8D:  41901f       cbeqa  #$90, L9EAF
  9E90:  41b01c       cbeqa  #$B0, L9EAF
  9E93:  41ff08       cbeqa  #$FF, L9E9E
  9E96:  5f           clrx   
  9E97:  a60b         lda    #$0B
  9E99:  cd8dcf       jsr    LinErr_Set
  9E9C:  2052         bra    L9EF0
L9E9E:
  9E9E:  cd9cca       jsr    LinSci_RxOn
  9EA1:  cd99ea       jsr    Lin_GotoSleep2
  9EA4:  204a         bra    L9EF0
L9EA6:
  9EA6:  95           tsx    
  9EA7:  e601         lda    1,x
  9EA9:  a102         cmp    #$02
  9EAB:  2643         bne    L9EF0
  9EAD:  2012         bra    L9EC1
L9EAF:
  9EAF:  5f           clrx   
  9EB0:  a607         lda    #$07
  9EB2:  2003         bra    L9EB7
L9EB4:
  9EB4:  5f           clrx   
  9EB5:  a612         lda    #$12
L9EB7:
  9EB7:  cd9ba1       jsr    LinErr_Report
  9EBA:  9ee602       lda    2,s
  9EBD:  a102         cmp    #$02
  9EBF:  2629         bne    L9EEA
L9EC1:
  9EC1:  6e90b7       mov    #$90, g_linRxState
  9EC4:  a604         lda    #$04
  9EC6:  c701d4       sta    $01D4
  9EC9:  6e11b1       mov    #$11, g_linTpState
  9ECC:  2022         bra    L9EF0
L9ECE:
  9ECE:  95           tsx    
  9ECF:  e601         lda    1,x
  9ED1:  a102         cmp    #$02
  9ED3:  260f         bne    L9EE4
  9ED5:  5f           clrx   
  9ED6:  0fb604       brclr  7, g_linByteCnt, L9EDD
  9ED9:  a615         lda    #$15
  9EDB:  2002         bra    L9EDF
L9EDD:
  9EDD:  a613         lda    #$13
L9EDF:
  9EDF:  cd9ba1       jsr    LinErr_Report
  9EE2:  20dd         bra    L9EC1
L9EE4:
  9EE4:  5f           clrx   
  9EE5:  a613         lda    #$13
  9EE7:  cd9ba1       jsr    LinErr_Report
L9EEA:
  9EEA:  cd9cca       jsr    LinSci_RxOn
  9EED:  6e0fb1       mov    #$0F, g_linTpState
L9EF0:
  9EF0:  a702         ais    #$02
  9EF2:  81           rts    

;---------------------------------------------------------------
; LinLL_Enable   [0x9EF3]
;---------------------------------------------------------------
  9EF3:  c601e3       lda    g_llFlags
  9EF6:  a4fc         and    #$FC
  9EF8:  aa08         ora    #$08
  9EFA:  c701e3       sta    g_llFlags
  9EFD:  81           rts    

;---------------------------------------------------------------
; LinLL_Disable   [0x9EFE]
;---------------------------------------------------------------
  9EFE:  c601e3       lda    g_llFlags
  9F01:  a501         bit    #$01
  9F03:  270a         beq    L9F0F
  9F05:  a4fe         and    #$FE
  9F07:  c701e3       sta    g_llFlags
  9F0A:  5f           clrx   
  9F0B:  a611         lda    #$11
  9F0D:  ad31         bsr    LinLL_Start
L9F0F:
  9F0F:  81           rts    

;---------------------------------------------------------------
; LinLL_sub_9F10   [0x9F10]
;---------------------------------------------------------------
  9F10:  c601e7       lda    g_llStatusSaved
  9F13:  2a0f         bpl    L9F24
  9F15:  c601e3       lda    g_llFlags
  9F18:  a4f7         and    #$F7
  9F1A:  c701e3       sta    g_llFlags
  9F1D:  4501e7       ldhx   #$01E7
  9F20:  f6           lda    ,x
  9F21:  a47f         and    #$7F
  9F23:  f7           sta    ,x
L9F24:
  9F24:  81           rts    

;---------------------------------------------------------------
; LinLL_sub_9F25   [0x9F25]
;---------------------------------------------------------------
  9F25:  c601e3       lda    g_llFlags
  9F28:  a508         bit    #$08
  9F2A:  2602         bne    L9F2E
  9F2C:  2033         bra    LinLL_Abort
L9F2E:
  9F2E:  a640         lda    #$40
  9F30:  4501e6       ldhx   #$01E6
  9F33:  fb           add    ,x
  9F34:  f7           sta    ,x
  9F35:  3201e4       ldhx   g_llId
  9F38:  af01         aix    #$01
  9F3A:  9601e4       sthx   g_llId
  9F3D:  cc9fdb       jmp    LinLL_Dispatch

;---------------------------------------------------------------
; LinLL_Start   [0x9F40]   <- 9F0D
;---------------------------------------------------------------
  9F40:  87           psha   
  9F41:  89           pshx   
  9F42:  c601e6       lda    g_llStatus
  9F45:  c701e7       sta    g_llStatusSaved
  9F48:  a67f         lda    #$7F
  9F4A:  c701e6       sta    g_llStatus
  9F4D:  95           tsx    
  9F4E:  e601         lda    1,x
  9F50:  c701e8       sta    $01E8
  9F53:  a603         lda    #$03
  9F55:  c701e5       sta    $01E5
  9F58:  4f           clra   
  9F59:  c701e4       sta    g_llId
  9F5C:  ad7d         bsr    LinLL_Dispatch
  9F5E:  a702         ais    #$02
  9F60:  81           rts    

;---------------------------------------------------------------
; LinLL_Abort   [0x9F61]
;---------------------------------------------------------------
  9F61:  c601e3       lda    g_llFlags
  9F64:  a4fb         and    #$FB
  9F66:  c701e3       sta    g_llFlags
  9F69:  2070         bra    LinLL_Dispatch

;---------------------------------------------------------------
; LinLL_Classify   [0x9F6B]   <- 9462, 94E6
;---------------------------------------------------------------
  9F6B:  87           psha   
  9F6C:  89           pshx   
  9F6D:  87           psha   
  9F6E:  95           tsx    
  9F6F:  7f           clr    ,x
  9F70:  c601e3       lda    g_llFlags
  9F73:  a502         bit    #$02
  9F75:  262d         bne    L9FA4
  9F77:  9ece05       ldhx   5,x
  9F7A:  9601e4       sthx   g_llId
  9F7D:  95           tsx    
  9F7E:  e602         lda    2,x
  9F80:  a17e         cmp    #$7E
  9F82:  2607         bne    L9F8B
  9F84:  c601e3       lda    g_llFlags
  9F87:  a4fb         and    #$FB
  9F89:  2005         bra    L9F90
L9F8B:
  9F8B:  c601e3       lda    g_llFlags
  9F8E:  aa04         ora    #$04
L9F90:
  9F90:  c701e3       sta    g_llFlags
  9F93:  9efe06       ldhx   6,s
  9F96:  650041       cphx   #$0041
  9F99:  2409         bcc    L9FA4
  9F9B:  aa02         ora    #$02
  9F9D:  c701e3       sta    g_llFlags
  9FA0:  a601         lda    #$01
  9FA2:  95           tsx    
  9FA3:  f7           sta    ,x
L9FA4:
  9FA4:  95           tsx    
  9FA5:  f6           lda    ,x
  9FA6:  a703         ais    #$03
  9FA8:  81           rts    

;---------------------------------------------------------------
; LinLL_OnError   [0x9FA9]   <- 9390, 9431, 948D, 94BF, 95B2, 960A
;---------------------------------------------------------------
  9FA9:  87           psha   
  9FAA:  89           pshx   
  9FAB:  c601e6       lda    g_llStatus
  9FAE:  a540         bit    #$40
  9FB0:  2614         bne    L9FC6
  9FB2:  95           tsx    
  9FB3:  6d01         tst    1,x
  9FB5:  260f         bne    L9FC6
  9FB7:  3201e4       ldhx   g_llId
  9FBA:  afff         aix    #$FF
  9FBC:  9601e4       sthx   g_llId
  9FBF:  c601e3       lda    g_llFlags
  9FC2:  aa09         ora    #$09
  9FC4:  2005         bra    L9FCB
L9FC6:
  9FC6:  c601e3       lda    g_llFlags
  9FC9:  a4fd         and    #$FD
L9FCB:
  9FCB:  c701e3       sta    g_llFlags
  9FCE:  a702         ais    #$02
  9FD0:  81           rts    

;---------------------------------------------------------------
; LinLL_OnIdle   [0x9FD1]   <- 937D, 9449, 94D0, 97C3, 97F8, 9822
;---------------------------------------------------------------
  9FD1:  c601e3       lda    g_llFlags
  9FD4:  a4fd         and    #$FD
  9FD6:  c701e3       sta    g_llFlags
  9FD9:  4f           clra   
  9FDA:  81           rts    

;---------------------------------------------------------------
; LinLL_Dispatch   [0x9FDB]   <- 9F5C
;---------------------------------------------------------------
  9FDB:  c601e3       lda    g_llFlags
  9FDE:  a504         bit    #$04
  9FE0:  2709         beq    L9FEB
  9FE2:  c601e5       lda    $01E5
  9FE5:  ce01e4       ldx    g_llId
  9FE8:  cc9396       jmp    LinTp_StartTimer
L9FEB:
  9FEB:  5f           clrx   
  9FEC:  4f           clra   
  9FED:  20e2         bra    LinLL_OnIdle

;---------------------------------------------------------------
; LinTp_ResetCnt   [0x9FEF]
;---------------------------------------------------------------
  9FEF:  4f           clra   
  9FF0:  c70227       sta    $0227
  9FF3:  c70226       sta    $0226
  9FF6:  81           rts    

;---------------------------------------------------------------
; mem_fill_down   [0x9FF7]   <- 9694, 974F
;---------------------------------------------------------------
  9FF7:  87           psha   
  9FF8:  89           pshx   
  9FF9:  2016         bra    LA011
L9FFB:
  9FFB:  afff         aix    #$FF
  9FFD:  9eff07       sthx   7,s
  A000:  95           tsx    
  A001:  e601         lda    1,x
  A003:  eb07         add    7,x
  A005:  87           psha   
  A006:  f6           lda    ,x
  A007:  95           tsx    
  A008:  e907         adc    7,x
  A00A:  87           psha   
  A00B:  8a           pulh   
  A00C:  88           pulx   
  A00D:  9ee606       lda    6,s
  A010:  f7           sta    ,x
LA011:
  A011:  9efe07       ldhx   7,s
  A014:  26e5         bne    L9FFB
  A016:  a702         ais    #$02
  A018:  81           rts    

;---------------------------------------------------------------
; mem_set   [0xA019]   <- 9851, 985F
;---------------------------------------------------------------
  A019:  8b           pshh   
  A01A:  87           psha   
  A01B:  89           pshx   
  A01C:  87           psha   
  A01D:  89           pshx   
  A01E:  8a           pulh   
  A01F:  88           pulx   
  A020:  2003         bra    LA025
LA022:
  A022:  7f           clr    ,x
  A023:  af01         aix    #$01
LA025:
  A025:  9ee607       lda    7,s
  A028:  2706         beq    LA030
  A02A:  4a           deca   
  A02B:  9ee707       sta    7,s
  A02E:  20f2         bra    LA022
LA030:
  A030:  9ee606       lda    6,s
  A033:  270b         beq    LA040
  A035:  4a           deca   
  A036:  9ee706       sta    6,s
  A039:  4f           clra   
  A03A:  4a           deca   
  A03B:  9ee707       sta    7,s
  A03E:  20e2         bra    LA022
LA040:
  A040:  88           pulx   
  A041:  86           pula   
  A042:  8a           pulh   
  A043:  81           rts    
;   .... data/gap A044-A045 ....

;---------------------------------------------------------------
; mem_copy   [0xA045]   <- 9486, 950D, 9594, 95D7, 9671, 96CB, 972E, 9781
;---------------------------------------------------------------
  A045:  8b           pshh   
  A046:  87           psha   
  A047:  89           pshx   
  A048:  201a         bra    LA064
LA04A:
  A04A:  9eee06       ldx    6,s
  A04D:  89           pshx   
  A04E:  8a           pulh   
  A04F:  9eee07       ldx    7,s
  A052:  f6           lda    ,x
  A053:  af01         aix    #$01
  A055:  9eef07       stx    7,s
  A058:  8b           pshh   
  A059:  88           pulx   
  A05A:  9eef06       stx    6,s
  A05D:  8a           pulh   
  A05E:  88           pulx   
  A05F:  f7           sta    ,x
  A060:  af01         aix    #$01
  A062:  89           pshx   
  A063:  8b           pshh   
LA064:
  A064:  9eee09       ldx    9,s
  A067:  2706         beq    LA06F
  A069:  5a           decx   
  A06A:  9eef09       stx    9,s
  A06D:  20db         bra    LA04A
LA06F:
  A06F:  9ee608       lda    8,s
  A072:  270a         beq    LA07E
  A074:  4a           deca   
  A075:  9ee708       sta    8,s
  A078:  5a           decx   
  A079:  9eef09       stx    9,s
  A07C:  20cc         bra    LA04A
LA07E:
  A07E:  88           pulx   
  A07F:  86           pula   
  A080:  8a           pulh   
  A081:  81           rts    
;   .... data/gap A082-A083 ....

;---------------------------------------------------------------
; mem_copy_far   [0xA083]   <- 997D, 99BB
;---------------------------------------------------------------
  A083:  87           psha   
  A084:  89           pshx   
  A085:  2021         bra    LA0A8
LA087:
  A087:  afff         aix    #$FF
  A089:  9eff07       sthx   7,s
  A08C:  95           tsx    
  A08D:  e601         lda    1,x
  A08F:  eb07         add    7,x
  A091:  87           psha   
  A092:  f6           lda    ,x
  A093:  95           tsx    
  A094:  e907         adc    7,x
  A096:  87           psha   
  A097:  e606         lda    6,x
  A099:  eb08         add    8,x
  A09B:  87           psha   
  A09C:  e605         lda    5,x
  A09E:  95           tsx    
  A09F:  e909         adc    9,x
  A0A1:  87           psha   
  A0A2:  8a           pulh   
  A0A3:  88           pulx   
  A0A4:  f6           lda    ,x
  A0A5:  8a           pulh   
  A0A6:  88           pulx   
  A0A7:  f7           sta    ,x
LA0A8:
  A0A8:  9efe07       ldhx   7,s
  A0AB:  26da         bne    LA087
  A0AD:  a702         ais    #$02
  A0AF:  81           rts    

;---------------------------------------------------------------
; sem_take   [0xA0B0]
;---------------------------------------------------------------
  A0B0:  87           psha   
  A0B1:  c60226       lda    $0226
  A0B4:  260b         bne    LA0C1
  A0B6:  95           tsx    
  A0B7:  9f           txa    
  A0B8:  8b           pshh   
  A0B9:  88           pulx   
  A0BA:  ad1d         bsr    crit_store
  A0BC:  95           tsx    
  A0BD:  f6           lda    ,x
  A0BE:  c70227       sta    $0227
LA0C1:
  A0C1:  450226       ldhx   #$0226
  A0C4:  7c           inc    ,x
  A0C5:  8a           pulh   
  A0C6:  81           rts    

;---------------------------------------------------------------
; sem_give   [0xA0C7]
;---------------------------------------------------------------
  A0C7:  87           psha   
  A0C8:  450226       ldhx   #$0226
  A0CB:  7a           dec    ,x
  A0CC:  f6           lda    ,x
  A0CD:  2608         bne    LA0D7
  A0CF:  c60227       lda    $0227
  A0D2:  95           tsx    
  A0D3:  f7           sta    ,x
  A0D4:  5f           clrx   
  A0D5:  ad09         bsr    crit_restore
LA0D7:
  A0D7:  8a           pulh   
  A0D8:  81           rts    

;---------------------------------------------------------------
; crit_store   [0xA0D9]   <- A0BA
;---------------------------------------------------------------
  A0D9:  89           pshx   
  A0DA:  8a           pulh   
  A0DB:  97           tax    
  A0DC:  85           tpa    
  A0DD:  9b           sei    
  A0DE:  f7           sta    ,x
  A0DF:  81           rts    

;---------------------------------------------------------------
; crit_restore   [0xA0E0]   <- A0D5
;---------------------------------------------------------------
  A0E0:  a408         and    #$08
  A0E2:  2601         bne    LA0E5
  A0E4:  84           tap    
LA0E5:
  A0E5:  81           rts    

;---------------------------------------------------------------
; Sensor_Init   [0xA0E6]   <- 87A0
;---------------------------------------------------------------
  A0E6:  a641         lda    #$41
  A0E8:  c70016       sta    ADC1CFG
  A0EB:  4f           clra   
  A0EC:  c70011       sta    ADC1SC2
  A0EF:  a60f         lda    #$0F
  A0F1:  c70017       sta    APCTL1
  A0F4:  44           lsra   
  A0F5:  c70018       sta    APCTL2
  A0F8:  4f           clra   
  A0F9:  c70019       sta    APCTL3
  A0FC:  c70015       sta    ADC1CVL
  A0FF:  c70014       sta    ADC1CVH
  A102:  81           rts    

;---------------------------------------------------------------
; Adc_Read   [0xA103]   <- A8C9, A8D8, A920, A929, A95A, A96A, A988, AB66
;---------------------------------------------------------------
  A103:  87           psha   
  A104:  89           pshx   
  A105:  87           psha   
  A106:  a41f         and    #$1F
  A108:  95           tsx    
  A109:  e702         sta    2,x
  A10B:  411f18       cbeqa  #$1F, LA126
  A10E:  c70010       sta    ADC1SC1
  A111:  5f           clrx   
  A112:  a602         lda    #$02
  A114:  cdb653       jsr    Delay_Loop
  A117:  2001         bra    LA11A
LA119:
  A119:  7f           clr    ,x
LA11A:
  A11A:  c60010       lda    ADC1SC1
  A11D:  95           tsx    
  A11E:  2af9         bpl    LA119
  A120:  7f           clr    ,x
  A121:  c60013       lda    ADC1RL
  A124:  2005         bra    LA12B
LA126:
  A126:  c70010       sta    ADC1SC1
  A129:  a6ff         lda    #$FF
LA12B:
  A12B:  a703         ais    #$03
  A12D:  81           rts    

;---------------------------------------------------------------
; Ctrl_Init   [0xA12E]   <- 8794
;---------------------------------------------------------------
  A12E:  4f           clra   
  A12F:  c702b4       sta    $02B4
  A132:  c702b5       sta    $02B5
  A135:  4c           inca   
  A136:  c702b3       sta    $02B3
  A139:  81           rts    

;---------------------------------------------------------------
; Ctrl_sub_A13A   [0xA13A]   <- AA04, BA31, BA80
;---------------------------------------------------------------
  A13A:  a7fe         ais    #$FE
  A13C:  4f           clra   
  A13D:  c702b3       sta    $02B3
  A140:  c602b6       lda    g_supplyVoltage
  A143:  c1016c       cmp    $016C
  A146:  2507         bcs    LA14F
  A148:  c602b2       lda    $02B2
  A14B:  a103         cmp    #$03
  A14D:  247c         bcc    LA1CB
LA14F:
  A14F:  c6016a       lda    $016A
  A152:  4b47         dbnza  LA19B
  A154:  c602b6       lda    g_supplyVoltage
  A157:  ae5a         ldx    #$5A
  A159:  42           mul    
  A15A:  bfc6         stx    g_mulDiv_tmp
  A15C:  8c           clrh   
  A15D:  aea6         ldx    #$A6
  A15F:  cdc078       jsr    muls8b
  A162:  a01a         sub    #$1A
  A164:  2402         bcc    LA168
  A166:  3ac6         dec    g_mulDiv_tmp
LA168:
  A168:  97           tax    
  A169:  b6c6         lda    g_mulDiv_tmp
  A16B:  87           psha   
  A16C:  8a           pulh   
  A16D:  a640         lda    #$40
  A16F:  b7c6         sta    g_mulDiv_tmp
  A171:  4f           clra   
  A172:  cdc127       jsr    div16
  A175:  ce02b2       ldx    $02B2
  A178:  8c           clrh   
  A179:  cdc0cb       jsr    mul16
  A17C:  95           tsx    
  A17D:  e701         sta    1,x
  A17F:  bec6         ldx    g_mulDiv_tmp
  A181:  9eef01       stx    1,s
  A184:  cdc174       jsr    ldiv_init
  A187:  45c1f5       ldhx   #$C1F5
  A18A:  cdc0f9       jsr    cmp32
  A18D:  9104         blt    LA193
  A18F:  a6c8         lda    #$C8
  A191:  2044         bra    LA1D7
LA193:
  A193:  9efe01       ldhx   1,s
  A196:  9602b4       sthx   $02B4
  A199:  2028         bra    LA1C3
LA19B:
  A19B:  c602b1       lda    $02B1
  A19E:  4b18         dbnza  LA1B8
  A1A0:  c602b6       lda    g_supplyVoltage
  A1A3:  c1016d       cmp    $016D
  A1A6:  241b         bcc    LA1C3
  A1A8:  ce02b2       ldx    $02B2
  A1AB:  58           lslx   
  A1AC:  4f           clra   
  A1AD:  c702b5       sta    $02B5
  A1B0:  cf02b4       stx    $02B4
  A1B3:  c702b1       sta    $02B1
  A1B6:  200b         bra    LA1C3
LA1B8:
  A1B8:  ce02b2       ldx    $02B2
  A1BB:  58           lslx   
  A1BC:  4f           clra   
  A1BD:  c702b5       sta    $02B5
  A1C0:  cf02b4       stx    $02B4
LA1C3:
  A1C3:  a601         lda    #$01
  A1C5:  c702b3       sta    $02B3
  A1C8:  a702         ais    #$02
  A1CA:  81           rts    
LA1CB:
  A1CB:  a601         lda    #$01
  A1CD:  c702b1       sta    $02B1
  A1D0:  c6028f       lda    $028F
  A1D3:  4b08         dbnza  LA1DD
  A1D5:  a604         lda    #$04
LA1D7:
  A1D7:  c702b4       sta    $02B4
  A1DA:  4f           clra   
  A1DB:  2004         bra    LA1E1
LA1DD:
  A1DD:  4f           clra   
  A1DE:  c702b4       sta    $02B4
LA1E1:
  A1E1:  c702b5       sta    $02B5
  A1E4:  20dd         bra    LA1C3

;---------------------------------------------------------------
; Ctrl_Start   [0xA1E6]   <- 87B5
;---------------------------------------------------------------
  A1E6:  87           psha   
  A1E7:  4f           clra   
  A1E8:  c70238       sta    $0238
  A1EB:  c70237       sta    $0237
  A1EE:  c7023a       sta    $023A
  A1F1:  c70239       sta    $0239
  A1F4:  c70236       sta    $0236
  A1F7:  c70235       sta    $0235
  A1FA:  c70234       sta    $0234
  A1FD:  c70233       sta    $0233
  A200:  c70232       sta    $0232
  A203:  c70231       sta    $0231
  A206:  c7022f       sta    $022F
  A209:  c70230       sta    $0230
  A20C:  c7023c       sta    $023C
  A20F:  c7023d       sta    $023D
  A212:  c7023b       sta    $023B
  A215:  cda874       jsr    Motor_sub_A874
  A218:  cda91b       jsr    Motor_sub_A91B
  A21B:  95           tsx    
  A21C:  f7           sta    ,x
  A21D:  2612         bne    LA231
  A21F:  a60b         lda    #$0B
  A221:  c702a8       sta    $02A8
  A224:  a601         lda    #$01
  A226:  c7029b       sta    $029B
  A229:  c7029c       sta    $029C
  A22C:  a60b         lda    #$0B
  A22E:  c7023b       sta    $023B
LA231:
  A231:  cda8b6       jsr    Motor_sub_A8B6
  A234:  4b12         dbnza  LA248
  A236:  a607         lda    #$07
  A238:  c702a8       sta    $02A8
  A23B:  a601         lda    #$01
  A23D:  c7029b       sta    $029B
  A240:  c7023c       sta    $023C
  A243:  a60b         lda    #$0B
  A245:  c7023b       sta    $023B
LA248:
  A248:  c60172       lda    $0172
  A24B:  ae64         ldx    #$64
  A24D:  42           mul    
  A24E:  c7022e       sta    $022E
  A251:  cf022d       stx    $022D
  A254:  8a           pulh   
  A255:  81           rts    

;---------------------------------------------------------------
; Ctrl_Task   [0xA256]   <- 88B4
;---------------------------------------------------------------
  A256:  ad02         bsr    Ctrl_Step
  A258:  2016         bra    LA270

;---------------------------------------------------------------
; Ctrl_Step   [0xA25A]   <- Ctrl_Task
;---------------------------------------------------------------
  A25A:  32022b       ldhx   $022B
  A25D:  65ffff       cphx   #$FFFF
  A260:  2406         bcc    LA268
  A262:  af01         aix    #$01
  A264:  96022b       sthx   $022B
  A267:  81           rts    
LA268:
  A268:  4f           clra   
  A269:  c7022b       sta    $022B
  A26C:  c7022c       sta    $022C
  A26F:  81           rts    
LA270:
  A270:  87           psha   
  A271:  c6023b       lda    $023B
  A274:  a10c         cmp    #$0C
  A276:  2503         bcs    LA27B
  A278:  cca5a3       jmp    $A5A3
LA27B:
  A27B:  cdc0e6       jsr    switch_jump
         ; switch: 0->LA299  1->LA2A4  2->LA305  3->LA35C  4->LA3AE  5->LA3FE  6->LA446  7->LA482  8->LA47F  9->LA4F4  10->LA533  11->LA570
;   .... data/gap A296-A299 ....
LA299:
  A299:  cda874       jsr    Motor_sub_A874
  A29C:  a601         lda    #$01
  A29E:  c7023b       sta    $023B
  A2A1:  cca5aa       jmp    $A5AA
LA2A4:
  A2A4:  c602b6       lda    g_supplyVoltage
  A2A7:  5f           clrx   
  A2A8:  cda64e       jsr    $A64E
  A2AB:  95           tsx    
  A2AC:  f7           sta    ,x
  A2AD:  4b4d         dbnza  LA2FC
  A2AF:  c60295       lda    $0295
  A2B2:  4b2e         dbnza  LA2E2
  A2B4:  c60294       lda    $0294
  A2B7:  4b29         dbnza  LA2E2
  A2B9:  c6029b       lda    $029B
  A2BC:  2624         bne    LA2E2
  A2BE:  c60291       lda    $0291
  A2C1:  270b         beq    LA2CE
  A2C3:  c60292       lda    $0292
  A2C6:  ab0a         add    #$0A
  A2C8:  5f           clrx   
  A2C9:  cda79f       jsr    $A79F
  A2CC:  2009         bra    LA2D7
LA2CE:
  A2CE:  a60f         lda    #$0F
  A2D0:  c7022c       sta    $022C
  A2D3:  4f           clra   
  A2D4:  c7022b       sta    $022B
LA2D7:
  A2D7:  a602         lda    #$02
  A2D9:  c7023b       sta    $023B
  A2DC:  cda5ad       jsr    $A5AD
LA2DF:
  A2DF:  cca5aa       jmp    $A5AA
LA2E2:
  A2E2:  c60296       lda    $0296
  A2E5:  4b0a         dbnza  LA2F1
  A2E7:  c6022a       lda    $022A
  A2EA:  2605         bne    LA2F1
  A2EC:  a607         lda    #$07
  A2EE:  c7023b       sta    $023B
LA2F1:
  A2F1:  c60296       lda    $0296
  A2F4:  26e9         bne    LA2DF
  A2F6:  c7022a       sta    $022A
  A2F9:  cca5aa       jmp    $A5AA
LA2FC:
  A2FC:  cda874       jsr    Motor_sub_A874
  A2FF:  cda669       jsr    $A669
LA302:
  A302:  cca5aa       jmp    $A5AA
LA305:
  A305:  c602b6       lda    g_supplyVoltage
  A308:  5f           clrx   
  A309:  cda64e       jsr    $A64E
  A30C:  95           tsx    
  A30D:  f7           sta    ,x
  A30E:  4b43         dbnza  LA353
  A310:  c6029b       lda    $029B
  A313:  2633         bne    LA348
  A315:  32022b       ldhx   $022B
  A318:  65000f       cphx   #$000F
  A31B:  240d         bcc    LA32A
  A31D:  c60291       lda    $0291
  A320:  99           sec    
  A321:  c2022c       sbc    $022C
  A324:  4f           clra   
  A325:  c2022b       sbc    $022B
  A328:  24d8         bcc    LA302
LA32A:
  A32A:  c60293       lda    $0293
  A32D:  a40f         and    #$0F
  A32F:  ab32         add    #$32
  A331:  8c           clrh   
  A332:  97           tax    
  A333:  d60120       lda    g_cfg,x
  A336:  c70229       sta    $0229
  A339:  5f           clrx   
  A33A:  cda7fa       jsr    $A7FA
  A33D:  cda5ad       jsr    $A5AD
  A340:  a603         lda    #$03
  A342:  c7023b       sta    $023B
  A345:  cca5aa       jmp    $A5AA
LA348:
  A348:  a60b         lda    #$0B
  A34A:  c7023b       sta    $023B
  A34D:  cda874       jsr    Motor_sub_A874
  A350:  cca5aa       jmp    $A5AA
LA353:
  A353:  cda874       jsr    Motor_sub_A874
  A356:  cda669       jsr    $A669
LA359:
  A359:  cca5aa       jmp    $A5AA
LA35C:
  A35C:  c602b6       lda    g_supplyVoltage
  A35F:  5f           clrx   
  A360:  cda64e       jsr    $A64E
  A363:  95           tsx    
  A364:  f7           sta    ,x
  A365:  4b3e         dbnza  LA3A5
  A367:  c60151       lda    $0151
  A36A:  5f           clrx   
  A36B:  48           lsla   
  A36C:  59           rolx   
  A36D:  48           lsla   
  A36E:  59           rolx   
  A36F:  99           sec    
  A370:  c2022c       sbc    $022C
  A373:  9f           txa    
  A374:  c2022b       sbc    $022B
  A377:  2405         bcc    LA37E
  A379:  c60151       lda    $0151
  A37C:  2610         bne    LA38E
LA37E:
  A37E:  c60295       lda    $0295
  A381:  270b         beq    LA38E
  A383:  c60294       lda    $0294
  A386:  2706         beq    LA38E
  A388:  c6029b       lda    $029B
  A38B:  4a           deca   
  A38C:  26cb         bne    LA359
LA38E:
  A38E:  cda874       jsr    Motor_sub_A874
  A391:  5f           clrx   
  A392:  a6fa         lda    #$FA
  A394:  cdb653       jsr    Delay_Loop
  A397:  cda855       jsr    $A855
  A39A:  cda5ad       jsr    $A5AD
  A39D:  a604         lda    #$04
  A39F:  c7023b       sta    $023B
  A3A2:  cca5aa       jmp    $A5AA
LA3A5:
  A3A5:  cda874       jsr    Motor_sub_A874
  A3A8:  cda669       jsr    $A669
LA3AB:
  A3AB:  cca5aa       jmp    $A5AA
LA3AE:
  A3AE:  c602b6       lda    g_supplyVoltage
  A3B1:  5f           clrx   
  A3B2:  cda64e       jsr    $A64E
  A3B5:  95           tsx    
  A3B6:  f7           sta    ,x
  A3B7:  4b3f         dbnza  LA3F8
  A3B9:  cda894       jsr    $A894
  A3BC:  95           tsx    
  A3BD:  f7           sta    ,x
  A3BE:  2718         beq    LA3D8
  A3C0:  a101         cmp    #$01
  A3C2:  27e7         beq    LA3AB
  A3C4:  a102         cmp    #$02
  A3C6:  2605         bne    LA3CD
  A3C8:  a601         lda    #$01
  A3CA:  c7023d       sta    $023D
LA3CD:
  A3CD:  a60b         lda    #$0B
  A3CF:  c7023b       sta    $023B
  A3D2:  cda874       jsr    Motor_sub_A874
  A3D5:  cca5aa       jmp    $A5AA
LA3D8:
  A3D8:  32022b       ldhx   $022B
  A3DB:  650032       cphx   #$0032
  A3DE:  250b         bcs    LA3EB
  A3E0:  cda874       jsr    Motor_sub_A874
  A3E3:  a606         lda    #$06
  A3E5:  c7023b       sta    $023B
LA3E8:
  A3E8:  cca5aa       jmp    $A5AA
LA3EB:
  A3EB:  c60295       lda    $0295
  A3EE:  26f8         bne    LA3E8
  A3F0:  a605         lda    #$05
  A3F2:  c7023b       sta    $023B
  A3F5:  cca5aa       jmp    $A5AA
LA3F8:
  A3F8:  cda669       jsr    $A669
  A3FB:  cca5aa       jmp    $A5AA
LA3FE:
  A3FE:  c602b6       lda    g_supplyVoltage
  A401:  5f           clrx   
  A402:  cda64e       jsr    $A64E
  A405:  95           tsx    
  A406:  f7           sta    ,x
  A407:  4b34         dbnza  LA43D
  A409:  c60295       lda    $0295
  A40C:  4b1d         dbnza  LA42B
  A40E:  cda874       jsr    Motor_sub_A874
  A411:  5f           clrx   
  A412:  a6fa         lda    #$FA
  A414:  cdb653       jsr    Delay_Loop
  A417:  c60292       lda    $0292
  A41A:  ab0a         add    #$0A
  A41C:  5f           clrx   
  A41D:  cda79f       jsr    $A79F
  A420:  cda5ad       jsr    $A5AD
  A423:  a602         lda    #$02
  A425:  c7023b       sta    $023B
LA428:
  A428:  cca5aa       jmp    $A5AA
LA42B:
  A42B:  32022b       ldhx   $022B
  A42E:  650032       cphx   #$0032
  A431:  25f5         bcs    LA428
  A433:  cda874       jsr    Motor_sub_A874
  A436:  4f           clra   
  A437:  c7023b       sta    $023B
  A43A:  cca5aa       jmp    $A5AA
LA43D:
  A43D:  cda874       jsr    Motor_sub_A874
  A440:  cda669       jsr    $A669
  A443:  cca5aa       jmp    $A5AA
LA446:
  A446:  c602b6       lda    g_supplyVoltage
  A449:  5f           clrx   
  A44A:  cda64e       jsr    $A64E
  A44D:  95           tsx    
  A44E:  f7           sta    ,x
  A44F:  4b28         dbnza  LA479
  A451:  c60295       lda    $0295
  A454:  2609         bne    LA45F
  A456:  c7023b       sta    $023B
  A459:  cda874       jsr    Motor_sub_A874
LA45C:
  A45C:  cca5aa       jmp    $A5AA
LA45F:
  A45F:  c60296       lda    $0296
  A462:  4b0a         dbnza  LA46E
  A464:  c6022a       lda    $022A
  A467:  2605         bne    LA46E
  A469:  a607         lda    #$07
  A46B:  c7023b       sta    $023B
LA46E:
  A46E:  c60296       lda    $0296
  A471:  26e9         bne    LA45C
  A473:  c7022a       sta    $022A
  A476:  cca5aa       jmp    $A5AA
LA479:
  A479:  cda874       jsr    Motor_sub_A874
  A47C:  cda669       jsr    $A669
LA47F:
  A47F:  cca5aa       jmp    $A5AA
LA482:
  A482:  c602b6       lda    g_supplyVoltage
  A485:  5f           clrx   
  A486:  cda64e       jsr    $A64E
  A489:  95           tsx    
  A48A:  f7           sta    ,x
  A48B:  4b61         dbnza  LA4EE
  A48D:  c6023c       lda    $023C
  A490:  262e         bne    LA4C0
  A492:  cda8b6       jsr    Motor_sub_A8B6
  A495:  95           tsx    
  A496:  f7           sta    ,x
  A497:  4b27         dbnza  LA4C0
  A499:  c6023a       lda    $023A
  A49C:  a102         cmp    #$02
  A49E:  261c         bne    LA4BC
  A4A0:  cda874       jsr    Motor_sub_A874
  A4A3:  a60b         lda    #$0B
  A4A5:  c7023b       sta    $023B
  A4A8:  a601         lda    #$01
  A4AA:  c7029b       sta    $029B
  A4AD:  4f           clra   
  A4AE:  c7023a       sta    $023A
  A4B1:  4c           inca   
  A4B2:  c7023c       sta    $023C
  A4B5:  a607         lda    #$07
  A4B7:  c702a8       sta    $02A8
  A4BA:  2004         bra    LA4C0
LA4BC:
  A4BC:  45023a       ldhx   #$023A
  A4BF:  7c           inc    ,x
LA4C0:
  A4C0:  cda894       jsr    $A894
  A4C3:  95           tsx    
  A4C4:  f7           sta    ,x
  A4C5:  a402         and    #$02
  A4C7:  270d         beq    LA4D6
  A4C9:  a601         lda    #$01
  A4CB:  c7023d       sta    $023D
  A4CE:  cda874       jsr    Motor_sub_A874
  A4D1:  a60b         lda    #$0B
  A4D3:  c7023b       sta    $023B
LA4D6:
  A4D6:  95           tsx    
  A4D7:  7d           tst    ,x
  A4D8:  260c         bne    LA4E6
  A4DA:  cda874       jsr    Motor_sub_A874
  A4DD:  a606         lda    #$06
  A4DF:  c7023b       sta    $023B
  A4E2:  4f           clra   
  A4E3:  c7023c       sta    $023C
LA4E6:
  A4E6:  a601         lda    #$01
  A4E8:  c7022a       sta    $022A
  A4EB:  cca5aa       jmp    $A5AA
LA4EE:
  A4EE:  cda669       jsr    $A669
LA4F1:
  A4F1:  cca5aa       jmp    $A5AA
LA4F4:
  A4F4:  c602b6       lda    g_supplyVoltage
  A4F7:  c1016d       cmp    $016D
  A4FA:  24f5         bcc    LA4F1
  A4FC:  c1016e       cmp    $016E
  A4FF:  241a         bcc    LA51B
  A501:  c60232       lda    $0232
  A504:  a102         cmp    #$02
  A506:  250c         bcs    LA514
  A508:  4f           clra   
  A509:  c70232       sta    $0232
  A50C:  a60a         lda    #$0A
  A50E:  c7023b       sta    $023B
  A511:  cca5aa       jmp    $A5AA
LA514:
  A514:  450232       ldhx   #$0232
  A517:  7c           inc    ,x
  A518:  cca5aa       jmp    $A5AA
LA51B:
  A51B:  c60231       lda    $0231
  A51E:  a102         cmp    #$02
  A520:  250b         bcs    LA52D
  A522:  4f           clra   
  A523:  c70231       sta    $0231
  A526:  a606         lda    #$06
  A528:  c7023b       sta    $023B
  A52B:  207d         bra    LA5AA
LA52D:
  A52D:  450231       ldhx   #$0231
  A530:  7c           inc    ,x
  A531:  2077         bra    LA5AA
LA533:
  A533:  c602b6       lda    g_supplyVoltage
  A536:  c1016f       cmp    $016F
  A539:  236f         bls    LA5AA
  A53B:  c1016c       cmp    $016C
  A53E:  2418         bcc    LA558
  A540:  c60234       lda    $0234
  A543:  a102         cmp    #$02
  A545:  250b         bcs    LA552
  A547:  4f           clra   
  A548:  c70234       sta    $0234
  A54B:  a606         lda    #$06
  A54D:  c7023b       sta    $023B
  A550:  2058         bra    LA5AA
LA552:
  A552:  450234       ldhx   #$0234
  A555:  7c           inc    ,x
  A556:  2052         bra    LA5AA
LA558:
  A558:  c60233       lda    $0233
  A55B:  a102         cmp    #$02
  A55D:  250b         bcs    LA56A
  A55F:  4f           clra   
  A560:  c70233       sta    $0233
  A563:  a609         lda    #$09
  A565:  c7023b       sta    $023B
  A568:  2040         bra    LA5AA
LA56A:
  A56A:  450233       ldhx   #$0233
  A56D:  7c           inc    ,x
  A56E:  203a         bra    LA5AA
LA570:
  A570:  c6029c       lda    $029C
  A573:  4b29         dbnza  LA59E
  A575:  cda91b       jsr    Motor_sub_A91B
  A578:  95           tsx    
  A579:  f7           sta    ,x
  A57A:  4b2e         dbnza  LA5AA
  A57C:  c60237       lda    $0237
  A57F:  a102         cmp    #$02
  A581:  2615         bne    LA598
  A583:  4f           clra   
  A584:  c702a8       sta    $02A8
  A587:  c7029b       sta    $029B
  A58A:  c7029c       sta    $029C
  A58D:  a606         lda    #$06
  A58F:  c7023b       sta    $023B
  A592:  4f           clra   
  A593:  c70237       sta    $0237
  A596:  2012         bra    LA5AA
LA598:
  A598:  450237       ldhx   #$0237
  A59B:  7c           inc    ,x
  A59C:  200c         bra    LA5AA
LA59E:
  A59E:  cda874       jsr    Motor_sub_A874
  A5A1:  2007         bra    LA5AA
LA5A3:
  A5A3:  cda874       jsr    Motor_sub_A874
  A5A6:  4f           clra   
  A5A7:  c7023b       sta    $023B
LA5AA:
  A5AA:  8a           pulh   
  A5AB:  81           rts    
;   .... data/gap A5AC-A5AD ....

;---------------------------------------------------------------
; sub_A5AD   [0xA5AD]   <- A2DC, A33D, A39A, A420
;---------------------------------------------------------------
  A5AD:  4f           clra   
  A5AE:  c7022b       sta    $022B
  A5B1:  c7022c       sta    $022C
  A5B4:  81           rts    

;---------------------------------------------------------------
; MotorPos_Task   [0xA5B5]   <- 8935
;---------------------------------------------------------------
  A5B5:  87           psha   
  A5B6:  cda99a       jsr    $A99A
  A5B9:  95           tsx    
  A5BA:  f7           sta    ,x
  A5BB:  4b36         dbnza  LA5F3
  A5BD:  c6029a       lda    $029A
  A5C0:  a102         cmp    #$02
  A5C2:  262f         bne    LA5F3
  A5C4:  c6029b       lda    $029B
  A5C7:  262a         bne    LA5F3
  A5C9:  cda91b       jsr    Motor_sub_A91B
  A5CC:  95           tsx    
  A5CD:  f7           sta    ,x
  A5CE:  2623         bne    LA5F3
  A5D0:  c60238       lda    $0238
  A5D3:  a102         cmp    #$02
  A5D5:  2618         bne    LA5EF
  A5D7:  a60b         lda    #$0B
  A5D9:  c702a8       sta    $02A8
  A5DC:  a601         lda    #$01
  A5DE:  c7029b       sta    $029B
  A5E1:  c7029c       sta    $029C
  A5E4:  a60b         lda    #$0B
  A5E6:  c7023b       sta    $023B
  A5E9:  4f           clra   
  A5EA:  c70238       sta    $0238
  A5ED:  2004         bra    LA5F3
LA5EF:
  A5EF:  450238       ldhx   #$0238
  A5F2:  7c           inc    ,x
LA5F3:
  A5F3:  c6023d       lda    $023D
  A5F6:  4b0e         dbnza  LA606
  A5F8:  c6029b       lda    $029B
  A5FB:  2609         bne    LA606
  A5FD:  a603         lda    #$03
  A5FF:  c702a8       sta    $02A8
  A602:  44           lsra   
  A603:  c7029b       sta    $029B
LA606:
  A606:  8a           pulh   
  A607:  81           rts    

;---------------------------------------------------------------
; sub_A608   [0xA608]   <- A682
;---------------------------------------------------------------
  A608:  87           psha   
  A609:  89           pshx   
  A60A:  87           psha   
  A60B:  95           tsx    
  A60C:  7f           clr    ,x
  A60D:  c1016e       cmp    $016E
  A610:  2415         bcc    LA627
  A612:  c60235       lda    $0235
  A615:  a102         cmp    #$02
  A617:  2506         bcs    LA61F
  A619:  4f           clra   
  A61A:  c70235       sta    $0235
  A61D:  2004         bra    LA623
LA61F:
  A61F:  450235       ldhx   #$0235
  A622:  7c           inc    ,x
LA623:
  A623:  a601         lda    #$01
  A625:  95           tsx    
  A626:  f7           sta    ,x
LA627:
  A627:  f6           lda    ,x
  A628:  a703         ais    #$03
  A62A:  81           rts    

;---------------------------------------------------------------
; sub_A62B   [0xA62B]   <- A66E
;---------------------------------------------------------------
  A62B:  87           psha   
  A62C:  89           pshx   
  A62D:  87           psha   
  A62E:  95           tsx    
  A62F:  7f           clr    ,x
  A630:  c1016c       cmp    $016C
  A633:  2315         bls    LA64A
  A635:  c60236       lda    $0236
  A638:  a102         cmp    #$02
  A63A:  2506         bcs    LA642
  A63C:  4f           clra   
  A63D:  c70236       sta    $0236
  A640:  2004         bra    LA646
LA642:
  A642:  450236       ldhx   #$0236
  A645:  7c           inc    ,x
LA646:
  A646:  a601         lda    #$01
  A648:  95           tsx    
  A649:  f7           sta    ,x
LA64A:
  A64A:  f6           lda    ,x
  A64B:  a703         ais    #$03
  A64D:  81           rts    

;---------------------------------------------------------------
; sub_A64E   [0xA64E]   <- A2A8, A309, A360, A3B2, A402, A44A, A486
;---------------------------------------------------------------
  A64E:  87           psha   
  A64F:  89           pshx   
  A650:  87           psha   
  A651:  95           tsx    
  A652:  7f           clr    ,x
  A653:  c6016e       lda    $016E
  A656:  e102         cmp    2,x
  A658:  240b         bcc    LA665
  A65A:  e602         lda    2,x
  A65C:  c1016c       cmp    $016C
  A65F:  2404         bcc    LA665
  A661:  a601         lda    #$01
  A663:  2001         bra    LA666
LA665:
  A665:  4f           clra   
LA666:
  A666:  a703         ais    #$03
  A668:  81           rts    

;---------------------------------------------------------------
; sub_A669   [0xA669]   <- A2FF, A356, A3A8, A3F8, A440, A47C, A4EE
;---------------------------------------------------------------
  A669:  87           psha   
  A66A:  c602b6       lda    g_supplyVoltage
  A66D:  5f           clrx   
  A66E:  adbb         bsr    LA62B
  A670:  95           tsx    
  A671:  f7           sta    ,x
  A672:  4b0a         dbnza  LA67E
  A674:  c60236       lda    $0236
  A677:  2605         bne    LA67E
  A679:  a609         lda    #$09
  A67B:  c7023b       sta    $023B
LA67E:
  A67E:  c602b6       lda    g_supplyVoltage
  A681:  5f           clrx   
  A682:  ad84         bsr    LA608
  A684:  95           tsx    
  A685:  f7           sta    ,x
  A686:  4b0a         dbnza  LA692
  A688:  c60235       lda    $0235
  A68B:  2605         bne    LA692
  A68D:  a60a         lda    #$0A
  A68F:  c7023b       sta    $023B
LA692:
  A692:  8a           pulh   
  A693:  81           rts    

;---------------------------------------------------------------
; Ctrl_SlowTask   [0xA694]   <- 8938
;---------------------------------------------------------------
  A694:  87           psha   
  A695:  c6023c       lda    $023C
  A698:  4b5d         dbnza  LA6F7
  A69A:  32022f       ldhx   $022F
  A69D:  3e022d       cphx   $022D
  A6A0:  244b         bcc    LA6ED
  A6A2:  cda8b6       jsr    Motor_sub_A8B6
  A6A5:  95           tsx    
  A6A6:  f7           sta    ,x
  A6A7:  4b1b         dbnza  LA6C4
  A6A9:  c6023a       lda    $023A
  A6AC:  a102         cmp    #$02
  A6AE:  2609         bne    LA6B9
  A6B0:  cda874       jsr    Motor_sub_A874
  A6B3:  4f           clra   
  A6B4:  c7023a       sta    $023A
  A6B7:  2004         bra    LA6BD
LA6B9:
  A6B9:  45023a       ldhx   #$023A
  A6BC:  7c           inc    ,x
LA6BD:
  A6BD:  a601         lda    #$01
  A6BF:  c7029b       sta    $029B
  A6C2:  201f         bra    LA6E3
LA6C4:
  A6C4:  c60239       lda    $0239
  A6C7:  a102         cmp    #$02
  A6C9:  2614         bne    LA6DF
  A6CB:  a606         lda    #$06
  A6CD:  c7023b       sta    $023B
  A6D0:  4f           clra   
  A6D1:  c7029b       sta    $029B
  A6D4:  c702a8       sta    $02A8
  A6D7:  c7023c       sta    $023C
  A6DA:  c70239       sta    $0239
  A6DD:  2004         bra    LA6E3
LA6DF:
  A6DF:  450239       ldhx   #$0239
  A6E2:  7c           inc    ,x
LA6E3:
  A6E3:  32022f       ldhx   $022F
  A6E6:  af01         aix    #$01
  A6E8:  96022f       sthx   $022F
  A6EB:  200a         bra    LA6F7
LA6ED:
  A6ED:  4f           clra   
  A6EE:  c7022f       sta    $022F
  A6F1:  c70230       sta    $0230
  A6F4:  c7023c       sta    $023C
LA6F7:
  A6F7:  8a           pulh   
  A6F8:  81           rts    

;---------------------------------------------------------------
; MotorPos_Init   [0xA6F9]   <- 87B2
;---------------------------------------------------------------
  A6F9:  4f           clra   
  A6FA:  c70247       sta    $0247
  A6FD:  c70246       sta    $0246
  A700:  c70244       sta    $0244
  A703:  c70243       sta    $0243
  A706:  4c           inca   
  A707:  c70241       sta    $0241
  A70A:  a6ff         lda    #$FF
  A70C:  c70242       sta    $0242
  A70F:  4f           clra   
  A710:  c70245       sta    $0245
  A713:  cda88f       jsr    Motor_sub_A88F
  A716:  cca874       jmp    Motor_sub_A874

;---------------------------------------------------------------
; MotorPos_Isr   [0xA719]   <- 8A1F
;---------------------------------------------------------------
  A719:  c60245       lda    $0245
  A71C:  273a         beq    LA758
  A71E:  c60244       lda    $0244
  A721:  c10246       cmp    $0246
  A724:  241a         bcc    LA740
  A726:  c10247       cmp    $0247
  A729:  450008       ldhx   #$0008
  A72C:  2405         bcc    LA733
  A72E:  f6           lda    ,x
  A72F:  aa04         ora    #$04
  A731:  2003         bra    LA736
LA733:
  A733:  f6           lda    ,x
  A734:  a4fb         and    #$FB
LA736:
  A736:  f7           sta    ,x
  A737:  45000a       ldhx   #$000A
  A73A:  f6           lda    ,x
  A73B:  a4ef         and    #$EF
  A73D:  f7           sta    ,x
  A73E:  2012         bra    LA752
LA740:
  A740:  450008       ldhx   #$0008
  A743:  f6           lda    ,x
  A744:  aa04         ora    #$04
  A746:  f7           sta    ,x
  A747:  45000a       ldhx   #$000A
  A74A:  f6           lda    ,x
  A74B:  a4ef         and    #$EF
  A74D:  f7           sta    ,x
  A74E:  4f           clra   
  A74F:  c70244       sta    $0244
LA752:
  A752:  450244       ldhx   #$0244
  A755:  7c           inc    ,x
  A756:  2039         bra    LA791
LA758:
  A758:  c60243       lda    $0243
  A75B:  a102         cmp    #$02
  A75D:  2514         bcs    LA773
  A75F:  450008       ldhx   #$0008
  A762:  f6           lda    ,x
  A763:  a4fb         and    #$FB
  A765:  f7           sta    ,x
  A766:  45000a       ldhx   #$000A
  A769:  f6           lda    ,x
  A76A:  a4ef         and    #$EF
  A76C:  f7           sta    ,x
  A76D:  450243       ldhx   #$0243
  A770:  7a           dec    ,x
  A771:  201e         bra    LA791
LA773:
  A773:  4b1c         dbnza  LA791
  A775:  c60247       lda    $0247
  A778:  a108         cmp    #$08
  A77A:  2503         bcs    LA77F
  A77C:  cda957       jsr    Motor_sub_A957
LA77F:
  A77F:  450008       ldhx   #$0008
  A782:  f6           lda    ,x
  A783:  a4fb         and    #$FB
  A785:  f7           sta    ,x
  A786:  45000a       ldhx   #$000A
  A789:  f6           lda    ,x
  A78A:  aa10         ora    #$10
  A78C:  f7           sta    ,x
  A78D:  4f           clra   
  A78E:  c70243       sta    $0243
LA791:
  A791:  c6029a       lda    $029A
  A794:  a1ff         cmp    #$FF
  A796:  2406         bcc    LA79E
  A798:  4b04         dbnza  LA79E
  A79A:  45029a       ldhx   #$029A
  A79D:  7c           inc    ,x
LA79E:
  A79E:  81           rts    

;---------------------------------------------------------------
; sub_A79F   [0xA79F]   <- A2C9, A41D
;---------------------------------------------------------------
  A79F:  87           psha   
  A7A0:  89           pshx   
  A7A1:  a11a         cmp    #$1A
  A7A3:  2441         bcc    LA7E6
  A7A5:  4d           tsta   
  A7A6:  272b         beq    LA7D3
  A7A8:  a601         lda    #$01
  A7AA:  c70245       sta    $0245
  A7AD:  95           tsx    
  A7AE:  e601         lda    1,x
  A7B0:  c70247       sta    $0247
  A7B3:  a619         lda    #$19
  A7B5:  c70246       sta    $0246
  A7B8:  4f           clra   
  A7B9:  c70244       sta    $0244
  A7BC:  450008       ldhx   #$0008
  A7BF:  f6           lda    ,x
  A7C0:  aa04         ora    #$04
  A7C2:  f7           sta    ,x
  A7C3:  45000a       ldhx   #$000A
  A7C6:  f6           lda    ,x
  A7C7:  a4ef         and    #$EF
  A7C9:  f7           sta    ,x
  A7CA:  4f           clra   
  A7CB:  c7023f       sta    $023F
  A7CE:  c7029a       sta    $029A
  A7D1:  2024         bra    LA7F7
LA7D3:
  A7D3:  c70245       sta    $0245
  A7D6:  450008       ldhx   #$0008
  A7D9:  f6           lda    ,x
  A7DA:  a4fb         and    #$FB
  A7DC:  f7           sta    ,x
  A7DD:  45000a       ldhx   #$000A
  A7E0:  f6           lda    ,x
  A7E1:  a4ef         and    #$EF
  A7E3:  f7           sta    ,x
  A7E4:  2011         bra    LA7F7
LA7E6:
  A7E6:  4f           clra   
  A7E7:  c7023f       sta    $023F
  A7EA:  c7029a       sta    $029A
  A7ED:  a60a         lda    #$0A
  A7EF:  c70247       sta    $0247
  A7F2:  a619         lda    #$19
  A7F4:  c70246       sta    $0246
LA7F7:
  A7F7:  a702         ais    #$02
  A7F9:  81           rts    

;---------------------------------------------------------------
; sub_A7FA   [0xA7FA]   <- A33A
;---------------------------------------------------------------
  A7FA:  87           psha   
  A7FB:  89           pshx   
  A7FC:  a115         cmp    #$15
  A7FE:  2441         bcc    LA841
  A800:  4d           tsta   
  A801:  272b         beq    LA82E
  A803:  a601         lda    #$01
  A805:  c70245       sta    $0245
  A808:  95           tsx    
  A809:  e601         lda    1,x
  A80B:  c70247       sta    $0247
  A80E:  a614         lda    #$14
  A810:  c70246       sta    $0246
  A813:  4f           clra   
  A814:  c70244       sta    $0244
  A817:  450008       ldhx   #$0008
  A81A:  f6           lda    ,x
  A81B:  aa04         ora    #$04
  A81D:  f7           sta    ,x
  A81E:  45000a       ldhx   #$000A
  A821:  f6           lda    ,x
  A822:  a4ef         and    #$EF
  A824:  f7           sta    ,x
  A825:  4f           clra   
  A826:  c7023f       sta    $023F
  A829:  c7029a       sta    $029A
  A82C:  2024         bra    LA852
LA82E:
  A82E:  c70245       sta    $0245
  A831:  450008       ldhx   #$0008
  A834:  f6           lda    ,x
  A835:  a4fb         and    #$FB
  A837:  f7           sta    ,x
  A838:  45000a       ldhx   #$000A
  A83B:  f6           lda    ,x
  A83C:  a4ef         and    #$EF
  A83E:  f7           sta    ,x
  A83F:  2011         bra    LA852
LA841:
  A841:  4f           clra   
  A842:  c7023f       sta    $023F
  A845:  c7029a       sta    $029A
  A848:  a60c         lda    #$0C
  A84A:  c70247       sta    $0247
  A84D:  a614         lda    #$14
  A84F:  c70246       sta    $0246
LA852:
  A852:  a702         ais    #$02
  A854:  81           rts    

;---------------------------------------------------------------
; sub_A855   [0xA855]   <- A397
;---------------------------------------------------------------
  A855:  4f           clra   
  A856:  c70245       sta    $0245
  A859:  450008       ldhx   #$0008
  A85C:  f6           lda    ,x
  A85D:  a4fb         and    #$FB
  A85F:  f7           sta    ,x
  A860:  45000a       ldhx   #$000A
  A863:  f6           lda    ,x
  A864:  a4ef         and    #$EF
  A866:  f7           sta    ,x
  A867:  a604         lda    #$04
  A869:  c70243       sta    $0243
  A86C:  4f           clra   
  A86D:  c7023f       sta    $023F
  A870:  c7029a       sta    $029A
  A873:  81           rts    

;---------------------------------------------------------------
; Motor_sub_A874   [0xA874]   <- A215, A299, A2FC, A34D, A353, A38E, A3A5, A3D2
;---------------------------------------------------------------
  A874:  4f           clra   
  A875:  c70245       sta    $0245
  A878:  450008       ldhx   #$0008
  A87B:  f6           lda    ,x
  A87C:  a4fb         and    #$FB
  A87E:  f7           sta    ,x
  A87F:  45000a       ldhx   #$000A
  A882:  f6           lda    ,x
  A883:  a4ef         and    #$EF
  A885:  f7           sta    ,x
  A886:  a601         lda    #$01
  A888:  c7023f       sta    $023F
  A88B:  c7029a       sta    $029A
  A88E:  81           rts    

;---------------------------------------------------------------
; Motor_sub_A88F   [0xA88F]   <- A713
;---------------------------------------------------------------
  A88F:  4f           clra   
  A890:  c70240       sta    $0240
  A893:  81           rts    

;---------------------------------------------------------------
; sub_A894   [0xA894]   <- A3B9, A4C0
;---------------------------------------------------------------
  A894:  c60240       lda    $0240
  A897:  aa02         ora    #$02
  A899:  c70240       sta    $0240
  A89C:  ce0242       ldx    $0242
  A89F:  2711         beq    LA8B2
  A8A1:  c60241       lda    $0241
  A8A4:  8c           clrh   
  A8A5:  52           div    
  A8A6:  a108         cmp    #$08
  A8A8:  2408         bcc    LA8B2
  A8AA:  c60240       lda    $0240
  A8AD:  a4fd         and    #$FD
  A8AF:  c70240       sta    $0240
LA8B2:
  A8B2:  c60240       lda    $0240
  A8B5:  81           rts    

;---------------------------------------------------------------
; Motor_sub_A8B6   [0xA8B6]   <- A231, A492, A6A2
;---------------------------------------------------------------
  A8B6:  a7fe         ais    #$FE
  A8B8:  450008       ldhx   #$0008
  A8BB:  f6           lda    ,x
  A8BC:  aa04         ora    #$04
  A8BE:  f7           sta    ,x
  A8BF:  45000a       ldhx   #$000A
  A8C2:  f6           lda    ,x
  A8C3:  a4ef         and    #$EF
  A8C5:  f7           sta    ,x
  A8C6:  5f           clrx   
  A8C7:  a60a         lda    #$0A
  A8C9:  cda103       jsr    Adc_Read
  A8CC:  95           tsx    
  A8CD:  e701         sta    1,x
  A8CF:  5f           clrx   
  A8D0:  a6f0         lda    #$F0
  A8D2:  cdb653       jsr    Delay_Loop
  A8D5:  5f           clrx   
  A8D6:  a602         lda    #$02
  A8D8:  cda103       jsr    Adc_Read
  A8DB:  c70241       sta    $0241
  A8DE:  c60240       lda    $0240
  A8E1:  aa01         ora    #$01
  A8E3:  c70240       sta    $0240
  A8E6:  a601         lda    #$01
  A8E8:  95           tsx    
  A8E9:  f7           sta    ,x
  A8EA:  c60241       lda    $0241
  A8ED:  2724         beq    LA913
  A8EF:  e601         lda    1,x
  A8F1:  5f           clrx   
  A8F2:  48           lsla   
  A8F3:  59           rolx   
  A8F4:  48           lsla   
  A8F5:  59           rolx   
  A8F6:  48           lsla   
  A8F7:  59           rolx   
  A8F8:  bfc6         stx    g_mulDiv_tmp
  A8FA:  ce0241       ldx    $0241
  A8FD:  8c           clrh   
  A8FE:  cdc127       jsr    div16
  A901:  a012         sub    #$12
  A903:  b6c6         lda    g_mulDiv_tmp
  A905:  a200         sbc    #$00
  A907:  240a         bcc    LA913
  A909:  c60240       lda    $0240
  A90C:  a4fe         and    #$FE
  A90E:  c70240       sta    $0240
  A911:  95           tsx    
  A912:  7f           clr    ,x
LA913:
  A913:  cda874       jsr    Motor_sub_A874
  A916:  95           tsx    
  A917:  f6           lda    ,x
  A918:  a702         ais    #$02
  A91A:  81           rts    

;---------------------------------------------------------------
; Motor_sub_A91B   [0xA91B]   <- A218, A575, A5C9
;---------------------------------------------------------------
  A91B:  a7fd         ais    #$FD
  A91D:  5f           clrx   
  A91E:  a60a         lda    #$0A
  A920:  cda103       jsr    Adc_Read
  A923:  95           tsx    
  A924:  e702         sta    2,x
  A926:  5f           clrx   
  A927:  a602         lda    #$02
  A929:  cda103       jsr    Adc_Read
  A92C:  95           tsx    
  A92D:  e701         sta    1,x
  A92F:  c60240       lda    $0240
  A932:  a4fa         and    #$FA
  A934:  c70240       sta    $0240
  A937:  a601         lda    #$01
  A939:  f7           sta    ,x
  A93A:  6d01         tst    1,x
  A93C:  2714         beq    LA952
  A93E:  e602         lda    2,x
  A940:  ee01         ldx    1,x
  A942:  8c           clrh   
  A943:  52           div    
  A944:  a107         cmp    #$07
  A946:  240a         bcc    LA952
  A948:  c60240       lda    $0240
  A94B:  aa04         ora    #$04
  A94D:  c70240       sta    $0240
  A950:  95           tsx    
  A951:  7f           clr    ,x
LA952:
  A952:  95           tsx    
  A953:  f6           lda    ,x
  A954:  a703         ais    #$03
  A956:  81           rts    

;---------------------------------------------------------------
; Motor_sub_A957   [0xA957]   <- A77C
;---------------------------------------------------------------
  A957:  5f           clrx   
  A958:  a602         lda    #$02
  A95A:  cda103       jsr    Adc_Read
  A95D:  c70105       sta    $0105
  A960:  c60170       lda    $0170
  A963:  5f           clrx   
  A964:  cdb653       jsr    Delay_Loop
  A967:  5f           clrx   
  A968:  a602         lda    #$02
  A96A:  cda103       jsr    Adc_Read
  A96D:  c70106       sta    $0106
  A970:  c60171       lda    $0171
  A973:  5f           clrx   
  A974:  cdb653       jsr    Delay_Loop
  A977:  c60105       lda    $0105
  A97A:  c10106       cmp    $0106
  A97D:  2203         bhi    LA982
  A97F:  c60106       lda    $0106
LA982:
  A982:  c70106       sta    $0106
  A985:  5f           clrx   
  A986:  a602         lda    #$02
  A988:  cda103       jsr    Adc_Read
  A98B:  c70105       sta    $0105
  A98E:  c10106       cmp    $0106
  A991:  2203         bhi    LA996
  A993:  c60106       lda    $0106
LA996:
  A996:  c70242       sta    $0242
  A999:  81           rts    

;---------------------------------------------------------------
; sub_A99A   [0xA99A]   <- A5B6
;---------------------------------------------------------------
  A99A:  c6023f       lda    $023F
  A99D:  81           rts    

;---------------------------------------------------------------
; Motor_Init   [0xA99E]   <- 8791
;---------------------------------------------------------------
  A99E:  4f           clra   
  A99F:  c702b2       sta    $02B2
  A9A2:  5f           clrx   
  A9A3:  4c           inca   
  A9A4:  ad66         bsr    Fault_Report
  A9A6:  ccb620       jmp    Diag_sub_B620

;---------------------------------------------------------------
; Motor_Task   [0xA9A9]   <- 88E0
;---------------------------------------------------------------
  A9A9:  87           psha   
  A9AA:  c60275       lda    g_outputVariant
  A9AD:  2645         bne    LA9F4
  A9AF:  c6028f       lda    $028F
  A9B2:  4b24         dbnza  LA9D8
  A9B4:  c6028e       lda    $028E
  A9B7:  417f15       cbeqa  #$7F, LA9CF
  A9BA:  c60249       lda    $0249
  A9BD:  4b10         dbnza  LA9CF
  A9BF:  c6028e       lda    $028E
  A9C2:  a165         cmp    #$65
  A9C4:  2502         bcs    LA9C8
  A9C6:  a664         lda    #$64
LA9C8:
  A9C8:  c702b2       sta    $02B2
  A9CB:  262c         bne    LA9F9
  A9CD:  2020         bra    LA9EF
LA9CF:
  A9CF:  c6028e       lda    $028E
  A9D2:  a17f         cmp    #$7F
  A9D4:  2615         bne    LA9EB
  A9D6:  201c         bra    LA9F4
LA9D8:
  A9D8:  c60276       lda    g_ctrlErrFlag
  A9DB:  4b0e         dbnza  LA9EB
  A9DD:  a650         lda    #$50
  A9DF:  c702b2       sta    $02B2
  A9E2:  45000a       ldhx   #$000A
  A9E5:  f6           lda    ,x
  A9E6:  aa01         ora    #$01
  A9E8:  f7           sta    ,x
  A9E9:  201f         bra    LAA0A
LA9EB:
  A9EB:  4f           clra   
  A9EC:  c702b2       sta    $02B2
LA9EF:
  A9EF:  cdb620       jsr    Diag_sub_B620
  A9F2:  2016         bra    LAA0A
LA9F4:
  A9F4:  a650         lda    #$50
  A9F6:  c702b2       sta    $02B2
LA9F9:
  A9F9:  cdb5d6       jsr    $B5D6
  A9FC:  9ee701       sta    1,s
  A9FF:  2609         bne    LAA0A
  AA01:  cdb5a3       jsr    Diag_Init
  AA04:  cda13a       jsr    Ctrl_sub_A13A
  AA07:  cdb5e4       jsr    $B5E4
LAA0A:
  AA0A:  8a           pulh   
  AA0B:  81           rts    

;---------------------------------------------------------------
; Fault_Report   [0xAA0C]   <- 87FC, A9A4
;---------------------------------------------------------------
  AA0C:  c70249       sta    $0249
  AA0F:  81           rts    

;---------------------------------------------------------------
; Fault_Init   [0xAA10]   <- 879D
;---------------------------------------------------------------
  AA10:  87           psha   
  AA11:  95           tsx    
  AA12:  7f           clr    ,x
  AA13:  8c           clrh   
  AA14:  4f           clra   
  AA15:  9eee01       ldx    1,s
LAA18:
  AA18:  d7024e       sta    $024E,x
  AA1B:  5c           incx   
  AA1C:  a303         cpx    #$03
  AA1E:  25f8         bcs    LAA18
  AA20:  9eef01       stx    1,s
  AA23:  a603         lda    #$03
  AA25:  95           tsx    
  AA26:  f7           sta    ,x
  AA27:  8c           clrh   
  AA28:  4f           clra   
  AA29:  9eee01       ldx    1,s
LAA2C:
  AA2C:  d7024e       sta    $024E,x
  AA2F:  5c           incx   
  AA30:  a30d         cpx    #$0D
  AA32:  25f8         bcs    LAA2C
  AA34:  8a           pulh   
  AA35:  81           rts    

;---------------------------------------------------------------
; Fault_Task   [0xAA36]   <- 889D, ACC1
;---------------------------------------------------------------
  AA36:  87           psha   
  AA37:  4f           clra   
  AA38:  95           tsx    
  AA39:  f7           sta    ,x
LAA3A:
  AA3A:  5f           clrx   
  AA3B:  ad2b         bsr    Fault_sub_AA68
  AA3D:  95           tsx    
  AA3E:  7c           inc    ,x
  AA3F:  f6           lda    ,x
  AA40:  a103         cmp    #$03
  AA42:  25f6         bcs    LAA3A
  AA44:  7f           clr    ,x
LAA45:
  AA45:  c60299       lda    g_featureFlags
  AA48:  a401         and    #$01
  AA4A:  2703         beq    LAA4F
  AA4C:  f6           lda    ,x
  AA4D:  200d         bra    LAA5C
LAA4F:
  AA4F:  f6           lda    ,x
  AA50:  41040c       cbeqa  #$04, LAA5F
  AA53:  410509       cbeqa  #$05, LAA5F
  AA56:  410806       cbeqa  #$08, LAA5F
  AA59:  410903       cbeqa  #$09, LAA5F
LAA5C:
  AA5C:  5f           clrx   
  AA5D:  ad7e         bsr    Fault_sub_AADD
LAA5F:
  AA5F:  95           tsx    
  AA60:  7c           inc    ,x
  AA61:  f6           lda    ,x
  AA62:  a10a         cmp    #$0A
  AA64:  25df         bcs    LAA45
  AA66:  8a           pulh   
  AA67:  81           rts    

;---------------------------------------------------------------
; Fault_sub_AA68   [0xAA68]   <- AA3B
;---------------------------------------------------------------
  AA68:  87           psha   
  AA69:  89           pshx   
  AA6A:  a7fd         ais    #$FD
  AA6C:  8c           clrh   
  AA6D:  97           tax    
  AA6E:  d6024e       lda    $024E,x
  AA71:  48           lsla   
  AA72:  9ee703       sta    3,s
  AA75:  9eee05       ldx    5,s
  AA78:  58           lslx   
  AA79:  58           lslx   
  AA7A:  d6c1fa       lda    $C1FA,x
  AA7D:  9ee702       sta    2,s
  AA80:  dec1f9       ldx    $C1F9,x
  AA83:  f6           lda    ,x
  AA84:  9ee701       sta    1,s
  AA87:  9eee05       ldx    5,s
  AA8A:  58           lslx   
  AA8B:  58           lslx   
  AA8C:  d6c1fa       lda    $C1FA,x
  AA8F:  9ee401       and    1,s
  AA92:  9ee102       cmp    2,s
  AA95:  2703         beq    LAA9A
  AA97:  9e6c03       inc    3,s
LAA9A:
  AA9A:  9ee603       lda    3,s
  AA9D:  a40f         and    #$0F
  AA9F:  9ee703       sta    3,s
  AAA2:  2609         bne    LAAAD
  AAA4:  9eee05       ldx    5,s
  AAA7:  d7024e       sta    $024E,x
  AAAA:  5f           clrx   
  AAAB:  200f         bra    LAABC
LAAAD:
  AAAD:  a10f         cmp    #$0F
  AAAF:  261b         bne    LAACC
  AAB1:  9eee05       ldx    5,s
  AAB4:  a61f         lda    #$1F
  AAB6:  d7024e       sta    $024E,x
  AAB9:  5f           clrx   
  AABA:  a601         lda    #$01
LAABC:
  AABC:  87           psha   
  AABD:  89           pshx   
  AABE:  9eee07       ldx    7,s
  AAC1:  58           lslx   
  AAC2:  58           lslx   
  AAC3:  9ebec1fb     ldhx   $C1FB,x
  AAC7:  cdc048       jsr    rotate3
  AACA:  200e         bra    LAADA
LAACC:
  AACC:  9eee05       ldx    5,s
  AACF:  d6024e       lda    $024E,x
  AAD2:  a4f0         and    #$F0
  AAD4:  9eea03       ora    3,s
  AAD7:  d7024e       sta    $024E,x
LAADA:
  AADA:  a705         ais    #$05
  AADC:  81           rts    

;---------------------------------------------------------------
; Fault_sub_AADD   [0xAADD]   <- AA5D
;---------------------------------------------------------------
  AADD:  87           psha   
  AADE:  89           pshx   
  AADF:  a7fd         ais    #$FD
  AAE1:  ab03         add    #$03
  AAE3:  95           tsx    
  AAE4:  e701         sta    1,x
  AAE6:  97           tax    
  AAE7:  8c           clrh   
  AAE8:  d6024e       lda    $024E,x
  AAEB:  48           lsla   
  AAEC:  9ee701       sta    1,s
  AAEF:  9ee605       lda    5,s
  AAF2:  ae05         ldx    #$05
  AAF4:  42           mul    
  AAF5:  97           tax    
  AAF6:  d6c207       lda    $C207,x
  AAF9:  5f           clrx   
  AAFA:  87           psha   
  AAFB:  89           pshx   
  AAFC:  9ee607       lda    7,s
  AAFF:  ae05         ldx    #$05
  AB01:  42           mul    
  AB02:  97           tax    
  AB03:  d6c206       lda    $C206,x
  AB06:  5f           clrx   
  AB07:  87           psha   
  AB08:  89           pshx   
  AB09:  9ee609       lda    9,s
  AB0C:  ae05         ldx    #$05
  AB0E:  42           mul    
  AB0F:  97           tax    
  AB10:  d6c205       lda    $C205,x
  AB13:  5f           clrx   
  AB14:  ad4c         bsr    Fault_sub_AB62
  AB16:  a704         ais    #$04
  AB18:  95           tsx    
  AB19:  e702         sta    2,x
  AB1B:  4b01         dbnza  LAB1E
  AB1D:  7c           inc    ,x
LAB1E:
  AB1E:  f6           lda    ,x
  AB1F:  a40f         and    #$0F
  AB21:  f7           sta    ,x
  AB22:  2609         bne    LAB2D
  AB24:  ee01         ldx    1,x
  AB26:  8c           clrh   
  AB27:  d7024e       sta    $024E,x
  AB2A:  5f           clrx   
  AB2B:  200f         bra    LAB3C
LAB2D:
  AB2D:  a10f         cmp    #$0F
  AB2F:  261d         bne    LAB4E
  AB31:  ee01         ldx    1,x
  AB33:  8c           clrh   
  AB34:  a61f         lda    #$1F
  AB36:  d7024e       sta    $024E,x
  AB39:  5f           clrx   
  AB3A:  a601         lda    #$01
LAB3C:
  AB3C:  87           psha   
  AB3D:  89           pshx   
  AB3E:  9ee607       lda    7,s
  AB41:  ae05         ldx    #$05
  AB43:  42           mul    
  AB44:  97           tax    
  AB45:  9ebec208     ldhx   $C208,x
  AB49:  cdc048       jsr    rotate3
  AB4C:  2011         bra    LAB5F
LAB4E:
  AB4E:  ee04         ldx    4,x
  AB50:  8c           clrh   
  AB51:  d6024e       lda    $024E,x
  AB54:  a4f0         and    #$F0
  AB56:  9eea01       ora    1,s
  AB59:  9eee02       ldx    2,s
  AB5C:  d7024e       sta    $024E,x
LAB5F:
  AB5F:  a705         ais    #$05
  AB61:  81           rts    

;---------------------------------------------------------------
; Fault_sub_AB62   [0xAB62]   <- AB14
;---------------------------------------------------------------
  AB62:  87           psha   
  AB63:  89           pshx   
  AB64:  87           psha   
  AB65:  5f           clrx   
  AB66:  cda103       jsr    Adc_Read
  AB69:  95           tsx    
  AB6A:  f7           sta    ,x
  AB6B:  e606         lda    6,x
  AB6D:  f1           cmp    ,x
  AB6E:  2209         bhi    LAB79
  AB70:  f6           lda    ,x
  AB71:  e108         cmp    8,x
  AB73:  2204         bhi    LAB79
  AB75:  a601         lda    #$01
  AB77:  2001         bra    LAB7A
LAB79:
  AB79:  4f           clra   
LAB7A:
  AB7A:  a703         ais    #$03
  AB7C:  81           rts    

;---------------------------------------------------------------
; sub_AB7D   [0xAB7D]
;---------------------------------------------------------------
  AB7D:  87           psha   
  AB7E:  89           pshx   
  AB7F:  c6024b       lda    $024B
  AB82:  2606         bne    LAB8A
  AB84:  95           tsx    
  AB85:  e601         lda    1,x
  AB87:  c702cc       sta    $02CC
LAB8A:
  AB8A:  a702         ais    #$02
  AB8C:  81           rts    

;---------------------------------------------------------------
; sub_AB8D   [0xAB8D]
;---------------------------------------------------------------
  AB8D:  c702c6       sta    $02C6
  AB90:  81           rts    

;---------------------------------------------------------------
; sub_AB91   [0xAB91]
;---------------------------------------------------------------
  AB91:  87           psha   
  AB92:  89           pshx   
  AB93:  c6024b       lda    $024B
  AB96:  2606         bne    LAB9E
  AB98:  95           tsx    
  AB99:  e601         lda    1,x
  AB9B:  c702ce       sta    $02CE
LAB9E:
  AB9E:  a702         ais    #$02
  ABA0:  81           rts    

;---------------------------------------------------------------
; sub_ABA1   [0xABA1]
;---------------------------------------------------------------
  ABA1:  a101         cmp    #$01
  ABA3:  2608         bne    LABAD
  ABA5:  c702ce       sta    $02CE
  ABA8:  c702cc       sta    $02CC
  ABAB:  2001         bra    LABAE
LABAD:
  ABAD:  4f           clra   
LABAE:
  ABAE:  c7024b       sta    $024B
  ABB1:  81           rts    

;---------------------------------------------------------------
; sub_ABB2   [0xABB2]
;---------------------------------------------------------------
  ABB2:  4b1a         dbnza  LABCE
  ABB4:  4502cd       ldhx   #$02CD
  ABB7:  f6           lda    ,x
  ABB8:  aa80         ora    #$80
  ABBA:  f7           sta    ,x
  ABBB:  4502cb       ldhx   #$02CB
  ABBE:  f6           lda    ,x
  ABBF:  aa80         ora    #$80
  ABC1:  f7           sta    ,x
  ABC2:  a607         lda    #$07
  ABC4:  c702a9       sta    $02A9
  ABC7:  c702a0       sta    $02A0
  ABCA:  a601         lda    #$01
  ABCC:  202a         bra    LABF8
LABCE:
  ABCE:  c602cd       lda    $02CD
  ABD1:  a480         and    #$80
  ABD3:  2607         bne    LABDC
  ABD5:  c602cb       lda    $02CB
  ABD8:  a480         and    #$80
  ABDA:  271f         beq    LABFB
LABDC:
  ABDC:  c602ce       lda    $02CE
  ABDF:  2609         bne    LABEA
  ABE1:  a60f         lda    #$0F
  ABE3:  c702cd       sta    $02CD
  ABE6:  4f           clra   
  ABE7:  c702a9       sta    $02A9
LABEA:
  ABEA:  c602cc       lda    $02CC
  ABED:  260c         bne    LABFB
  ABEF:  a60f         lda    #$0F
  ABF1:  c702cb       sta    $02CB
  ABF4:  4f           clra   
  ABF5:  c702a0       sta    $02A0
LABF8:
  ABF8:  c702d1       sta    $02D1
LABFB:
  ABFB:  81           rts    

;---------------------------------------------------------------
; sub_ABFC   [0xABFC]
;---------------------------------------------------------------
  ABFC:  4b0d         dbnza  LAC0B
  ABFE:  4502cf       ldhx   #$02CF
  AC01:  f6           lda    ,x
  AC02:  aa80         ora    #$80
  AC04:  f7           sta    ,x
  AC05:  6f01         clr    1,x
  AC07:  a607         lda    #$07
  AC09:  2012         bra    LAC1D
LAC0B:
  AC0B:  c602cf       lda    $02CF
  AC0E:  a480         and    #$80
  AC10:  270e         beq    LAC20
  AC12:  c602d0       lda    $02D0
  AC15:  2609         bne    LAC20
  AC17:  a60f         lda    #$0F
  AC19:  c702cf       sta    $02CF
  AC1C:  4f           clra   
LAC1D:
  AC1D:  c702a0       sta    $02A0
LAC20:
  AC20:  81           rts    

;---------------------------------------------------------------
; sub_AC21   [0xAC21]
;---------------------------------------------------------------
  AC21:  c702c8       sta    $02C8
  AC24:  81           rts    

;---------------------------------------------------------------
; sub_AC25   [0xAC25]
;---------------------------------------------------------------
  AC25:  c702ca       sta    $02CA
  AC28:  81           rts    

;---------------------------------------------------------------
; sub_AC29   [0xAC29]
;---------------------------------------------------------------
  AC29:  c702d0       sta    $02D0
  AC2C:  81           rts    

;---------------------------------------------------------------
; sub_AC2D   [0xAC2D]
;---------------------------------------------------------------
  AC2D:  c702be       sta    $02BE
  AC30:  81           rts    

;---------------------------------------------------------------
; sub_AC31   [0xAC31]
;---------------------------------------------------------------
  AC31:  a101         cmp    #$01
  AC33:  260c         bne    LAC41
  AC35:  c7024d       sta    $024D
  AC38:  c702bb       sta    $02BB
  AC3B:  a607         lda    #$07
  AC3D:  c702a3       sta    $02A3
  AC40:  81           rts    
LAC41:
  AC41:  c602bb       lda    $02BB
  AC44:  4b0e         dbnza  LAC54
  AC46:  c602be       lda    $02BE
  AC49:  2609         bne    LAC54
  AC4B:  c7024d       sta    $024D
  AC4E:  c702a3       sta    $02A3
  AC51:  c702bb       sta    $02BB
LAC54:
  AC54:  81           rts    

;---------------------------------------------------------------
; sub_AC55   [0xAC55]
;---------------------------------------------------------------
  AC55:  c702bd       sta    $02BD
  AC58:  81           rts    

;---------------------------------------------------------------
; sub_AC59   [0xAC59]
;---------------------------------------------------------------
  AC59:  a101         cmp    #$01
  AC5B:  260c         bne    LAC69
  AC5D:  c7024d       sta    $024D
  AC60:  c702ba       sta    $02BA
  AC63:  a607         lda    #$07
  AC65:  c702a4       sta    $02A4
  AC68:  81           rts    
LAC69:
  AC69:  c602ba       lda    $02BA
  AC6C:  4b0e         dbnza  LAC7C
  AC6E:  c602bd       lda    $02BD
  AC71:  2609         bne    LAC7C
  AC73:  c7024d       sta    $024D
  AC76:  c702a4       sta    $02A4
  AC79:  c702ba       sta    $02BA
LAC7C:
  AC7C:  81           rts    

;---------------------------------------------------------------
; sub_AC7D   [0xAC7D]   <- ADB1, AE21
;---------------------------------------------------------------
  AC7D:  c6024d       lda    $024D
  AC80:  81           rts    

;---------------------------------------------------------------
; LinSignals_Init   [0xAC81]   <- 879A, 8DFB
;---------------------------------------------------------------
  AC81:  4f           clra   
  AC82:  c70266       sta    $0266
  AC85:  c70267       sta    $0267
  AC88:  c70268       sta    $0268
  AC8B:  c70269       sta    $0269
  AC8E:  c70264       sta    $0264
  AC91:  c7026a       sta    $026A
  AC94:  c7026c       sta    $026C
  AC97:  c7026d       sta    $026D
  AC9A:  c7026b       sta    $026B
  AC9D:  c70265       sta    $0265
  ACA0:  c70260       sta    $0260
  ACA3:  c70261       sta    $0261
  ACA6:  c7025e       sta    $025E
  ACA9:  c7025f       sta    $025F
  ACAC:  c7025c       sta    $025C
  ACAF:  c7025d       sta    $025D
  ACB2:  4c           inca   
  ACB3:  c70277       sta    $0277
  ACB6:  81           rts    

;---------------------------------------------------------------
; LinSignals_Refresh   [0xACB7]   <- 87CA
;---------------------------------------------------------------
  ACB7:  87           psha   
  ACB8:  4f           clra   
  ACB9:  c70263       sta    $0263
  ACBC:  c70262       sta    $0262
  ACBF:  95           tsx    
  ACC0:  7f           clr    ,x
LACC1:
  ACC1:  cdaa36       jsr    Fault_Task
  ACC4:  95           tsx    
  ACC5:  7c           inc    ,x
  ACC6:  f6           lda    ,x
  ACC7:  a105         cmp    #$05
  ACC9:  25f6         bcs    LACC1
  ACCB:  7f           clr    ,x
  ACCC:  8c           clrh   
  ACCD:  9eee01       ldx    1,s
LACD0:
  ACD0:  58           lslx   
  ACD1:  d602c6       lda    $02C6,x
  ACD4:  4b05         dbnza  LACDB
  ACD6:  a603         lda    #$03
  ACD8:  d702c5       sta    $02C5,x
LACDB:
  ACDB:  9e6c01       inc    1,s
  ACDE:  9eee01       ldx    1,s
  ACE1:  a306         cpx    #$06
  ACE3:  25eb         bcs    LACD0
  ACE5:  c602bd       lda    $02BD
  ACE8:  a101         cmp    #$01
  ACEA:  260a         bne    LACF6
  ACEC:  c70263       sta    $0263
  ACEF:  c7025f       sta    $025F
  ACF2:  4f           clra   
  ACF3:  c7025e       sta    $025E
LACF6:
  ACF6:  c602be       lda    $02BE
  ACF9:  a101         cmp    #$01
  ACFB:  260a         bne    LAD07
  ACFD:  c70262       sta    $0262
  AD00:  c7025d       sta    $025D
  AD03:  4f           clra   
  AD04:  c7025c       sta    $025C
LAD07:
  AD07:  8a           pulh   
  AD08:  81           rts    

;---------------------------------------------------------------
; sub_AD09   [0xAD09]   <- LinApp_ResetA
;---------------------------------------------------------------
  AD09:  87           psha   
  AD0A:  95           tsx    
  AD0B:  7f           clr    ,x
  AD0C:  c60299       lda    g_featureFlags
  AD0F:  a401         and    #$01
  AD11:  2603         bne    LAD16
  AD13:  ccae31       jmp    $AE31
LAD16:
  AD16:  c602ba       lda    $02BA
  AD19:  2636         bne    LAD51
  AD1B:  c602bb       lda    $02BB
  AD1E:  2631         bne    LAD51
  AD20:  c602bd       lda    $02BD
  AD23:  4b2c         dbnza  LAD51
  AD25:  c602be       lda    $02BE
  AD28:  a101         cmp    #$01
  AD2A:  2625         bne    LAD51
  AD2C:  c702bc       sta    $02BC
  AD2F:  4f           clra   
  AD30:  c70284       sta    $0284
  AD33:  c70283       sta    $0283
  AD36:  32025e       ldhx   $025E
  AD39:  2608         bne    LAD43
  AD3B:  4c           inca   
  AD3C:  c7025f       sta    $025F
  AD3F:  4f           clra   
  AD40:  c7025e       sta    $025E
LAD43:
  AD43:  32025c       ldhx   $025C
  AD46:  2609         bne    LAD51
  AD48:  a601         lda    #$01
  AD4A:  c7025d       sta    $025D
  AD4D:  4f           clra   
  AD4E:  c7025c       sta    $025C
LAD51:
  AD51:  c602ba       lda    $02BA
  AD54:  2667         bne    LADBD
  AD56:  c602bd       lda    $02BD
  AD59:  2608         bne    LAD63
  AD5B:  c602be       lda    $02BE
  AD5E:  2603         bne    LAD63
  AD60:  c702bc       sta    $02BC
LAD63:
  AD63:  c602bd       lda    $02BD
  AD66:  4b20         dbnza  LAD88
  AD68:  c602be       lda    $02BE
  AD6B:  261b         bne    LAD88
  AD6D:  c602bc       lda    $02BC
  AD70:  2616         bne    LAD88
  AD72:  32025e       ldhx   $025E
  AD75:  2611         bne    LAD88
  AD77:  c60263       lda    $0263
  AD7A:  260c         bne    LAD88
  AD7C:  a601         lda    #$01
  AD7E:  c70284       sta    $0284
  AD81:  c7025f       sta    $025F
  AD84:  4f           clra   
  AD85:  c7025e       sta    $025E
LAD88:
  AD88:  c60134       lda    $0134
  AD8B:  ae20         ldx    #$20
  AD8D:  42           mul    
  AD8E:  c0025f       sub    $025F
  AD91:  9f           txa    
  AD92:  c2025e       sbc    $025E
  AD95:  2409         bcc    LADA0
  AD97:  4f           clra   
  AD98:  c70284       sta    $0284
  AD9B:  a607         lda    #$07
  AD9D:  c702a4       sta    $02A4
LADA0:
  ADA0:  c602bd       lda    $02BD
  ADA3:  261c         bne    LADC1
  ADA5:  c7025e       sta    $025E
  ADA8:  c7025f       sta    $025F
  ADAB:  c70284       sta    $0284
  ADAE:  c70263       sta    $0263
  ADB1:  cdac7d       jsr    $AC7D
  ADB4:  95           tsx    
  ADB5:  f7           sta    ,x
  ADB6:  2609         bne    LADC1
  ADB8:  c702a4       sta    $02A4
  ADBB:  2004         bra    LADC1
LADBD:
  ADBD:  4f           clra   
  ADBE:  c70284       sta    $0284
LADC1:
  ADC1:  c602bb       lda    $02BB
  ADC4:  2667         bne    LAE2D
  ADC6:  c602bd       lda    $02BD
  ADC9:  2608         bne    LADD3
  ADCB:  c602be       lda    $02BE
  ADCE:  2603         bne    LADD3
  ADD0:  c702bc       sta    $02BC
LADD3:
  ADD3:  c602be       lda    $02BE
  ADD6:  4b20         dbnza  LADF8
  ADD8:  c602bd       lda    $02BD
  ADDB:  261b         bne    LADF8
  ADDD:  c602bc       lda    $02BC
  ADE0:  2616         bne    LADF8
  ADE2:  32025c       ldhx   $025C
  ADE5:  2611         bne    LADF8
  ADE7:  c60262       lda    $0262
  ADEA:  260c         bne    LADF8
  ADEC:  a601         lda    #$01
  ADEE:  c70283       sta    $0283
  ADF1:  c7025d       sta    $025D
  ADF4:  4f           clra   
  ADF5:  c7025c       sta    $025C
LADF8:
  ADF8:  c60134       lda    $0134
  ADFB:  ae20         ldx    #$20
  ADFD:  42           mul    
  ADFE:  c0025d       sub    $025D
  AE01:  9f           txa    
  AE02:  c2025c       sbc    $025C
  AE05:  2409         bcc    LAE10
  AE07:  4f           clra   
  AE08:  c70283       sta    $0283
  AE0B:  a607         lda    #$07
  AE0D:  c702a3       sta    $02A3
LAE10:
  AE10:  c602be       lda    $02BE
  AE13:  261c         bne    LAE31
  AE15:  c7025c       sta    $025C
  AE18:  c7025d       sta    $025D
  AE1B:  c70283       sta    $0283
  AE1E:  c70262       sta    $0262
  AE21:  cdac7d       jsr    $AC7D
  AE24:  95           tsx    
  AE25:  f7           sta    ,x
  AE26:  2609         bne    LAE31
  AE28:  c702a3       sta    $02A3
  AE2B:  2004         bra    LAE31
LAE2D:
  AE2D:  4f           clra   
  AE2E:  c70283       sta    $0283
LAE31:
  AE31:  cdaf21       jsr    $AF21
  AE34:  8a           pulh   
  AE35:  81           rts    
LAE36:
  AE36:  c60267       lda    $0267
  AE39:  2704         beq    LAE3F
  AE3B:  450267       ldhx   #$0267
  AE3E:  7a           dec    ,x
LAE3F:
  AE3F:  c6026b       lda    $026B
  AE42:  2704         beq    LAE48
  AE44:  45026b       ldhx   #$026B
  AE47:  7a           dec    ,x
LAE48:
  AE48:  320268       ldhx   $0268
  AE4B:  270a         beq    LAE57
  AE4D:  65ffff       cphx   #$FFFF
  AE50:  2405         bcc    LAE57
  AE52:  af01         aix    #$01
  AE54:  960268       sthx   $0268
LAE57:
  AE57:  32026c       ldhx   $026C
  AE5A:  270a         beq    LAE66
  AE5C:  65ffff       cphx   #$FFFF
  AE5F:  2405         bcc    LAE66
  AE61:  af01         aix    #$01
  AE63:  96026c       sthx   $026C
LAE66:
  AE66:  c60299       lda    g_featureFlags
  AE69:  a401         and    #$01
  AE6B:  271e         beq    LAE8B
  AE6D:  32025c       ldhx   $025C
  AE70:  270a         beq    LAE7C
  AE72:  65ffff       cphx   #$FFFF
  AE75:  2405         bcc    LAE7C
  AE77:  af01         aix    #$01
  AE79:  96025c       sthx   $025C
LAE7C:
  AE7C:  32025e       ldhx   $025E
  AE7F:  270a         beq    LAE8B
  AE81:  65ffff       cphx   #$FFFF
  AE84:  2405         bcc    LAE8B
  AE86:  af01         aix    #$01
  AE88:  96025e       sthx   $025E
LAE8B:
  AE8B:  320260       ldhx   $0260
  AE8E:  270a         beq    LAE9A
  AE90:  65ffff       cphx   #$FFFF
  AE93:  2405         bcc    LAE9A
  AE95:  af01         aix    #$01
  AE97:  960260       sthx   $0260
LAE9A:
  AE9A:  81           rts    

;---------------------------------------------------------------
; sub_AE9B   [0xAE9B]   <- 8D6E
;---------------------------------------------------------------
  AE9B:  87           psha   
  AE9C:  95           tsx    
  AE9D:  7f           clr    ,x
  AE9E:  8c           clrh   
  AE9F:  9eee01       ldx    1,s
LAEA2:
  AEA2:  58           lslx   
  AEA3:  d602d6       lda    $02D6,x
  AEA6:  260d         bne    LAEB5
  AEA8:  d602d7       lda    $02D7,x
  AEAB:  2608         bne    LAEB5
  AEAD:  c70264       sta    $0264
  AEB0:  a60f         lda    #$0F
  AEB2:  d702d6       sta    $02D6,x
LAEB5:
  AEB5:  9eee01       ldx    1,s
  AEB8:  58           lslx   
  AEB9:  d602d6       lda    $02D6,x
  AEBC:  4b0d         dbnza  LAECB
  AEBE:  d602d7       lda    $02D7,x
  AEC1:  2608         bne    LAECB
  AEC3:  c70265       sta    $0265
  AEC6:  a60f         lda    #$0F
  AEC8:  d702d6       sta    $02D6,x
LAECB:
  AECB:  9eee01       ldx    1,s
  AECE:  58           lslx   
  AECF:  4f           clra   
  AED0:  d702d7       sta    $02D7,x
  AED3:  9e6c01       inc    1,s
  AED6:  9eee01       ldx    1,s
  AED9:  a302         cpx    #$02
  AEDB:  25c5         bcs    LAEA2
  AEDD:  95           tsx    
  AEDE:  7f           clr    ,x
  AEDF:  8c           clrh   
  AEE0:  9eee01       ldx    1,s
LAEE3:
  AEE3:  58           lslx   
  AEE4:  d602c5       lda    $02C5,x
  AEE7:  a102         cmp    #$02
  AEE9:  262a         bne    LAF15
  AEEB:  d602c6       lda    $02C6,x
  AEEE:  2620         bne    LAF10
  AEF0:  a60f         lda    #$0F
  AEF2:  d702c5       sta    $02C5,x
  AEF5:  9ee601       lda    1,s
  AEF8:  a103         cmp    #$03
  AEFA:  2406         bcc    LAF02
  AEFC:  4f           clra   
  AEFD:  c702a1       sta    $02A1
  AF00:  2013         bra    LAF15
LAF02:
  AF02:  a104         cmp    #$04
  AF04:  2604         bne    LAF0A
  AF06:  4f           clra   
  AF07:  c702a9       sta    $02A9
LAF0A:
  AF0A:  4f           clra   
  AF0B:  c702a0       sta    $02A0
  AF0E:  2005         bra    LAF15
LAF10:
  AF10:  9ee601       lda    1,s
  AF13:  a103         cmp    #$03
LAF15:
  AF15:  9e6c01       inc    1,s
  AF18:  9eee01       ldx    1,s
  AF1B:  a306         cpx    #$06
  AF1D:  25c4         bcs    LAEE3
  AF1F:  8a           pulh   
  AF20:  81           rts    

;---------------------------------------------------------------
; sub_AF21   [0xAF21]   <- AE31
;---------------------------------------------------------------
  AF21:  87           psha   
  AF22:  95           tsx    
  AF23:  7f           clr    ,x
LAF24:
  AF24:  95           tsx    
  AF25:  fe           ldx    ,x
  AF26:  58           lslx   
  AF27:  8c           clrh   
  AF28:  d602d6       lda    $02D6,x
  AF2B:  263d         bne    LAF6A
  AF2D:  d602d7       lda    $02D7,x
  AF30:  2608         bne    LAF3A
  AF32:  c70264       sta    $0264
  AF35:  a60f         lda    #$0F
  AF37:  d702d6       sta    $02D6,x
LAF3A:
  AF3A:  9eee01       ldx    1,s
  AF3D:  58           lslx   
  AF3E:  d602d7       lda    $02D7,x
  AF41:  a1f9         cmp    #$F9
  AF43:  9004         bge    LAF49
  AF45:  a609         lda    #$09
  AF47:  2006         bra    LAF4F
LAF49:
  AF49:  a108         cmp    #$08
  AF4B:  9107         blt    LAF54
  AF4D:  a607         lda    #$07
LAF4F:
  AF4F:  c702d3       sta    $02D3
  AF52:  200a         bra    LAF5E
LAF54:
  AF54:  a40f         and    #$0F
  AF56:  c702d3       sta    $02D3
  AF59:  d602d7       lda    $02D7,x
  AF5C:  a40f         and    #$0F
LAF5E:
  AF5E:  9eee01       ldx    1,s
  AF61:  d702d4       sta    $02D4,x
  AF64:  a601         lda    #$01
  AF66:  c70277       sta    $0277
  AF69:  8c           clrh   
LAF6A:
  AF6A:  9eee01       ldx    1,s
  AF6D:  58           lslx   
  AF6E:  d602d6       lda    $02D6,x
  AF71:  4a           deca   
  AF72:  263c         bne    LAFB0
  AF74:  d602d7       lda    $02D7,x
  AF77:  2608         bne    LAF81
  AF79:  c70265       sta    $0265
  AF7C:  a60f         lda    #$0F
  AF7E:  d702d6       sta    $02D6,x
LAF81:
  AF81:  9eee01       ldx    1,s
  AF84:  58           lslx   
  AF85:  d602d7       lda    $02D7,x
  AF88:  a1f9         cmp    #$F9
  AF8A:  9004         bge    LAF90
  AF8C:  a609         lda    #$09
  AF8E:  2006         bra    LAF96
LAF90:
  AF90:  a108         cmp    #$08
  AF92:  9107         blt    LAF9B
  AF94:  a607         lda    #$07
LAF96:
  AF96:  c702d2       sta    $02D2
  AF99:  200a         bra    LAFA5
LAF9B:
  AF9B:  a40f         and    #$0F
  AF9D:  c702d2       sta    $02D2
  AFA0:  d602d7       lda    $02D7,x
  AFA3:  a40f         and    #$0F
LAFA5:
  AFA5:  9eee01       ldx    1,s
  AFA8:  d702d4       sta    $02D4,x
  AFAB:  a601         lda    #$01
  AFAD:  c70277       sta    $0277
LAFB0:
  AFB0:  95           tsx    
  AFB1:  7c           inc    ,x
  AFB2:  fe           ldx    ,x
  AFB3:  a302         cpx    #$02
  AFB5:  2403         bcc    LAFBA
  AFB7:  ccaf24       jmp    $AF24
LAFBA:
  AFBA:  95           tsx    
  AFBB:  7f           clr    ,x
LAFBC:
  AFBC:  c60299       lda    g_featureFlags
  AFBF:  a402         and    #$02
  AFC1:  2747         beq    LB00A
  AFC3:  fe           ldx    ,x
  AFC4:  58           lslx   
  AFC5:  8c           clrh   
  AFC6:  d602c5       lda    $02C5,x
  AFC9:  a57f         bit    #$7F
  AFCB:  2703         beq    LAFD0
  AFCD:  ccb055       jmp    $B055
LAFD0:
  AFD0:  4f           clra   
  AFD1:  87           psha   
  AFD2:  87           psha   
  AFD3:  95           tsx    
  AFD4:  e602         lda    2,x
  AFD6:  5f           clrx   
  AFD7:  cdb307       jsr    $B307
  AFDA:  a702         ais    #$02
  AFDC:  c702d3       sta    $02D3
  AFDF:  2708         beq    LAFE9
  AFE1:  9eee01       ldx    1,s
  AFE4:  8c           clrh   
  AFE5:  a601         lda    #$01
  AFE7:  2003         bra    LAFEC
LAFE9:
  AFE9:  95           tsx    
  AFEA:  fe           ldx    ,x
  AFEB:  8c           clrh   
LAFEC:
  AFEC:  d702bf       sta    $02BF,x
  AFEF:  c60264       lda    $0264
  AFF2:  2661         bne    LB055
  AFF4:  5f           clrx   
  AFF5:  cdb40c       jsr    $B40C
  AFF8:  5f           clrx   
  AFF9:  4f           clra   
  AFFA:  cdb400       jsr    $B400
  AFFD:  95           tsx    
  AFFE:  fe           ldx    ,x
  AFFF:  58           lslx   
  B000:  8c           clrh   
  B001:  d602c5       lda    $02C5,x
  B004:  a57f         bit    #$7F
  B006:  264d         bne    LB055
  B008:  2046         bra    LB050
LB00A:
  B00A:  f6           lda    ,x
  B00B:  410447       cbeqa  #$04, LB055
  B00E:  97           tax    
  B00F:  58           lslx   
  B010:  8c           clrh   
  B011:  d602c5       lda    $02C5,x
  B014:  a57f         bit    #$7F
  B016:  263d         bne    LB055
  B018:  4f           clra   
  B019:  87           psha   
  B01A:  87           psha   
  B01B:  95           tsx    
  B01C:  e602         lda    2,x
  B01E:  5f           clrx   
  B01F:  cdb307       jsr    $B307
  B022:  a702         ais    #$02
  B024:  c702d3       sta    $02D3
  B027:  2708         beq    LB031
  B029:  9eee01       ldx    1,s
  B02C:  8c           clrh   
  B02D:  a601         lda    #$01
  B02F:  2003         bra    LB034
LB031:
  B031:  95           tsx    
  B032:  fe           ldx    ,x
  B033:  8c           clrh   
LB034:
  B034:  d702bf       sta    $02BF,x
  B037:  c60264       lda    $0264
  B03A:  2619         bne    LB055
  B03C:  5f           clrx   
  B03D:  cdb40c       jsr    $B40C
  B040:  5f           clrx   
  B041:  4f           clra   
  B042:  cdb400       jsr    $B400
  B045:  95           tsx    
  B046:  fe           ldx    ,x
  B047:  58           lslx   
  B048:  8c           clrh   
  B049:  d602c5       lda    $02C5,x
  B04C:  a57f         bit    #$7F
  B04E:  2605         bne    LB055
LB050:
  B050:  a60f         lda    #$0F
  B052:  d702c5       sta    $02C5,x
LB055:
  B055:  c60299       lda    g_featureFlags
  B058:  a402         and    #$02
  B05A:  95           tsx    
  B05B:  274d         beq    LB0AA
  B05D:  fe           ldx    ,x
  B05E:  58           lslx   
  B05F:  8c           clrh   
  B060:  d602c5       lda    $02C5,x
  B063:  a47f         and    #$7F
  B065:  a101         cmp    #$01
  B067:  2703         beq    LB06C
  B069:  ccb0fa       jmp    $B0FA
LB06C:
  B06C:  87           psha   
  B06D:  4f           clra   
  B06E:  87           psha   
  B06F:  95           tsx    
  B070:  e602         lda    2,x
  B072:  5f           clrx   
  B073:  cdb307       jsr    $B307
  B076:  a702         ais    #$02
  B078:  c702d2       sta    $02D2
  B07B:  2708         beq    LB085
  B07D:  9eee01       ldx    1,s
  B080:  8c           clrh   
  B081:  a601         lda    #$01
  B083:  2003         bra    LB088
LB085:
  B085:  95           tsx    
  B086:  fe           ldx    ,x
  B087:  8c           clrh   
LB088:
  B088:  d702bf       sta    $02BF,x
  B08B:  c60265       lda    $0265
  B08E:  266a         bne    LB0FA
  B090:  5f           clrx   
  B091:  a601         lda    #$01
  B093:  cdb40c       jsr    $B40C
  B096:  5f           clrx   
  B097:  a601         lda    #$01
  B099:  cdb400       jsr    $B400
  B09C:  95           tsx    
  B09D:  fe           ldx    ,x
  B09E:  58           lslx   
  B09F:  8c           clrh   
  B0A0:  d602c5       lda    $02C5,x
  B0A3:  a47f         and    #$7F
  B0A5:  4a           deca   
  B0A6:  2652         bne    LB0FA
  B0A8:  204b         bra    LB0F5
LB0AA:
  B0AA:  f6           lda    ,x
  B0AB:  41044c       cbeqa  #$04, LB0FA
  B0AE:  97           tax    
  B0AF:  58           lslx   
  B0B0:  8c           clrh   
  B0B1:  d602c5       lda    $02C5,x
  B0B4:  a47f         and    #$7F
  B0B6:  a101         cmp    #$01
  B0B8:  2640         bne    LB0FA
  B0BA:  87           psha   
  B0BB:  4f           clra   
  B0BC:  87           psha   
  B0BD:  95           tsx    
  B0BE:  e602         lda    2,x
  B0C0:  5f           clrx   
  B0C1:  cdb307       jsr    $B307
  B0C4:  a702         ais    #$02
  B0C6:  c702d2       sta    $02D2
  B0C9:  2708         beq    LB0D3
  B0CB:  9eee01       ldx    1,s
  B0CE:  8c           clrh   
  B0CF:  a601         lda    #$01
  B0D1:  2003         bra    LB0D6
LB0D3:
  B0D3:  95           tsx    
  B0D4:  fe           ldx    ,x
  B0D5:  8c           clrh   
LB0D6:
  B0D6:  d702bf       sta    $02BF,x
  B0D9:  c60265       lda    $0265
  B0DC:  261c         bne    LB0FA
  B0DE:  5f           clrx   
  B0DF:  a601         lda    #$01
  B0E1:  cdb40c       jsr    $B40C
  B0E4:  5f           clrx   
  B0E5:  a601         lda    #$01
  B0E7:  cdb400       jsr    $B400
  B0EA:  95           tsx    
  B0EB:  fe           ldx    ,x
  B0EC:  58           lslx   
  B0ED:  8c           clrh   
  B0EE:  d602c5       lda    $02C5,x
  B0F1:  a47f         and    #$7F
  B0F3:  4b05         dbnza  LB0FA
LB0F5:
  B0F5:  a60f         lda    #$0F
  B0F7:  d702c5       sta    $02C5,x
LB0FA:
  B0FA:  95           tsx    
  B0FB:  7c           inc    ,x
  B0FC:  f6           lda    ,x
  B0FD:  a106         cmp    #$06
  B0FF:  2403         bcc    LB104
  B101:  ccafbc       jmp    $AFBC
LB104:
  B104:  c60264       lda    $0264
  B107:  2708         beq    LB111
  B109:  c60265       lda    $0265
  B10C:  2703         beq    LB111
  B10E:  ccb2d2       jmp    $B2D2
LB111:
  B111:  7f           clr    ,x
LB112:
  B112:  c60299       lda    g_featureFlags
  B115:  a402         and    #$02
  B117:  2703         beq    LB11C
  B119:  fe           ldx    ,x
  B11A:  2005         bra    LB121
LB11C:
  B11C:  f6           lda    ,x
  B11D:  410414       cbeqa  #$04, LB134
  B120:  97           tax    
LB121:
  B121:  58           lslx   
  B122:  8c           clrh   
  B123:  d602c5       lda    $02C5,x
  B126:  a103         cmp    #$03
  B128:  260a         bne    LB134
  B12A:  d602c6       lda    $02C6,x
  B12D:  2605         bne    LB134
  B12F:  a60f         lda    #$0F
  B131:  d702c5       sta    $02C5,x
LB134:
  B134:  95           tsx    
  B135:  7c           inc    ,x
  B136:  f6           lda    ,x
  B137:  a106         cmp    #$06
  B139:  25d7         bcs    LB112
  B13B:  7f           clr    ,x
  B13C:  8c           clrh   
  B13D:  9eee01       ldx    1,s
LB140:
  B140:  58           lslx   
  B141:  d602d7       lda    $02D7,x
  B144:  2776         beq    LB1BC
  B146:  d602d6       lda    $02D6,x
  B149:  a10f         cmp    #$0F
  B14B:  266f         bne    LB1BC
  B14D:  c60264       lda    $0264
  B150:  2632         bne    LB184
  B152:  d602d7       lda    $02D7,x
  B155:  a1f9         cmp    #$F9
  B157:  9004         bge    LB15D
  B159:  a609         lda    #$09
  B15B:  2006         bra    LB163
LB15D:
  B15D:  a108         cmp    #$08
  B15F:  9107         blt    LB168
  B161:  a607         lda    #$07
LB163:
  B163:  c702d3       sta    $02D3
  B166:  200a         bra    LB172
LB168:
  B168:  a40f         and    #$0F
  B16A:  c702d3       sta    $02D3
  B16D:  d602d7       lda    $02D7,x
  B170:  a40f         and    #$0F
LB172:
  B172:  9eee01       ldx    1,s
  B175:  d702d4       sta    $02D4,x
  B178:  58           lslx   
  B179:  8c           clrh   
  B17A:  4f           clra   
  B17B:  d702d6       sta    $02D6,x
  B17E:  4c           inca   
  B17F:  c70264       sta    $0264
  B182:  2035         bra    LB1B9
LB184:
  B184:  c60265       lda    $0265
  B187:  2633         bne    LB1BC
  B189:  d602d7       lda    $02D7,x
  B18C:  a1f9         cmp    #$F9
  B18E:  9004         bge    LB194
  B190:  a609         lda    #$09
  B192:  2006         bra    LB19A
LB194:
  B194:  a108         cmp    #$08
  B196:  9107         blt    LB19F
  B198:  a607         lda    #$07
LB19A:
  B19A:  c702d2       sta    $02D2
  B19D:  200a         bra    LB1A9
LB19F:
  B19F:  a40f         and    #$0F
  B1A1:  c702d2       sta    $02D2
  B1A4:  d602d7       lda    $02D7,x
  B1A7:  a40f         and    #$0F
LB1A9:
  B1A9:  9eee01       ldx    1,s
  B1AC:  d702d4       sta    $02D4,x
  B1AF:  58           lslx   
  B1B0:  8c           clrh   
  B1B1:  a601         lda    #$01
  B1B3:  d702d6       sta    $02D6,x
  B1B6:  c70265       sta    $0265
LB1B9:
  B1B9:  c70277       sta    $0277
LB1BC:
  B1BC:  9e6c01       inc    1,s
  B1BF:  9eee01       ldx    1,s
  B1C2:  a302         cpx    #$02
  B1C4:  2403         bcc    LB1C9
  B1C6:  ccb140       jmp    $B140
LB1C9:
  B1C9:  95           tsx    
  B1CA:  7f           clr    ,x
LB1CB:
  B1CB:  c60299       lda    g_featureFlags
  B1CE:  a402         and    #$02
  B1D0:  2763         beq    LB235
  B1D2:  fe           ldx    ,x
  B1D3:  58           lslx   
  B1D4:  8c           clrh   
  B1D5:  d602c5       lda    $02C5,x
  B1D8:  a10f         cmp    #$0F
  B1DA:  2703         beq    LB1DF
LB1DC:
  B1DC:  ccb29b       jmp    $B29B
LB1DF:
  B1DF:  d602c6       lda    $02C6,x
  B1E2:  4a           deca   
  B1E3:  26f7         bne    LB1DC
  B1E5:  c60264       lda    $0264
  B1E8:  261c         bne    LB206
  B1EA:  87           psha   
  B1EB:  87           psha   
  B1EC:  95           tsx    
  B1ED:  e602         lda    2,x
  B1EF:  5f           clrx   
  B1F0:  cdb307       jsr    $B307
  B1F3:  a702         ais    #$02
  B1F5:  c702d3       sta    $02D3
  B1F8:  c602af       lda    $02AF
  B1FB:  9eee01       ldx    1,s
  B1FE:  8c           clrh   
  B1FF:  4b03         dbnza  LB204
LB201:
  B201:  4f           clra   
  B202:  2066         bra    LB26A
LB204:
  B204:  2062         bra    LB268
LB206:
  B206:  c60265       lda    $0265
  B209:  2703         beq    LB20E
  B20B:  ccb296       jmp    $B296
LB20E:
  B20E:  a601         lda    #$01
  B210:  87           psha   
  B211:  4f           clra   
  B212:  87           psha   
  B213:  95           tsx    
  B214:  e602         lda    2,x
  B216:  5f           clrx   
  B217:  cdb307       jsr    $B307
  B21A:  a702         ais    #$02
  B21C:  c702d2       sta    $02D2
  B21F:  c602af       lda    $02AF
  B222:  9eee01       ldx    1,s
  B225:  8c           clrh   
  B226:  4b02         dbnza  LB22A
  B228:  2067         bra    LB291
LB22A:
  B22A:  a601         lda    #$01
LB22C:
  B22C:  d702bf       sta    $02BF,x
  B22F:  58           lslx   
  B230:  8c           clrh   
  B231:  a601         lda    #$01
  B233:  2063         bra    LB298
LB235:
  B235:  f6           lda    ,x
  B236:  a104         cmp    #$04
  B238:  2761         beq    LB29B
  B23A:  97           tax    
  B23B:  58           lslx   
  B23C:  8c           clrh   
  B23D:  d602c5       lda    $02C5,x
  B240:  a10f         cmp    #$0F
  B242:  2657         bne    LB29B
  B244:  d602c6       lda    $02C6,x
  B247:  4a           deca   
  B248:  2651         bne    LB29B
  B24A:  c60264       lda    $0264
  B24D:  2623         bne    LB272
  B24F:  87           psha   
  B250:  87           psha   
  B251:  95           tsx    
  B252:  e602         lda    2,x
  B254:  5f           clrx   
  B255:  cdb307       jsr    $B307
  B258:  a702         ais    #$02
  B25A:  c702d3       sta    $02D3
  B25D:  c602af       lda    $02AF
  B260:  9eee01       ldx    1,s
  B263:  8c           clrh   
  B264:  4b02         dbnza  LB268
  B266:  2099         bra    LB201
LB268:
  B268:  a601         lda    #$01
LB26A:
  B26A:  d702bf       sta    $02BF,x
  B26D:  58           lslx   
  B26E:  8c           clrh   
  B26F:  4f           clra   
  B270:  2026         bra    LB298
LB272:
  B272:  c60265       lda    $0265
  B275:  261f         bne    LB296
  B277:  a601         lda    #$01
  B279:  87           psha   
  B27A:  4f           clra   
  B27B:  87           psha   
  B27C:  95           tsx    
  B27D:  e602         lda    2,x
  B27F:  5f           clrx   
  B280:  cdb307       jsr    $B307
  B283:  a702         ais    #$02
  B285:  c702d2       sta    $02D2
  B288:  c602af       lda    $02AF
  B28B:  9eee01       ldx    1,s
  B28E:  8c           clrh   
  B28F:  4b03         dbnza  LB294
LB291:
  B291:  4f           clra   
  B292:  2098         bra    LB22C
LB294:
  B294:  2094         bra    LB22A
LB296:
  B296:  a603         lda    #$03
LB298:
  B298:  d702c5       sta    $02C5,x
LB29B:
  B29B:  95           tsx    
  B29C:  7c           inc    ,x
  B29D:  f6           lda    ,x
  B29E:  a106         cmp    #$06
  B2A0:  2403         bcc    LB2A5
  B2A2:  ccb1cb       jmp    $B1CB
LB2A5:
  B2A5:  c60264       lda    $0264
  B2A8:  260f         bne    LB2B9
  B2AA:  c702d3       sta    $02D3
  B2AD:  c70266       sta    $0266
  B2B0:  5f           clrx   
  B2B1:  cdb40c       jsr    $B40C
  B2B4:  5f           clrx   
  B2B5:  4f           clra   
  B2B6:  cdb400       jsr    $B400
LB2B9:
  B2B9:  c60265       lda    $0265
  B2BC:  263e         bne    LB2FC
  B2BE:  c702d2       sta    $02D2
  B2C1:  c7026a       sta    $026A
  B2C4:  5f           clrx   
  B2C5:  a601         lda    #$01
  B2C7:  cdb40c       jsr    $B40C
  B2CA:  5f           clrx   
  B2CB:  a601         lda    #$01
  B2CD:  cdb400       jsr    $B400
  B2D0:  202a         bra    LB2FC
LB2D2:
  B2D2:  7f           clr    ,x
LB2D3:
  B2D3:  c60299       lda    g_featureFlags
  B2D6:  a402         and    #$02
  B2D8:  2703         beq    LB2DD
  B2DA:  fe           ldx    ,x
  B2DB:  2005         bra    LB2E2
LB2DD:
  B2DD:  f6           lda    ,x
  B2DE:  410414       cbeqa  #$04, LB2F5
  B2E1:  97           tax    
LB2E2:
  B2E2:  58           lslx   
  B2E3:  8c           clrh   
  B2E4:  d602c5       lda    $02C5,x
  B2E7:  a10f         cmp    #$0F
  B2E9:  260a         bne    LB2F5
  B2EB:  d602c6       lda    $02C6,x
  B2EE:  4b05         dbnza  LB2F5
  B2F0:  a603         lda    #$03
  B2F2:  d702c5       sta    $02C5,x
LB2F5:
  B2F5:  95           tsx    
  B2F6:  7c           inc    ,x
  B2F7:  f6           lda    ,x
  B2F8:  a106         cmp    #$06
  B2FA:  25d7         bcs    LB2D3
LB2FC:
  B2FC:  c602af       lda    $02AF
  B2FF:  4b04         dbnza  LB305
  B301:  4f           clra   
  B302:  c702af       sta    $02AF
LB305:
  B305:  8a           pulh   
  B306:  81           rts    

;---------------------------------------------------------------
; sub_B307   [0xB307]   <- AFD7, B01F, B073, B0C1, B1F0, B217, B255, B280
;---------------------------------------------------------------
  B307:  87           psha   
  B308:  89           pshx   
  B309:  a7fe         ais    #$FE
  B30B:  95           tsx    
  B30C:  6f01         clr    1,x
  B30E:  ee07         ldx    7,x
  B310:  58           lslx   
  B311:  58           lslx   
  B312:  8c           clrh   
  B313:  d60266       lda    $0266,x
  B316:  a47f         and    #$7F
  B318:  9ee701       sta    1,s
  B31B:  2714         beq    LB331
  B31D:  41013e       cbeqa  #$01, LB35E
  B320:  a102         cmp    #$02
  B322:  2778         beq    LB39C
  B324:  a103         cmp    #$03
  B326:  277a         beq    LB3A2
  B328:  9e6f01       clr    1,s
  B32B:  9e6f02       clr    2,s
  B32E:  ccb3d7       jmp    $B3D7
LB331:
  B331:  9eee04       ldx    4,s
  B334:  58           lslx   
  B335:  d602c6       lda    $02C6,x
  B338:  2606         bne    LB340
  B33A:  95           tsx    
  B33B:  6f01         clr    1,x
  B33D:  ccb3d7       jmp    $B3D7
LB340:
  B340:  a601         lda    #$01
  B342:  9ee701       sta    1,s
  B345:  9eee08       ldx    8,s
  B348:  58           lslx   
  B349:  58           lslx   
  B34A:  d70269       sta    $0269,x
  B34D:  4f           clra   
  B34E:  d70268       sta    $0268,x
  B351:  c60133       lda    $0133
  B354:  d70267       sta    $0267,x
  B357:  a601         lda    #$01
  B359:  95           tsx    
  B35A:  e701         sta    1,x
  B35C:  2076         bra    LB3D4
LB35E:
  B35E:  9ee702       sta    2,s
  B361:  9eee04       ldx    4,s
  B364:  58           lslx   
  B365:  d602c6       lda    $02C6,x
  B368:  261c         bne    LB386
  B36A:  9eee08       ldx    8,s
  B36D:  58           lslx   
  B36E:  58           lslx   
  B36F:  d60267       lda    $0267,x
  B372:  2607         bne    LB37B
LB374:
  B374:  95           tsx    
  B375:  7f           clr    ,x
LB376:
  B376:  95           tsx    
  B377:  6f01         clr    1,x
  B379:  2057         bra    LB3D2
LB37B:
  B37B:  a602         lda    #$02
  B37D:  95           tsx    
  B37E:  f7           sta    ,x
  B37F:  e607         lda    7,x
  B381:  5f           clrx   
  B382:  ad7c         bsr    LB400
  B384:  20f0         bra    LB376
LB386:
  B386:  9eee08       ldx    8,s
  B389:  58           lslx   
  B38A:  58           lslx   
  B38B:  9ebe0268     ldhx   $0268,x
  B38F:  650961       cphx   #$0961
  B392:  2543         bcs    LB3D7
  B394:  a603         lda    #$03
  B396:  95           tsx    
  B397:  f7           sta    ,x
  B398:  e701         sta    1,x
  B39A:  203b         bra    LB3D7
LB39C:
  B39C:  95           tsx    
  B39D:  6f01         clr    1,x
  B39F:  7f           clr    ,x
  B3A0:  2035         bra    LB3D7
LB3A2:
  B3A2:  9eee04       ldx    4,s
  B3A5:  58           lslx   
  B3A6:  d602c6       lda    $02C6,x
  B3A9:  27c9         beq    LB374
  B3AB:  9e6f02       clr    2,s
  B3AE:  9e6f01       clr    1,s
  B3B1:  a602         lda    #$02
  B3B3:  d702c5       sta    $02C5,x
  B3B6:  95           tsx    
  B3B7:  e603         lda    3,x
  B3B9:  a103         cmp    #$03
  B3BB:  2407         bcc    LB3C4
  B3BD:  a607         lda    #$07
  B3BF:  c702a1       sta    $02A1
  B3C2:  200e         bra    LB3D2
LB3C4:
  B3C4:  a104         cmp    #$04
  B3C6:  2605         bne    LB3CD
  B3C8:  a607         lda    #$07
  B3CA:  c702a9       sta    $02A9
LB3CD:
  B3CD:  a607         lda    #$07
  B3CF:  c702a0       sta    $02A0
LB3D2:
  B3D2:  a601         lda    #$01
LB3D4:
  B3D4:  c70277       sta    $0277
LB3D7:
  B3D7:  95           tsx    
  B3D8:  7d           tst    ,x
  B3D9:  2606         bne    LB3E1
  B3DB:  ee07         ldx    7,x
  B3DD:  8c           clrh   
  B3DE:  4f           clra   
  B3DF:  2005         bra    LB3E6
LB3E1:
  B3E1:  ee07         ldx    7,x
  B3E3:  8c           clrh   
  B3E4:  a601         lda    #$01
LB3E6:
  B3E6:  d70264       sta    $0264,x
  B3E9:  58           lslx   
  B3EA:  58           lslx   
  B3EB:  8c           clrh   
  B3EC:  9ee601       lda    1,s
  B3EF:  aa80         ora    #$80
  B3F1:  d40266       and    $0266,x
  B3F4:  9eea01       ora    1,s
  B3F7:  d70266       sta    $0266,x
  B3FA:  95           tsx    
  B3FB:  e601         lda    1,x
  B3FD:  a704         ais    #$04
  B3FF:  81           rts    

;---------------------------------------------------------------
; sub_B400   [0xB400]   <- AFFA, B042, B099, B0E7, B2B6, B2CD, B382
;---------------------------------------------------------------
  B400:  97           tax    
  B401:  58           lslx   
  B402:  58           lslx   
  B403:  8c           clrh   
  B404:  4f           clra   
  B405:  d70268       sta    $0268,x
  B408:  d70269       sta    $0269,x
  B40B:  81           rts    

;---------------------------------------------------------------
; sub_B40C   [0xB40C]   <- AFF5, B03D, B093, B0E1, B2B1, B2C7
;---------------------------------------------------------------
  B40C:  97           tax    
  B40D:  58           lslx   
  B40E:  58           lslx   
  B40F:  8c           clrh   
  B410:  4f           clra   
  B411:  d70267       sta    $0267,x
  B414:  81           rts    

;---------------------------------------------------------------
; Ports_Init   [0xB415]   <- 8779
;---------------------------------------------------------------
  B415:  a601         lda    #$01
  B417:  c7026f       sta    $026F
  B41A:  a61c         lda    #$1C
  B41C:  c71809       sta    SPMSC1
  B41F:  a601         lda    #$01
  B421:  c7180a       sta    SPMSC2
  B424:  4f           clra   
  B425:  c70000       sta    PTAD
  B428:  4a           deca   
  B429:  c70001       sta    PTADD
  B42C:  450001       ldhx   #$0001
  B42F:  f6           lda    ,x
  B430:  a4fd         and    #$FD
  B432:  f7           sta    ,x
  B433:  a6ff         lda    #$FF
  B435:  c71841       sta    PTASE
  B438:  4f           clra   
  B439:  c71842       sta    PTADS
  B43C:  c70002       sta    PTBD
  B43F:  4a           deca   
  B440:  c70003       sta    PTBDD
  B443:  c71845       sta    PTBSE
  B446:  4f           clra   
  B447:  c71846       sta    PTBDS
  B44A:  450004       ldhx   #$0004
  B44D:  f6           lda    ,x
  B44E:  aa01         ora    #$01
  B450:  f7           sta    ,x
  B451:  a6ff         lda    #$FF
  B453:  c70005       sta    PTCDD
  B456:  450005       ldhx   #$0005
  B459:  f6           lda    ,x
  B45A:  a4c1         and    #$C1
  B45C:  f7           sta    ,x
  B45D:  f6           lda    ,x
  B45E:  aa01         ora    #$01
  B460:  f7           sta    ,x
  B461:  a602         lda    #$02
  B463:  c71848       sta    PTCPE
  B466:  4f           clra   
  B467:  c71849       sta    PTCSE
  B46A:  c7184a       sta    PTCDS
  B46D:  c70006       sta    PTDD
  B470:  4a           deca   
  B471:  c70007       sta    PTDDD
  B474:  450007       ldhx   #$0007
  B477:  f6           lda    ,x
  B478:  a4f0         and    #$F0
  B47A:  f7           sta    ,x
  B47B:  4f           clra   
  B47C:  c7184c       sta    PTDPE
  B47F:  c7184d       sta    PTDSE
  B482:  c7184e       sta    PTDDS
  B485:  450008       ldhx   #$0008
  B488:  f6           lda    ,x
  B489:  aa81         ora    #$81
  B48B:  f7           sta    ,x
  B48C:  450009       ldhx   #$0009
  B48F:  f6           lda    ,x
  B490:  aafd         ora    #$FD
  B492:  f7           sta    ,x
  B493:  f6           lda    ,x
  B494:  a4d7         and    #$D7
  B496:  f7           sta    ,x
  B497:  a628         lda    #$28
  B499:  c71850       sta    PTEPE
  B49C:  4f           clra   
  B49D:  c71851       sta    PTESE
  B4A0:  c71852       sta    PTEDS
  B4A3:  c7000a       sta    PTFD
  B4A6:  a6df         lda    #$DF
  B4A8:  c7000b       sta    PTFDD
  B4AB:  45000b       ldhx   #$000B
  B4AE:  f6           lda    ,x
  B4AF:  a4df         and    #$DF
  B4B1:  f7           sta    ,x
  B4B2:  4f           clra   
  B4B3:  c71854       sta    PTFPE
  B4B6:  c71855       sta    PTFSE
  B4B9:  c71856       sta    PTFDS
  B4BC:  c7000c       sta    PTGD
  B4BF:  4a           deca   
  B4C0:  c7000d       sta    PTGDD
  B4C3:  45000d       ldhx   #$000D
  B4C6:  f6           lda    ,x
  B4C7:  a490         and    #$90
  B4C9:  f7           sta    ,x
  B4CA:  a660         lda    #$60
  B4CC:  c71858       sta    PTGPE
  B4CF:  4f           clra   
  B4D0:  c71859       sta    PTGSE
  B4D3:  c7185a       sta    PTGDS
  B4D6:  81           rts    

;---------------------------------------------------------------
; Diag_Task   [0xB4D7]   <- 8908
;---------------------------------------------------------------
  B4D7:  450001       ldhx   #$0001
  B4DA:  f6           lda    ,x
  B4DB:  aa01         ora    #$01
  B4DD:  f7           sta    ,x
  B4DE:  f6           lda    ,x
  B4DF:  a4fd         and    #$FD
  B4E1:  f7           sta    ,x
  B4E2:  450003       ldhx   #$0003
  B4E5:  f6           lda    ,x
  B4E6:  a4fb         and    #$FB
  B4E8:  f7           sta    ,x
  B4E9:  450005       ldhx   #$0005
  B4EC:  f6           lda    ,x
  B4ED:  a4c1         and    #$C1
  B4EF:  f7           sta    ,x
  B4F0:  f6           lda    ,x
  B4F1:  aa01         ora    #$01
  B4F3:  f7           sta    ,x
  B4F4:  450007       ldhx   #$0007
  B4F7:  f6           lda    ,x
  B4F8:  a4f0         and    #$F0
  B4FA:  f7           sta    ,x
  B4FB:  450009       ldhx   #$0009
  B4FE:  f6           lda    ,x
  B4FF:  a4bf         and    #$BF
  B501:  f7           sta    ,x
  B502:  f6           lda    ,x
  B503:  aa8c         ora    #$8C
  B505:  f7           sta    ,x
  B506:  45000b       ldhx   #$000B
  B509:  f6           lda    ,x
  B50A:  aa11         ora    #$11
  B50C:  f7           sta    ,x
  B50D:  f6           lda    ,x
  B50E:  a4df         and    #$DF
  B510:  f7           sta    ,x
  B511:  45000d       ldhx   #$000D
  B514:  f6           lda    ,x
  B515:  a490         and    #$90
  B517:  f7           sta    ,x
  B518:  81           rts    

;---------------------------------------------------------------
; Ports_NvmPinLow   [0xB519]   <- 899B
;---------------------------------------------------------------
  B519:  450008       ldhx   #$0008
  B51C:  f6           lda    ,x
  B51D:  a47f         and    #$7F
  B51F:  f7           sta    ,x
  B520:  81           rts    

;---------------------------------------------------------------
; Ports_NvmPinHigh   [0xB521]   <- 89AA, 89CB
;---------------------------------------------------------------
  B521:  450008       ldhx   #$0008
  B524:  f6           lda    ,x
  B525:  aa80         ora    #$80
  B527:  f7           sta    ,x
  B528:  81           rts    

;---------------------------------------------------------------
; Ports_PrepareSleep   [0xB529]   <- 8958
;---------------------------------------------------------------
  B529:  450004       ldhx   #$0004
  B52C:  f6           lda    ,x
  B52D:  a4fe         and    #$FE
  B52F:  f7           sta    ,x
  B530:  450008       ldhx   #$0008
  B533:  f6           lda    ,x
  B534:  a4fe         and    #$FE
  B536:  f7           sta    ,x
  B537:  450009       ldhx   #$0009
  B53A:  f6           lda    ,x
  B53B:  aa01         ora    #$01
  B53D:  f7           sta    ,x
  B53E:  81           rts    

;---------------------------------------------------------------
; Ports_AllInputs   [0xB53F]   <- 895B
;---------------------------------------------------------------
  B53F:  4f           clra   
  B540:  c70001       sta    PTADD
  B543:  c70003       sta    PTBDD
  B546:  a681         lda    #$81
  B548:  c70005       sta    PTCDD
  B54B:  4f           clra   
  B54C:  c70007       sta    PTDDD
  B54F:  4c           inca   
  B550:  c70009       sta    PTEDD
  B553:  4f           clra   
  B554:  c7000b       sta    PTFDD
  B557:  c7000d       sta    PTGDD
  B55A:  81           rts    

;---------------------------------------------------------------
; Isr_Kbi   [0xB55B]
;---------------------------------------------------------------
  B55B:  8b           pshh   
  B55C:  a7fb         ais    #$FB
  B55E:  3202b4       ldhx   $02B4
  B561:  9eff01       sthx   1,s
  B564:  c60275       lda    g_outputVariant
  B567:  4b09         dbnza  LB572
  B569:  a664         lda    #$64
  B56B:  c70029       sta    TPM1C1VH
  B56E:  4f           clra   
  B56F:  c7002a       sta    TPM1C1VL
LB572:
  B572:  a6c8         lda    #$C8
  B574:  95           tsx    
  B575:  e702         sta    2,x
  B577:  4f           clra   
  B578:  c0002d       sub    TPM1C2VL
  B57B:  e703         sta    3,x
  B57D:  e602         lda    2,x
  B57F:  c2002c       sbc    TPM1C2VH
  B582:  e702         sta    2,x
  B584:  c602b3       lda    $02B3
  B587:  4b0f         dbnza  LB598
  B589:  4f           clra   
  B58A:  e001         sub    1,x
  B58C:  87           psha   
  B58D:  a6c8         lda    #$C8
  B58F:  f2           sbc    ,x
  B590:  97           tax    
  B591:  86           pula   
  B592:  cf002c       stx    TPM1C2VH
  B595:  c7002d       sta    TPM1C2VL
LB598:
  B598:  450020       ldhx   #$0020
  B59B:  f6           lda    ,x
  B59C:  a47f         and    #$7F
  B59E:  f7           sta    ,x
  B59F:  a705         ais    #$05
  B5A1:  8a           pulh   
  B5A2:  80           rti    

;---------------------------------------------------------------
; Diag_Init   [0xB5A3]   <- 8797, AA01
;---------------------------------------------------------------
  B5A3:  ad7b         bsr    Diag_sub_B620
  B5A5:  4f           clra   
  B5A6:  c70270       sta    $0270
  B5A9:  81           rts    

;---------------------------------------------------------------
; Diag_SlowTask   [0xB5AA]   <- 8944
;---------------------------------------------------------------
  B5AA:  c60270       lda    $0270
  B5AD:  2715         beq    LB5C4
  B5AF:  ad6f         bsr    Diag_sub_B620
  B5B1:  45000a       ldhx   #$000A
  B5B4:  f6           lda    ,x
  B5B5:  aa01         ora    #$01
  B5B7:  f7           sta    ,x
  B5B8:  5f           clrx   
  B5B9:  a664         lda    #$64
  B5BB:  cdb653       jsr    Delay_Loop
  B5BE:  4f           clra   
  B5BF:  c70270       sta    $0270
  B5C2:  ad20         bsr    LB5E4
LB5C4:
  B5C4:  c60275       lda    g_outputVariant
  B5C7:  260c         bne    LB5D5
  B5C9:  c60276       lda    g_ctrlErrFlag
  B5CC:  2607         bne    LB5D5
  B5CE:  45000a       ldhx   #$000A
  B5D1:  f6           lda    ,x
  B5D2:  a4fe         and    #$FE
  B5D4:  f7           sta    ,x
LB5D5:
  B5D5:  81           rts    

;---------------------------------------------------------------
; sub_B5D6   [0xB5D6]   <- A9F9
;---------------------------------------------------------------
  B5D6:  87           psha   
  B5D7:  95           tsx    
  B5D8:  7f           clr    ,x
  B5D9:  c6002b       lda    TPM1C2SC
  B5DC:  a420         and    #$20
  B5DE:  2702         beq    LB5E2
  B5E0:  a601         lda    #$01
LB5E2:
  B5E2:  8a           pulh   
  B5E3:  81           rts    

;---------------------------------------------------------------
; sub_B5E4   [0xB5E4]   <- AA07, B5C2
;---------------------------------------------------------------
  B5E4:  a7fe         ais    #$FE
  B5E6:  c60020       lda    TPM1SC
  B5E9:  c701aa       sta    $01AA
  B5EC:  4f           clra   
  B5ED:  c70020       sta    TPM1SC
  B5F0:  c60270       lda    $0270
  B5F3:  2622         bne    LB617
  B5F5:  c702b3       sta    $02B3
  B5F8:  45000a       ldhx   #$000A
  B5FB:  f6           lda    ,x
  B5FC:  a4fe         and    #$FE
  B5FE:  f7           sta    ,x
  B5FF:  a6c8         lda    #$C8
  B601:  c7002c       sta    TPM1C2VH
  B604:  4f           clra   
  B605:  c7002d       sta    TPM1C2VL
  B608:  a624         lda    #$24
  B60A:  c7002b       sta    TPM1C2SC
  B60D:  a655         lda    #$55
  B60F:  c70022       sta    TPM1CNTL
  B612:  a601         lda    #$01
  B614:  c702b3       sta    $02B3
LB617:
  B617:  c601aa       lda    $01AA
  B61A:  c70020       sta    TPM1SC
  B61D:  a702         ais    #$02
  B61F:  81           rts    

;---------------------------------------------------------------
; Diag_sub_B620   [0xB620]   <- A9EF, Diag_Init, B5AF
;---------------------------------------------------------------
  B620:  45000a       ldhx   #$000A
  B623:  f6           lda    ,x
  B624:  a4fe         and    #$FE
  B626:  f7           sta    ,x
  B627:  4f           clra   
  B628:  c7002b       sta    TPM1C2SC
  B62B:  f6           lda    ,x
  B62C:  a4fe         and    #$FE
  B62E:  f7           sta    ,x
  B62F:  a6c8         lda    #$C8
  B631:  c7002c       sta    TPM1C2VH
  B634:  4f           clra   
  B635:  c7002d       sta    TPM1C2VL
  B638:  81           rts    

;---------------------------------------------------------------
; sub_B639   [0xB639]
;---------------------------------------------------------------
  B639:  4f           clra   
  B63A:  c7002b       sta    TPM1C2SC
  B63D:  45000a       ldhx   #$000A
  B640:  f6           lda    ,x
  B641:  aa01         ora    #$01
  B643:  f7           sta    ,x
  B644:  a6c8         lda    #$C8
  B646:  c7002c       sta    TPM1C2VH
  B649:  4f           clra   
  B64A:  c7002d       sta    TPM1C2VL
  B64D:  5f           clrx   
  B64E:  a664         lda    #$64
  B650:  ccb653       jmp    Delay_Loop

;---------------------------------------------------------------
; Delay_Loop   [0xB653]   <- A114, A394, A414, A8D2, A964, A974, B5BB, B969
;---------------------------------------------------------------
  B653:  450000       ldhx   #$0000
  B656:  97           tax    
LB657:
  B657:  afff         aix    #$FF
  B659:  650000       cphx   #$0000
  B65C:  21f9         brn    LB657
  B65E:  21f7         brn    LB657
  B660:  21f5         brn    LB657
  B662:  21f3         brn    LB657
  B664:  26f1         bne    LB657
  B666:  81           rts    

;---------------------------------------------------------------
; Motor_sub_B667   [0xB667]   <- B81A, BA29, BA78
;---------------------------------------------------------------
  B667:  87           psha   
  B668:  89           pshx   
  B669:  a7f9         ais    #$F9
  B66B:  95           tsx    
  B66C:  6d0e         tst    14,x
  B66E:  2606         bne    LB676
  B670:  9ece0f       ldhx   15,x
  B673:  7f           clr    ,x
  B674:  200b         bra    LB681
LB676:
  B676:  e10c         cmp    12,x
  B678:  260a         bne    LB684
  B67A:  9ece0f       ldhx   15,x
  B67D:  7f           clr    ,x
  B67E:  95           tsx    
  B67F:  e608         lda    8,x
LB681:
  B681:  a709         ais    #$09
  B683:  81           rts    
LB684:
  B684:  e60c         lda    12,x
  B686:  e701         sta    1,x
  B688:  7f           clr    ,x
  B689:  e608         lda    8,x
  B68B:  e001         sub    1,x
  B68D:  e705         sta    5,x
  B68F:  4f           clra   
  B690:  f2           sbc    ,x
  B691:  e704         sta    4,x
  B693:  9ece04       ldhx   4,x
  B696:  95           tsx    
  B697:  9104         blt    LB69D
  B699:  e605         lda    5,x
  B69B:  2003         bra    LB6A0
LB69D:
  B69D:  e605         lda    5,x
  B69F:  40           nega   
LB6A0:
  B6A0:  e706         sta    6,x
  B6A2:  e10e         cmp    14,x
  B6A4:  251f         bcs    LB6C5
  B6A6:  3fc6         clr    g_mulDiv_tmp
  B6A8:  ee0e         ldx    14,x
  B6AA:  8c           clrh   
  B6AB:  cdc078       jsr    muls8b
  B6AE:  95           tsx    
  B6AF:  e703         sta    3,x
  B6B1:  b6c6         lda    g_mulDiv_tmp
  B6B3:  e702         sta    2,x
  B6B5:  9ece04       ldhx   4,x
  B6B8:  9041         bge    LB6FB
  B6BA:  95           tsx    
  B6BB:  6302         com    2,x
  B6BD:  6003         neg    3,x
  B6BF:  253a         bcs    LB6FB
  B6C1:  6c02         inc    2,x
  B6C3:  2036         bra    LB6FB
LB6C5:
  B6C5:  e60e         lda    14,x
  B6C7:  3fc6         clr    g_mulDiv_tmp
  B6C9:  ee06         ldx    6,x
  B6CB:  8c           clrh   
  B6CC:  cdc078       jsr    muls8b
  B6CF:  9efe10       ldhx   16,s
  B6D2:  87           psha   
  B6D3:  f6           lda    ,x
  B6D4:  95           tsx    
  B6D5:  f0           sub    ,x
  B6D6:  4f           clra   
  B6D7:  b2c6         sbc    g_mulDiv_tmp
  B6D9:  86           pula   
  B6DA:  900a         bge    LB6E6
  B6DC:  6f03         clr    3,x
  B6DE:  6f04         clr    4,x
  B6E0:  9ece10       ldhx   16,x
  B6E3:  7c           inc    ,x
  B6E4:  2019         bra    LB6FF
LB6E6:
  B6E6:  95           tsx    
  B6E7:  e608         lda    8,x
  B6E9:  e10c         cmp    12,x
  B6EB:  2505         bcs    LB6F2
  B6ED:  5f           clrx   
  B6EE:  a601         lda    #$01
  B6F0:  2003         bra    LB6F5
LB6F2:
  B6F2:  a6ff         lda    #$FF
  B6F4:  97           tax    
LB6F5:
  B6F5:  9ee704       sta    4,s
  B6F8:  9eef03       stx    3,s
LB6FB:
  B6FB:  9efe10       ldhx   16,s
  B6FE:  7f           clr    ,x
LB6FF:
  B6FF:  95           tsx    
  B700:  e603         lda    3,x
  B702:  eb0c         add    12,x
  B704:  a709         ais    #$09
  B706:  81           rts    

;---------------------------------------------------------------
; sub_B707   [0xB707]   <- B828
;---------------------------------------------------------------
  B707:  87           psha   
  B708:  89           pshx   
  B709:  a7fb         ais    #$FB
  B70B:  9efe0a       ldhx   10,s
  B70E:  f6           lda    ,x
  B70F:  95           tsx    
  B710:  e106         cmp    6,x
  B712:  2503         bcs    LB717
  B714:  ccb7ab       jmp    $B7AB
LB717:
  B717:  7f           clr    ,x
LB718:
  B718:  9efe0a       ldhx   10,s
  B71B:  f6           lda    ,x
  B71C:  e102         cmp    2,x
  B71E:  2407         bcc    LB727
  B720:  af02         aix    #$02
  B722:  9eff0a       sthx   10,s
  B725:  2007         bra    LB72E
LB727:
  B727:  a601         lda    #$01
  B729:  95           tsx    
  B72A:  f7           sta    ,x
  B72B:  9ece09       ldhx   9,x
LB72E:
  B72E:  f6           lda    ,x
  B72F:  95           tsx    
  B730:  e106         cmp    6,x
  B732:  2403         bcc    LB737
  B734:  7d           tst    ,x
  B735:  27e1         beq    LB718
LB737:
  B737:  7d           tst    ,x
  B738:  2671         bne    LB7AB
  B73A:  9ece09       ldhx   9,x
  B73D:  e601         lda    1,x
  B73F:  d0ffff       sub    $FFFF,x
  B742:  250e         bcs    LB752
  B744:  d6ffff       lda    $FFFF,x
  B747:  e001         sub    1,x
  B749:  40           nega   
  B74A:  95           tsx    
  B74B:  e703         sta    3,x
  B74D:  a601         lda    #$01
  B74F:  f7           sta    ,x
  B750:  2005         bra    LB757
LB752:
  B752:  40           nega   
  B753:  95           tsx    
  B754:  e703         sta    3,x
  B756:  7f           clr    ,x
LB757:
  B757:  9efe0a       ldhx   10,s
  B75A:  d6fffe       lda    $FFFE,x
  B75D:  f0           sub    ,x
  B75E:  40           nega   
  B75F:  95           tsx    
  B760:  e704         sta    4,x
  B762:  e606         lda    6,x
  B764:  3fc6         clr    g_mulDiv_tmp
  B766:  9ece09       ldhx   9,x
  B769:  d0fffe       sub    $FFFE,x
  B76C:  2402         bcc    LB770
  B76E:  3ac6         dec    g_mulDiv_tmp
LB770:
  B770:  95           tsx    
  B771:  ee03         ldx    3,x
  B773:  8c           clrh   
  B774:  cdc0cb       jsr    mul16
  B777:  9eee05       ldx    5,s
  B77A:  8c           clrh   
  B77B:  cdc127       jsr    div16
  B77E:  95           tsx    
  B77F:  e702         sta    2,x
  B781:  b6c6         lda    g_mulDiv_tmp
  B783:  e701         sta    1,x
  B785:  f6           lda    ,x
  B786:  9ece09       ldhx   9,x
  B789:  4b0f         dbnza  LB79A
  B78B:  9ee603       lda    3,s
  B78E:  dbffff       add    $FFFF,x
  B791:  95           tsx    
  B792:  e702         sta    2,x
  B794:  241f         bcc    LB7B5
  B796:  6c01         inc    1,x
  B798:  201b         bra    LB7B5
LB79A:
  B79A:  d6ffff       lda    $FFFF,x
  B79D:  95           tsx    
  B79E:  e002         sub    2,x
  B7A0:  e702         sta    2,x
  B7A2:  4f           clra   
  B7A3:  e201         sbc    1,x
  B7A5:  e701         sta    1,x
  B7A7:  e602         lda    2,x
  B7A9:  200a         bra    LB7B5
LB7AB:
  B7AB:  9efe0a       ldhx   10,s
  B7AE:  e601         lda    1,x
  B7B0:  95           tsx    
  B7B1:  e702         sta    2,x
  B7B3:  6f01         clr    1,x
LB7B5:
  B7B5:  a707         ais    #$07
  B7B7:  81           rts    

;---------------------------------------------------------------
; EnterCritical   [0xB7B8]   <- App_InitAll, 881B, 899E, 8C27, 8C47, 8E11, BE19
;---------------------------------------------------------------
  B7B8:  9b           sei    
  B7B9:  c60108       lda    g_criticalNesting
  B7BC:  a17e         cmp    #$7E
  B7BE:  2404         bcc    LB7C4
  B7C0:  450108       ldhx   #$0108
  B7C3:  7c           inc    ,x
LB7C4:
  B7C4:  81           rts    

;---------------------------------------------------------------
; ExitCritical   [0xB7C5]   <- 882F, 89C6, 8C2D, 8C8E, 8E30, BEB1
;---------------------------------------------------------------
  B7C5:  c60108       lda    g_criticalNesting
  B7C8:  2708         beq    LB7D2
  B7CA:  a17f         cmp    #$7F
  B7CC:  2404         bcc    LB7D2
  B7CE:  450108       ldhx   #$0108
  B7D1:  7a           dec    ,x
LB7D2:
  B7D2:  c60108       lda    g_criticalNesting
  B7D5:  2601         bne    LB7D8
  B7D7:  9a           cli    
LB7D8:
  B7D8:  81           rts    

;---------------------------------------------------------------
; Heater_Init   [0xB7D9]   <- 87C4
;---------------------------------------------------------------
  B7D9:  a646         lda    #$46
  B7DB:  c7028a       sta    $028A
  B7DE:  a606         lda    #$06
  B7E0:  c70273       sta    $0273
  B7E3:  4f           clra   
  B7E4:  c702a5       sta    $02A5
  B7E7:  81           rts    

;---------------------------------------------------------------
; Heater_Task   [0xB7E8]   <- 88F4, 8919
;---------------------------------------------------------------
  B7E8:  87           psha   
  B7E9:  5f           clrx   
  B7EA:  a603         lda    #$03
  B7EC:  cda103       jsr    Adc_Read
  B7EF:  95           tsx    
  B7F0:  f7           sta    ,x
  B7F1:  a1f8         cmp    #$F8
  B7F3:  2507         bcs    LB7FC
  B7F5:  a6ff         lda    #$FF
  B7F7:  f7           sta    ,x
  B7F8:  a60a         lda    #$0A
  B7FA:  2034         bra    LB830
LB7FC:
  B7FC:  a115         cmp    #$15
  B7FE:  2407         bcc    LB807
  B800:  a6ff         lda    #$FF
  B802:  f7           sta    ,x
  B803:  a607         lda    #$07
  B805:  2029         bra    LB830
LB807:
  B807:  45010a       ldhx   #$010A
  B80A:  89           pshx   
  B80B:  8b           pshh   
  B80C:  a604         lda    #$04
  B80E:  87           psha   
  B80F:  4f           clra   
  B810:  87           psha   
  B811:  c60109       lda    $0109
  B814:  5f           clrx   
  B815:  87           psha   
  B816:  89           pshx   
  B817:  9ee607       lda    7,s
  B81A:  cdb667       jsr    Motor_sub_B667
  B81D:  a706         ais    #$06
  B81F:  c70109       sta    $0109
  B822:  450135       ldhx   #$0135
  B825:  89           pshx   
  B826:  8b           pshh   
  B827:  5f           clrx   
  B828:  cdb707       jsr    $B707
  B82B:  a702         ais    #$02
  B82D:  95           tsx    
  B82E:  f7           sta    ,x
  B82F:  4f           clra   
LB830:
  B830:  c702a5       sta    $02A5
  B833:  c60273       lda    $0273
  B836:  270f         beq    LB847
  B838:  450273       ldhx   #$0273
  B83B:  7a           dec    ,x
  B83C:  a646         lda    #$46
  B83E:  c7028a       sta    $028A
  B841:  4f           clra   
  B842:  c702a5       sta    $02A5
  B845:  2004         bra    LB84B
LB847:
  B847:  f6           lda    ,x
  B848:  c7028a       sta    $028A
LB84B:
  B84B:  8a           pulh   
  B84C:  81           rts    

;---------------------------------------------------------------
; Inputs_Init   [0xB84D]   <- 8782
;---------------------------------------------------------------
  B84D:  87           psha   
  B84E:  95           tsx    
  B84F:  7f           clr    ,x
  B850:  a60f         lda    #$0F
  B852:  c702d6       sta    $02D6
  B855:  4f           clra   
  B856:  c702d7       sta    $02D7
  B859:  a60f         lda    #$0F
  B85B:  c702d8       sta    $02D8
  B85E:  4f           clra   
  B85F:  c702d9       sta    $02D9
  B862:  c702d3       sta    $02D3
  B865:  c702d1       sta    $02D1
  B868:  7f           clr    ,x
  B869:  8c           clrh   
  B86A:  9eee01       ldx    1,s
LB86D:
  B86D:  58           lslx   
  B86E:  a60f         lda    #$0F
  B870:  d702c5       sta    $02C5,x
  B873:  4f           clra   
  B874:  d702c6       sta    $02C6,x
  B877:  9eee01       ldx    1,s
  B87A:  d702bf       sta    $02BF,x
  B87D:  5c           incx   
  B87E:  9eef01       stx    1,s
  B881:  a306         cpx    #$06
  B883:  25e8         bcs    LB86D
  B885:  c702be       sta    $02BE
  B888:  c702bd       sta    $02BD
  B88B:  c702bc       sta    $02BC
  B88E:  c702b9       sta    g_nvmSaveRequest
  B891:  c702b7       sta    $02B7
  B894:  c702b8       sta    $02B8
  B897:  c702b6       sta    g_supplyVoltage
  B89A:  c702b4       sta    $02B4
  B89D:  c702b5       sta    $02B5
  B8A0:  4c           inca   
  B8A1:  c702b3       sta    $02B3
  B8A4:  4f           clra   
  B8A5:  c702b2       sta    $02B2
  B8A8:  c702b1       sta    $02B1
  B8AB:  4c           inca   
  B8AC:  c702b0       sta    g_testRequest
  B8AF:  4f           clra   
  B8B0:  c702ae       sta    g_linAppFlags
  B8B3:  c7029d       sta    g_cfgDefaults
  B8B6:  95           tsx    
  B8B7:  7f           clr    ,x
  B8B8:  8c           clrh   
  B8B9:  9eee01       ldx    1,s
LB8BC:
  B8BC:  d7029f       sta    $029F,x
  B8BF:  5c           incx   
  B8C0:  a30f         cpx    #$0F
  B8C2:  25f8         bcs    LB8BC
  B8C4:  9eef01       stx    1,s
  B8C7:  c7029c       sta    $029C
  B8CA:  c7029b       sta    $029B
  B8CD:  a602         lda    #$02
  B8CF:  c7029a       sta    $029A
  B8D2:  95           tsx    
  B8D3:  7f           clr    ,x
  B8D4:  8c           clrh   
  B8D5:  4f           clra   
  B8D6:  9eee01       ldx    1,s
LB8D9:
  B8D9:  d70278       sta    $0278,x
  B8DC:  5c           incx   
  B8DD:  a31f         cpx    #$1F
  B8DF:  25f8         bcs    LB8D9
  B8E1:  9eef01       stx    1,s
  B8E4:  c70277       sta    $0277
  B8E7:  c70276       sta    g_ctrlErrFlag
  B8EA:  c60299       lda    g_featureFlags
  B8ED:  a401         and    #$01
  B8EF:  2611         bne    LB902
  B8F1:  c602ea       lda    g_testMode
  B8F4:  260c         bne    LB902
  B8F6:  a607         lda    #$07
  B8F8:  c702a3       sta    $02A3
  B8FB:  c702a4       sta    $02A4
  B8FE:  4f           clra   
  B8FF:  c702bb       sta    $02BB
LB902:
  B902:  c60299       lda    g_featureFlags
  B905:  a404         and    #$04
  B907:  260a         bne    LB913
  B909:  c602ea       lda    g_testMode
  B90C:  2605         bne    LB913
  B90E:  a607         lda    #$07
  B910:  c702a8       sta    $02A8
LB913:
  B913:  c60299       lda    g_featureFlags
  B916:  a402         and    #$02
  B918:  2612         bne    LB92C
  B91A:  c602ea       lda    g_testMode
  B91D:  260d         bne    LB92C
  B91F:  a607         lda    #$07
  B921:  c702a5       sta    $02A5
  B924:  c702a9       sta    $02A9
  B927:  a6ff         lda    #$FF
  B929:  c7028a       sta    $028A
LB92C:
  B92C:  4f           clra   
  B92D:  c70275       sta    g_outputVariant
  B930:  8a           pulh   
  B931:  81           rts    

;---------------------------------------------------------------
; Supply_Init   [0xB932]   <- 87A3, BA60
;---------------------------------------------------------------
  B932:  a7fd         ais    #$FD
  B934:  a601         lda    #$01
  B936:  c702db       sta    $02DB
  B939:  450000       ldhx   #$0000
  B93C:  f6           lda    ,x
  B93D:  aa01         ora    #$01
  B93F:  f7           sta    ,x
  B940:  c60169       lda    $0169
  B943:  2704         beq    LB949
  B945:  a140         cmp    #$40
  B947:  2502         bcs    LB94B
LB949:
  B949:  a619         lda    #$19
LB94B:
  B94B:  c702e1       sta    g_tempCode
  B94E:  c60168       lda    $0168
  B951:  a147         cmp    #$47
  B953:  2508         bcs    LB95D
  B955:  a1c8         cmp    #$C8
  B957:  2404         bcc    LB95D
  B959:  a023         sub    #$23
  B95B:  2002         bra    LB95F
LB95D:
  B95D:  a623         lda    #$23
LB95F:
  B95F:  c702e2       sta    g_tempValue
  B962:  97           tax    
  B963:  8c           clrh   
  B964:  af41         aix    #$41
  B966:  9f           txa    
  B967:  8b           pshh   
  B968:  88           pulx   
  B969:  cdb653       jsr    Delay_Loop
  B96C:  4f           clra   
  B96D:  95           tsx    
  B96E:  e702         sta    2,x
  B970:  8c           clrh   
LB971:
  B971:  ae03         ldx    #$03
  B973:  42           mul    
  B974:  97           tax    
  B975:  4f           clra   
  B976:  d702e3       sta    $02E3,x
  B979:  9ee603       lda    3,s
  B97C:  ae03         ldx    #$03
  B97E:  42           mul    
  B97F:  87           psha   
  B980:  8b           pshh   
  B981:  9ee605       lda    5,s
  B984:  ae06         ldx    #$06
  B986:  42           mul    
  B987:  97           tax    
  B988:  d6c239       lda    $C239,x
  B98B:  9ee704       sta    4,s
  B98E:  9ebec237     ldhx   $C237,x
  B992:  f6           lda    ,x
  B993:  95           tsx    
  B994:  e702         sta    2,x
  B996:  e604         lda    4,x
  B998:  ae06         ldx    #$06
  B99A:  42           mul    
  B99B:  8c           clrh   
  B99C:  97           tax    
  B99D:  d6c239       lda    $C239,x
  B9A0:  95           tsx    
  B9A1:  e402         and    2,x
  B9A3:  e403         and    3,x
  B9A5:  8a           pulh   
  B9A6:  88           pulx   
  B9A7:  d702e4       sta    $02E4,x
  B9AA:  95           tsx    
  B9AB:  e602         lda    2,x
  B9AD:  ae03         ldx    #$03
  B9AF:  42           mul    
  B9B0:  8c           clrh   
  B9B1:  87           psha   
  B9B2:  8b           pshh   
  B9B3:  9ee605       lda    5,s
  B9B6:  ae06         ldx    #$06
  B9B8:  42           mul    
  B9B9:  97           tax    
  B9BA:  d6c23c       lda    $C23C,x
  B9BD:  9ee704       sta    4,s
  B9C0:  9ebec23a     ldhx   $C23A,x
  B9C4:  f6           lda    ,x
  B9C5:  95           tsx    
  B9C6:  e702         sta    2,x
  B9C8:  e604         lda    4,x
  B9CA:  ae06         ldx    #$06
  B9CC:  42           mul    
  B9CD:  8c           clrh   
  B9CE:  97           tax    
  B9CF:  d6c23c       lda    $C23C,x
  B9D2:  95           tsx    
  B9D3:  e402         and    2,x
  B9D5:  e403         and    3,x
  B9D7:  8a           pulh   
  B9D8:  88           pulx   
  B9D9:  d702e5       sta    $02E5,x
  B9DC:  9eee03       ldx    3,s
  B9DF:  8c           clrh   
  B9E0:  a602         lda    #$02
  B9E2:  d702dd       sta    $02DD,x
  B9E5:  9e6c03       inc    3,s
  B9E8:  9ee603       lda    3,s
  B9EB:  a102         cmp    #$02
  B9ED:  2582         bcs    LB971
  B9EF:  450000       ldhx   #$0000
  B9F2:  f6           lda    ,x
  B9F3:  a4fe         and    #$FE
  B9F5:  f7           sta    ,x
  B9F6:  4f           clra   
  B9F7:  c702dc       sta    $02DC
  B9FA:  a703         ais    #$03
  B9FC:  81           rts    

;---------------------------------------------------------------
; Supply_Task   [0xB9FD]   <- 8892
;---------------------------------------------------------------
  B9FD:  87           psha   
  B9FE:  450000       ldhx   #$0000
  BA01:  f6           lda    ,x
  BA02:  aa01         ora    #$01
  BA04:  f7           sta    ,x
  BA05:  5f           clrx   
  BA06:  a60a         lda    #$0A
  BA08:  cda103       jsr    Adc_Read
  BA0B:  95           tsx    
  BA0C:  f7           sta    ,x
  BA0D:  a14e         cmp    #$4E
  BA0F:  2554         bcs    LBA65
  BA11:  c602db       lda    $02DB
  BA14:  4b4a         dbnza  LBA60
  BA16:  4502dc       ldhx   #$02DC
  BA19:  89           pshx   
  BA1A:  8b           pshh   
  BA1B:  a602         lda    #$02
  BA1D:  87           psha   
  BA1E:  4f           clra   
  BA1F:  87           psha   
  BA20:  c602b6       lda    g_supplyVoltage
  BA23:  5f           clrx   
  BA24:  87           psha   
  BA25:  89           pshx   
  BA26:  9ee607       lda    7,s
  BA29:  cdb667       jsr    Motor_sub_B667
  BA2C:  a706         ais    #$06
  BA2E:  c702b6       sta    g_supplyVoltage
  BA31:  cda13a       jsr    Ctrl_sub_A13A
  BA34:  c602e2       lda    g_tempValue
  BA37:  5f           clrx   
  BA38:  cdb653       jsr    Delay_Loop
  BA3B:  4f           clra   
  BA3C:  95           tsx    
  BA3D:  f7           sta    ,x
LBA3E:
  BA3E:  5f           clrx   
  BA3F:  ad4f         bsr    Supply_sub_BA90
  BA41:  95           tsx    
  BA42:  f6           lda    ,x
  BA43:  48           lsla   
  BA44:  8c           clrh   
  BA45:  87           psha   
  BA46:  9ee602       lda    2,s
  BA49:  ae03         ldx    #$03
  BA4B:  42           mul    
  BA4C:  97           tax    
  BA4D:  d602e3       lda    $02E3,x
  BA50:  88           pulx   
  BA51:  db02d7       add    $02D7,x
  BA54:  d702d7       sta    $02D7,x
  BA57:  95           tsx    
  BA58:  7c           inc    ,x
  BA59:  f6           lda    ,x
  BA5A:  a102         cmp    #$02
  BA5C:  25e0         bcs    LBA3E
  BA5E:  2027         bra    LBA87
LBA60:
  BA60:  cdb932       jsr    Supply_Init
  BA63:  2022         bra    LBA87
LBA65:
  BA65:  4502dc       ldhx   #$02DC
  BA68:  89           pshx   
  BA69:  8b           pshh   
  BA6A:  a602         lda    #$02
  BA6C:  87           psha   
  BA6D:  4f           clra   
  BA6E:  87           psha   
  BA6F:  c602b6       lda    g_supplyVoltage
  BA72:  5f           clrx   
  BA73:  87           psha   
  BA74:  89           pshx   
  BA75:  9ee607       lda    7,s
  BA78:  cdb667       jsr    Motor_sub_B667
  BA7B:  a706         ais    #$06
  BA7D:  c702b6       sta    g_supplyVoltage
  BA80:  cda13a       jsr    Ctrl_sub_A13A
  BA83:  4f           clra   
  BA84:  c702db       sta    $02DB
LBA87:
  BA87:  450000       ldhx   #$0000
  BA8A:  f6           lda    ,x
  BA8B:  a4fe         and    #$FE
  BA8D:  f7           sta    ,x
  BA8E:  8a           pulh   
  BA8F:  81           rts    

;---------------------------------------------------------------
; Supply_sub_BA90   [0xBA90]   <- BA3F
;---------------------------------------------------------------
  BA90:  87           psha   
  BA91:  89           pshx   
  BA92:  a7fb         ais    #$FB
  BA94:  95           tsx    
  BA95:  6f03         clr    3,x
  BA97:  6f04         clr    4,x
  BA99:  97           tax    
  BA9A:  8c           clrh   
  BA9B:  4f           clra   
  BA9C:  d702df       sta    $02DF,x
  BA9F:  9ee607       lda    7,s
  BAA2:  ae06         ldx    #$06
  BAA4:  42           mul    
  BAA5:  97           tax    
  BAA6:  9ebec237     ldhx   $C237,x
  BAAA:  f6           lda    ,x
  BAAB:  95           tsx    
  BAAC:  f7           sta    ,x
  BAAD:  e606         lda    6,x
  BAAF:  ae06         ldx    #$06
  BAB1:  42           mul    
  BAB2:  8c           clrh   
  BAB3:  97           tax    
  BAB4:  d6c239       lda    $C239,x
  BAB7:  9ee401       and    1,s
  BABA:  9ee702       sta    2,s
  BABD:  9ebec23a     ldhx   $C23A,x
  BAC1:  f6           lda    ,x
  BAC2:  95           tsx    
  BAC3:  f7           sta    ,x
  BAC4:  e606         lda    6,x
  BAC6:  ae06         ldx    #$06
  BAC8:  42           mul    
  BAC9:  8c           clrh   
  BACA:  97           tax    
  BACB:  d6c23c       lda    $C23C,x
  BACE:  95           tsx    
  BACF:  f4           and    ,x
  BAD0:  e702         sta    2,x
  BAD2:  c602e1       lda    g_tempCode
  BAD5:  5f           clrx   
  BAD6:  cdb653       jsr    Delay_Loop
  BAD9:  95           tsx    
  BADA:  e606         lda    6,x
  BADC:  ae06         ldx    #$06
  BADE:  42           mul    
  BADF:  8c           clrh   
  BAE0:  97           tax    
  BAE1:  9ebec237     ldhx   $C237,x
  BAE5:  f6           lda    ,x
  BAE6:  95           tsx    
  BAE7:  f7           sta    ,x
  BAE8:  e606         lda    6,x
  BAEA:  ae06         ldx    #$06
  BAEC:  42           mul    
  BAED:  8c           clrh   
  BAEE:  97           tax    
  BAEF:  d6c239       lda    $C239,x
  BAF2:  9ee401       and    1,s
  BAF5:  9ee102       cmp    2,s
  BAF8:  261e         bne    LBB18
  BAFA:  9ebec23a     ldhx   $C23A,x
  BAFE:  f6           lda    ,x
  BAFF:  95           tsx    
  BB00:  f7           sta    ,x
  BB01:  e606         lda    6,x
  BB03:  ae06         ldx    #$06
  BB05:  42           mul    
  BB06:  8c           clrh   
  BB07:  97           tax    
  BB08:  d6c23c       lda    $C23C,x
  BB0B:  9ee401       and    1,s
  BB0E:  9ee103       cmp    3,s
  BB11:  2605         bne    LBB18
  BB13:  a601         lda    #$01
  BB15:  9ee705       sta    5,s
LBB18:
  BB18:  9ee607       lda    7,s
  BB1B:  ae03         ldx    #$03
  BB1D:  42           mul    
  BB1E:  97           tax    
  BB1F:  d602e4       lda    $02E4,x
  BB22:  9ee102       cmp    2,s
  BB25:  270b         beq    LBB32
  BB27:  d602e5       lda    $02E5,x
  BB2A:  9ee103       cmp    3,s
  BB2D:  2703         beq    LBB32
LBB2F:
  BB2F:  ccbc0a       jmp    $BC0A
LBB32:
  BB32:  9ee605       lda    5,s
  BB35:  4a           deca   
  BB36:  26f7         bne    LBB2F
  BB38:  d602e4       lda    $02E4,x
  BB3B:  9ee102       cmp    2,s
  BB3E:  273c         beq    LBB7C
  BB40:  9ee607       lda    7,s
  BB43:  ae06         ldx    #$06
  BB45:  42           mul    
  BB46:  97           tax    
  BB47:  d6c23c       lda    $C23C,x
  BB4A:  9ee103       cmp    3,s
  BB4D:  2617         bne    LBB66
  BB4F:  d6c239       lda    $C239,x
  BB52:  9ee102       cmp    2,s
  BB55:  2717         beq    LBB6E
LBB57:
  BB57:  9eee07       ldx    7,s
  BB5A:  d602df       lda    $02DF,x
  BB5D:  2666         bne    LBBC5
  BB5F:  a601         lda    #$01
  BB61:  d702dd       sta    $02DD,x
  BB64:  204d         bra    LBBB3
LBB66:
  BB66:  d6c239       lda    $C239,x
  BB69:  9ee102       cmp    2,s
  BB6C:  27e9         beq    LBB57
LBB6E:
  BB6E:  9eee07       ldx    7,s
  BB71:  d602dd       lda    $02DD,x
  BB74:  a102         cmp    #$02
  BB76:  264d         bne    LBBC5
  BB78:  a6ff         lda    #$FF
  BB7A:  2046         bra    LBBC2
LBB7C:
  BB7C:  d602e5       lda    $02E5,x
  BB7F:  9ee103       cmp    3,s
  BB82:  2741         beq    LBBC5
  BB84:  9ee607       lda    7,s
  BB87:  ae06         ldx    #$06
  BB89:  42           mul    
  BB8A:  97           tax    
  BB8B:  d6c239       lda    $C239,x
  BB8E:  9ee102       cmp    2,s
  BB91:  260a         bne    LBB9D
  BB93:  d6c23c       lda    $C23C,x
  BB96:  9ee103       cmp    3,s
  BB99:  260a         bne    LBBA5
  BB9B:  201b         bra    LBBB8
LBB9D:
  BB9D:  d6c23c       lda    $C23C,x
  BBA0:  9ee103       cmp    3,s
  BBA3:  2613         bne    LBBB8
LBBA5:
  BBA5:  9eee07       ldx    7,s
  BBA8:  d602df       lda    $02DF,x
  BBAB:  2618         bne    LBBC5
  BBAD:  a602         lda    #$02
  BBAF:  d702dd       sta    $02DD,x
  BBB2:  4a           deca   
LBBB3:
  BBB3:  d702df       sta    $02DF,x
  BBB6:  200d         bra    LBBC5
LBBB8:
  BBB8:  9eee07       ldx    7,s
  BBBB:  d602dd       lda    $02DD,x
  BBBE:  a101         cmp    #$01
  BBC0:  2603         bne    LBBC5
LBBC2:
  BBC2:  95           tsx    
  BBC3:  e703         sta    3,x
LBBC5:
  BBC5:  95           tsx    
  BBC6:  e606         lda    6,x
  BBC8:  ae03         ldx    #$03
  BBCA:  42           mul    
  BBCB:  8c           clrh   
  BBCC:  97           tax    
  BBCD:  9ee604       lda    4,s
  BBD0:  d702e3       sta    $02E3,x
  BBD3:  9ee607       lda    7,s
  BBD6:  ae03         ldx    #$03
  BBD8:  42           mul    
  BBD9:  87           psha   
  BBDA:  8b           pshh   
  BBDB:  9ee609       lda    9,s
  BBDE:  ae06         ldx    #$06
  BBE0:  42           mul    
  BBE1:  97           tax    
  BBE2:  d6c23c       lda    $C23C,x
  BBE5:  95           tsx    
  BBE6:  e404         and    4,x
  BBE8:  8a           pulh   
  BBE9:  88           pulx   
  BBEA:  d702e5       sta    $02E5,x
  BBED:  95           tsx    
  BBEE:  e606         lda    6,x
  BBF0:  ae03         ldx    #$03
  BBF2:  42           mul    
  BBF3:  8c           clrh   
  BBF4:  87           psha   
  BBF5:  8b           pshh   
  BBF6:  9ee609       lda    9,s
  BBF9:  ae06         ldx    #$06
  BBFB:  42           mul    
  BBFC:  97           tax    
  BBFD:  d6c239       lda    $C239,x
  BC00:  95           tsx    
  BC01:  e403         and    3,x
  BC03:  8a           pulh   
  BC04:  88           pulx   
  BC05:  d702e4       sta    $02E4,x
  BC08:  2047         bra    LBC51
LBC0A:
  BC0A:  9ee605       lda    5,s
  BC0D:  4b37         dbnza  LBC46
  BC0F:  9ee607       lda    7,s
  BC12:  ae03         ldx    #$03
  BC14:  42           mul    
  BC15:  8c           clrh   
  BC16:  87           psha   
  BC17:  8b           pshh   
  BC18:  9ee609       lda    9,s
  BC1B:  ae06         ldx    #$06
  BC1D:  42           mul    
  BC1E:  97           tax    
  BC1F:  d6c23c       lda    $C23C,x
  BC22:  95           tsx    
  BC23:  e404         and    4,x
  BC25:  8a           pulh   
  BC26:  88           pulx   
  BC27:  d702e5       sta    $02E5,x
  BC2A:  95           tsx    
  BC2B:  e606         lda    6,x
  BC2D:  ae03         ldx    #$03
  BC2F:  42           mul    
  BC30:  8c           clrh   
  BC31:  87           psha   
  BC32:  8b           pshh   
  BC33:  9ee609       lda    9,s
  BC36:  ae06         ldx    #$06
  BC38:  42           mul    
  BC39:  97           tax    
  BC3A:  d6c239       lda    $C239,x
  BC3D:  95           tsx    
  BC3E:  e403         and    3,x
  BC40:  8a           pulh   
  BC41:  88           pulx   
  BC42:  d702e4       sta    $02E4,x
  BC45:  8c           clrh   
LBC46:
  BC46:  9ee607       lda    7,s
  BC49:  ae03         ldx    #$03
  BC4B:  42           mul    
  BC4C:  97           tax    
  BC4D:  4f           clra   
  BC4E:  d702e3       sta    $02E3,x
LBC51:
  BC51:  a707         ais    #$07
  BC53:  81           rts    

;---------------------------------------------------------------
; Outputs_Init   [0xBC54]   <- 878B
;---------------------------------------------------------------
  BC54:  c61800       lda    SRS
  BC57:  c7010b       sta    $010B
  BC5A:  a480         and    #$80
  BC5C:  2647         bne    LBCA5
  BC5E:  c6010b       lda    $010B
  BC61:  a440         and    #$40
  BC63:  2710         beq    LBC75
  BC65:  c60164       lda    $0164
  BC68:  a1fe         cmp    #$FE
  BC6A:  2409         bcc    LBC75
  BC6C:  450164       ldhx   #$0164
  BC6F:  7c           inc    ,x
  BC70:  a601         lda    #$01
  BC72:  c702b9       sta    g_nvmSaveRequest
LBC75:
  BC75:  c6010b       lda    $010B
  BC78:  a460         and    #$60
  BC7A:  a120         cmp    #$20
  BC7C:  2610         bne    LBC8E
  BC7E:  c60165       lda    $0165
  BC81:  a1fe         cmp    #$FE
  BC83:  2409         bcc    LBC8E
  BC85:  450165       ldhx   #$0165
  BC88:  7c           inc    ,x
  BC89:  a601         lda    #$01
  BC8B:  c702b9       sta    g_nvmSaveRequest
LBC8E:
  BC8E:  c6010b       lda    $010B
  BC91:  a404         and    #$04
  BC93:  2710         beq    LBCA5
  BC95:  c60167       lda    $0167
  BC98:  a1fe         cmp    #$FE
  BC9A:  2409         bcc    LBCA5
  BC9C:  450167       ldhx   #$0167
  BC9F:  7c           inc    ,x
  BCA0:  a601         lda    #$01
  BCA2:  c702b9       sta    g_nvmSaveRequest
LBCA5:
  BCA5:  090408       brclr  4, PTCD, LBCB0
  BCA8:  a601         lda    #$01
  BCAA:  c70275       sta    g_outputVariant
  BCAD:  cdbeb7       jsr    Adc_sub_BEB7
LBCB0:
  BCB0:  81           rts    

;---------------------------------------------------------------
; Outputs_Task   [0xBCB1]   <- 88E3, 893B
;---------------------------------------------------------------
  BCB1:  ad1a         bsr    LBCCD
  BCB3:  cdbd7d       jsr    $BD7D
  BCB6:  c602ae       lda    g_linAppFlags
  BCB9:  410808       cbeqa  #$08, LBCC4
  BCBC:  411005       cbeqa  #$10, LBCC4
  BCBF:  c6029d       lda    g_cfgDefaults
  BCC2:  4b06         dbnza  LBCCA
LBCC4:
  BCC4:  a60e         lda    #$0E
LBCC6:
  BCC6:  c702a2       sta    g_diagState
  BCC9:  81           rts    
LBCCA:
  BCCA:  4f           clra   
  BCCB:  20f9         bra    LBCC6

;---------------------------------------------------------------
; sub_BCCD   [0xBCCD]   <- Outputs_Task
;---------------------------------------------------------------
  BCCD:  a7fc         ais    #$FC
  BCCF:  32010c       ldhx   $010C
  BCD2:  65036d       cphx   #$036D
  BCD5:  2472         bcc    LBD49
  BCD7:  c6010d       lda    $010D
  BCDA:  ce010c       ldx    $010C
  BCDD:  48           lsla   
  BCDE:  59           rolx   
  BCDF:  48           lsla   
  BCE0:  59           rolx   
  BCE1:  48           lsla   
  BCE2:  59           rolx   
  BCE3:  48           lsla   
  BCE4:  59           rolx   
  BCE5:  48           lsla   
  BCE6:  59           rolx   
  BCE7:  ab02         add    #$02
  BCE9:  9ee702       sta    2,s
  BCEC:  9f           txa    
  BCED:  a986         adc    #$86
  BCEF:  95           tsx    
  BCF0:  f7           sta    ,x
  BCF1:  2028         bra    LBD1B
LBCF3:
  BCF3:  9efe01       ldhx   1,s
  BCF6:  9eae         ldhx   ,x
  BCF8:  9eff03       sthx   3,s
  BCFB:  9f           txa    
  BCFC:  c80110       eor    $0110
  BCFF:  c70110       sta    $0110
  BD02:  c6010f       lda    $010F
  BD05:  95           tsx    
  BD06:  e802         eor    2,x
  BD08:  c7010f       sta    $010F
  BD0B:  9ece02       ldhx   2,x
  BD0E:  af01         aix    #$01
  BD10:  9eff03       sthx   3,s
  BD13:  9efe01       ldhx   1,s
  BD16:  af02         aix    #$02
  BD18:  9eff01       sthx   1,s
LBD1B:
  BD1B:  c6010d       lda    $010D
  BD1E:  ce010c       ldx    $010C
  BD21:  48           lsla   
  BD22:  59           rolx   
  BD23:  48           lsla   
  BD24:  59           rolx   
  BD25:  48           lsla   
  BD26:  59           rolx   
  BD27:  48           lsla   
  BD28:  59           rolx   
  BD29:  48           lsla   
  BD2A:  59           rolx   
  BD2B:  ab22         add    #$22
  BD2D:  87           psha   
  BD2E:  9f           txa    
  BD2F:  a986         adc    #$86
  BD31:  97           tax    
  BD32:  86           pula   
  BD33:  99           sec    
  BD34:  9ee202       sbc    2,s
  BD37:  9f           txa    
  BD38:  95           tsx    
  BD39:  f2           sbc    ,x
  BD3A:  24b7         bcc    LBCF3
  BD3C:  32010c       ldhx   $010C
  BD3F:  af01         aix    #$01
  BD41:  96010c       sthx   $010C
  BD44:  c6010e       lda    $010E
  BD47:  2005         bra    LBD4E
LBD49:
  BD49:  a601         lda    #$01
  BD4B:  c7010e       sta    $010E
LBD4E:
  BD4E:  4b2a         dbnza  LBD7A
  BD50:  32010f       ldhx   $010F
  BD53:  9602b7       sthx   $02B7
  BD56:  65cafe       cphx   #$CAFE
  BD59:  2708         beq    LBD63
  BD5B:  4502ae       ldhx   #$02AE
  BD5E:  f6           lda    ,x
  BD5F:  aa10         ora    #$10
  BD61:  2006         bra    LBD69
LBD63:
  BD63:  4502ae       ldhx   #$02AE
  BD66:  f6           lda    ,x
  BD67:  a4ef         and    #$EF
LBD69:
  BD69:  f7           sta    ,x
  BD6A:  4f           clra   
  BD6B:  c7010e       sta    $010E
  BD6E:  c7010f       sta    $010F
  BD71:  c70110       sta    $0110
  BD74:  c7010c       sta    $010C
  BD77:  c7010d       sta    $010D
LBD7A:
  BD7A:  a704         ais    #$04
  BD7C:  81           rts    

;---------------------------------------------------------------
; sub_BD7D   [0xBD7D]   <- BCB3
;---------------------------------------------------------------
  BD7D:  a7fd         ais    #$FD
  BD7F:  95           tsx    
  BD80:  6f02         clr    2,x
  BD82:  c60111       lda    $0111
  BD85:  a501         bit    #$01
  BD87:  2703         beq    LBD8C
  BD89:  ccbe19       jmp    $BE19
LBD8C:
  BD8C:  c60113       lda    $0113
  BD8F:  ce0112       ldx    $0112
  BD92:  48           lsla   
  BD93:  59           rolx   
  BD94:  48           lsla   
  BD95:  59           rolx   
  BD96:  ab70         add    #$70
  BD98:  2401         bcc    LBD9B
  BD9A:  5c           incx   
LBD9B:
  BD9B:  9ee702       sta    2,s
  BD9E:  9eef01       stx    1,s
  BDA1:  2028         bra    LBDCB
LBDA3:
  BDA3:  a6aa         lda    #$AA
  BDA5:  f7           sta    ,x
  BDA6:  95           tsx    
  BDA7:  6c02         inc    2,x
  BDA9:  9eae         ldhx   ,x
  BDAB:  f6           lda    ,x
  BDAC:  a1aa         cmp    #$AA
  BDAE:  260c         bne    LBDBC
  BDB0:  a655         lda    #$55
  BDB2:  f7           sta    ,x
  BDB3:  95           tsx    
  BDB4:  6c02         inc    2,x
  BDB6:  9eae         ldhx   ,x
  BDB8:  f6           lda    ,x
  BDB9:  415507       cbeqa  #$55, LBDC3
LBDBC:
  BDBC:  450111       ldhx   #$0111
  BDBF:  f6           lda    ,x
  BDC0:  aa02         ora    #$02
  BDC2:  f7           sta    ,x
LBDC3:
  BDC3:  9efe01       ldhx   1,s
  BDC6:  af01         aix    #$01
  BDC8:  9eff01       sthx   1,s
LBDCB:
  BDCB:  c60113       lda    $0113
  BDCE:  ce0112       ldx    $0112
  BDD1:  48           lsla   
  BDD2:  59           rolx   
  BDD3:  48           lsla   
  BDD4:  59           rolx   
  BDD5:  ab74         add    #$74
  BDD7:  2401         bcc    LBDDA
  BDD9:  5c           incx   
LBDDA:
  BDDA:  99           sec    
  BDDB:  9ee202       sbc    2,s
  BDDE:  9f           txa    
  BDDF:  95           tsx    
  BDE0:  f2           sbc    ,x
  BDE1:  2507         bcs    LBDEA
  BDE3:  9eae         ldhx   ,x
  BDE5:  65007a       cphx   #$007A
  BDE8:  25b9         bcs    LBDA3
LBDEA:
  BDEA:  9efe01       ldhx   1,s
  BDED:  650079       cphx   #$0079
  BDF0:  450111       ldhx   #$0111
  BDF3:  f6           lda    ,x
  BDF4:  2504         bcs    LBDFA
  BDF6:  aa01         ora    #$01
  BDF8:  2002         bra    LBDFC
LBDFA:
  BDFA:  a4fe         and    #$FE
LBDFC:
  BDFC:  f7           sta    ,x
  BDFD:  c60111       lda    $0111
  BE00:  a401         and    #$01
  BE02:  270a         beq    LBE0E
  BE04:  4f           clra   
  BE05:  c70112       sta    $0112
  BE08:  c70113       sta    $0113
  BE0B:  ccbeb4       jmp    $BEB4
LBE0E:
  BE0E:  320112       ldhx   $0112
  BE11:  af01         aix    #$01
  BE13:  960112       sthx   $0112
  BE16:  ccbeb4       jmp    $BEB4
LBE19:
  BE19:  cdb7b8       jsr    EnterCritical
  BE1C:  c60113       lda    $0113
  BE1F:  ce0112       ldx    $0112
  BE22:  48           lsla   
  BE23:  59           rolx   
  BE24:  48           lsla   
  BE25:  59           rolx   
  BE26:  ab7a         add    #$7A
  BE28:  2401         bcc    LBE2B
  BE2A:  5c           incx   
LBE2B:
  BE2B:  c70073       sta    $0073
  BE2E:  cf0072       stx    $0072
  BE31:  320072       ldhx   $0072
  BE34:  af03         aix    #$03
  BE36:  960070       sthx   $0070
  BE39:  320072       ldhx   $0072
  BE3C:  960074       sthx   $0074
  BE3F:  2739         beq    LBE7A
  BE41:  202f         bra    LBE72
LBE43:
  BE43:  f6           lda    ,x
  BE44:  c70076       sta    $0076
  BE47:  a6aa         lda    #$AA
  BE49:  f7           sta    ,x
  BE4A:  95           tsx    
  BE4B:  6c02         inc    2,x
  BE4D:  320074       ldhx   $0074
  BE50:  f6           lda    ,x
  BE51:  a1aa         cmp    #$AA
  BE53:  260d         bne    LBE62
  BE55:  a655         lda    #$55
  BE57:  f7           sta    ,x
  BE58:  95           tsx    
  BE59:  6c02         inc    2,x
  BE5B:  320074       ldhx   $0074
  BE5E:  f6           lda    ,x
  BE5F:  41550a       cbeqa  #$55, LBE6C
LBE62:
  BE62:  450111       ldhx   #$0111
  BE65:  f6           lda    ,x
  BE66:  aa02         ora    #$02
  BE68:  f7           sta    ,x
  BE69:  320074       ldhx   $0074
LBE6C:
  BE6C:  c60076       lda    $0076
  BE6F:  f7           sta    ,x
  BE70:  af01         aix    #$01
LBE72:
  BE72:  960074       sthx   $0074
  BE75:  3e0070       cphx   $0070
  BE78:  23c9         bls    LBE43
LBE7A:
  BE7A:  6501f6       cphx   #$01F6
  BE7D:  262a         bne    LBEA9
  BE7F:  4f           clra   
  BE80:  c70112       sta    $0112
  BE83:  c70113       sta    $0113
  BE86:  450111       ldhx   #$0111
  BE89:  f6           lda    ,x
  BE8A:  a4fe         and    #$FE
  BE8C:  f7           sta    ,x
  BE8D:  a402         and    #$02
  BE8F:  2708         beq    LBE99
  BE91:  4502ae       ldhx   #$02AE
  BE94:  f6           lda    ,x
  BE95:  aa08         ora    #$08
  BE97:  2006         bra    LBE9F
LBE99:
  BE99:  4502ae       ldhx   #$02AE
  BE9C:  f6           lda    ,x
  BE9D:  a4f7         and    #$F7
LBE9F:
  BE9F:  f7           sta    ,x
  BEA0:  450111       ldhx   #$0111
  BEA3:  f6           lda    ,x
  BEA4:  a4fd         and    #$FD
  BEA6:  f7           sta    ,x
  BEA7:  2008         bra    LBEB1
LBEA9:
  BEA9:  320112       ldhx   $0112
  BEAC:  af01         aix    #$01
  BEAE:  960112       sthx   $0112
LBEB1:
  BEB1:  cdb7c5       jsr    ExitCritical
LBEB4:
  BEB4:  a703         ais    #$03
  BEB6:  81           rts    

;---------------------------------------------------------------
; Adc_sub_BEB7   [0xBEB7]   <- BCAD
;---------------------------------------------------------------
  BEB7:  4f           clra   
  BEB8:  c7026f       sta    $026F
  BEBB:  c6ffbe       lda    $FFBE
  BEBE:  c7004e       sta    ICGTRM
  BEC1:  81           rts    

;---------------------------------------------------------------
; Adc_Init   [0xBEC2]   <- 877F
;---------------------------------------------------------------
  BEC2:  ad03         bsr    Adc_DetectVariant
  BEC4:  ccbfa7       jmp    Variant_ReadStraps

;---------------------------------------------------------------
; Adc_DetectVariant   [0xBEC7]   <- Adc_Init
;---------------------------------------------------------------
  BEC7:  87           psha   
  BEC8:  5f           clrx   
  BEC9:  a60b         lda    #$0B
  BECB:  cda103       jsr    Adc_Read
  BECE:  95           tsx    
  BECF:  f7           sta    ,x
  BED0:  4f           clra   
  BED1:  c702ea       sta    g_testMode
  BED4:  f6           lda    ,x
  BED5:  a111         cmp    #$11
  BED7:  2510         bcs    LBEE9
  BED9:  a119         cmp    #$19
  BEDB:  240c         bcc    LBEE9
  BEDD:  a601         lda    #$01
  BEDF:  c702ec       sta    g_variantCode
  BEE2:  c702eb       sta    g_variantSub
  BEE5:  4f           clra   
  BEE6:  ccbf96       jmp    $BF96
LBEE9:
  BEE9:  a11d         cmp    #$1D
  BEEB:  2511         bcs    LBEFE
  BEED:  a126         cmp    #$26
  BEEF:  240d         bcc    LBEFE
  BEF1:  a602         lda    #$02
  BEF3:  c702ec       sta    g_variantCode
  BEF6:  4a           deca   
  BEF7:  c702eb       sta    g_variantSub
  BEFA:  4c           inca   
  BEFB:  ccbf96       jmp    $BF96
LBEFE:
  BEFE:  a12a         cmp    #$2A
  BF00:  2512         bcs    LBF14
  BF02:  a134         cmp    #$34
  BF04:  240e         bcc    LBF14
  BF06:  a603         lda    #$03
  BF08:  c702ec       sta    g_variantCode
  BF0B:  44           lsra   
  BF0C:  c702eb       sta    g_variantSub
  BF0F:  a601         lda    #$01
  BF11:  ccbf96       jmp    $BF96
LBF14:
  BF14:  a139         cmp    #$39
  BF16:  2512         bcs    LBF2A
  BF18:  a144         cmp    #$44
  BF1A:  240e         bcc    LBF2A
  BF1C:  a604         lda    #$04
  BF1E:  c702ec       sta    g_variantCode
  BF21:  a601         lda    #$01
  BF23:  c702eb       sta    g_variantSub
  BF26:  a603         lda    #$03
  BF28:  206c         bra    LBF96
LBF2A:
  BF2A:  a16a         cmp    #$6A
  BF2C:  2512         bcs    LBF40
  BF2E:  a177         cmp    #$77
  BF30:  240e         bcc    LBF40
  BF32:  a607         lda    #$07
  BF34:  c702ec       sta    g_variantCode
  BF37:  a601         lda    #$01
  BF39:  c702eb       sta    g_variantSub
  BF3C:  a608         lda    #$08
  BF3E:  2056         bra    LBF96
LBF40:
  BF40:  a17c         cmp    #$7C
  BF42:  2512         bcs    LBF56
  BF44:  a18a         cmp    #$8A
  BF46:  240e         bcc    LBF56
  BF48:  a608         lda    #$08
  BF4A:  c702ec       sta    g_variantCode
  BF4D:  a601         lda    #$01
  BF4F:  c702eb       sta    g_variantSub
  BF52:  a609         lda    #$09
  BF54:  2040         bra    LBF96
LBF56:
  BF56:  a18e         cmp    #$8E
  BF58:  2512         bcs    LBF6C
  BF5A:  a19e         cmp    #$9E
  BF5C:  240e         bcc    LBF6C
  BF5E:  a609         lda    #$09
  BF60:  c702ec       sta    g_variantCode
  BF63:  a601         lda    #$01
  BF65:  c702eb       sta    g_variantSub
  BF68:  a60f         lda    #$0F
  BF6A:  202a         bra    LBF96
LBF6C:
  BF6C:  a1a3         cmp    #$A3
  BF6E:  2512         bcs    LBF82
  BF70:  a1b2         cmp    #$B2
  BF72:  240e         bcc    LBF82
  BF74:  a60a         lda    #$0A
  BF76:  c702ec       sta    g_variantCode
  BF79:  a601         lda    #$01
  BF7B:  c702eb       sta    g_variantSub
  BF7E:  a60c         lda    #$0C
  BF80:  2014         bra    LBF96
LBF82:
  BF82:  a1b7         cmp    #$B7
  BF84:  2515         bcs    LBF9B
  BF86:  a1c9         cmp    #$C9
  BF88:  2411         bcc    LBF9B
  BF8A:  a60b         lda    #$0B
  BF8C:  c702ec       sta    g_variantCode
  BF8F:  a601         lda    #$01
  BF91:  c702eb       sta    g_variantSub
  BF94:  a60b         lda    #$0B
LBF96:
  BF96:  c70299       sta    g_featureFlags
  BF99:  200a         bra    LBFA5
LBF9B:
  BF9B:  a60e         lda    #$0E
  BF9D:  c702ec       sta    g_variantCode
  BFA0:  a601         lda    #$01
  BFA2:  c702ea       sta    g_testMode
LBFA5:
  BFA5:  8a           pulh   
  BFA6:  81           rts    
LBFA7:
  BFA7:  a7f8         ais    #$F8
  BFA9:  4f           clra   
  BFAA:  c70298       sta    g_codingByte
  BFAD:  95           tsx    
  BFAE:  6f02         clr    2,x
LBFB0:
  BFB0:  95           tsx    
  BFB1:  ee02         ldx    2,x
  BFB3:  58           lslx   
  BFB4:  8c           clrh   
  BFB5:  d6c246       lda    $C246,x
  BFB8:  9ee702       sta    2,s
  BFBB:  dec245       ldx    $C245,x
  BFBE:  f6           lda    ,x
  BFBF:  9ee701       sta    1,s
  BFC2:  9eee03       ldx    3,s
  BFC5:  58           lslx   
  BFC6:  d6c246       lda    $C246,x
  BFC9:  95           tsx    
  BFCA:  f4           and    ,x
  BFCB:  e101         cmp    1,x
  BFCD:  af03         aix    #$03
  BFCF:  9f           txa    
  BFD0:  270e         beq    LBFE0
  BFD2:  9eeb03       add    3,s
  BFD5:  97           tax    
  BFD6:  2405         bcc    LBFDD
  BFD8:  8b           pshh   
  BFD9:  9e6c01       inc    1,s
  BFDC:  8a           pulh   
LBFDD:
  BFDD:  7f           clr    ,x
  BFDE:  200e         bra    LBFEE
LBFE0:
  BFE0:  9eeb03       add    3,s
  BFE3:  97           tax    
  BFE4:  2405         bcc    LBFEB
  BFE6:  8b           pshh   
  BFE7:  9e6c01       inc    1,s
  BFEA:  8a           pulh   
LBFEB:
  BFEB:  a601         lda    #$01
  BFED:  f7           sta    ,x
LBFEE:
  BFEE:  95           tsx    
  BFEF:  af03         aix    #$03
  BFF1:  9f           txa    
  BFF2:  9eeb03       add    3,s
  BFF5:  97           tax    
  BFF6:  2405         bcc    LBFFD
  BFF8:  8b           pshh   
  BFF9:  9e6c01       inc    1,s
  BFFC:  8a           pulh   
LBFFD:
  BFFD:  f6           lda    ,x
  BFFE:  95           tsx    
  BFFF:  ee02         ldx    2,x
  C001:  2703         beq    LC006
LC003:
  C003:  48           lsla   
  C004:  5bfd         dbnzx  LC003
LC006:
  C006:  450298       ldhx   #$0298
  C009:  fa           ora    ,x
  C00A:  f7           sta    ,x
  C00B:  9e6c03       inc    3,s
  C00E:  9ee603       lda    3,s
  C011:  a105         cmp    #$05
  C013:  259b         bcs    LBFB0
  C015:  f6           lda    ,x
  C016:  a101         cmp    #$01
  C018:  2605         bne    LC01F
  C01A:  c70298       sta    g_codingByte
  C01D:  2003         bra    LC022
LC01F:
  C01F:  a016         sub    #$16
  C021:  f7           sta    ,x
LC022:
  C022:  450004       ldhx   #$0004
  C025:  f6           lda    ,x
  C026:  aa01         ora    #$01
  C028:  f7           sta    ,x
  C029:  450008       ldhx   #$0008
  C02C:  f6           lda    ,x
  C02D:  aa81         ora    #$81
  C02F:  f7           sta    ,x
  C030:  4f           clra   
  C031:  c7000c       sta    PTGD
  C034:  c71848       sta    PTCPE
  C037:  c71850       sta    PTEPE
  C03A:  450009       ldhx   #$0009
  C03D:  f6           lda    ,x
  C03E:  aafd         ora    #$FD
  C040:  f7           sta    ,x
  C041:  4f           clra   
  C042:  c71858       sta    PTGPE
  C045:  a708         ais    #$08
  C047:  81           rts    

;---------------------------------------------------------------
; rotate3   [0xC048]   <- 9B82, AAC7, AB49
;---------------------------------------------------------------
  C048:  9ee603       lda    3,s
  C04B:  87           psha   
  C04C:  9ee602       lda    2,s
  C04F:  9ee704       sta    4,s
  C052:  9ee605       lda    5,s
  C055:  9ee702       sta    2,s
  C058:  9ee603       lda    3,s
  C05B:  9ee705       sta    5,s
  C05E:  9eef03       stx    3,s
  C061:  88           pulx   
  C062:  86           pula   
  C063:  8b           pshh   
  C064:  81           rts    
;   .... data/gap C065-C06C ....

;---------------------------------------------------------------
; muls8   [0xC06C]   <- 8849, 885D, 8871
;---------------------------------------------------------------
  C06C:  89           pshx   
  C06D:  ae80         ldx    #$80
  C06F:  2009         bra    LC07A
;   .... data/gap C071-C078 ....

;---------------------------------------------------------------
; muls8b   [0xC078]   <- A15F, B6AB, B6CC
;---------------------------------------------------------------
  C078:  89           pshx   
  C079:  5f           clrx   
LC07A:
  C07A:  3dc6         tst    g_mulDiv_tmp
  C07C:  2a09         bpl    LC087
  C07E:  5c           incx   
  C07F:  89           pshx   
  C080:  bec6         ldx    g_mulDiv_tmp
  C082:  ad41         bsr    negx
  C084:  bfc6         stx    g_mulDiv_tmp
  C086:  88           pulx   
LC087:
  C087:  87           psha   
  C088:  8b           pshh   
  C089:  9e6d01       tst    1,s
  C08C:  2a12         bpl    LC0A0
  C08E:  5c           incx   
  C08F:  5c           incx   
  C090:  89           pshx   
  C091:  9ee604       lda    4,s
  C094:  9eee02       ldx    2,s
  C097:  ad2c         bsr    negx
  C099:  9ee704       sta    4,s
  C09C:  9eef02       stx    2,s
  C09F:  88           pulx   
LC0A0:
  C0A0:  8a           pulh   
  C0A1:  86           pula   
  C0A2:  89           pshx   
  C0A3:  9eee02       ldx    2,s
  C0A6:  cdc127       jsr    div16
  C0A9:  9e6d01       tst    1,s
  C0AC:  2a09         bpl    LC0B7
  C0AE:  86           pula   
  C0AF:  44           lsra   
  C0B0:  9f           txa    
  C0B1:  8b           pshh   
  C0B2:  88           pulx   
  C0B3:  240c         bcc    LC0C1
  C0B5:  2008         bra    LC0BF
LC0B7:
  C0B7:  88           pulx   
  C0B8:  5c           incx   
  C0B9:  54           lsrx   
  C0BA:  54           lsrx   
  C0BB:  2406         bcc    LC0C3
  C0BD:  bec6         ldx    g_mulDiv_tmp
LC0BF:
  C0BF:  ad04         bsr    negx
LC0C1:
  C0C1:  bfc6         stx    g_mulDiv_tmp
LC0C3:
  C0C3:  88           pulx   
  C0C4:  81           rts    

;---------------------------------------------------------------
; negx   [0xC0C5]   <- C082, C097, C0BF
;---------------------------------------------------------------
  C0C5:  53           comx   
  C0C6:  40           nega   
  C0C7:  2601         bne    LC0CA
  C0C9:  5c           incx   
LC0CA:
  C0CA:  81           rts    

;---------------------------------------------------------------
; mul16   [0xC0CB]   <- A179, B774
;---------------------------------------------------------------
  C0CB:  89           pshx   
  C0CC:  87           psha   
  C0CD:  b6c6         lda    g_mulDiv_tmp
  C0CF:  42           mul    
  C0D0:  b7c6         sta    g_mulDiv_tmp
  C0D2:  8b           pshh   
  C0D3:  88           pulx   
  C0D4:  86           pula   
  C0D5:  87           psha   
  C0D6:  42           mul    
  C0D7:  bbc6         add    g_mulDiv_tmp
  C0D9:  b7c6         sta    g_mulDiv_tmp
  C0DB:  86           pula   
  C0DC:  88           pulx   
  C0DD:  42           mul    
  C0DE:  87           psha   
  C0DF:  9f           txa    
  C0E0:  bbc6         add    g_mulDiv_tmp
  C0E2:  b7c6         sta    g_mulDiv_tmp
  C0E4:  86           pula   
  C0E5:  81           rts    
;   .... data/gap C0E6-C0F9 ....

;---------------------------------------------------------------
; cmp32   [0xC0F9]   <- A18A
;---------------------------------------------------------------
  C0F9:  87           psha   
  C0FA:  b6c2         lda    g_div_a
  C0FC:  f1           cmp    ,x
  C0FD:  261e         bne    LC11D
  C0FF:  b6c3         lda    $C3
  C101:  e101         cmp    1,x
  C103:  260c         bne    LC111
  C105:  b6c4         lda    $C4
  C107:  e102         cmp    2,x
  C109:  2606         bne    LC111
  C10B:  b6c5         lda    $C5
  C10D:  e103         cmp    3,x
  C10F:  270c         beq    LC11D
LC111:
  C111:  85           tpa    
  C112:  2406         bcc    LC11A
  C114:  aa04         ora    #$04
  C116:  a47f         and    #$7F
  C118:  2002         bra    LC11C
LC11A:
  C11A:  a47b         and    #$7B
LC11C:
  C11C:  84           tap    
LC11D:
  C11D:  86           pula   
  C11E:  81           rts    
;   .... data/gap C11F-C127 ....

;---------------------------------------------------------------
; div16   [0xC127]   <- A172, A8FE, B77B, C0A6
;---------------------------------------------------------------
  C127:  87           psha   
  C128:  650100       cphx   #$0100
  C12B:  240b         bcc    LC138
  C12D:  b6c6         lda    g_mulDiv_tmp
  C12F:  52           div    
  C130:  b7c6         sta    g_mulDiv_tmp
  C132:  86           pula   
  C133:  52           div    
  C134:  8b           pshh   
  C135:  88           pulx   
  C136:  8c           clrh   
  C137:  81           rts    
LC138:
  C138:  8b           pshh   
  C139:  89           pshx   
  C13A:  ae08         ldx    #$08
  C13C:  4f           clra   
  C13D:  89           pshx   
  C13E:  87           psha   
  C13F:  95           tsx    
LC140:
  C140:  6804         lsl    4,x
  C142:  39c6         rol    g_mulDiv_tmp
  C144:  49           rola   
  C145:  f7           sta    ,x
  C146:  e103         cmp    3,x
  C148:  2516         bcs    LC160
  C14A:  2609         bne    LC155
  C14C:  b6c6         lda    g_mulDiv_tmp
  C14E:  e002         sub    2,x
  C150:  2407         bcc    LC159
  C152:  f6           lda    ,x
  C153:  200b         bra    LC160
LC155:
  C155:  b6c6         lda    g_mulDiv_tmp
  C157:  e002         sub    2,x
LC159:
  C159:  b7c6         sta    g_mulDiv_tmp
  C15B:  f6           lda    ,x
  C15C:  e203         sbc    3,x
  C15E:  6c04         inc    4,x
LC160:
  C160:  6b01dd       dbnz   1,x, LC140
  C163:  f7           sta    ,x
  C164:  8a           pulh   
  C165:  a703         ais    #$03
  C167:  bec6         ldx    g_mulDiv_tmp
  C169:  86           pula   
  C16A:  3fc6         clr    g_mulDiv_tmp
  C16C:  81           rts    
;   .... data/gap C16D-C174 ....

;---------------------------------------------------------------
; ldiv_init   [0xC174]   <- A184
;---------------------------------------------------------------
  C174:  b7c5         sta    $C5
  C176:  bfc4         stx    $C4
  C178:  3fc3         clr    $C3
  C17A:  3fc2         clr    g_div_a
  C17C:  81           rts    
