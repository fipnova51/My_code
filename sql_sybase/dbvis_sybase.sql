select @@version;
select @@spid;
select db_name();
sp_help SE_HEAD_DBF; --COREPL_REP DYN_AUDIT_REP
sp_spaceused TRN_HDRF_DBF, 1;
sp_helpindex GET_ONB_INVALID_ONB;
sp_helprotect TRN_HDR_DBF;
sp_helpdb;
setuser 'guest';

select id,name from sysobjects where name like '%FLT%'; --H399634_H1S
select * from syscolumns where id = 1309738675;
select * from sysindexes where name like '%_SST%';
select * from sysusers where uid=2;
select object_id('TRN_HDR_DBF');

drop index TRN_HDR_DBF.TRN_HDR_SST0;
drop index GET_ONB.GET_ONB_SST0;
drop index ONB_BY_MKTOP.ONB_BY_MKTOP_SST0;
drop index GET_ONB_INVALID_ONB.GET_ONB_INVALID_ONB_SST1;
drop index GET_ONB_INVALID_ONB.GET_ONB_INVALID_ONB_SST0;
drop index TRMKTOP_DBF.TRMKTOP_SST0;

-- RDB scope SQL
select * from RDB_OBJECT_DBF where M_OBJECT_ID='CM.476';
select * from RDB_CLASS_DBF where M_CLASS_NAME=(select M_CLASS_NAME from RDB_OBJECT_DBF where M_OBJECT_ID='CM.476');
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFD_TABLE_NAME,M_RFD_FORMULA from RDBCNSTR_DBF where M_RFD_TABLE_NAME like '%SITRN%'; and M_RFD_FORMULA='M_INSGEN%';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFG_RELATIONSHIP,M_RFD_TABLE_NAME,M_RFD_FORMULA,M_RFD_RELATIONSHIP from RDBCNSTR_DBF where M_RFG_TABLE_NAME='CM_MKTSR_DBF'; and M_RFG_FORMULA='M_LABEL';
select 'select * from '+M_RFG_TABLE_NAME+' where '+M_RFG_FORMULA+' = ''188'' ;' from RDBCNSTR_DBF where M_RFD_TABLE_NAME='CM_MKTSR_DBF'; and M_RFD_FORMULA='M_LABEL';

--3.1 queries
select OB.M_OBJECT_ID, OB.M_OBJECT_NAME, OB.M_CLASS_NAME, CL.M_TABLE_NAME, CS.M_RFD_TABLE_NAME
from RDB_OBJECT_DBF OB join RDB_CLASS_DBF CL on OB.M_CLASS_NAME = CL.M_CLASS_NAME join RDBCNSTR_DBF CS on CL.M_TABLE_NAME = CS.M_RFG_TABLE_NAME where M_OBJECT_NAME like '%Rate curve%'; -- list dependance for one object to export
select * from RDBCNSTR_DBF where M_RFG_TABLE_NAME = 'TRN_HDR_DBF' and M_RFG_FORMULA = 'M_INSTRUMENT';
select rtrim(M_RFG_TABLE_NAME), rtrim(M_RFG_FORMULA), rtrim(M_RFD_TABLE_NAME), rtrim(M_RFD_FORMULA) from RDBCNSTR_DBF;
select T1.M_ID, T1.M_INSTRUMENT,M_RSKSECTION, M_PL_KEY1, count(1) from TRN_ARCB_DBF T1 left join TRN_PLIN_DBF T2 on convert(char(20),T1.M_INSTRUMENT) = T2.M_REFERENCE where T2.M_REFERENCE is null group by T1.M_ID, T1.M_INSTRUMENT, M_RSKSECTION, M_PL_KEY1;
select M_TRN_FMLY,M_TRN_GRP, M_TRN_TYPE, count(1) from TRN_HDR_DBF T join FLT_MAP_DBF M on T.M_NB = M.M_NB group by M_TRN_FMLY,M_TRN_GRP, M_TRN_TYPE order by count(1) DESC; --what s the representation of the deals in FLT_MAP_DBF?
select dyn.M_IDJOB,dyn.M_DATEGEN,scn.M_REFERENCE, scn.M_NB_ITEMS,case when dyn.M_EXE_STATUS = 'T' then 'On-going' when dyn.M_EXE_STATUS = 'F' then 'Failed' end as STATUS, count(*) as REMAINING, ((scn.M_NB_ITEMS - count(*))/scn.M_NB_ITEMS) * 100 as PCT_COMPLETE
from DYN_AUDIT_REP dyn join SCANNER_REP scn on convert(char,dyn.M_IDJOB) = scn.M_EXT_ID
    join BATCH_REP bat on scn.M_REFERENCE = bat.M_SCANNER_ID
    join ITEM_REP itm on itm.M_BAT_REF= bat.M_BAT_REF and itm.M_SCANNER_ID = bat.M_SCANNER_ID
group by dyn.M_IDJOB,scn.M_REFERENCE order by dyn.M_IDJOB;-- Remaining deals to be completed per batch of feeders

select dyn.M_IDJOB,dyn.M_DATEGEN,scn.M_REFERENCE, itm.M_ITM_REF
from DYN_AUDIT_REP dyn join SCANNER_REP scn on convert(char,dyn.M_IDJOB) = scn.M_EXT_ID
    join BATCH_REP bat on scn.M_REFERENCE = bat.M_SCANNER_ID
    join ITEM_REP itm on itm.M_BAT_REF= bat.M_BAT_REF and itm.M_SCANNER_ID = bat.M_SCANNER_ID
where dyn.M_IDJOB = 1306763; -- list of remaining deals to be completed per batch of feeders

select M_IDJOB, M_DATEGEN, M_DELETED, M_TAG_DATA from DYN_AUDIT_REP where M_DELETED='N' and M_TAG_DATA='CPLIRD'; -- get information about the audit of batch of feeders execution

select MESSAGE_TIME_STAMP,PATH, STEP, GSTATUS from MXODR_ASSEMBLY_LOG order by MESSAGE_TIME_STAMP;

select distinct(M_MX_REF_JOB) from SST_COREPL_REP;
truncate table SST_COREPL_REP;

--2.11 queries
select M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE, count(*) as total from TRN_HDR_DBF  group by M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE order by M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE;
select M_TRN_FMLY, M_TRN_GRP,M_TRN_TYPE,M_TRN_STATUS, count(1) from TRN_HDR_DBF where M_PURGE_STS <> 2 group by M_TRN_FMLY, M_TRN_GRP,M_TRN_TYPE,M_TRN_STATUS order by M_TRN_FMLY, M_TRN_GRP,M_TRN_TYPE,M_TRN_STATUS;
select M_PURGE_DATE,M_PURGE_GRP,M_PURGE_STS, count(1) from TRN_HDR_DBF group by M_PURGE_DATE,M_PURGE_GRP,M_PURGE_STS order by M_PURGE_DATE,M_PURGE_GRP,M_PURGE_STS;
select M_TRN_DATE,count(1) as number_of_deals_inserted from TRN_HDR_DBF where M_TRN_DATE between '2015-10-13' and '2015-10-20' group by M_TRN_DATE order by M_TRN_DATE;

;
select T2.M__ALIAS_, count(*) from TRN_MDS_DBF T1 join MPX_SMC_DBF T2 on T1.M_ALIAS = T2.M__ALIAS_ join MPY_SMC_DBF T3 on T2.M__INDEX_ = T3.M__INDEX_ group by T2.M__ALIAS_;
select distinct(M_ALIAS) from TRN_MDS_DBF;
select count(*) from MPY_SMC_DBF where M__INDEX_ in (select M__INDEX_ from MPX_SMC_DBF where M__ALIAS_='./BACK');

select  T.M_TRN_FMLY, T.M_TRN_GRP, T.M_TRN_TYPE, count(1) as TOTAL
from TRN_HDR_DBF T join TRN_HDRF_DBF TF on T.M_NB = TF.M_NB
group by T.M_TRN_FMLY, T.M_TRN_GRP, T.M_TRN_TYPE
order by T.M_TRN_FMLY, T.M_TRN_GRP, T.M_TRN_TYPE;

select M_NB, count(1) as TOTAL from TRN_HDRF_DBF group by M_NB order by count(1) DESC;

select  T.M_TRN_FMLY, T.M_TRN_GRP, T.M_TRN_TYPE, count(1) as TOTAL 
from TRN_HDR_DBF T 
where T.M_NB in (select M_NB from (select M_NB from FLT_MAP_BBVA_DBF union select M_NB from FLT_MAP_BANCOMER_DBF) T) 
group by T.M_TRN_FMLY, T.M_TRN_GRP, T.M_TRN_TYPE;


-- ROF correction
select * from DPI_ID_DBF where M_LABEL1 like '%ARC%';
update DPI_ID_DBF set M_UNIQUE_ID=64 where M_LABEL1='SPB_ARC' and M_LABEL2='trn_arch.dbf' and M_UNIQUE_ID=63;
insert TRN_ARCH_DBF(M_ID,M_TIME_CMP,M_BO_FO,M_USR_NAME,M_USR_GROUP,M_USR_DESK,M_DELETED,M_PC,M_COMMENT,M_DATE_ARC)
values (64,60000,'BO','REALTIME','HOUSEKEEP','',0,0,'Manual purge of deals for the ROF','2016/06/06');
update TRN_HDR_DBF set M_PURGE_REF=64, M_PURGE_DATE='2016/06/06' 
where M_BPFOLIO not in ('MX818BE','MX821BC','MX821BEBC','MX821TN','MX825HN','MX830BC','CPMDERIVA','CPMDERMN','CPCDIFWBO','CPMDIIRS','CPMSPREMX',
'CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDIOTC','FOCSWANEG','FOMMCRO10','FOMMCRO15','FOMMCRO16','FOMMCRO18',
'FOMMCRO19','FOMMCRO22','FOMSWATME','FOMXEBCGL','FOMIRSMNR','FOMMCRO11','FOMMCRO14','FOMMCRO21','FOMMCRO25','FOMMCRO29',
'FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC','FOMTEMPO','FOMXBCCGL','CVMRATES','CMMENERGY',
'DEMTRADIN','DGMDERIV','DGMMXEMER','DGMRESLP','DGMTASAS','DGMUDIS','LPMDIFWD','RCMDISCRE','LPMDIDEPO','LPMDIMMOO','LPMDIOTC',
'LPMDIRBAS','LPMIRS1','LPMIRS2','MKMDERIV','POMFX','LPMASIGNA','LPMDCCCME','LPMDCCEUR','LPMDCCINT','LPMDCCMXN','LPMDCCUSD',
'LPMDCNCOL','LPMDIRCUR','LPMEXDER','LPMXDERSW','MKMTRDEPO','POMIRSTIE','POMUDIMKT','POMUDIS','POCXCCY','POMINVERS','POMVALREL',
'POMXCCY','CRCTASAS','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','ESMDIGTIE',
'ESMDIGTOT','ESMFLEXIC','ESMMMOO','LPMVOLTAS','LPMVOLTOT','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','DEMESTTC','DEMESTTI','ESMCOATRM',
'ESMDEPOS','ESMESTRMI','ESMESTRVA','ESMESTTAS','ESMWARRAN','AJUSTEVOLATIP','FVA_MXCRUCES','INIRDOOFF','MXCRUCDGA','MXCRUCECP',
'MXCRUCEDG','MXCRUCEEU','MXCRUCELP','MXCRUCENP','MXCRUCEUS','MXCRUCNPC','BANKING_BOOK','BB_ASIA','CORTO PLAZO','CORTO_PLAZO_CLI',
'CVA_CORTO','ETFCORTO','INIRDOCPBANK','INIRDOCPLAZO','STIR_ASIA','STIR_CNH','STIR_EUR','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRDTASARS','INIRDOCRDMAD','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_LT_ASIA','FVA_RATES',
'FVA_RATES_ASIA','ESTRATFLOW','ESTRATGFI','INIRDOESTRAGFI','BERMUDA EUROESB','COBEXTEXO','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS',
'CORTO NO BDT','FINP_COLAT_CRED','FINP_COLAT_RATE','FVA_NP_IR','INTERNAS_SABR','LEG_NPTIPOS','NP_COMMODITIES','NP_FOREX','OPCOTCBON',
'SLOPE_SABR','SWAPTIONAV','TRD3SPREAD','GM_GAPBONOS','GM_GAPDERIV','GM_GAPEQTY','GM_GAPWWR','SW_INI_2016','ASSET MILAN','ASSETBONOS',
'ASWGOB','BCAT TIPOS LARG','BGIPCAUX','BNACOBLAR','BOND OPT','BONOFW','BONOFWHD','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO',
'CL LARGO','COBERPAT','CORPOIRS','CPPI_SWAPS','CVA_LARGO','DDIVIRS','ELECTRICAS','ESTRATEGIAS','ESTRATGFI_BOND','ETFDEUDA','EUROFIMA',
'FORWARD','FVA SWAPS','INDICES DEUDA','INIRDOLP','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK','LATAM_SWAPS','LINKERS_ESP','LINKERS_ESP_H',
'LT NY','LTNY2','LT_ASIA','LT_BOND','LT_BONDH','LT_BONDT','LT_CHINA','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_HK_STRATEGY1','LT_KOREA',
'LT_KOREA_REPO','LT_KRW','LT_TWD','MACROBCLSW','MICROCOB','OPERPAT','PROFIT','PROJECT_GL_SW','STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO',
'SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC','SWAPS_CVA','SWAPS_RF','SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT',
'SW_CORTO','SW_ELECTRONIC','SW_EQUITY','SW_GBP','SW_GERMANY','SW_INI_2015','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS','TEMPMC02','VTABNPVMX','VTACAJAMX',
'XXBBVLPSW','ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA','FLOORSPV','CRDCLP','CRDCOP','CRDPEN','INIRDOSUDAM','MXCRUCECA','MXCRUCECL','MXCRUCECO',
'MXCRUCEPE','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA','BBV VANILLAMC02','BCAT VOL INT','BDT BBV','BDT BBV MC02',
'BDT CORTO MC02','BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BNACOBVOL','BOND_INFLATION','CFCHIPOT','CHILENOS','CHILENOS BBVA',
'CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBMAXMIN','CORRELACION USD','DERCOMBI','DIG BBVA','DIG DOM','DIG EUROESB','DIGUSDBBVA',
'ESP-INFLATION','EUR-INFLATION','EXOTICAS','FIN98','FINP_TRIP','FVA_INFLATION','FVA_VOL_RATES','HEDGEAV','HEDGEVIT','HIBRIDOS','HIPOTECRED',
'INIRDOVTP','LARGO NO BDT','LEGVOLATIPOS','MACROBCLVOL','OPC BONOS','OPCBDTHOJAS','OPCION COB','OPCION NC','OPCMIBOR','OPCSALES','OPTIPCFC',
'PROJECT_GL_VT','REVERFLFL','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONUSDBBVA','TIPDIVCFC','UNNIM_VTIP','US-INFLATION','VOL ASSETSWAP',
'VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5','VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY',
'VOLKRW','VOLSGD','VOLTWD','VOLUSD','VTCBBVA','VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA',
'ZC-OPTIONS','INIRDOPD','INIRDOPD997','AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3','AAAPDTI1',
'AAAPDTI1B','AAAPDTI2','AAAPDTI3','PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','ANALISTAS','G3','G3_EQUITY','INIRDOTRADSIST','LT_PROGRAM','NON_LIN_HF',
'UST_LOCK','UST_SPREAD','MGDSTOXAF','INIRDODISTMAD','INIRDOMIL','ASSWMIL','INIRDOOPC','INIRDODERIVNY','INIRDOUS_TREASU','NY_MANAGEMENT',
'NY_ST_DER','MAD_UST_BTB','UST_BOND','UST_STRAT','KOR_LT_SWAP','INIKORLT','VOL_IR_KOREA_1','INIRDOLTIRTPE','TWN_LTIRD2_DBU','TWN_VOLIR1_DBU',
'INIRDOVOLIRTPE','TWN_LTIRD1_DBU') or M_SPFOLIO not in ('MX818BE','MX821BC','MX821BEBC','MX821TN','MX825HN','MX830BC','CPMDERIVA','CPMDERMN','CPCDIFWBO','CPMDIIRS','CPMSPREMX',
'CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDIOTC','FOCSWANEG','FOMMCRO10','FOMMCRO15','FOMMCRO16','FOMMCRO18',
'FOMMCRO19','FOMMCRO22','FOMSWATME','FOMXEBCGL','FOMIRSMNR','FOMMCRO11','FOMMCRO14','FOMMCRO21','FOMMCRO25','FOMMCRO29',
'FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC','FOMTEMPO','FOMXBCCGL','CVMRATES','CMMENERGY',
'DEMTRADIN','DGMDERIV','DGMMXEMER','DGMRESLP','DGMTASAS','DGMUDIS','LPMDIFWD','RCMDISCRE','LPMDIDEPO','LPMDIMMOO','LPMDIOTC',
'LPMDIRBAS','LPMIRS1','LPMIRS2','MKMDERIV','POMFX','LPMASIGNA','LPMDCCCME','LPMDCCEUR','LPMDCCINT','LPMDCCMXN','LPMDCCUSD',
'LPMDCNCOL','LPMDIRCUR','LPMEXDER','LPMXDERSW','MKMTRDEPO','POMIRSTIE','POMUDIMKT','POMUDIS','POCXCCY','POMINVERS','POMVALREL',
'POMXCCY','CRCTASAS','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','ESMDIGTIE',
'ESMDIGTOT','ESMFLEXIC','ESMMMOO','LPMVOLTAS','LPMVOLTOT','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','DEMESTTC','DEMESTTI','ESMCOATRM',
'ESMDEPOS','ESMESTRMI','ESMESTRVA','ESMESTTAS','ESMWARRAN','AJUSTEVOLATIP','FVA_MXCRUCES','INIRDOOFF','MXCRUCDGA','MXCRUCECP',
'MXCRUCEDG','MXCRUCEEU','MXCRUCELP','MXCRUCENP','MXCRUCEUS','MXCRUCNPC','BANKING_BOOK','BB_ASIA','CORTO PLAZO','CORTO_PLAZO_CLI',
'CVA_CORTO','ETFCORTO','INIRDOCPBANK','INIRDOCPLAZO','STIR_ASIA','STIR_CNH','STIR_EUR','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRDTASARS','INIRDOCRDMAD','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_LT_ASIA','FVA_RATES',
'FVA_RATES_ASIA','ESTRATFLOW','ESTRATGFI','INIRDOESTRAGFI','BERMUDA EUROESB','COBEXTEXO','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS',
'CORTO NO BDT','FINP_COLAT_CRED','FINP_COLAT_RATE','FVA_NP_IR','INTERNAS_SABR','LEG_NPTIPOS','NP_COMMODITIES','NP_FOREX','OPCOTCBON',
'SLOPE_SABR','SWAPTIONAV','TRD3SPREAD','GM_GAPBONOS','GM_GAPDERIV','GM_GAPEQTY','GM_GAPWWR','SW_INI_2016','ASSET MILAN','ASSETBONOS',
'ASWGOB','BCAT TIPOS LARG','BGIPCAUX','BNACOBLAR','BOND OPT','BONOFW','BONOFWHD','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO',
'CL LARGO','COBERPAT','CORPOIRS','CPPI_SWAPS','CVA_LARGO','DDIVIRS','ELECTRICAS','ESTRATEGIAS','ESTRATGFI_BOND','ETFDEUDA','EUROFIMA',
'FORWARD','FVA SWAPS','INDICES DEUDA','INIRDOLP','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK','LATAM_SWAPS','LINKERS_ESP','LINKERS_ESP_H',
'LT NY','LTNY2','LT_ASIA','LT_BOND','LT_BONDH','LT_BONDT','LT_CHINA','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_HK_STRATEGY1','LT_KOREA',
'LT_KOREA_REPO','LT_KRW','LT_TWD','MACROBCLSW','MICROCOB','OPERPAT','PROFIT','PROJECT_GL_SW','STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO',
'SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC','SWAPS_CVA','SWAPS_RF','SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT',
'SW_CORTO','SW_ELECTRONIC','SW_EQUITY','SW_GBP','SW_GERMANY','SW_INI_2015','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS','TEMPMC02','VTABNPVMX','VTACAJAMX',
'XXBBVLPSW','ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA','FLOORSPV','CRDCLP','CRDCOP','CRDPEN','INIRDOSUDAM','MXCRUCECA','MXCRUCECL','MXCRUCECO',
'MXCRUCEPE','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA','BBV VANILLAMC02','BCAT VOL INT','BDT BBV','BDT BBV MC02',
'BDT CORTO MC02','BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BNACOBVOL','BOND_INFLATION','CFCHIPOT','CHILENOS','CHILENOS BBVA',
'CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBMAXMIN','CORRELACION USD','DERCOMBI','DIG BBVA','DIG DOM','DIG EUROESB','DIGUSDBBVA',
'ESP-INFLATION','EUR-INFLATION','EXOTICAS','FIN98','FINP_TRIP','FVA_INFLATION','FVA_VOL_RATES','HEDGEAV','HEDGEVIT','HIBRIDOS','HIPOTECRED',
'INIRDOVTP','LARGO NO BDT','LEGVOLATIPOS','MACROBCLVOL','OPC BONOS','OPCBDTHOJAS','OPCION COB','OPCION NC','OPCMIBOR','OPCSALES','OPTIPCFC',
'PROJECT_GL_VT','REVERFLFL','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONUSDBBVA','TIPDIVCFC','UNNIM_VTIP','US-INFLATION','VOL ASSETSWAP',
'VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5','VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY',
'VOLKRW','VOLSGD','VOLTWD','VOLUSD','VTCBBVA','VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA',
'ZC-OPTIONS','INIRDOPD','INIRDOPD997','AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3','AAAPDTI1',
'AAAPDTI1B','AAAPDTI2','AAAPDTI3','PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','ANALISTAS','G3','G3_EQUITY','INIRDOTRADSIST','LT_PROGRAM','NON_LIN_HF',
'UST_LOCK','UST_SPREAD','MGDSTOXAF','INIRDODISTMAD','INIRDOMIL','ASSWMIL','INIRDOOPC','INIRDODERIVNY','INIRDOUS_TREASU','NY_MANAGEMENT',
'NY_ST_DER','MAD_UST_BTB','UST_BOND','UST_STRAT','KOR_LT_SWAP','INIKORLT','VOL_IR_KOREA_1','INIRDOLTIRTPE','TWN_LTIRD2_DBU','TWN_VOLIR1_DBU',
'INIRDOVOLIRTPE','TWN_LTIRD1_DBU'); --2422090

-- BBVA rec scope of deals
truncate table MX_USER_GROUP_DBF;
select * from TRN_ARCH_DBF;
select * from DPI_ID_DBF where M_LABEL1 = 'SPB_ARC' and M_LABEL2 = 'trn_arch.dbf'; -- 59
select count(1) as Num from TRN_HDR_DBF where M_NB in (select M_NB from RT_LOAN_DBF where M_FLEX=1) and M_TRN_STATUS<>'DEAD';

insert TRN_ARCH_DBF(M_ID,M_TIME_CMP,M_BO_FO,M_USR_NAME,M_USR_GROUP,M_USR_DESK,M_DELETED,M_PC,M_COMMENT,M_DATE_ARC)
values (61,60000,'BO','REALTIME','HOUSEKEEP','',0,0,'Manual purge of deals for the ROF','2015/10/21');
select * from TRN_ARCH_DBF;

drop table BBVA_FLT_MAP_FULLCORE_DBF;
select T1.M_NB into BBVA_FLT_MAP_FULLCORE_DBF from TRN_HDR_DBF T1 join FLT_MAP_FULLCORE_DBF T2 on T1.M_NB=T2.M_NB
where T1.M_BPFOLIO in 
('AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3',
'AAAPDTI1','AAAPDTI1B','AAAPDTI2','AAAPDTI3','ANALISTAS','ASSET MILAN','ASSETBONOS','ASSWMIL',
'ASWGOB','BANKING_BOOK','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA',
'BBV VANILLAMC02','BB_ASIA','BCAT TIPOS LARG','BCAT VOL INT','BDT BBV MC02','BDT CORTO MC02',
'BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BERMUDA EUROESB','BNACOBLAR','BNACOBVOL','BOND OPT'
,'BOND_INFLATION','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO','CFCHIPOT','CHILENOS',
'CHILENOS BBVA','CL LARGO','CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBERPAT','COBEXTEXO',
'COBMAXMIN','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS','CORPOIRS','CORRELACION USD','CORTO NO BDT',
'CORTOPLAZO','CORTO_PLAZO_CLI','CPCDIFWBO','CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDERIVA',
'CPMDERMN','CPMDIIRS','CPMDIOTC','CPMSPREMX','CPPI_SWAPS','CRCTASAS','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','CVA_CORTO','CVA_LARGO','CVA_RATES',
'DDIVIRS','DEMESTTC','DEMESTTI','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','DERCOMBI','DIG BBVA',
'DIG DOM','DIG EUROESB','DIGUSDBBVA','ELECTRICAS','ESMCOATRM','ESMDEPOS','ESMDIGTIE','ESMDIGTOT','ESMESTRMI',
'ESMESTRVA','ESMESTTAS','ESMFLEXIC','ESMMMOO','ESMWARRAN','ESP-INFLATION','ESTRATEGIAS','ESTRATFLOW',
'ESTRATGFI','ESTRATGFI_BOND','ETFCORTO','ETFDEUDA','EUR-INFLATION','EUROFIMA','EXOTICAS','FOCSWANEG',
'FOMIRSMNR','FOMMCRO10','FOMMCRO11','FOMMCRO14','FOMMCRO15','FOMMCRO16','FOMMCRO18','FOMMCRO19','FOMMCRO21',
'FOMMCRO22','FOMMCRO25','FOMMCRO29','FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC',
'FOMSWATME','FOMTEMPO','FORWARD','FVA SWAPS','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_INFLATION',
'FVA_LT_ASIA','FVA_NP_IR','FVA_RATES','FVA_RATES_ASIA','FVA_VOL_RATES','G3','G3_EQUITY','HEDGEAV','HEDGEVIT',
'HIBRIDOS','HIPOTECRED','INDICES DEUDA','INTERNAS_SABR','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK',
'KOR_LT_SWAP','LARGO NO BDT','LATAM_SWAPS','LIS TIPOS','LON_ESTRUCTURAS','LPMASIGNA','LPMDCCEUR',
'LPMDCCINT','LPMDCCMXN','LPMDCCUSD','LPMDCNCOL','LPMDIDEPO','LPMDIMMOO','LPMDIOTC','LPMDIRBAS','LPMDIRCUR',
'LPMEXDER','LPMIRS1','LPMIRS2','LPMVOLTAS','LPMVOLTOT','LPMXDERSW','LT NY','LT NY2','LT_ASIA','LT_BOND',
'LT_BONDH','LT_BONDT','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_KOREA','LT_KOREA_REPO',
'LT_KRW','LT_PROGRAM','LT_TWD','MACROBCLSW','MACROBCLVOL','MAD_UST_BTB','MGDSTOXAF','MI ESTRUCTURAS',
'MICROCOB','MKMDERIV','MKMTRDEPO','NON_LIN_HF','NP_COMMODITIES','NP_FOREX','NY_ST_DER','OPCBDTHOJAS',
'OPCION COB','OPCION NC','OPCMIBOR','OPCOTCBON','OPCSALES','OPERPAT','OPTIPCFC','POCXCCY','POMFX',
'POMINVERS','POMIRSTIE','POMUDIMKT','POMUDIS','POMVALREL','POMXCCY','PROFIT','PROJECT_GL_SW','PROJECT_GL_VT',
'PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','REVERFLFL','SLOPE_SABR','STIR_ASIA','STIR_CNH','STIR_EUR',
'STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO','SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC',
'SWAPS_CVA','SWAPS_RF','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONAV','SWAPTIONUSDBBVA',
'SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT','SW_CORTO','SW_ELECTRONIC',
'SW_EQUITY','SW_GBP','SW_GERMANY','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS',
'TEMP MC02','TIPDIVCFC','TRD3SPREAD','TWN_LTIRD1_DBU','UNNIM_VTIP','US-INFLATION','UST_BOND','UST_LOCK',
'UST_SPREAD','UST_STRAT','VOL ASSET SWAP','VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5',
'VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY','VOLKRW',
'VOLSGD','VOLTWD','VOLUSD','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','VTABNPVMX','VTACAJAMX','VTC BBVA',
'VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA','XXBBVLPSW',
'ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA')
or T1.M_SPFOLIO in
('AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3',
'AAAPDTI1','AAAPDTI1B','AAAPDTI2','AAAPDTI3','ANALISTAS','ASSET MILAN','ASSETBONOS','ASSWMIL',
'ASWGOB','BANKING_BOOK','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA',
'BBV VANILLAMC02','BB_ASIA','BCAT TIPOS LARG','BCAT VOL INT','BDT BBV MC02','BDT CORTO MC02',
'BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BERMUDA EUROESB','BNACOBLAR','BNACOBVOL','BOND OPT'
,'BOND_INFLATION','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO','CFCHIPOT','CHILENOS',
'CHILENOS BBVA','CL LARGO','CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBERPAT','COBEXTEXO',
'COBMAXMIN','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS','CORPOIRS','CORRELACION USD','CORTO NO BDT',
'CORTOPLAZO','CORTO_PLAZO_CLI','CPCDIFWBO','CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDERIVA',
'CPMDERMN','CPMDIIRS','CPMDIOTC','CPMSPREMX','CPPI_SWAPS','CRCTASAS','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','CVA_CORTO','CVA_LARGO','CVA_RATES',
'DDIVIRS','DEMESTTC','DEMESTTI','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','DERCOMBI','DIG BBVA',
'DIG DOM','DIG EUROESB','DIGUSDBBVA','ELECTRICAS','ESMCOATRM','ESMDEPOS','ESMDIGTIE','ESMDIGTOT','ESMESTRMI',
'ESMESTRVA','ESMESTTAS','ESMFLEXIC','ESMMMOO','ESMWARRAN','ESP-INFLATION','ESTRATEGIAS','ESTRATFLOW',
'ESTRATGFI','ESTRATGFI_BOND','ETFCORTO','ETFDEUDA','EUR-INFLATION','EUROFIMA','EXOTICAS','FOCSWANEG',
'FOMIRSMNR','FOMMCRO10','FOMMCRO11','FOMMCRO14','FOMMCRO15','FOMMCRO16','FOMMCRO18','FOMMCRO19','FOMMCRO21',
'FOMMCRO22','FOMMCRO25','FOMMCRO29','FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC',
'FOMSWATME','FOMTEMPO','FORWARD','FVA SWAPS','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_INFLATION',
'FVA_LT_ASIA','FVA_NP_IR','FVA_RATES','FVA_RATES_ASIA','FVA_VOL_RATES','G3','G3_EQUITY','HEDGEAV','HEDGEVIT',
'HIBRIDOS','HIPOTECRED','INDICES DEUDA','INTERNAS_SABR','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK',
'KOR_LT_SWAP','LARGO NO BDT','LATAM_SWAPS','LIS TIPOS','LON_ESTRUCTURAS','LPMASIGNA','LPMDCCEUR',
'LPMDCCINT','LPMDCCMXN','LPMDCCUSD','LPMDCNCOL','LPMDIDEPO','LPMDIMMOO','LPMDIOTC','LPMDIRBAS','LPMDIRCUR',
'LPMEXDER','LPMIRS1','LPMIRS2','LPMVOLTAS','LPMVOLTOT','LPMXDERSW','LT NY','LT NY2','LT_ASIA','LT_BOND',
'LT_BONDH','LT_BONDT','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_KOREA','LT_KOREA_REPO',
'LT_KRW','LT_PROGRAM','LT_TWD','MACROBCLSW','MACROBCLVOL','MAD_UST_BTB','MGDSTOXAF','MI ESTRUCTURAS',
'MICROCOB','MKMDERIV','MKMTRDEPO','NON_LIN_HF','NP_COMMODITIES','NP_FOREX','NY_ST_DER','OPCBDTHOJAS',
'OPCION COB','OPCION NC','OPCMIBOR','OPCOTCBON','OPCSALES','OPERPAT','OPTIPCFC','POCXCCY','POMFX',
'POMINVERS','POMIRSTIE','POMUDIMKT','POMUDIS','POMVALREL','POMXCCY','PROFIT','PROJECT_GL_SW','PROJECT_GL_VT',
'PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','REVERFLFL','SLOPE_SABR','STIR_ASIA','STIR_CNH','STIR_EUR',
'STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO','SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC',
'SWAPS_CVA','SWAPS_RF','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONAV','SWAPTIONUSDBBVA',
'SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT','SW_CORTO','SW_ELECTRONIC',
'SW_EQUITY','SW_GBP','SW_GERMANY','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS',
'TEMP MC02','TIPDIVCFC','TRD3SPREAD','TWN_LTIRD1_DBU','UNNIM_VTIP','US-INFLATION','UST_BOND','UST_LOCK',
'UST_SPREAD','UST_STRAT','VOL ASSET SWAP','VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5',
'VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY','VOLKRW',
'VOLSGD','VOLTWD','VOLUSD','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','VTABNPVMX','VTACAJAMX','VTC BBVA',
'VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA','XXBBVLPSW',
'ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA');

select T1.M_NB from TRN_HDR_DBF T1 left join BBVA_FLT_MAP_FULLCORE_DBF T2 on T1.M_NB=T2.M_NB 
where T1.M_TRN_STATUS='LIVE' and (T1.M_BPFOLIO in 
('AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3',
'AAAPDTI1','AAAPDTI1B','AAAPDTI2','AAAPDTI3','ANALISTAS','ASSET MILAN','ASSETBONOS','ASSWMIL',
'ASWGOB','BANKING_BOOK','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA',
'BBV VANILLAMC02','BB_ASIA','BCAT TIPOS LARG','BCAT VOL INT','BDT BBV MC02','BDT CORTO MC02',
'BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BERMUDA EUROESB','BNACOBLAR','BNACOBVOL','BOND OPT'
,'BOND_INFLATION','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO','CFCHIPOT','CHILENOS',
'CHILENOS BBVA','CL LARGO','CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBERPAT','COBEXTEXO',
'COBMAXMIN','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS','CORPOIRS','CORRELACION USD','CORTO NO BDT',
'CORTOPLAZO','CORTO_PLAZO_CLI','CPCDIFWBO','CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDERIVA',
'CPMDERMN','CPMDIIRS','CPMDIOTC','CPMSPREMX','CPPI_SWAPS','CRCTASAS','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','CVA_CORTO','CVA_LARGO','CVA_RATES',
'DDIVIRS','DEMESTTC','DEMESTTI','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','DERCOMBI','DIG BBVA',
'DIG DOM','DIG EUROESB','DIGUSDBBVA','ELECTRICAS','ESMCOATRM','ESMDEPOS','ESMDIGTIE','ESMDIGTOT','ESMESTRMI',
'ESMESTRVA','ESMESTTAS','ESMFLEXIC','ESMMMOO','ESMWARRAN','ESP-INFLATION','ESTRATEGIAS','ESTRATFLOW',
'ESTRATGFI','ESTRATGFI_BOND','ETFCORTO','ETFDEUDA','EUR-INFLATION','EUROFIMA','EXOTICAS','FOCSWANEG',
'FOMIRSMNR','FOMMCRO10','FOMMCRO11','FOMMCRO14','FOMMCRO15','FOMMCRO16','FOMMCRO18','FOMMCRO19','FOMMCRO21',
'FOMMCRO22','FOMMCRO25','FOMMCRO29','FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC',
'FOMSWATME','FOMTEMPO','FORWARD','FVA SWAPS','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_INFLATION',
'FVA_LT_ASIA','FVA_NP_IR','FVA_RATES','FVA_RATES_ASIA','FVA_VOL_RATES','G3','G3_EQUITY','HEDGEAV','HEDGEVIT',
'HIBRIDOS','HIPOTECRED','INDICES DEUDA','INTERNAS_SABR','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK',
'KOR_LT_SWAP','LARGO NO BDT','LATAM_SWAPS','LIS TIPOS','LON_ESTRUCTURAS','LPMASIGNA','LPMDCCEUR',
'LPMDCCINT','LPMDCCMXN','LPMDCCUSD','LPMDCNCOL','LPMDIDEPO','LPMDIMMOO','LPMDIOTC','LPMDIRBAS','LPMDIRCUR',
'LPMEXDER','LPMIRS1','LPMIRS2','LPMVOLTAS','LPMVOLTOT','LPMXDERSW','LT NY','LT NY2','LT_ASIA','LT_BOND',
'LT_BONDH','LT_BONDT','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_KOREA','LT_KOREA_REPO',
'LT_KRW','LT_PROGRAM','LT_TWD','MACROBCLSW','MACROBCLVOL','MAD_UST_BTB','MGDSTOXAF','MI ESTRUCTURAS',
'MICROCOB','MKMDERIV','MKMTRDEPO','NON_LIN_HF','NP_COMMODITIES','NP_FOREX','NY_ST_DER','OPCBDTHOJAS',
'OPCION COB','OPCION NC','OPCMIBOR','OPCOTCBON','OPCSALES','OPERPAT','OPTIPCFC','POCXCCY','POMFX',
'POMINVERS','POMIRSTIE','POMUDIMKT','POMUDIS','POMVALREL','POMXCCY','PROFIT','PROJECT_GL_SW','PROJECT_GL_VT',
'PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','REVERFLFL','SLOPE_SABR','STIR_ASIA','STIR_CNH','STIR_EUR',
'STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO','SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC',
'SWAPS_CVA','SWAPS_RF','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONAV','SWAPTIONUSDBBVA',
'SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT','SW_CORTO','SW_ELECTRONIC',
'SW_EQUITY','SW_GBP','SW_GERMANY','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS',
'TEMP MC02','TIPDIVCFC','TRD3SPREAD','TWN_LTIRD1_DBU','UNNIM_VTIP','US-INFLATION','UST_BOND','UST_LOCK',
'UST_SPREAD','UST_STRAT','VOL ASSET SWAP','VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5',
'VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY','VOLKRW',
'VOLSGD','VOLTWD','VOLUSD','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','VTABNPVMX','VTACAJAMX','VTC BBVA',
'VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA','XXBBVLPSW',
'ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA')
or T1.M_SPFOLIO in
('AAAPDFX1','AAAPDFX2','AAAPDFX3','AAAPDG01','AAAPDG02','AAAPDG04','AAAPDRV1','AAAPDRV2','AAAPDRV3',
'AAAPDTI1','AAAPDTI1B','AAAPDTI2','AAAPDTI3','ANALISTAS','ASSET MILAN','ASSETBONOS','ASSWMIL',
'ASWGOB','BANKING_BOOK','BBV BERMUDA COR','BBV CORTO','BBV CORTO MCO2','BBV DIG','BBV VANILLA',
'BBV VANILLAMC02','BB_ASIA','BCAT TIPOS LARG','BCAT VOL INT','BDT BBV MC02','BDT CORTO MC02',
'BDTBBV2','BDTBBV3','BERM USD COR','BERMUDA DOM','BERMUDA EUROESB','BNACOBLAR','BNACOBVOL','BOND OPT'
,'BOND_INFLATION','BONOS FORWARD','BONOS_LINKERS','CDS_LARGO_PLAZO','CFCHIPOT','CHILENOS',
'CHILENOS BBVA','CL LARGO','CL VOLAT TIPOS','CLOSE BDT BBV','CLOSE BDT MC02','COBERPAT','COBEXTEXO',
'COBMAXMIN','COB_BONOS','COB_EXTERNAL','COB_EXT_TIPOS','CORPOIRS','CORRELACION USD','CORTO NO BDT',
'CORTOPLAZO','CORTO_PLAZO_CLI','CPCDIFWBO','CPCDIOTC','CPCGARENT','CPCVENCOR','CPMDENREG','CPMDERIVA',
'CPMDERMN','CPMDIIRS','CPMDIOTC','CPMSPREMX','CPPI_SWAPS','CRCTASAS','CRDBANCOS','CRDBTBCLP','CRDBTBCOP',
'CRDBTBPEN','CRDCHILE','CRMCHL','CRMPEN','CRMTASAS','CRMTEMPO','CVA_CORTO','CVA_LARGO','CVA_RATES',
'DDIVIRS','DEMESTTC','DEMESTTI','DEMSWAPTI','DEMSWATOT','DEMVOLATI','DEMVOLTOT','DERCOMBI','DIG BBVA',
'DIG DOM','DIG EUROESB','DIGUSDBBVA','ELECTRICAS','ESMCOATRM','ESMDEPOS','ESMDIGTIE','ESMDIGTOT','ESMESTRMI',
'ESMESTRVA','ESMESTTAS','ESMFLEXIC','ESMMMOO','ESMWARRAN','ESP-INFLATION','ESTRATEGIAS','ESTRATFLOW',
'ESTRATGFI','ESTRATGFI_BOND','ETFCORTO','ETFDEUDA','EUR-INFLATION','EUROFIMA','EXOTICAS','FOCSWANEG',
'FOMIRSMNR','FOMMCRO10','FOMMCRO11','FOMMCRO14','FOMMCRO15','FOMMCRO16','FOMMCRO18','FOMMCRO19','FOMMCRO21',
'FOMMCRO22','FOMMCRO25','FOMMCRO29','FOMMICRO2','FOMMICRO4','FOMMICRO5','FOMMICRO8','FOMMICRO9','FOMMIRSNC',
'FOMSWATME','FOMTEMPO','FORWARD','FVA SWAPS','FVA_COLATERAL','FVA_COLAT_BILAT','FVA_COLAT_CCP','FVA_INFLATION',
'FVA_LT_ASIA','FVA_NP_IR','FVA_RATES','FVA_RATES_ASIA','FVA_VOL_RATES','G3','G3_EQUITY','HEDGEAV','HEDGEVIT',
'HIBRIDOS','HIPOTECRED','INDICES DEUDA','INTERNAS_SABR','IRSCOMBI','IRSMEFF','IRSTRAD','IR_CINE','IR_STOCK',
'KOR_LT_SWAP','LARGO NO BDT','LATAM_SWAPS','LIS TIPOS','LON_ESTRUCTURAS','LPMASIGNA','LPMDCCEUR',
'LPMDCCINT','LPMDCCMXN','LPMDCCUSD','LPMDCNCOL','LPMDIDEPO','LPMDIMMOO','LPMDIOTC','LPMDIRBAS','LPMDIRCUR',
'LPMEXDER','LPMIRS1','LPMIRS2','LPMVOLTAS','LPMVOLTOT','LPMXDERSW','LT NY','LT NY2','LT_ASIA','LT_BOND',
'LT_BONDH','LT_BONDT','LT_CNH','LT_HKD','LT_HKFX2','LT_HKFX_CNH','LT_HK_OPT','LT_KOREA','LT_KOREA_REPO',
'LT_KRW','LT_PROGRAM','LT_TWD','MACROBCLSW','MACROBCLVOL','MAD_UST_BTB','MGDSTOXAF','MI ESTRUCTURAS',
'MICROCOB','MKMDERIV','MKMTRDEPO','NON_LIN_HF','NP_COMMODITIES','NP_FOREX','NY_ST_DER','OPCBDTHOJAS',
'OPCION COB','OPCION NC','OPCMIBOR','OPCOTCBON','OPCSALES','OPERPAT','OPTIPCFC','POCXCCY','POMFX',
'POMINVERS','POMIRSTIE','POMUDIMKT','POMUDIS','POMVALREL','POMXCCY','PROFIT','PROJECT_GL_SW','PROJECT_GL_VT',
'PT_CREDITO','PT_FX','PT_RV','PT_SWAPS','REVERFLFL','SLOPE_SABR','STIR_ASIA','STIR_CNH','STIR_EUR',
'STOCKPYME','SWACLIDIV','SWACLIINT','SWAPDIVCO','SWAPDIVNC','SWAPFXIRS','SWAPINTCO','SWAPINTNC',
'SWAPS_CVA','SWAPS_RF','SWAPTION EURO','SWAPTION LARGO','SWAPTION USD','SWAPTIONAV','SWAPTIONUSDBBVA',
'SWBBVA','SWDIRFIN','SWNYBBVA','SW_BANKS','SW_CCY_BASIS','SW_COLAT_PT','SW_CORTO','SW_ELECTRONIC',
'SW_EQUITY','SW_GBP','SW_GERMANY','SW_INSURANCE','SW_PASTORA','SW_TI','SW_TRADING_1','SW_TRADING_2',
'SW_TRADING_3','SW_TRADING_4','SW_TRADING_5','SW_TRADING_6','SW_USD','TAIWAN_FX','TAIWAN_IRS',
'TEMP MC02','TIPDIVCFC','TRD3SPREAD','TWN_LTIRD1_DBU','UNNIM_VTIP','US-INFLATION','UST_BOND','UST_LOCK',
'UST_SPREAD','UST_STRAT','VOL ASSET SWAP','VOL-INFLATION','VOLASIA1','VOLASIA2','VOLASIA3','VOLASIA5',
'VOLASIA6','VOLAUD','VOLCHF','VOLCNY','VOLCNY_EXO','VOLGBP','VOLHKD','VOLHKD_2','VOLJPY','VOLKRW',
'VOLSGD','VOLTWD','VOLUSD','VRMCAPCNF','VRMEXOTIC','VRMEXOTOT','VTABNPVMX','VTACAJAMX','VTC BBVA',
'VTCBDTBBVA','VTCOPCBONOBBVA','VTCSWAPTIONBBVA','VTLBDTBBVA','VTLDIGBBVA','VTLVANILLABBVA','XXBBVLPSW',
'ZZASSETSWAP','ZZMC02','ZZSWAPS','ZZUSA')) and T2.M_NB is null;


