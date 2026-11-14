; Bootloader image (0xF400-0xFE73) - MC9S08AW32 LIN bootloader
; Generated annotated disassembly (HCS08). Addresses are absolute.
; Symbol names are the reverse-engineering labels used in the C sources.


;---------------------------------------------------------------
; Boot_Reset   [0xF400]
;---------------------------------------------------------------
  F400:  c61800       lda    SRS
  F403:  4d           tsta   
  F404:  2712         beq    LF418
  F406:  a480         and    #$80
  F408:  260e         bne    LF418
  F40A:  45f3fe       ldhx   #$F3FE
  F40D:  f6           lda    ,x
  F40E:  87           psha   
  F40F:  e401         and    1,x
  F411:  ee01         ldx    1,x
  F413:  8a           pulh   
  F414:  4c           inca   
  F415:  2701         beq    LF418
  F417:  fc           jmp    ,x
LF418:
  F418:  45046f       ldhx   #$046F
  F41B:  94           txs    
  F41C:  45fe2a       ldhx   #$FE2A
LF41F:
  F41F:  e601         lda    1,x
  F421:  87           psha   
  F422:  f6           lda    ,x
  F423:  87           psha   
LF424:
  F424:  e602         lda    2,x
  F426:  2749         beq    LF471
  F428:  a560         bit    #$60
  F42A:  2606         bne    LF432
  F42C:  a702         ais    #$02
  F42E:  af05         aix    #$05
  F430:  20ed         bra    LF41F
LF432:
  F432:  89           pshx   
  F433:  8b           pshh   
  F434:  e606         lda    6,x
  F436:  e001         sub    1,x
  F438:  87           psha   
  F439:  e605         lda    5,x
  F43B:  f2           sbc    ,x
  F43C:  9e6d01       tst    1,s
  F43F:  2701         beq    LF442
  F441:  4c           inca   
LF442:
  F442:  87           psha   
  F443:  e603         lda    3,x
  F445:  87           psha   
  F446:  ee04         ldx    4,x
  F448:  8a           pulh   
LF449:
  F449:  89           pshx   
  F44A:  8b           pshh   
  F44B:  9eee07       ldx    7,s
  F44E:  89           pshx   
  F44F:  8a           pulh   
  F450:  9eee08       ldx    8,s
  F453:  9e6c08       inc    8,s
  F456:  2603         bne    LF45B
  F458:  9e6c07       inc    7,s
LF45B:
  F45B:  f6           lda    ,x
  F45C:  8a           pulh   
  F45D:  88           pulx   
  F45E:  f7           sta    ,x
  F45F:  af01         aix    #$01
  F461:  9e6b02e4     dbnz   2,s, LF449
  F465:  9e6b01e0     dbnz   1,s, LF449
  F469:  a702         ais    #$02
  F46B:  8a           pulh   
  F46C:  88           pulx   
  F46D:  af05         aix    #$05
  F46F:  20b3         bra    LF424
LF471:
  F471:  a702         ais    #$02
  F473:  450217       ldhx   #$0217
  F476:  2003         bra    LF47B
LF478:
  F478:  7f           clr    ,x
  F479:  af01         aix    #$01
LF47B:
  F47B:  65031d       cphx   #$031D
  F47E:  26f8         bne    LF478
  F480:  cdf6b1       jsr    Boot_Main
LF483:
  F483:  20fe         bra    LF483

;---------------------------------------------------------------
; Boot_Stop   [0xF485]
;---------------------------------------------------------------
  F485:  9b           sei    
  F486:  8e           stop   
LF487:
  F487:  20fe         bra    LF487

;---------------------------------------------------------------
; Boot_sub_F489   [0xF489]   <- F6C6
;---------------------------------------------------------------
  F489:  a7f8         ais    #$F8
  F48B:  95           tsx    
  F48C:  6f06         clr    6,x
  F48E:  6f01         clr    1,x
  F490:  cdfd33       jsr    Boot_CopFeed
  F493:  c6009a       lda    $009A
  F496:  ab2f         add    #$2F
  F498:  95           tsx    
  F499:  e707         sta    7,x
  F49B:  ccf51f       jmp    $F51F
LF49E:
  F49E:  cdfc10       jsr    Boot_SciGetc
  F4A1:  a604         lda    #$04
  F4A3:  95           tsx    
  F4A4:  e001         sub    1,x
  F4A6:  87           psha   
  F4A7:  95           tsx    
  F4A8:  af03         aix    #$03
  F4AA:  9f           txa    
  F4AB:  9eeb03       add    3,s
  F4AE:  97           tax    
  F4AF:  2405         bcc    LF4B6
  F4B1:  8b           pshh   
  F4B2:  9e6c01       inc    1,s
  F4B5:  8a           pulh   
LF4B6:
  F4B6:  9f           txa    
  F4B7:  8b           pshh   
  F4B8:  88           pulx   
  F4B9:  cdfcc4       jsr    Boot_SciPutHex
  F4BC:  8a           pulh   
  F4BD:  95           tsx    
  F4BE:  f7           sta    ,x
  F4BF:  2743         beq    LF504
  F4C1:  eb01         add    1,x
  F4C3:  e701         sta    1,x
  F4C5:  a104         cmp    #$04
  F4C7:  263b         bne    LF504
  F4C9:  7f           clr    ,x
  F4CA:  2002         bra    LF4CE
LF4CC:
  F4CC:  95           tsx    
  F4CD:  7c           inc    ,x
LF4CE:
  F4CE:  af02         aix    #$02
  F4D0:  9f           txa    
  F4D1:  9eeb01       add    1,s
  F4D4:  97           tax    
  F4D5:  2405         bcc    LF4DC
  F4D7:  8b           pshh   
  F4D8:  9e6c01       inc    1,s
  F4DB:  8a           pulh   
LF4DC:
  F4DC:  f6           lda    ,x
  F4DD:  95           tsx    
  F4DE:  fe           ldx    ,x
  F4DF:  8c           clrh   
  F4E0:  d1fe59       cmp    $FE59,x
  F4E3:  2605         bne    LF4EA
  F4E5:  9f           txa    
  F4E6:  a104         cmp    #$04
  F4E8:  25e2         bcs    LF4CC
LF4EA:
  F4EA:  95           tsx    
  F4EB:  f6           lda    ,x
  F4EC:  a104         cmp    #$04
  F4EE:  2419         bcc    LF509
  F4F0:  7c           inc    ,x
  F4F1:  e601         lda    1,x
  F4F3:  f0           sub    ,x
  F4F4:  e701         sta    1,x
  F4F6:  87           psha   
  F4F7:  f6           lda    ,x
  F4F8:  87           psha   
  F4F9:  95           tsx    
  F4FA:  af04         aix    #$04
  F4FC:  9f           txa    
  F4FD:  8b           pshh   
  F4FE:  88           pulx   
  F4FF:  cdf5ee       jsr    Boot_sub_F5EE
  F502:  a702         ais    #$02
LF504:
  F504:  cdfd33       jsr    Boot_CopFeed
  F507:  2016         bra    LF51F
LF509:
  F509:  a601         lda    #$01
  F50B:  e706         sta    6,x
LF50D:
  F50D:  95           tsx    
  F50E:  6d06         tst    6,x
  F510:  2727         beq    LF539
  F512:  a601         lda    #$01
  F514:  87           psha   
  F515:  a65d         lda    #$5D
  F517:  aefe         ldx    #$FE
  F519:  cdfc67       jsr    Boot_SciPutc
  F51C:  8a           pulh   
  F51D:  2014         bra    LF533
LF51F:
  F51F:  c6009a       lda    $009A
  F522:  95           tsx    
  F523:  ee07         ldx    7,x
  F525:  cdfd76       jsr    Boot_Delay
  F528:  4d           tsta   
  F529:  2603         bne    LF52E
  F52B:  ccf49e       jmp    $F49E
LF52E:
  F52E:  20dd         bra    LF50D
LF530:
  F530:  cdfc10       jsr    Boot_SciGetc
LF533:
  F533:  cdfc56       jsr    Boot_SciPoll
  F536:  4d           tsta   
  F537:  27f7         beq    LF530
LF539:
  F539:  95           tsx    
  F53A:  e606         lda    6,x
  F53C:  a708         ais    #$08
  F53E:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F53F   [0xF53F]   <- F6D1
;---------------------------------------------------------------
  F53F:  a7f9         ais    #$F9
  F541:  cdf677       jsr    Boot_sub_F677
  F544:  9ee705       sta    5,s
  F547:  9eef04       stx    4,s
  F54A:  a602         lda    #$02
  F54C:  87           psha   
  F54D:  95           tsx    
  F54E:  af04         aix    #$04
  F550:  9f           txa    
  F551:  8b           pshh   
  F552:  88           pulx   
  F553:  cdfc67       jsr    Boot_SciPutc
  F556:  8a           pulh   
  F557:  2003         bra    LF55C
LF559:
  F559:  cdfc10       jsr    Boot_SciGetc
LF55C:
  F55C:  cdfc56       jsr    Boot_SciPoll
  F55F:  4d           tsta   
  F560:  27f7         beq    LF559
  F562:  a602         lda    #$02
  F564:  87           psha   
  F565:  95           tsx    
  F566:  af04         aix    #$04
  F568:  9f           txa    
  F569:  8b           pshh   
  F56A:  88           pulx   
  F56B:  cdf626       jsr    Boot_Crc
  F56E:  8a           pulh   
  F56F:  9ee705       sta    5,s
  F572:  9eef04       stx    4,s
  F575:  cdfc10       jsr    Boot_SciGetc
  F578:  95           tsx    
  F579:  7f           clr    ,x
  F57A:  cdfd33       jsr    Boot_CopFeed
  F57D:  95           tsx    
  F57E:  6f06         clr    6,x
LF580:
  F580:  c6009a       lda    $009A
  F583:  ab78         add    #$78
  F585:  e705         sta    5,x
  F587:  204c         bra    LF5D5
LF589:
  F589:  cdfc10       jsr    Boot_SciGetc
  F58C:  a602         lda    #$02
  F58E:  95           tsx    
  F58F:  f0           sub    ,x
  F590:  87           psha   
  F591:  95           tsx    
  F592:  af02         aix    #$02
  F594:  9f           txa    
  F595:  9eeb02       add    2,s
  F598:  97           tax    
  F599:  2405         bcc    LF5A0
  F59B:  8b           pshh   
  F59C:  9e6c01       inc    1,s
  F59F:  8a           pulh   
LF5A0:
  F5A0:  9f           txa    
  F5A1:  8b           pshh   
  F5A2:  88           pulx   
  F5A3:  cdfcc4       jsr    Boot_SciPutHex
  F5A6:  8a           pulh   
  F5A7:  95           tsx    
  F5A8:  fb           add    ,x
  F5A9:  f7           sta    ,x
  F5AA:  a102         cmp    #$02
  F5AC:  2621         bne    LF5CF
  F5AE:  9ece01       ldhx   1,x
  F5B1:  9ef304       cphx   4,s
  F5B4:  260a         bne    LF5C0
  F5B6:  cdfd33       jsr    Boot_CopFeed
  F5B9:  cdfdfe       jsr    Boot_sub_FDFE
  F5BC:  a601         lda    #$01
  F5BE:  202b         bra    LF5EB
LF5C0:
  F5C0:  95           tsx    
  F5C1:  e602         lda    2,x
  F5C3:  e103         cmp    3,x
  F5C5:  2607         bne    LF5CE
  F5C7:  e701         sta    1,x
  F5C9:  a601         lda    #$01
  F5CB:  f7           sta    ,x
  F5CC:  2001         bra    LF5CF
LF5CE:
  F5CE:  7f           clr    ,x
LF5CF:
  F5CF:  cdfd33       jsr    Boot_CopFeed
  F5D2:  cdfdfe       jsr    Boot_sub_FDFE
LF5D5:
  F5D5:  c6009a       lda    $009A
  F5D8:  95           tsx    
  F5D9:  ee05         ldx    5,x
  F5DB:  cdfd76       jsr    Boot_Delay
  F5DE:  4d           tsta   
  F5DF:  27a8         beq    LF589
  F5E1:  95           tsx    
  F5E2:  6c06         inc    6,x
  F5E4:  e606         lda    6,x
  F5E6:  a10a         cmp    #$0A
  F5E8:  2596         bcs    LF580
  F5EA:  4f           clra   
LF5EB:
  F5EB:  a707         ais    #$07
  F5ED:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F5EE   [0xF5EE]   <- F4FF
;---------------------------------------------------------------
  F5EE:  87           psha   
  F5EF:  89           pshx   
  F5F0:  87           psha   
  F5F1:  95           tsx    
  F5F2:  6d05         tst    5,x
  F5F4:  272d         beq    LF623
  F5F6:  6d06         tst    6,x
  F5F8:  2729         beq    LF623
  F5FA:  7f           clr    ,x
  F5FB:  2021         bra    LF61E
LF5FD:
  F5FD:  eb02         add    2,x
  F5FF:  87           psha   
  F600:  4f           clra   
  F601:  e901         adc    1,x
  F603:  87           psha   
  F604:  e605         lda    5,x
  F606:  5f           clrx   
  F607:  9eeb03       add    3,s
  F60A:  2401         bcc    LF60D
  F60C:  5c           incx   
LF60D:
  F60D:  9eeb05       add    5,s
  F610:  87           psha   
  F611:  9f           txa    
  F612:  95           tsx    
  F613:  e904         adc    4,x
  F615:  87           psha   
  F616:  8a           pulh   
  F617:  88           pulx   
  F618:  f6           lda    ,x
  F619:  8a           pulh   
  F61A:  88           pulx   
  F61B:  f7           sta    ,x
  F61C:  95           tsx    
  F61D:  7c           inc    ,x
LF61E:
  F61E:  f6           lda    ,x
  F61F:  e106         cmp    6,x
  F621:  25da         bcs    LF5FD
LF623:
  F623:  a703         ais    #$03
  F625:  81           rts    

;---------------------------------------------------------------
; Boot_Crc   [0xF626]   <- F56B
;---------------------------------------------------------------
  F626:  87           psha   
  F627:  89           pshx   
  F628:  a7fc         ais    #$FC
  F62A:  95           tsx    
  F62B:  7f           clr    ,x
  F62C:  6f01         clr    1,x
  F62E:  e608         lda    8,x
  F630:  e703         sta    3,x
  F632:  2039         bra    LF66D
LF634:
  F634:  9efe05       ldhx   5,s
  F637:  4f           clra   
  F638:  9ee802       eor    2,s
  F63B:  9ee702       sta    2,s
  F63E:  9ee601       lda    1,s
  F641:  f8           eor    ,x
  F642:  95           tsx    
  F643:  f7           sta    ,x
  F644:  9ece04       ldhx   4,x
  F647:  af01         aix    #$01
  F649:  9eff05       sthx   5,s
  F64C:  a608         lda    #$08
  F64E:  95           tsx    
  F64F:  e702         sta    2,x
LF651:
  F651:  f6           lda    ,x
  F652:  2b05         bmi    LF659
  F654:  6801         lsl    1,x
  F656:  79           rol    ,x
  F657:  200f         bra    LF668
LF659:
  F659:  e601         lda    1,x
  F65B:  fe           ldx    ,x
  F65C:  48           lsla   
  F65D:  59           rolx   
  F65E:  a805         eor    #$05
  F660:  9ee702       sta    2,s
  F663:  9f           txa    
  F664:  a810         eor    #$10
  F666:  95           tsx    
  F667:  f7           sta    ,x
LF668:
  F668:  6b02e6       dbnz   2,x, LF651
  F66B:  6a03         dec    3,x
LF66D:
  F66D:  6d03         tst    3,x
  F66F:  26c3         bne    LF634
  F671:  e601         lda    1,x
  F673:  fe           ldx    ,x
  F674:  a706         ais    #$06
  F676:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F677   [0xF677]   <- F541
;---------------------------------------------------------------
  F677:  a7fb         ais    #$FB
  F679:  320061       ldhx   TPM2CNTH
  F67C:  9eff03       sthx   3,s
  F67F:  32046f       ldhx   $046F
  F682:  9eff01       sthx   1,s
  F685:  a620         lda    #$20
  F687:  95           tsx    
  F688:  e704         sta    4,x
  F68A:  2019         bra    LF6A5
LF68C:
  F68C:  9efe01       ldhx   1,s
  F68F:  9ee604       lda    4,s
  F692:  f8           eor    ,x
  F693:  95           tsx    
  F694:  e703         sta    3,x
  F696:  4f           clra   
  F697:  e802         eor    2,x
  F699:  e702         sta    2,x
  F69B:  9eae         ldhx   ,x
  F69D:  afff         aix    #$FF
  F69F:  9eff01       sthx   1,s
  F6A2:  95           tsx    
  F6A3:  e604         lda    4,x
LF6A5:
  F6A5:  6a04         dec    4,x
  F6A7:  4d           tsta   
  F6A8:  26e2         bne    LF68C
  F6AA:  e603         lda    3,x
  F6AC:  ee02         ldx    2,x
  F6AE:  a705         ais    #$05
  F6B0:  81           rts    

;---------------------------------------------------------------
; Boot_Main   [0xF6B1]   <- F480
;---------------------------------------------------------------
  F6B1:  a7fc         ais    #$FC
  F6B3:  95           tsx    
  F6B4:  6f03         clr    3,x
  F6B6:  7f           clr    ,x
  F6B7:  6f01         clr    1,x
  F6B9:  4f           clra   
  F6BA:  c70070       sta    $0070
  F6BD:  ad7c         bsr    Boot_sub_F73B
  F6BF:  450070       ldhx   #$0070
  F6C2:  f6           lda    ,x
  F6C3:  aa01         ora    #$01
  F6C5:  f7           sta    ,x
  F6C6:  cdf489       jsr    Boot_sub_F489
  F6C9:  4d           tsta   
  F6CA:  2602         bne    LF6CE
  F6CC:  9d           nop    
  F6CD:  8d           fcb    #$8D
LF6CE:
  F6CE:  cdfde8       jsr    Boot_sub_FDE8
  F6D1:  cdf53f       jsr    Boot_sub_F53F
  F6D4:  4d           tsta   
  F6D5:  2602         bne    LF6D9
  F6D7:  9d           nop    
  F6D8:  8d           fcb    #$8D
LF6D9:
  F6D9:  a637         lda    #$37
  F6DB:  c71820       sta    FCDIV
LF6DE:
  F6DE:  cdfd33       jsr    Boot_CopFeed
  F6E1:  cdfc10       jsr    Boot_SciGetc
  F6E4:  95           tsx    
  F6E5:  e603         lda    3,x
  F6E7:  c1009a       cmp    $009A
  F6EA:  2708         beq    LF6F4
  F6EC:  c6009a       lda    $009A
  F6EF:  e703         sta    3,x
  F6F1:  cdfdfe       jsr    Boot_sub_FDFE
LF6F4:
  F6F4:  9efe01       ldhx   1,s
  F6F7:  2703         beq    LF6FC
  F6F9:  7d           tst    ,x
  F6FA:  262b         bne    LF727
LF6FC:
  F6FC:  a601         lda    #$01
  F6FE:  87           psha   
  F6FF:  95           tsx    
  F700:  af03         aix    #$03
  F702:  9f           txa    
  F703:  8b           pshh   
  F704:  88           pulx   
  F705:  cdfcc4       jsr    Boot_SciPutHex
  F708:  8a           pulh   
  F709:  4d           tsta   
  F70A:  271b         beq    LF727
  F70C:  4501f6       ldhx   #$01F6
  F70F:  2010         bra    LF721
LF711:
  F711:  95           tsx    
  F712:  e102         cmp    2,x
  F714:  2606         bne    LF71C
  F716:  4f           clra   
  F717:  c70218       sta    $0218
  F71A:  200b         bra    LF727
LF71C:
  F71C:  9efe01       ldhx   1,s
  F71F:  af03         aix    #$03
LF721:
  F721:  9eff01       sthx   1,s
  F724:  f6           lda    ,x
  F725:  26ea         bne    LF711
LF727:
  F727:  9efe01       ldhx   1,s
  F72A:  27b2         beq    LF6DE
  F72C:  7d           tst    ,x
  F72D:  27af         beq    LF6DE
  F72F:  9ece01       ldhx   1,x
  F732:  fd           jsr    ,x
  F733:  4ba9         dbnza  LF6DE
  F735:  95           tsx    
  F736:  7f           clr    ,x
  F737:  6f01         clr    1,x
  F739:  20a3         bra    LF6DE

;---------------------------------------------------------------
; Boot_sub_F73B   [0xF73B]   <- F6BD
;---------------------------------------------------------------
  F73B:  4f           clra   
  F73C:  c71802       sta    SOPT
  F73F:  cdfbad       jsr    Boot_FlashErase
  F742:  c60008       lda    PTED
  F745:  a401         and    #$01
  F747:  2707         beq    LF750
  F749:  450070       ldhx   #$0070
  F74C:  f6           lda    ,x
  F74D:  aa02         ora    #$02
  F74F:  f7           sta    ,x
LF750:
  F750:  cdfbcf       jsr    Boot_SciInit
  F753:  cdfd06       jsr    Boot_sub_FD06
  F756:  ccfbec       jmp    $FBEC

;---------------------------------------------------------------
; Boot_FlashProgram   [0xF759]   <- F801, F8A0, F92B, FA78, FA89
;---------------------------------------------------------------
  F759:  87           psha   
  F75A:  89           pshx   
  F75B:  2016         bra    LF773
LF75D:
  F75D:  9efe05       ldhx   5,s
  F760:  af01         aix    #$01
  F762:  9eff05       sthx   5,s
  F765:  afff         aix    #$FF
  F767:  f6           lda    ,x
  F768:  9efe01       ldhx   1,s
  F76B:  af01         aix    #$01
  F76D:  9eff01       sthx   1,s
  F770:  afff         aix    #$FF
  F772:  f7           sta    ,x
LF773:
  F773:  95           tsx    
  F774:  e606         lda    6,x
  F776:  6a06         dec    6,x
  F778:  4d           tsta   
  F779:  26e2         bne    LF75D
  F77B:  a702         ais    #$02
  F77D:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F77E   [0xF77E]
;---------------------------------------------------------------
  F77E:  87           psha   
  F77F:  95           tsx    
  F780:  7f           clr    ,x
  F781:  c60218       lda    $0218
  F784:  2708         beq    LF78E
  F786:  410110       cbeqa  #$01, LF799
  F789:  410238       cbeqa  #$02, LF7C4
  F78C:  2052         bra    LF7E0
LF78E:
  F78E:  a601         lda    #$01
  F790:  c70218       sta    $0218
  F793:  4f           clra   
  F794:  c70219       sta    $0219
  F797:  2047         bra    LF7E0
LF799:
  F799:  a602         lda    #$02
  F79B:  c00219       sub    $0219
  F79E:  87           psha   
  F79F:  c60219       lda    $0219
  F7A2:  ab1a         add    #$1A
  F7A4:  87           psha   
  F7A5:  4f           clra   
  F7A6:  a902         adc    #$02
  F7A8:  97           tax    
  F7A9:  86           pula   
  F7AA:  cdfcc4       jsr    Boot_SciPutHex
  F7AD:  8a           pulh   
  F7AE:  450219       ldhx   #$0219
  F7B1:  fb           add    ,x
  F7B2:  f7           sta    ,x
  F7B3:  a102         cmp    #$02
  F7B5:  2629         bne    LF7E0
  F7B7:  c70218       sta    $0218
  F7BA:  3201f0       ldhx   $01F0
  F7BD:  2621         bne    LF7E0
  F7BF:  4a           deca   
  F7C0:  95           tsx    
  F7C1:  f7           sta    ,x
  F7C2:  201c         bra    LF7E0
LF7C4:
  F7C4:  c6009c       lda    $009C
  F7C7:  a101         cmp    #$01
  F7C9:  2615         bne    LF7E0
  F7CB:  f7           sta    ,x
  F7CC:  c6021b       lda    $021B
  F7CF:  ce021a       ldx    $021A
  F7D2:  cd01a0       jsr    g_tickCount
  F7D5:  a601         lda    #$01
  F7D7:  87           psha   
  F7D8:  a65d         lda    #$5D
  F7DA:  aefe         ldx    #$FE
  F7DC:  cdfc67       jsr    Boot_SciPutc
  F7DF:  8a           pulh   
LF7E0:
  F7E0:  95           tsx    
  F7E1:  f6           lda    ,x
  F7E2:  8a           pulh   
  F7E3:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F7E4   [0xF7E4]
;---------------------------------------------------------------
  F7E4:  87           psha   
  F7E5:  95           tsx    
  F7E6:  7f           clr    ,x
  F7E7:  c60218       lda    $0218
  F7EA:  2620         bne    LF80C
  F7EC:  a601         lda    #$01
  F7EE:  c70218       sta    $0218
  F7F1:  4f           clra   
  F7F2:  c70219       sta    $0219
  F7F5:  a616         lda    #$16
  F7F7:  87           psha   
  F7F8:  45fe5e       ldhx   #$FE5E
  F7FB:  89           pshx   
  F7FC:  8b           pshh   
  F7FD:  a61a         lda    #$1A
  F7FF:  ae02         ldx    #$02
  F801:  cdf759       jsr    Boot_FlashProgram
  F804:  a703         ais    #$03
  F806:  321806       ldhx   SDIDH
  F809:  96021b       sthx   $021B
LF80C:
  F80C:  a616         lda    #$16
  F80E:  c00219       sub    $0219
  F811:  87           psha   
  F812:  c60219       lda    $0219
  F815:  ab1a         add    #$1A
  F817:  87           psha   
  F818:  4f           clra   
  F819:  a902         adc    #$02
  F81B:  97           tax    
  F81C:  86           pula   
  F81D:  cdfc67       jsr    Boot_SciPutc
  F820:  8a           pulh   
  F821:  450219       ldhx   #$0219
  F824:  fb           add    ,x
  F825:  f7           sta    ,x
  F826:  a116         cmp    #$16
  F828:  2604         bne    LF82E
  F82A:  a601         lda    #$01
  F82C:  95           tsx    
  F82D:  f7           sta    ,x
LF82E:
  F82E:  95           tsx    
  F82F:  f6           lda    ,x
  F830:  8a           pulh   
  F831:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F832   [0xF832]
;---------------------------------------------------------------
  F832:  87           psha   
  F833:  95           tsx    
  F834:  7f           clr    ,x
  F835:  c60218       lda    $0218
  F838:  2708         beq    LF842
  F83A:  410110       cbeqa  #$01, LF84D
  F83D:  410228       cbeqa  #$02, LF868
  F840:  2077         bra    LF8B9
LF842:
  F842:  a601         lda    #$01
  F844:  c70218       sta    $0218
  F847:  4f           clra   
  F848:  c70219       sta    $0219
  F84B:  206c         bra    LF8B9
LF84D:
  F84D:  c00219       sub    $0219
  F850:  87           psha   
  F851:  a61a         lda    #$1A
  F853:  ae02         ldx    #$02
  F855:  cdfcc4       jsr    Boot_SciPutHex
  F858:  8a           pulh   
  F859:  450219       ldhx   #$0219
  F85C:  fb           add    ,x
  F85D:  f7           sta    ,x
  F85E:  4b59         dbnza  LF8B9
  F860:  a602         lda    #$02
  F862:  c70218       sta    $0218
  F865:  7f           clr    ,x
  F866:  2051         bra    LF8B9
LF868:
  F868:  c6021a       lda    $021A
  F86B:  c00219       sub    $0219
  F86E:  87           psha   
  F86F:  c60219       lda    $0219
  F872:  ab1b         add    #$1B
  F874:  87           psha   
  F875:  4f           clra   
  F876:  a902         adc    #$02
  F878:  97           tax    
  F879:  86           pula   
  F87A:  cdfcc4       jsr    Boot_SciPutHex
  F87D:  8a           pulh   
  F87E:  450219       ldhx   #$0219
  F881:  fb           add    ,x
  F882:  f7           sta    ,x
  F883:  e601         lda    1,x
  F885:  f1           cmp    ,x
  F886:  2631         bne    LF8B9
  F888:  a601         lda    #$01
  F88A:  9ee701       sta    1,s
  F88D:  e601         lda    1,x
  F88F:  a151         cmp    #$51
  F891:  2426         bcc    LF8B9
  F893:  c6021a       lda    $021A
  F896:  87           psha   
  F897:  45021b       ldhx   #$021B
  F89A:  89           pshx   
  F89B:  8b           pshh   
  F89C:  a6a0         lda    #$A0
  F89E:  ae01         ldx    #$01
  F8A0:  cdf759       jsr    Boot_FlashProgram
  F8A3:  a703         ais    #$03
  F8A5:  4501a0       ldhx   #$01A0
  F8A8:  9601f0       sthx   $01F0
  F8AB:  9601f4       sthx   $01F4
  F8AE:  a601         lda    #$01
  F8B0:  87           psha   
  F8B1:  a65d         lda    #$5D
  F8B3:  aefe         ldx    #$FE
  F8B5:  cdfc67       jsr    Boot_SciPutc
  F8B8:  8a           pulh   
LF8B9:
  F8B9:  95           tsx    
  F8BA:  f6           lda    ,x
  F8BB:  8a           pulh   
  F8BC:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F8BD   [0xF8BD]
;---------------------------------------------------------------
  F8BD:  87           psha   
  F8BE:  95           tsx    
  F8BF:  7f           clr    ,x
  F8C0:  c60218       lda    $0218
  F8C3:  2708         beq    LF8CD
  F8C5:  410110       cbeqa  #$01, LF8D8
  F8C8:  410228       cbeqa  #$02, LF8F3
  F8CB:  2077         bra    LF944
LF8CD:
  F8CD:  a601         lda    #$01
  F8CF:  c70218       sta    $0218
  F8D2:  4f           clra   
  F8D3:  c70219       sta    $0219
  F8D6:  206c         bra    LF944
LF8D8:
  F8D8:  c00219       sub    $0219
  F8DB:  87           psha   
  F8DC:  a61a         lda    #$1A
  F8DE:  ae02         ldx    #$02
  F8E0:  cdfcc4       jsr    Boot_SciPutHex
  F8E3:  8a           pulh   
  F8E4:  450219       ldhx   #$0219
  F8E7:  fb           add    ,x
  F8E8:  f7           sta    ,x
  F8E9:  4b59         dbnza  LF944
  F8EB:  a602         lda    #$02
  F8ED:  c70218       sta    $0218
  F8F0:  7f           clr    ,x
  F8F1:  2051         bra    LF944
LF8F3:
  F8F3:  c6021a       lda    $021A
  F8F6:  c00219       sub    $0219
  F8F9:  87           psha   
  F8FA:  c60219       lda    $0219
  F8FD:  ab1b         add    #$1B
  F8FF:  87           psha   
  F900:  4f           clra   
  F901:  a902         adc    #$02
  F903:  97           tax    
  F904:  86           pula   
  F905:  cdfcc4       jsr    Boot_SciPutHex
  F908:  8a           pulh   
  F909:  450219       ldhx   #$0219
  F90C:  fb           add    ,x
  F90D:  f7           sta    ,x
  F90E:  e601         lda    1,x
  F910:  f1           cmp    ,x
  F911:  2631         bne    LF944
  F913:  a601         lda    #$01
  F915:  9ee701       sta    1,s
  F918:  e601         lda    1,x
  F91A:  a1a1         cmp    #$A1
  F91C:  2426         bcc    LF944
  F91E:  c6021a       lda    $021A
  F921:  87           psha   
  F922:  45021b       ldhx   #$021B
  F925:  89           pshx   
  F926:  8b           pshh   
  F927:  a600         lda    #$00
  F929:  ae01         ldx    #$01
  F92B:  cdf759       jsr    Boot_FlashProgram
  F92E:  a703         ais    #$03
  F930:  450100       ldhx   #$0100
  F933:  9601f2       sthx   $01F2
  F936:  9601f4       sthx   $01F4
  F939:  a601         lda    #$01
  F93B:  87           psha   
  F93C:  a65d         lda    #$5D
  F93E:  aefe         ldx    #$FE
  F940:  cdfc67       jsr    Boot_SciPutc
  F943:  8a           pulh   
LF944:
  F944:  95           tsx    
  F945:  f6           lda    ,x
  F946:  8a           pulh   
  F947:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F948   [0xF948]
;---------------------------------------------------------------
  F948:  8d           fcb    #$8D
  F949:  a601         lda    #$01
  F94B:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F94C   [0xF94C]
;---------------------------------------------------------------
  F94C:  87           psha   
  F94D:  95           tsx    
  F94E:  7f           clr    ,x
  F94F:  c60218       lda    $0218
  F952:  2708         beq    LF95C
  F954:  410110       cbeqa  #$01, LF967
  F957:  410345       cbeqa  #$03, LF99F
  F95A:  2069         bra    LF9C5
LF95C:
  F95C:  a601         lda    #$01
  F95E:  c70218       sta    $0218
  F961:  4f           clra   
  F962:  c70219       sta    $0219
  F965:  205e         bra    LF9C5
LF967:
  F967:  a603         lda    #$03
  F969:  c00219       sub    $0219
  F96C:  87           psha   
  F96D:  c60219       lda    $0219
  F970:  ab1a         add    #$1A
  F972:  87           psha   
  F973:  4f           clra   
  F974:  a902         adc    #$02
  F976:  97           tax    
  F977:  86           pula   
  F978:  cdfcc4       jsr    Boot_SciPutHex
  F97B:  8a           pulh   
  F97C:  450219       ldhx   #$0219
  F97F:  fb           add    ,x
  F980:  f7           sta    ,x
  F981:  a103         cmp    #$03
  F983:  2640         bne    LF9C5
  F985:  c70218       sta    $0218
  F988:  7f           clr    ,x
  F989:  32021a       ldhx   $021A
  F98C:  2608         bne    LF996
  F98E:  3201f4       ldhx   $01F4
  F991:  2703         beq    LF996
  F993:  96021a       sthx   $021A
LF996:
  F996:  4f           clra   
  F997:  c701f4       sta    $01F4
  F99A:  c701f5       sta    $01F5
  F99D:  2026         bra    LF9C5
LF99F:
  F99F:  c6021c       lda    $021C
  F9A2:  c00219       sub    $0219
  F9A5:  87           psha   
  F9A6:  c60219       lda    $0219
  F9A9:  cb021b       add    $021B
  F9AC:  87           psha   
  F9AD:  4f           clra   
  F9AE:  c9021a       adc    $021A
  F9B1:  97           tax    
  F9B2:  86           pula   
  F9B3:  cdfc67       jsr    Boot_SciPutc
  F9B6:  8a           pulh   
  F9B7:  450219       ldhx   #$0219
  F9BA:  fb           add    ,x
  F9BB:  f7           sta    ,x
  F9BC:  e603         lda    3,x
  F9BE:  f1           cmp    ,x
  F9BF:  2604         bne    LF9C5
  F9C1:  a601         lda    #$01
  F9C3:  95           tsx    
  F9C4:  f7           sta    ,x
LF9C5:
  F9C5:  95           tsx    
  F9C6:  f6           lda    ,x
  F9C7:  8a           pulh   
  F9C8:  81           rts    

;---------------------------------------------------------------
; Boot_sub_F9C9   [0xF9C9]
;---------------------------------------------------------------
  F9C9:  87           psha   
  F9CA:  95           tsx    
  F9CB:  7f           clr    ,x
  F9CC:  c60218       lda    $0218
  F9CF:  270c         beq    LF9DD
  F9D1:  410110       cbeqa  #$01, LF9E4
  F9D4:  410236       cbeqa  #$02, LFA0D
  F9D7:  a103         cmp    #$03
  F9D9:  2766         beq    LFA41
  F9DB:  207a         bra    LFA57
LF9DD:
  F9DD:  a601         lda    #$01
  F9DF:  c70218       sta    $0218
  F9E2:  206f         bra    LFA53
LF9E4:
  F9E4:  a603         lda    #$03
  F9E6:  c00219       sub    $0219
  F9E9:  87           psha   
  F9EA:  c60219       lda    $0219
  F9ED:  ab1a         add    #$1A
  F9EF:  87           psha   
  F9F0:  4f           clra   
  F9F1:  a902         adc    #$02
  F9F3:  97           tax    
  F9F4:  86           pula   
  F9F5:  cdfcc4       jsr    Boot_SciPutHex
  F9F8:  8a           pulh   
  F9F9:  450219       ldhx   #$0219
  F9FC:  fb           add    ,x
  F9FD:  f7           sta    ,x
  F9FE:  a103         cmp    #$03
  FA00:  2655         bne    LFA57
  FA02:  a602         lda    #$02
  FA04:  c70218       sta    $0218
  FA07:  4a           deca   
  FA08:  e704         sta    4,x
  FA0A:  7f           clr    ,x
  FA0B:  204a         bra    LFA57
LFA0D:
  FA0D:  c60219       lda    $0219
  FA10:  cb021b       add    $021B
  FA13:  87           psha   
  FA14:  4f           clra   
  FA15:  c9021a       adc    $021A
  FA18:  87           psha   
  FA19:  8a           pulh   
  FA1A:  88           pulx   
  FA1B:  f6           lda    ,x
  FA1C:  a183         cmp    #$83
  FA1E:  2604         bne    LFA24
  FA20:  a601         lda    #$01
  FA22:  2001         bra    LFA25
LFA24:
  FA24:  4f           clra   
LFA25:
  FA25:  c7021d       sta    $021D
  FA28:  450219       ldhx   #$0219
  FA2B:  7c           inc    ,x
  FA2C:  e604         lda    4,x
  FA2E:  2705         beq    LFA35
  FA30:  e603         lda    3,x
  FA32:  f1           cmp    ,x
  FA33:  2622         bne    LFA57
LFA35:
  FA35:  a601         lda    #$01
  FA37:  c70219       sta    $0219
  FA3A:  a603         lda    #$03
  FA3C:  c70218       sta    $0218
  FA3F:  2016         bra    LFA57
LFA41:
  FA41:  c60219       lda    $0219
  FA44:  87           psha   
  FA45:  a61d         lda    #$1D
  FA47:  ae02         ldx    #$02
  FA49:  cdfc67       jsr    Boot_SciPutc
  FA4C:  8a           pulh   
  FA4D:  a101         cmp    #$01
  FA4F:  2602         bne    LFA53
  FA51:  95           tsx    
  FA52:  f7           sta    ,x
LFA53:
  FA53:  4f           clra   
  FA54:  c70219       sta    $0219
LFA57:
  FA57:  95           tsx    
  FA58:  f6           lda    ,x
  FA59:  8a           pulh   
  FA5A:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FA5B   [0xFA5B]
;---------------------------------------------------------------
  FA5B:  87           psha   
  FA5C:  95           tsx    
  FA5D:  7f           clr    ,x
  FA5E:  c60218       lda    $0218
  FA61:  262b         bne    LFA8E
  FA63:  a601         lda    #$01
  FA65:  c70218       sta    $0218
  FA68:  4f           clra   
  FA69:  c70219       sta    $0219
  FA6C:  a604         lda    #$04
  FA6E:  87           psha   
  FA6F:  45ffc0       ldhx   #$FFC0
  FA72:  89           pshx   
  FA73:  8b           pshh   
  FA74:  a61a         lda    #$1A
  FA76:  ae02         ldx    #$02
  FA78:  cdf759       jsr    Boot_FlashProgram
  FA7B:  a703         ais    #$03
  FA7D:  450104       ldhx   #$0104
  FA80:  89           pshx   
  FA81:  8b           pshh   
  FA82:  a686         lda    #$86
  FA84:  87           psha   
  FA85:  a61e         lda    #$1E
  FA87:  ae02         ldx    #$02
  FA89:  cdf759       jsr    Boot_FlashProgram
  FA8C:  a703         ais    #$03
LFA8E:
  FA8E:  a608         lda    #$08
  FA90:  c00219       sub    $0219
  FA93:  87           psha   
  FA94:  c60219       lda    $0219
  FA97:  ab1a         add    #$1A
  FA99:  87           psha   
  FA9A:  4f           clra   
  FA9B:  a902         adc    #$02
  FA9D:  97           tax    
  FA9E:  86           pula   
  FA9F:  cdfc67       jsr    Boot_SciPutc
  FAA2:  8a           pulh   
  FAA3:  450219       ldhx   #$0219
  FAA6:  fb           add    ,x
  FAA7:  f7           sta    ,x
  FAA8:  a108         cmp    #$08
  FAAA:  2604         bne    LFAB0
  FAAC:  a601         lda    #$01
  FAAE:  95           tsx    
  FAAF:  f7           sta    ,x
LFAB0:
  FAB0:  95           tsx    
  FAB1:  f6           lda    ,x
  FAB2:  8a           pulh   
  FAB3:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FAB4   [0xFAB4]
;---------------------------------------------------------------
  FAB4:  c60218       lda    $0218
  FAB7:  2603         bne    LFABC
  FAB9:  c70217       sta    $0217
LFABC:
  FABC:  200c         bra    LFACA

;---------------------------------------------------------------
; Boot_sub_FABE   [0xFABE]
;---------------------------------------------------------------
  FABE:  c60218       lda    $0218
  FAC1:  2605         bne    LFAC8
  FAC3:  a601         lda    #$01
  FAC5:  c70217       sta    $0217
LFAC8:
  FAC8:  2000         bra    LFACA
LFACA:
  FACA:  87           psha   
  FACB:  95           tsx    
  FACC:  7f           clr    ,x
  FACD:  c60218       lda    $0218
  FAD0:  2710         beq    LFAE2
  FAD2:  410119       cbeqa  #$01, LFAEE
  FAD5:  41023d       cbeqa  #$02, LFB15
  FAD8:  a103         cmp    #$03
  FADA:  2603         bne    LFADF
  FADC:  ccfb82       jmp    $FB82
LFADF:
  FADF:  ccfba9       jmp    $FBA9
LFAE2:
  FAE2:  a601         lda    #$01
  FAE4:  c70218       sta    $0218
  FAE7:  4f           clra   
  FAE8:  c70219       sta    $0219
LFAEB:
  FAEB:  ccfba9       jmp    $FBA9
LFAEE:
  FAEE:  a603         lda    #$03
  FAF0:  c00219       sub    $0219
  FAF3:  87           psha   
  FAF4:  c60219       lda    $0219
  FAF7:  ab1a         add    #$1A
  FAF9:  87           psha   
  FAFA:  4f           clra   
  FAFB:  a902         adc    #$02
  FAFD:  97           tax    
  FAFE:  86           pula   
  FAFF:  cdfcc4       jsr    Boot_SciPutHex
  FB02:  8a           pulh   
  FB03:  450219       ldhx   #$0219
  FB06:  fb           add    ,x
  FB07:  f7           sta    ,x
  FB08:  a103         cmp    #$03
  FB0A:  26df         bne    LFAEB
  FB0C:  a602         lda    #$02
  FB0E:  c70218       sta    $0218
  FB11:  7f           clr    ,x
  FB12:  ccfba9       jmp    $FBA9
LFB15:
  FB15:  c60217       lda    $0217
  FB18:  4b0f         dbnza  LFB29
  FB1A:  ce0219       ldx    $0219
  FB1D:  8c           clrh   
  FB1E:  a683         lda    #$83
  FB20:  d7021d       sta    $021D,x
  FB23:  450219       ldhx   #$0219
  FB26:  7c           inc    ,x
  FB27:  201b         bra    LFB44
LFB29:
  FB29:  c6021c       lda    $021C
  FB2C:  c00219       sub    $0219
  FB2F:  87           psha   
  FB30:  c60219       lda    $0219
  FB33:  ab1d         add    #$1D
  FB35:  87           psha   
  FB36:  4f           clra   
  FB37:  a902         adc    #$02
  FB39:  97           tax    
  FB3A:  86           pula   
  FB3B:  cdfcc4       jsr    Boot_SciPutHex
  FB3E:  8a           pulh   
  FB3F:  450219       ldhx   #$0219
  FB42:  fb           add    ,x
  FB43:  f7           sta    ,x
LFB44:
  FB44:  c6021c       lda    $021C
  FB47:  c10219       cmp    $0219
  FB4A:  265d         bne    LFBA9
  FB4C:  3201f2       ldhx   $01F2
  FB4F:  2606         bne    LFB57
  FB51:  a601         lda    #$01
  FB53:  95           tsx    
  FB54:  f7           sta    ,x
  FB55:  2052         bra    LFBA9
LFB57:
  FB57:  a603         lda    #$03
  FB59:  c70218       sta    $0218
  FB5C:  32021a       ldhx   $021A
  FB5F:  658601       cphx   #$8601
  FB62:  2445         bcc    LFBA9
  FB64:  c6021c       lda    $021C
  FB67:  cb021b       add    $021B
  FB6A:  87           psha   
  FB6B:  4f           clra   
  FB6C:  c9021a       adc    $021A
  FB6F:  97           tax    
  FB70:  86           pula   
  FB71:  a000         sub    #$00
  FB73:  9f           txa    
  FB74:  a286         sbc    #$86
  FB76:  2531         bcs    LFBA9
  FB78:  32021a       ldhx   $021A
  FB7B:  a655         lda    #$55
  FB7D:  d77c1d       sta    $7C1D,x
  FB80:  2027         bra    LFBA9
LFB82:
  FB82:  c6009c       lda    $009C
  FB85:  a101         cmp    #$01
  FB87:  2620         bne    LFBA9
  FB89:  f7           sta    ,x
  FB8A:  c6021c       lda    $021C
  FB8D:  87           psha   
  FB8E:  45021d       ldhx   #$021D
  FB91:  89           pshx   
  FB92:  8b           pshh   
  FB93:  c6021b       lda    $021B
  FB96:  ce021a       ldx    $021A
  FB99:  cd0100       jsr    g_sleepState
  FB9C:  a703         ais    #$03
  FB9E:  a601         lda    #$01
  FBA0:  87           psha   
  FBA1:  a65d         lda    #$5D
  FBA3:  aefe         ldx    #$FE
  FBA5:  cdfc67       jsr    Boot_SciPutc
  FBA8:  8a           pulh   
LFBA9:
  FBA9:  95           tsx    
  FBAA:  f6           lda    ,x
  FBAB:  8a           pulh   
  FBAC:  81           rts    

;---------------------------------------------------------------
; Boot_FlashErase   [0xFBAD]   <- F73F
;---------------------------------------------------------------
  FBAD:  a62a         lda    #$2A
  FBAF:  c70048       sta    ICGC1
  FBB2:  a630         lda    #$30
  FBB4:  c70049       sta    ICGC2
  FBB7:  2001         bra    LFBBA
LFBB9:
  FBB9:  9d           nop    
LFBBA:
  FBBA:  c6004a       lda    ICGS1
  FBBD:  a408         and    #$08
  FBBF:  27f8         beq    LFBB9
LFBC1:
  FBC1:  c6004b       lda    ICGS2
  FBC4:  a401         and    #$01
  FBC6:  27f9         beq    LFBC1
  FBC8:  c6ffbe       lda    $FFBE
  FBCB:  c7004e       sta    ICGTRM
  FBCE:  81           rts    

;---------------------------------------------------------------
; Boot_SciInit   [0xFBCF]   <- F750
;---------------------------------------------------------------
  FBCF:  4f           clra   
  FBD0:  c7001c       sta    IRQSC
  FBD3:  a614         lda    #$14
  FBD5:  c71809       sta    SPMSC1
  FBD8:  a605         lda    #$05
  FBDA:  c7180a       sta    SPMSC2
  FBDD:  450004       ldhx   #$0004
  FBE0:  f6           lda    ,x
  FBE1:  aa01         ora    #$01
  FBE3:  f7           sta    ,x
  FBE4:  450005       ldhx   #$0005
  FBE7:  f6           lda    ,x
  FBE8:  aa01         ora    #$01
  FBEA:  f7           sta    ,x
  FBEB:  81           rts    
LFBEC:
  FBEC:  a624         lda    #$24
  FBEE:  c70039       sta    SCI1BDL
  FBF1:  4f           clra   
  FBF2:  c70038       sta    SCI1BDH
  FBF5:  c7003a       sta    SCI1C1
  FBF8:  a60c         lda    #$0C
  FBFA:  c7003b       sta    SCI1C2
  FBFD:  4f           clra   
  FBFE:  c7003e       sta    SCI1C3
  FC01:  3f7f         clr    $7F
  FC03:  3f7e         clr    $7E
  FC05:  3f7d         clr    $7D
  FC07:  3f74         clr    $74
  FC09:  3f73         clr    $73
  FC0B:  3f72         clr    $72
  FC0D:  3f71         clr    $71
  FC0F:  81           rts    

;---------------------------------------------------------------
; Boot_SciGetc   [0xFC10]   <- F49E, F530, F559, F575, F589, F6E1
;---------------------------------------------------------------
  FC10:  3d74         tst    $74
  FC12:  2719         beq    LFC2D
  FC14:  c6003c       lda    SCI1S1
  FC17:  2a14         bpl    LFC2D
  FC19:  be73         ldx    $73
  FC1B:  8c           clrh   
  FC1C:  e675         lda    117,x
  FC1E:  c7003f       sta    SCI1D
  FC21:  3c73         inc    $73
  FC23:  b673         lda    $73
  FC25:  a108         cmp    #$08
  FC27:  2502         bcs    LFC2B
  FC29:  3f73         clr    $73
LFC2B:
  FC2B:  3a74         dec    $74
LFC2D:
  FC2D:  c6003c       lda    SCI1S1
  FC30:  a520         bit    #$20
  FC32:  2721         beq    LFC55
  FC34:  b67f         lda    $7F
  FC36:  a118         cmp    #$18
  FC38:  241b         bcc    LFC55
  FC3A:  c6003f       lda    SCI1D
  FC3D:  be7d         ldx    $7D
  FC3F:  8c           clrh   
  FC40:  e780         sta    128,x
  FC42:  3d71         tst    $71
  FC44:  260d         bne    LFC53
  FC46:  3c7d         inc    $7D
  FC48:  b67d         lda    $7D
  FC4A:  a118         cmp    #$18
  FC4C:  2502         bcs    LFC50
  FC4E:  3f7d         clr    $7D
LFC50:
  FC50:  3c7f         inc    $7F
  FC52:  81           rts    
LFC53:
  FC53:  3a71         dec    $71
LFC55:
  FC55:  81           rts    

;---------------------------------------------------------------
; Boot_SciPoll   [0xFC56]   <- F533, F55C
;---------------------------------------------------------------
  FC56:  87           psha   
  FC57:  95           tsx    
  FC58:  7f           clr    ,x
  FC59:  3d74         tst    $74
  FC5B:  2607         bne    LFC64
  FC5D:  3d71         tst    $71
  FC5F:  2603         bne    LFC64
  FC61:  a601         lda    #$01
  FC63:  f7           sta    ,x
LFC64:
  FC64:  f6           lda    ,x
  FC65:  8a           pulh   
  FC66:  81           rts    

;---------------------------------------------------------------
; Boot_SciPutc   [0xFC67]   <- F519, F553, F7DC, F81D, F8B5, F940, F9B3, FA49
;---------------------------------------------------------------
  FC67:  87           psha   
  FC68:  89           pshx   
  FC69:  87           psha   
  FC6A:  95           tsx    
  FC6B:  7f           clr    ,x
  FC6C:  5f           clrx   
  FC6D:  a608         lda    #$08
  FC6F:  b074         sub    $74
  FC71:  2401         bcc    LFC74
  FC73:  5a           decx   
LFC74:
  FC74:  bf9d         stx    $9D
  FC76:  95           tsx    
  FC77:  ee05         ldx    5,x
  FC79:  8c           clrh   
  FC7A:  89           pshx   
  FC7B:  9ee001       sub    1,s
  FC7E:  88           pulx   
  FC7F:  b69d         lda    $9D
  FC81:  8b           pshh   
  FC82:  95           tsx    
  FC83:  f2           sbc    ,x
  FC84:  8a           pulh   
  FC85:  9007         bge    LFC8E
  FC87:  a608         lda    #$08
  FC89:  b074         sub    $74
  FC8B:  95           tsx    
  FC8C:  e705         sta    5,x
LFC8E:
  FC8E:  95           tsx    
  FC8F:  e605         lda    5,x
  FC91:  f7           sta    ,x
  FC92:  201e         bra    LFCB2
LFC94:
  FC94:  9efe02       ldhx   2,s
  FC97:  f6           lda    ,x
  FC98:  be72         ldx    $72
  FC9A:  8c           clrh   
  FC9B:  e775         sta    117,x
  FC9D:  9efe02       ldhx   2,s
  FCA0:  af01         aix    #$01
  FCA2:  9eff02       sthx   2,s
  FCA5:  95           tsx    
  FCA6:  6a05         dec    5,x
  FCA8:  3c72         inc    $72
  FCAA:  b672         lda    $72
  FCAC:  a108         cmp    #$08
  FCAE:  2502         bcs    LFCB2
  FCB0:  3f72         clr    $72
LFCB2:
  FCB2:  6d05         tst    5,x
  FCB4:  26de         bne    LFC94
  FCB6:  b674         lda    $74
  FCB8:  fb           add    ,x
  FCB9:  b774         sta    $74
  FCBB:  b671         lda    $71
  FCBD:  fb           add    ,x
  FCBE:  b771         sta    $71
  FCC0:  f6           lda    ,x
  FCC1:  a703         ais    #$03
  FCC3:  81           rts    

;---------------------------------------------------------------
; Boot_SciPutHex   [0xFCC4]   <- F4B9, F5A3, F705, F7AA, F855, F87A, F8E0, F905
;---------------------------------------------------------------
  FCC4:  87           psha   
  FCC5:  89           pshx   
  FCC6:  87           psha   
  FCC7:  95           tsx    
  FCC8:  7f           clr    ,x
  FCC9:  3d7f         tst    $7F
  FCCB:  2735         beq    LFD02
  FCCD:  e605         lda    5,x
  FCCF:  2731         beq    LFD02
  FCD1:  b17f         cmp    $7F
  FCD3:  2304         bls    LFCD9
  FCD5:  b67f         lda    $7F
  FCD7:  e705         sta    5,x
LFCD9:
  FCD9:  f7           sta    ,x
  FCDA:  201d         bra    LFCF9
LFCDC:
  FCDC:  be7e         ldx    $7E
  FCDE:  8c           clrh   
  FCDF:  e680         lda    128,x
  FCE1:  9efe02       ldhx   2,s
  FCE4:  af01         aix    #$01
  FCE6:  9eff02       sthx   2,s
  FCE9:  afff         aix    #$FF
  FCEB:  f7           sta    ,x
  FCEC:  3c7e         inc    $7E
  FCEE:  b67e         lda    $7E
  FCF0:  a118         cmp    #$18
  FCF2:  2502         bcs    LFCF6
  FCF4:  3f7e         clr    $7E
LFCF6:
  FCF6:  95           tsx    
  FCF7:  6a05         dec    5,x
LFCF9:
  FCF9:  6d05         tst    5,x
  FCFB:  26df         bne    LFCDC
  FCFD:  b67f         lda    $7F
  FCFF:  f0           sub    ,x
  FD00:  b77f         sta    $7F
LFD02:
  FD02:  f6           lda    ,x
  FD03:  a703         ais    #$03
  FD05:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FD06   [0xFD06]   <- F753
;---------------------------------------------------------------
  FD06:  3f9a         clr    $9A
  FD08:  45056c       ldhx   #$056C
  FD0B:  3598         sthx   $98
  FD0D:  4f           clra   
  FD0E:  c70061       sta    TPM2CNTH
  FD11:  c70062       sta    TPM2CNTL
  FD14:  a60b         lda    #$0B
  FD16:  c70060       sta    TPM2SC
  FD19:  4f           clra   
  FD1A:  c70063       sta    TPM2MODH
  FD1D:  c70064       sta    TPM2MODL
  FD20:  a610         lda    #$10
  FD22:  c70065       sta    TPM2C0SC
  FD25:  4f           clra   
  FD26:  c70068       sta    TPM2C1SC
  FD29:  960066       sthx   TPM2C0VH
  FD2C:  c70069       sta    TPM2C1VH
  FD2F:  c7006a       sta    TPM2C1VL
  FD32:  81           rts    

;---------------------------------------------------------------
; Boot_CopFeed   [0xFD33]   <- F490, F504, F57A, F5B6, F5CF, F6DE
;---------------------------------------------------------------
  FD33:  200e         bra    LFD43
LFD35:
  FD35:  b699         lda    $99
  FD37:  ab6c         add    #$6C
  FD39:  b799         sta    $99
  FD3B:  b698         lda    $98
  FD3D:  a905         adc    #$05
  FD3F:  b798         sta    $98
  FD41:  3c9a         inc    $9A
LFD43:
  FD43:  c60062       lda    TPM2CNTL
  FD46:  87           psha   
  FD47:  c60061       lda    TPM2CNTH
  FD4A:  87           psha   
  FD4B:  b699         lda    $99
  FD4D:  be98         ldx    $98
  FD4F:  ad58         bsr    Boot_sub_FDA9
  FD51:  a702         ais    #$02
  FD53:  4d           tsta   
  FD54:  26df         bne    LFD35
  FD56:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FD57   [0xFD57]   <- FE19
;---------------------------------------------------------------
  FD57:  87           psha   
  FD58:  87           psha   
  FD59:  a104         cmp    #$04
  FD5B:  2516         bcs    LFD73
  FD5D:  ae07         ldx    #$07
  FD5F:  8c           clrh   
  FD60:  52           div    
  FD61:  ab04         add    #$04
  FD63:  95           tsx    
  FD64:  f7           sta    ,x
  FD65:  e601         lda    1,x
  FD67:  f0           sub    ,x
  FD68:  e701         sta    1,x
  FD6A:  2003         bra    LFD6F
LFD6C:
  FD6C:  9d           nop    
  FD6D:  6a01         dec    1,x
LFD6F:
  FD6F:  6d01         tst    1,x
  FD71:  26f9         bne    LFD6C
LFD73:
  FD73:  a702         ais    #$02
  FD75:  81           rts    

;---------------------------------------------------------------
; Boot_Delay   [0xFD76]   <- F525, F5DB, FE03
;---------------------------------------------------------------
  FD76:  87           psha   
  FD77:  89           pshx   
  FD78:  87           psha   
  FD79:  9e6f01       clr    1,s
  FD7C:  9ee102       cmp    2,s
  FD7F:  2510         bcs    LFD91
  FD81:  5f           clrx   
  FD82:  9ee002       sub    2,s
  FD85:  2401         bcc    LFD88
  FD87:  5a           decx   
LFD88:
  FD88:  a07f         sub    #$7F
  FD8A:  9f           txa    
  FD8B:  a200         sbc    #$00
  FD8D:  9015         bge    LFDA4
  FD8F:  200f         bra    LFDA0
LFD91:
  FD91:  9f           txa    
  FD92:  5f           clrx   
  FD93:  9ee003       sub    3,s
  FD96:  2401         bcc    LFD99
  FD98:  5a           decx   
LFD99:
  FD99:  a080         sub    #$80
  FD9B:  9f           txa    
  FD9C:  a200         sbc    #$00
  FD9E:  9104         blt    LFDA4
LFDA0:
  FDA0:  a601         lda    #$01
  FDA2:  95           tsx    
  FDA3:  f7           sta    ,x
LFDA4:
  FDA4:  95           tsx    
  FDA5:  f6           lda    ,x
  FDA6:  a703         ais    #$03
  FDA8:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FDA9   [0xFDA9]   <- FD4F
;---------------------------------------------------------------
  FDA9:  87           psha   
  FDAA:  89           pshx   
  FDAB:  87           psha   
  FDAC:  95           tsx    
  FDAD:  7f           clr    ,x
  FDAE:  9ece05       ldhx   5,x
  FDB1:  9ef302       cphx   2,s
  FDB4:  95           tsx    
  FDB5:  2515         bcs    LFDCC
  FDB7:  e606         lda    6,x
  FDB9:  e002         sub    2,x
  FDBB:  87           psha   
  FDBC:  e605         lda    5,x
  FDBE:  95           tsx    
  FDBF:  e202         sbc    2,x
  FDC1:  97           tax    
  FDC2:  86           pula   
  FDC3:  a0ff         sub    #$FF
  FDC5:  9f           txa    
  FDC6:  a27f         sbc    #$7F
  FDC8:  2419         bcc    LFDE3
  FDCA:  2013         bra    LFDDF
LFDCC:
  FDCC:  9ee007       sub    7,s
  FDCF:  87           psha   
  FDD0:  e601         lda    1,x
  FDD2:  95           tsx    
  FDD3:  e206         sbc    6,x
  FDD5:  97           tax    
  FDD6:  86           pula   
  FDD7:  99           sec    
  FDD8:  a2ff         sbc    #$FF
  FDDA:  9f           txa    
  FDDB:  a27f         sbc    #$7F
  FDDD:  2504         bcs    LFDE3
LFDDF:
  FDDF:  a601         lda    #$01
  FDE1:  95           tsx    
  FDE2:  f7           sta    ,x
LFDE3:
  FDE3:  95           tsx    
  FDE4:  f6           lda    ,x
  FDE5:  a703         ais    #$03
  FDE7:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FDE8   [0xFDE8]   <- F6CE
;---------------------------------------------------------------
  FDE8:  c6009a       lda    $009A
  FDEB:  b79b         sta    $9B
  FDED:  3f9c         clr    $9C
  FDEF:  450008       ldhx   #$0008
  FDF2:  f6           lda    ,x
  FDF3:  aa80         ora    #$80
  FDF5:  f7           sta    ,x
  FDF6:  450009       ldhx   #$0009
  FDF9:  f6           lda    ,x
  FDFA:  aa80         ora    #$80
  FDFC:  f7           sta    ,x
  FDFD:  81           rts    

;---------------------------------------------------------------
; Boot_sub_FDFE   [0xFDFE]   <- F5B9, F5D2, F6F1
;---------------------------------------------------------------
  FDFE:  c6009a       lda    $009A
  FE01:  be9b         ldx    $9B
  FE03:  cdfd76       jsr    Boot_Delay
  FE06:  4d           tsta   
  FE07:  271e         beq    LFE27
  FE09:  c6009a       lda    $009A
  FE0C:  ab1e         add    #$1E
  FE0E:  b79b         sta    $9B
  FE10:  450008       ldhx   #$0008
  FE13:  f6           lda    ,x
  FE14:  a47f         and    #$7F
  FE16:  f7           sta    ,x
  FE17:  a602         lda    #$02
  FE19:  cdfd57       jsr    Boot_sub_FD57
  FE1C:  450008       ldhx   #$0008
  FE1F:  f6           lda    ,x
  FE20:  aa80         ora    #$80
  FE22:  f7           sta    ,x
  FE23:  6e019c       mov    #$01, $9C
  FE26:  81           rts    
LFE27:
  FE27:  3f9c         clr    $9C
  FE29:  81           rts    
