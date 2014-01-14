      SUBROUTINE W3CNVXTOVS (IDATE,IBUFTN,IFLDUN,stnid,INSTR,KINDX,NN)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    W3CNVXTOVS
C   PRGMMR: KEYSER           ORG: NP22       DATE: 2013-02-14
C
C ABSTRACT: CONVERTS AN RTOVS OR ATOVS REPORT ORIGINALLY IN UNPACKED
C   NMCEDS FORMAT TO UNPACKED IW3UNPBF FORMAT (AS DESCRIBED IN ROUTINE
C   IW3UNPBF).  THE UNPACKED NMCEDS FORMAT IS FILLED ONLY WITH THOSE
C   VALUES NEEDED FOR RTOVS OR ATOVS PROCESSING BY THE PREPDATA
C   PROGRAM.
C
C PROGRAM HISTORY LOG:
C 1998-02-17  D. A. KEYSER -- ORIGINAL AUTHOR (ADAPTED FROM W3LIB
C        ROUTINE W3FI43).
C 1998-06-15  D. A. KEYSER -- ADAPTED FOR USE ONLY WITH RTOVS DATA
C        (AFTER TOVS DEMISE) (I.E., NO PARTLY-CLOUDY PATH AVAILABLE,
C        ONLY ESSENTIAL DATA IN UNPACKED NMCEDS FORMAT); WRITES OUT
C        ONLY CATEGORY 1 IW3UNPBF DATA SINCE THIS IS ALL THAT IS
C        PROCESSED IN PREPDATA; OTHERWISE STREAMLINED
C 1998-09-21  D .A. KEYSER -- SUBROUTINE NOW Y2K AND FORTRAN 90
C        COMPLIANT
C 1999-11-19  D. A. KEYSER -- INCLUDES NOAA-15 ATOVS DATA (AS WELL AS
C        RTOVS DATA); RENAMED SUBROUTINE
C 2001-10-29  D. A. KEYSER -- RETURNS SATELLITE ID AS DEFINED IN
C        BUFR CODE TABLE 0-01-007 IN WORD 6 OF UNPACKED IW3UNPBF
C        FORMAT (INTEGER)
C 2004-09-09  D. A. KEYSER -- MODIFIED INDEXING FOR UNPACKED IW3UNPBF
C        FORMAT TO COMPLY WITH CHANGES MADE IN ROUTINES IW3UNPBF AND
C        W3UNPKB7; ALLOW OUTPUT ARGUMENT IFLDUN TO HAVE ADJUSTABLE
C        DIMENSION BASED ON WHATEVER IS PASSED IN FROM CALLING PROGRAM
C        (BEFORE WAS ONLY 273 WORDS WHICH DIDN'T MATCH 2500-WORDS IN
C        prepdata.f - LUCKY MEMORY WASN'T CLOBBERED)
C 2012-11-30  J. WOOLLEN  INITIAL PORT TO WCOSS 
C 2013-02-14  D. A. KEYSER -- FINAL CHANGES TO RUN ON WCOSS
C
C USAGE:    CALL W3CNVXTOVS(IDATE,IBUFTN,IFLDUN,STNID,INSTR,KINDX,NN)
C   INPUT ARGUMENT LIST:
C     IDATE    - 4-WORD ARRAY HOLDING "CENTRAL" DATE TO PROCESS
C              - (YYYY, MM, DD, HH)
C     IBUFTN   - ADDRESS HOLDING A SINGLE RTOVS/ATOVS REPORT (140
C              - INTEGER WORDS) IN UNPACKED NMCEDS FORMAT (THE UNPACKED
C              - NMCEDS FORMAT IS FILLED ONLY WITH THOSE VALUES NEEDED
C              - FOR RTOVS/ATOVS PROCESSING BY THE PREPDATA PROGRAM)
C     INSTR    - INDICATOR FOR RETRIEVAL PATH (EITHER 1 FOR CLEAR OR
C              - 3 FOR CLOUDY)
C     KINDX    - INTEGER  1-5 DIGIT NUMBER USED TO GENERATE FIRST
C              - 5 CHARACTERS OF STATION ID (USUALLY JUST A REPORT
C              - COUNTER INDEX EXCEPT FIRST NUMBER MAY BE NADIR
C              - PROXIMITY INDICATOR -- SEE PREPDATA PROGRAM)
C     NN       - SWITCH TO INDICATE RTOVS (NN=1) OR ATOVS (NN=2)
C
C   OUTPUT ARGUMENT LIST:
C     IFLDUN   - INTEGER *-WORD ARRAY HOLDING A SINGLE RTOVS/ATOVS
C              - REPORT IN UNPACKED IW3UNPBF FORMAT (SEE ROUTINE
C              - IW3UNPBF) (NOTE: DOES NOT INCLUDE STATION ID)
C              - (MUST BE DIMENSIONED TO AT LEAST 283-WORDS BY
C              - CALLING PROGRAM, ONLY FIRST 283-WORDS ARE FILLED)
C     STNID    - CHARACTER*8 SINGLE REPORT STATION IDENTIFICATION (UP
C              - TO 8 CHARACTERS, LEFT-JUSTIFIED)
C
C
C REMARKS: MUST BE CALLED AFTER CALL TO W3FA07 WHICH FILLS IN VALUES
C          IN COMMON BLOCK /FA07AA/.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  NCEP WCOSS
C
C$$$
 
      REAL  RDATA(283),PMAND(20)
 
      INTEGER  IDATE(4),IDATA(283),IFLDUN(*),IBUFTN(140)
 
      CHARACTER*1  CSUFX(3,4),CSAT(2)
      CHARACTER*8  STNID
 
      COMMON/FA07AA/TM(20),Z(20),MLVLS
 
      EQUIVALENCE (IDATA,RDATA)
 
      SAVE
 
      DATA  CSUFX /'W','?','Y',    'E','?','G',
     $             'S','?','U',    'A','?','C'/
      DATA  CSAT  /'R','A'/
      DATA  XMISS/99999./,IMISS/99999/
      DATA  PMAND/10000.,8500.,7000.,5000.,4000.,3000.,2500.,2000.,
     $ 1500.,1000.,700.,500.,300.,200.,100.,70.,50.,30.,20.,10./
 

C  INITIALIZE ALL CATEGORY TYPES AND NUMBER OF LEVELS TO ZERO
 
      IDATA(13:52) = 0
 
C  ALLOWS 21 LEVELS FOR CAT. 1 - THIS IS THE ONLY CATEGORY THAT IS
C   PROCESSED  (SET ALL WORDS IN CAT. 1 TO MISSING)
 
      RDATA(53:283) = XMISS
 
C  SET Q.M.'S TO 2 FOR CATEGORY 1 (DEFAULT)
 
      RDATA(59:279:11) = 2.0
      RDATA(60:280:11) = 2.0
      RDATA(61:281:11) = 2.0
      RDATA(62:282:11) = 2.0
      RDATA(63:283:11) = 2.0
 
C  FILL IN IW3UNPBF REPORT HEADER
 
      RDATA(1)  = IBUFTN(5)/100.
      RDATA(2)  = IBUFTN(6)/100.
      IF(IBUFTN(6).LT.0)  RDATA(2) = 360. + IBUFTN(6)/100.
      IF(RDATA(2).EQ.360.0)  RDATA(2) = 0.0
      RDATA(3)  = 0.
      IHR  = MOD(IBUFTN(3),256)
      IB4  = IBUFTN(4)/256
      XMIN = IB4/60.
      RDATA(4)  = IHR + XMIN
      IDATA(5)  = IMISS
      IDATA(6)  = IMISS
      IF(IDATE(1).GE.1996)  THEN
         IDATA(6)  = 202 + IBUFTN(1)
      ELSE  IF(IDATE(1).GE.1991.AND.IBUFTN(1).LT.4)  THEN
         IDATA(6)  = 202 + IBUFTN(1)
      ELSE
         IF(IBUFTN(1).GT.5)  IDATA(6)  = 194 + IBUFTN(1)
      END IF
      RDATA(7)  = IBUFTN(8)
      IDATA(8)  = IMISS
      IDATA(9)  = 61
      RDATA(10) = 0.
      RDATA(11) = XMISS
      IDATA(12) = IMISS
 
C  STN. ID: POS. 1-5 FROM 'KINDX', POS. 6 FROM CHAR. BASED ON SATELLITE
C   NUMBER & RETRIEVAL PATH, POS. 7 INDICATES RTOVS ("R") OR ATOVS ("A")
 
C       POSITION 6 CHARACTER POSSIBILITIES ARE:
C            ODD  SATELLITE NUMBERS 3, 7, 11, 15, ETC.:  A, C
C            ODD  SATELLITE NUMBERS 1, 5,  9, 13, ETC.:  E, G
C            EVEN SATELLITE NUMBERS 2, 6, 10, 14, ETC.:  S, U
C            EVEN SATELLITE NUMBERS 4, 8, 12, 16, ETC.:  W, Y
C    WHERE: CHARACTERS  A, E, S, W  ARE FOR CLEAR PATH (DEFAULT)
C           CHARACTERS  C, G, U, Y  ARE FOR CLOUDY (MICROWAVE) PATH
 
      MODSAT = MOD(IBUFTN(1),4) + 1
 
C  STATION IDENTIFICATION IN "STNID" (8 CHARACTERS)
 
      WRITE(STNID,1)  KINDX,CSUFX(INSTR,MODSAT),CSAT(NN)
    1 FORMAT(I5.5,A1,A1,' ')
 
C  FILL IN IW3UNPBF CATEGORY 1 (MANDATORY LEVEL DATA)
 
      IDATA(13) = MLVLS + 1
      IDATA(14) = 53
      K = 53
 
      DO I = 1,MLVLS
         IF(I.EQ.2)  THEN
            RDATA(K) = 9250.
            K = K + 11
         END IF
         RDATA(K) = PMAND(I)
         RDATA(K+1) = Z(I) + 0.5
         IF(TM(I).LT.10273.)  RDATA(K+2) = (TM(I) - 273.16) * 10.
         K = K + 11
      ENDDO
 
C  COPY IW3UNPBF FIELD (IDATA) TO IFLDUN FOR TRANSFER OUT OF SUBROUTINE
 
      IFLDUN(1:283) = IDATA
 
      RETURN
      END