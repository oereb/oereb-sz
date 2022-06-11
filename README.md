# oereb-sz

## mgdm2oereb

```
docker-compose up
```

Create data scheme:
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --createEnumTabs --nameByTopic --createGeomIdx --createFk --createFkIdx --strokeArcs --defaultSrsCode 2056 --dbschema afu_kbs --models "KbS_Basis_V1_4;KbS_LV95_V1_4" --schemaimport 
```

Import codes and symbols:
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --createEnumTabs --nameByTopic --createGeomIdx --createFk --createFkIdx --strokeArcs --defaultSrsCode 2056 --dbschema afu_kbs --models "KbS_Basis_V1_4" --import KbS_Codetexte_V1_4.xml
```

Import data:
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --createEnumTabs --nameByTopic --createGeomIdx --createFk --createFkIdx --strokeArcs --defaultSrsCode 2056 --dbschema afu_kbs --models "KbS_LV95_V1_4" --import ch.sz.kataster-belasteter-standorte.mgdm_lv95_20220610.xtf
```

Create transfer scheme:
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --idSeqMin 1000000000 --createMetaInfo --createBasketCol --sqlExtRefCols  --createEnumTabs --nameByTopic --createGeomIdx --createFk --createFkIdx --strokeArcs --defaultSrsCode 2056 --dbschema afu_kbs_oerebv2 --models "OeREBKRMtrsfr_V2_0" --iliMetaAttrs metaattrs.ini --schemaimport 
```

Create empty basket:
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --defaultSrsCode 2056 --dbschema afu_kbs_oerebv2 --models "OeREBKRMtrsfr_V2_0" --iliMetaAttrs metaattrs.ini --import ch.sz.afu.oereb_kbs.empty.xtf 
```

... Datenumbau ...

Export: 
```
java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --defaultSrsCode 2056 --dbschema afu_kbs_oerebv2 --models "OeREBKRMtrsfr_V2_0" --disableValidation --export ch.sz.afu.oereb_kataster_belasteter_standorte_V2_0.xtf
```

Validate:
```
java -jar /Users/stefan/apps/ilivalidator-1.11.13/ilivalidator-1.11.13.jar --allObjectsAccessible ../oereb_config/ch.sz.agi.oereb_zustaendigestellen_V2_0.xtf ch.sz.afu.oereb_kataster_belasteter_standorte_V2_0.xtf
```

## Config

### Grundbuchkreise
Gibt anscheinend nur einen GB-Kreis. Trotz Schwyz, Rickenbach, Ibach und Seewen? 

### Themen
```
java -jar /Users/stefan/apps/ilivalidator-1.11.11/ilivalidator-1.11.11.jar --allObjectsAccessible OeREBKRM_V2_0_Gesetze_20210414.xml OeREBKRM_V2_0_Themen_20220301.xml ch.sz.agi.oereb_zustaendigestellen_V2_0.xtf ch.sz.sk.oereb_gesetze_V2_0.xtf ch.sz.agi.oereb_themen_V2_0.xtf
```

java -jar /Users/stefan/apps/ili2pg-4.8.0/ili2pg-4.8.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --defaultSrsCode 2056 --dbschema agi_av_1372 --models "DM01AVCH24LV95D" --disableValidation --nameByTopic --strokeArcs --defaultSrsCode 2056 --doSchemaImport --import 1372.itf
