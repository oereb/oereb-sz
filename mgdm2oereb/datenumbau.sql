
DELETE FROM 
    afu_kbs_oerebv2.transferstruktur_geometrie
;

DELETE FROM 
    afu_kbs_oerebv2.transferstruktur_hinweisvorschrift
;

DELETE FROM 
    afu_kbs_oerebv2.dokumente_dokument
;

DELETE FROM 
    afu_kbs_oerebv2.transferstruktur_eigentumsbeschraenkung
;

DELETE FROM 
    afu_kbs_oerebv2.transferstruktur_legendeeintrag
;

DELETE FROM 
    afu_kbs_oerebv2.transferstruktur_darstellungsdienst
;

INSERT INTO
    afu_kbs_oerebv2.transferstruktur_darstellungsdienst 
    (
        t_basket,
        verweiswms_de
    )
SELECT 
    basket.t_id,
    'https://geodienste.ch/db/kataster_belasteter_standorte_v1_4_0/deu?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&LAYERS=kataster_belasteter_standorte&STYLES=default&CRS=EPSG:2056&FORMAT=image/png'
FROM    
    (
        SELECT 
            t_id
        FROM 
            afu_kbs_oerebv2.t_ili2db_basket
        WHERE 
            topic = 'OeREBKRMtrsfr_V2_0.Transferstruktur'
    ) AS basket 
;    

WITH eigentumsbeschraenkung AS 
(
    SELECT 
        --nextval('afu_kbs_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        standort.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        standort.t_id AS standort_t_id,
        'ch.BelasteteStandorte' AS thema,
        'inKraft' AS rechtsstatus,
        standort.ersteintrag AS publiziertab,
        'ch.sz.afu' AS zustaendigestelle,
        statusaltlv.adefinition_de AS legendetext_de,
        standort.statusaltlv AS artcode,
        'https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5_20211015.xml' AS artcodeliste,
        statusaltlv.symbol AS symbol,
        darstellungsdienst.t_id AS darstellungsdienst
    FROM 
        afu_kbs.belastete_stndrte_belasteter_standort AS standort
        LEFT JOIN afu_kbs_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst 
        ON darstellungsdienst.verweiswms_de ILIKE '%kataster_belasteter_standorte%'
        INNER JOIN afu_kbs.codelisten_statusaltlv_definition AS statusaltlv 
        ON statusaltlv.acode = standort.statusaltlv 
)
,
legendeneintrag AS 
(
    INSERT INTO 
        afu_kbs_oerebv2.transferstruktur_legendeeintrag 
        (
            t_id,
            t_basket,
            symbol,
            legendetext_de,
            artcode,
            artcodeliste,
            thema,
            darstellungsdienst    
        )
    SELECT 
        DISTINCT ON (artcode, artcodeliste)
        nextval('afu_kbs_oerebv2.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
        basket_t_id,
        symbol,
        legendetext_de,
        artcode,
        artcodeliste,
        thema,
        darstellungsdienst
    FROM 
        eigentumsbeschraenkung 
    RETURNING *

)
INSERT INTO
    afu_kbs_oerebv2.transferstruktur_eigentumsbeschraenkung 
    (
        t_id,
        t_basket,
        rechtsstatus,
        publiziertab,
        darstellungsdienst,
        legende,
        zustaendigestelle
    )
SELECT 
    eigentumsbeschraenkung.t_id, 
    eigentumsbeschraenkung.basket_t_id,
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung.publiziertab,
    eigentumsbeschraenkung.darstellungsdienst,
    legendeneintrag.t_id,
    eigentumsbeschraenkung.zustaendigestelle
FROM 
    eigentumsbeschraenkung 
    LEFT JOIN legendeneintrag 
    ON (eigentumsbeschraenkung.artcode = legendeneintrag.artcode AND eigentumsbeschraenkung.artcodeliste = legendeneintrag.artcodeliste)
;

/*
 * Wir machen es billig (und es stimmt wohl eh): Jeder Standort hat ja ein Dokument. Annahme, dass es immer ein anderes Dokument ist.
 * Somit kopieren wir einfach "url_standort" als Dokument rüber.
 */

WITH dokumente AS 
(
    SELECT 
        nextval('afu_kbs_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(uuid_generate_v4() AS text), '-', ''),1,15) AS t_ili_tid,
        'Rechtsvorschrift' AS typ,
        standort.t_id AS s_t_id,
        standort.katasternummer AS titel_de,
        standort.url_standort AS textimweb_de,
        998 AS auszugindex,
        'inKraft' AS rechtsstatus,
        standort.ersteintrag AS publiziertab,
        'ch.sz.afu' AS zustaendigestelle
    FROM 
        afu_kbs.belastete_stndrte_belasteter_standort AS standort,
        (
            SELECT 
                t_id
            FROM 
                afu_kbs_oerebv2.t_ili2db_basket
            WHERE 
                topic = 'OeREBKRMtrsfr_V2_0.Transferstruktur'
        ) AS basket 
)
,
hinweisvorschrift AS 
(
    INSERT INTO 
        afu_kbs_oerebv2.transferstruktur_hinweisvorschrift 
        (
            t_basket,
            eigentumsbeschraenkung,
            vorschrift
        )
        SELECT 
            basket_t_id,
            s_t_id,
            t_id
        FROM 
            dokumente
)
INSERT INTO 
    afu_kbs_oerebv2.dokumente_dokument
    (
        t_id,
        t_basket,
        t_ili_tid,
        typ,
        titel_de, 
        textimweb_de,
        auszugindex,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
SELECT 
    t_id,
    basket_t_id,
    t_ili_tid,
    typ,
    titel_de, 
    textimweb_de,
    auszugindex,
    rechtsstatus,
    publiziertab,
    zustaendigestelle
FROM 
    dokumente
;


/**
 * Annahme: keine Punkte. 
 */
INSERT INTO 
    afu_kbs_oerebv2.transferstruktur_geometrie 
    (
        t_id,
        t_basket,
        flaeche,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung
    )
SELECT 
    poly.t_id,
    basket.t_id AS b_t_id,
    poly.apolygon,
    'inKraft' AS rechtsstatus,
    standort.ersteintrag AS publiziertab,
    standort.t_id AS eigentumsbeschraenkung
FROM 
    afu_kbs.belastete_stndrte_belasteter_standort AS standort
    LEFT JOIN afu_kbs.belastete_stndrte_multipolygon AS multipolygon 
    ON standort.t_id = multipolygon.belstt_stndttr_stndort_geo_lage_polygon 
    LEFT JOIN afu_kbs.belastete_stndrte_polygonstructure AS poly 
    ON multipolygon.t_id = poly.belstt_stndt_mltplygon_polygones,
    (
        SELECT 
            t_id
        FROM 
            afu_kbs_oerebv2.t_ili2db_basket
        WHERE 
            topic = 'OeREBKRMtrsfr_V2_0.Transferstruktur'
    ) AS basket 
;