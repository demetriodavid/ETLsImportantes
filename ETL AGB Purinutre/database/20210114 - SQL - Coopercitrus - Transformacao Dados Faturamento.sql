SELECT
    ('1#' || IDFILIAL) AS NK_EMPRESA,
    CAST(COALESCE(NULLIF(IDVENDEDOR, ''), '0') AS VARCHAR(20)) AS NK_VENDEDOR,
    (

        CASE
            WHEN NULLIF(TRIM(IDCULTURA), '') IS NULL
            THEN '0'
            ELSE UPPER('SAP#') || CAST(IDCULTURA AS VARCHAR(10))
        END
    ) AS NK_CULTURA,
    CODPRODUTO AS NK_PRODUTO,
    CAST(IDCOOPERADO AS VARCHAR) AS NK_CLIENTE,
    UPPER(
        COALESCE(NULLIF(DCMUNICIPIO, ''), 'N/I') || '#' ||
        COALESCE(UF, 'N/I')
    ) AS NK_MUNICIPIO_FATURAMENTO,
	NULLIF(TRIM(CODIBGE), '') AS DD_CODIGO_IBGE,
    TO_DATE(TRIM(DATMOVIMENTO), UPPER('YYYYMMDD')) AS NK_TEMPO_DIA_MOV,
    TO_DATE(TRIM(DATEMISSAO), UPPER('YYYYMMDD')) AS NK_TEMPO_DIA_EMISSAO,
    TO_DATE(TRIM(DATVENCIMENTO), UPPER('YYYYMMDD')) AS NK_TEMPO_DIA_VENC,
    CAST(COALESCE(NULLIF(
        (
            CASE
                WHEN SUBSTRING(UPPER(NUMNOTA_FISCAL) FROM '^S[0-9]{1,}$') IS NOT NULL
                THEN SUBSTRING(UPPER(NUMNOTA_FISCAL) FROM '^S([0-9]{1,})$')
                ELSE NUMNOTA_FISCAL
            END
        ), ''
    ), '0') AS INTEGER) AS DD_NOTA_FISCAL,
    COALESCE(NULLIF(TRIM(FLGSERIE_NF), ''), '000') AS DD_SERIE_NOTA_FISCAL,
    NULLIF(TRIM(OP), '') AS DD_NF_OP,
    CAST(COALESCE(NULLIF(TRIM(CFOP), ''), '0') AS SMALLINT) AS DD_NF_CFOP,
    NULLIF(TRIM(DESNOP), '') AS DD_NF_DESNOP,

    CAST(
        REGEXP_REPLACE(VLRNOTA, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_NOTA,
    CAST(
        REGEXP_REPLACE(VLRVENDA, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_VENDA,
    CAST(
        REGEXP_REPLACE(TOTAL_FRETE, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_FRETE,
    CAST(
        REGEXP_REPLACE(TOTAL_DEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_DEVOLUCAO,
    CAST(
        REGEXP_REPLACE(TOTAL_DESCONTO_ICM, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_DESCONTO_ICMS,
    CAST(
        REGEXP_REPLACE(TOTAL_MARGEM_DEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS VLR_MARGEM_DEVOLUCAO,
    (
        CASE
            WHEN SUBSTRING(VLRPERC_MARGEM FROM '(.*,.*)') IS NOT NULL
            THEN CAST(REPLACE(VLRPERC_MARGEM, ',', '.') AS NUMERIC(18,4))
            ELSE
                CAST(
                    REGEXP_REPLACE(VLRPERC_MARGEM, '^([0-9\.]{1,})(.*?)$', '\2\1')
                    AS NUMERIC(18,4)
                )
        END
    ) AS VLR_PERC_MARGEM,
    (
        CASE
            WHEN SUBSTRING(VLRPERC_MARKUP FROM '(.*,.*)') IS NOT NULL
            THEN CAST(REPLACE(VLRPERC_MARKUP, ',', '.') AS NUMERIC(18,4))
            ELSE
                CAST(
                    REGEXP_REPLACE(VLRPERC_MARKUP, '^([0-9\.]{1,})(.*?)$', '\2\1')
                    AS NUMERIC(18,4)
                )
        END
    ) AS VLR_PERC_MARKUP,
    CAST(
        REGEXP_REPLACE(QTDEVENDA, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS QTD_VENDA,
    CAST(
        REGEXP_REPLACE(QTDEDEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
        AS NUMERIC(18,4)
    ) AS QTD_DEVOLUCAO,

    (
        (
            CASE
                WHEN SUBSTRING(TOTAL_MARGEM FROM '(.*,.*)') IS NOT NULL
                THEN
                    CAST(
                        REPLACE(
                            REPLACE(
                                TOTAL_MARGEM,
                                '.',
                                ''
                            ),
                            ',',
                            '.'
                        )
                        AS NUMERIC(18,4)
                    )
                ELSE
                    CAST(
                        REGEXP_REPLACE(TOTAL_MARGEM, '^([0-9\.]{1,})(.*?)$', '\2\1')
                        AS NUMERIC(18,4)
                    )
            END
        ) -
        CAST(
            REGEXP_REPLACE(TOTAL_MARGEM_DEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
            AS NUMERIC(18,4)
        )
    ) AS VLR_MARGEM_CONTRIBUICAO,

    (
        CAST(
            REGEXP_REPLACE(VLRVENDA, '^([0-9\.]{1,})(.*?)$', '\2\1')
            AS NUMERIC(18,4)
        ) - CAST(
            REGEXP_REPLACE(TOTAL_DEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
            AS NUMERIC(18,4)
        )
    ) AS VLR_FATURAMENTO,

    (
        CAST(
            REGEXP_REPLACE(QTDEVENDA, '^([0-9\.]{1,})(.*?)$', '\2\1')
            AS NUMERIC(18,4)
        ) - CAST(
            REGEXP_REPLACE(QTDEDEVOLUCAO, '^([0-9\.]{1,})(.*?)$', '\2\1')
            AS NUMERIC(18,4)
        )
    ) AS QTD_MOVIMENTO
FROM MOVIMENTO_VENDAS
WHERE
    TRIM(DATMOVIMENTO) <> ''
    AND CAST(TRIM(DATMOVIMENTO) AS INTEGER) = ?
