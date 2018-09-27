/* ophalen gegevens uit de DDS-database; worden geladen in de MOZARD database */

spool /mnt/nfs_autofs/mozard/pmoz0340/koppelvlak/burger/prs_mozard.csv;
set serveroutput on;
set pagesize 0 line 999;
set heading off;
set feedback off;
set trimspool on;
set verify off;

select dds_tekensetconversie.teletex2unicode('"BRONREGISTRATIE";"BRONREFERENTIE";"BRONIDENTIFICATIE";"BRONURL";"BRONACTIEF";"BSN";"NAAM";"TUSSENVOEGSEL";"VOORVOEGSEL";"VOORLETTERS";"VOORNAMEN";"GESLACHT";"ADRES";"HUISNUMMER";"POSTCODE";"WOONPLAATS";"LAND";"POSTADRES";"POSTHUISNUMMER";"POSTPOSTCODE";"POSTWOONPLAATS";"POSTLAND";"DATUMGEBOORTE";"DATUMOVERLIJDEN";"WEERGAVENAAM";"WEERGAVEOMSCHRIJVING";"ZOEKREEKSEN";"SORTEERPRIO"') regel 
from dual
union all
select
'"'||BRONREGISTRATIE||'";'||
'"'||BRONREFERENTIE||'";'||
'"'||BRONIDENTIFICATIE||'";'||
'"'||BRONURL||'";'||
'"'||BRONACTIEF||'";'||
'"'||BSN||'";'||
'"'||NAAM||'";'||
'"'||TUSSENVOEGSEL||'";'||
'"'||VOORVOEGSEL||'";'||
'"'||VOORLETTERS||'";'||
'"'||VOORNAMEN||'";'||
'"'||GESLACHT||'";'||
'"'||ADRES||'";'||
'"'||HUISNUMMER||'";'||
'"'||POSTCODE||'";'||
'"'||WOONPLAATS||'";'||
'"'||LAND||'";'||
'"'||POSTADRES||'";'||
'"'||POSTHUISNUMMER||'";'||
'"'||POSTPOSTCODE||'";'||
'"'||POSTWOONPLAATS||'";'||
'"'||POSTLAND||'";'||
'"'||DATUMGEBOORTE||'";'||
'"'||DATUMOVERLIJDEN||'";'||
'"'||LTRIM(TUSSENVOEGSEL||' ')||NAAM||', '||VOORLETTERS||'";'|| --WEERGAVENAAM,
'"'||ADRES||', '||POSTCODE||' '||WOONPLAATS||' - BSN '||BSN||', '||decode(geslacht, 'M', 'man', 'V', 'vrouw')||', '||substr(datumgeboorte, 1,2)||'-'||substr(datumgeboorte, 3,2)||'-'||substr(datumgeboorte, 5,4)||'";'|| --WEERGAVEOMSCHRIJVING
'"'||BSN||' '||NAAM||' '||DATUMGEBOORTE||' '||POSTCODE||HUISNUMMER||' '||WOONPLAATS||'";'|| -- ZOEKREEKSEN
'"'||UPPER(NAAM)||VLT_ZONDER_PUNT||'"' REGEL -- SORTEERPRIO
FROM
(
select
'KEY2DATA' BRONREGISTRATIE,
NULL BRONREFERENTIE,
BRONIDENTIFICATIE,
NULL BRONURL,
BRONACTIEF,
to_char(BSN) BSN,
decode(andnam, 'E', subjectnaam, 'V', partner||' - '||ltrim(tv)||' '||subjectnaam, 'P', partner, 'N', subjectnaam||' - '||ltrim(tv_partner)||' '||partner ) NAAM,
decode(andnam, 'V', tv_partner, 'P', tv_partner, tv) TUSSENVOEGSEL,
VOORVOEGSEL,
VOORLETTERS,
VOORNAMEN,
GESLACHT,
ADRES,
TO_CHAR(HUISNUMMER) HUISNUMMER,
POSTCODE,
WOONPLAATS,
LAND,
NULL POSTADRES,
NULL POSTHUISNUMMER,
NULL POSTPOSTCODE,
NULL POSTWOONPLAATS,
NULL POSTLAND,
DATUMGEBOORTE,
DATUMOVERLIJDEN,
vlt_u VLT_ZONDER_PUNT
from
(
select 
to_char(po.SOFNUM) bronidentificatie,
decode(po.OVLDAT, null, decode(nvl(ao.gemkde, 0 ), 340, 'J', 'N'), 'N') BRONACTIEF,
to_char(po.SOFNUM) BSN,
decode(po.prsnrhuw, null, 'E', nvl(po.andnam, 'E')) andnam,
po.gesnam,
dds_tekensetconversie.teletex2unicode(po.gesnam_d) subjectnaam,
dds_tekensetconversie.teletex2unicode(partner.gesnam_d) partner,
po.gesvvg tv,
partner.gesvvg tv_partner,
decode(po.ovldat, null, pd.PREDIKAAT_OMS, 'De erven van') voorvoegsel,
decode(length(po.gesvlt), 
0, null, 
1, substr(po.gesvlt, 1,1)||'', 
2, substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||'',
3, substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||''||substr(po.gesvlt, 3, 1)||'',
4, substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||''||substr(po.gesvlt, 3, 1)||''||substr(po.gesvlt, 4, 1)||'',
5, substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||''||substr(po.gesvlt, 3, 1)||''||substr(po.gesvlt, 4, 1)||''||substr(po.gesvlt, 5, 1)||'',
6, substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||''||substr(po.gesvlt, 3, 1)||''||substr(po.gesvlt, 4, 1)||''||substr(po.gesvlt, 5, 1)||''||substr(po.gesvlt, 6, 1)||'',
   substr(po.gesvlt, 1,1)||''||substr(po.gesvlt, 2,1)||''||substr(po.gesvlt, 3, 1)||''||substr(po.gesvlt, 4, 1)||''||substr(po.gesvlt, 5, 1)||''||substr(po.gesvlt, 6, 1)||''||substr(po.gesvlt, 7, 1)||'') VOORLETTERS,
po.gesvlt_u vlt_u,
dds_tekensetconversie.teletex2unicode(po.gesvor) voornamen,
po.gesand geslacht,
dds_tekensetconversie.teletex2unicode(ao.sttnam_d)||' '||to_char(ao.huinum)||ao.huilet||rtrim(' '||ao.huitvg) adres,
to_char(ao.huinum)||ao.huilet||rtrim(' '||ao.huitvg) huisnummer,
substr(ao.PKDNUM, 1, 6) postcode,
ao.wplnam_u woonplaats,
lnd.LAND land,
decode(substr(to_char(po.GEBDAT), 7, 2), '00', '01', substr(to_char(po.GEBDAT), 7, 2))||decode(substr(to_char(po.GEBDAT), 5, 2), '00', '01', substr(to_char(po.GEBDAT), 5, 2))||substr(to_char(po.GEBDAT), 1, 4) datumgeboorte,
substr(to_char(po.OVLDAT), 7, 2)||substr(to_char(po.OVLDAT), 5, 2)||substr(to_char(po.OVLDAT), 1, 4) datumoverlijden
FROM  
dds_prs_opslag po,
dds_prsadr_opslag pao,
dds_adr_opslag ao,
dds_prs_opslag partner,
dds_predikaat pd,
dds_land lnd,
dds_indicatie ind
where po.prsnr = pao.prsnr
and po.prsnr = ind.SLEUTELSRV
-- and po.prsnr between 13000 and 14000
and ind.APPLICATIENR = 3
and ind.ONDERWERPCODE = 'PRS'
-- and nvl(ind.DATEND, sysdate) >= sysdate - 14
and pao.ADRNR = ao.adrnr
and po.PRSNRHUW = partner.PRSNR (+)
and (pao.DATEND is null or (po.ovldat is not null and pao.datend = po.ovldat)) 
and pao.SRTADR = 'V'
and po.ovldat is null
and po.ADLPRE = pd.PREDIKAAT (+)
and ao.lndkde = lnd.landcode (+)
)
);

spool off;
exit;
