BASLINE ; ; 9/3/20 12:54pm
 W !,"EPOCH FOLDER? " ; /tmp/epoch76/
 R EPOCHDIR
 W !,"EPOCH NUMBER? " ; 76
 R EPOCHNO
 W !,"BASELINE FOLDER? " ; /tmp/london27042020/
 R BASEDIR
 W !,"NEW BASELINE FOLDER? " ; /tmp/newbaseline/
 R NEWBF
 W !
 D FOLD(EPOCHDIR,BASEDIR,EPOCHNO,NEWBF)
 QUIT
 
FOLD(EPOCHDIR,BASEDIR,EPOCHNO,NEWBF) ;
 D BLPU(EPOCHDIR),STREET(EPOCHDIR),DPA(EPOCHDIR),LPI(EPOCHDIR),CLASS(EPOCHDIR)
 
 D GENBASE(BASEDIR,"ID15_StreetDesc_Records.csv","^STREET","ID15_StreetDesc_Records.new.csv",EPOCHNO,NEWBF)
 D GENBASE(BASEDIR,"ID21_BLPU_Records.csv","^BLPU","ID21_BLPU_Records.new.csv",EPOCHNO,NEWBF)
 D GENBASE(BASEDIR,"ID24_LPI_Records.csv","^LPI","ID24_LPI_Records.new.csv",EPOCHNO,NEWBF)
 D GENBASE(BASEDIR,"ID28_DPA_Records.csv","^DPA","ID28_DPA_Records.new.csv",EPOCHNO,NEWBF)
 D GENBASE(BASEDIR,"ID32_Class_Records.csv","^CLASS","ID32_Class_Records.new.csv",EPOCHNO,NEWBF)
 
 QUIT
 
GENBASE(BDIR,B,G1,NEW,EPOCH,NEWBF) ; MERGE DELTAS INTO BASELINE
 K ^UPDATES,^DELETES,^INSERTS
 S F=BDIR_B
 C F
 O F:(readonly)
 
 U 0 W !,"WRITING BASELINE FOR ",B
 
 ; LOAD BASELINE FILE
 F  U F R STR Q:$ZEOF  DO
 .S UPRN=$P(STR,",",4)
 .S DSTR=$GET(@G1@(UPRN))
 .I DSTR'="" DO
 ..S TYPE=$$TR^LIB($P(DSTR,",",2),"""","")
 ..I TYPE="U" S ^UPDATES(UPRN)=$E(G1,2,999)_"`"_DSTR
 ..I TYPE="D" S ^DELETES(UPRN)=$E(G1,2,999)_"`"_DSTR
 ..QUIT
 .QUIT
 C F
 
 U 0 W !,"WRITING INSERTS FOR ",B
 
 ; INSERTS
 S UPRN=""
 F  S UPRN=$O(@G1@(UPRN)) Q:UPRN=""  DO
 .S DSTR=^(UPRN)
 .S TYPE=$$TR^LIB($P(DSTR,",",2),"""","")
 .I TYPE="I" S ^INSERTS(UPRN)=$E(G1,2,999)_"`"_DSTR
 .QUIT
 
 ; CREATE A NEW BASELINE
 S NEW=$$TR^LIB(NEW,".new.",("."_EPOCH_"."))
 S F=NEWBF_NEW
 C F
 O F:(newversion)
 S BASE=BDIR_B
 C BASE
 O BASE:(readonly)
 F  U BASE R STR Q:$ZEOF  DO
 .S UPRN=$P(STR,",",4)
 .I $D(^UPDATES(UPRN)) USE F W $PIECE(^UPDATES(UPRN),"`",2,9999),! QUIT
 .I $D(^DELETES(UPRN)) QUIT ; FORGET DELETES
 .U F W STR,!
 .QUIT
 ; INSERTS
 S UPRN=""
 F  S UPRN=$O(^INSERTS(UPRN)) Q:UPRN=""  U F W $P(^(UPRN),"`",2,9999),!
 CLOSE F,BASE
 ;
 ; ARCHIVE OF UPDATED, DELETED AND INSERTED RECORD
 ;
 ;F GLOB="^INSERTS","^UPDATES","^DELETES" DO
 ;.S UPRN=""
 ;.F  S UPRN=$O(@GLOB@(UPRN)) Q:UPRN=""  DO
 ;..S ^ARCHIVE(UPRN,EPOCH,$E(GLOB,2))=^(UPRN)
 ;..QUIT
 ;.QUIT
 
 QUIT
 
BLPU(EPOCHDIR) 
 K ^BLPU
 S FILE=EPOCHDIR_"ID21_BLPU_Records.csv"
 CLOSE FILE
 O FILE:(readonly)
 F  U FILE R STR Q:$ZEOF  D
 .;U 0 W !,STR
 .S UPRN=$P(STR,",",4)
 .;I $D(^BLPU(UPRN)) BREAK
 .S ^BLPU(UPRN)=STR
 .QUIT
 C FILE	
 QUIT
 
STREET(EPOCHDIR) 
 K ^STREET
 S FILE=EPOCHDIR_"ID15_StreetDesc_Records.csv"
 CLOSE FILE
 O FILE:(readonly)
 F  U FILE R STR Q:$ZEOF  D
 .;U 0 W !,STR
 .S UPRN=$P(STR,",",4)
 .;U 0 W !,UPRN
 .I $D(^STREET(UPRN)) BREAK
 .S ^STREET(UPRN)=STR
 .QUIT
 C FILE
 QUIT
 
DPA(EPOCHDIR) 
 K ^DPA
 S FILE=EPOCHDIR_"ID28_DPA_Records.csv"
 CLOSE FILE
 
 O FILE:(readonly)
 F  U FILE R STR Q:$ZEOF  D
 .;U 0 W !,STR
 .S UPRN=$P(STR,",",4)
 .;U 0 W !,UPRN
 .I $D(^DPA(UPRN)) ; BREAK
 .S ^DPA(UPRN)=STR
 .QUIT
 
 C FILE
 QUIT
 
LPI(EPOCHDIR) 
 K ^LPI
 S FILE=EPOCHDIR_"ID24_LPI_Records.csv"
 CLOSE FILE
 
 O FILE:(readonly)
 F  U FILE R STR Q:$ZEOF  D
 .;U 0 W !,STR
 .S UPRN=$P(STR,",",4)
 .;U 0 W !,UPRN
 .I $D(^LPI(UPRN)) ; BREAK
 .S ^LPI(UPRN)=STR
 .QUIT
 
 C FILE
 QUIT
 
CLASS(EPOCHDIR) 
 K ^CLASS
 S FILE=EPOCHDIR_"ID32_Class_Records.csv"
 CLOSE FILE
 
 O FILE:(readonly)
 F  U FILE R STR Q:$ZEOF  D
 .;U 0 W !,STR
 .S UPRN=$P(STR,",",4)
 .;U 0 W !,UPRN
 .I $D(^CLASS(UPRN)) ; BREAK
 .S ^CLASS(UPRN)=STR
 .QUIT
 
 C FILE
 QUIT