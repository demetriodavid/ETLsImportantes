SELECT
    V.*
FROM
    STG_JSONDATA STG
    INNER JOIN LATERAL JSONB_TO_RECORD(STG.DATA) AS
        V(
            "CHAVEERP" VARCHAR,
            "CODIBGE" VARCHAR,
            "CODPRODUTO" VARCHAR,
            "DATEMISSAO" VARCHAR,
            "DATMOVIMENTO" VARCHAR,
            "DATVENCIMENTO" VARCHAR,
            "DCMUNICIPIO" VARCHAR,
            "FLGSERIE_NF" VARCHAR,
            "IDCOOPERADO" VARCHAR,
            "NP" VARCHAR,
            "PROPRIEDADE" VARCHAR,
            "IDCULTURA" VARCHAR,
            "IDFILIAL" VARCHAR,
            "IDVENDEDOR" VARCHAR,
            "PEDIDO" VARCHAR,
            "NUMNOTA_FISCAL" VARCHAR,
            "ITEM" VARCHAR,
            "QTDEDEVOLUCAO" VARCHAR,
            "QTDEVENDA" VARCHAR,
            "TOTAL_DESCONTO_ICM" VARCHAR,
            "TOTAL_DEVOLUCAO" VARCHAR,
            "TOTAL_FRETE" VARCHAR,
            "TOTAL_MARGEM" VARCHAR,
            "TOTAL_MARGEM_DEVOLUCAO" VARCHAR,
            "UF" VARCHAR,
            "VLRNOTA" VARCHAR,
            "VLRPERC_MARGEM" VARCHAR,
            "VLRPERC_MARKUP" VARCHAR,
            "MARKUP" VARCHAR,
            "VLRQUANTIDADE_MOVIMENTO" VARCHAR,
            "VLRVENDA" VARCHAR,
            "CFOP" VARCHAR,
            "DESNOP" VARCHAR,
            "FC" VARCHAR,
            "C_PGTO" VARCHAR,
            "OP" VARCHAR,
            "NFORIG" VARCHAR,
            "P_COMISSAO" VARCHAR,
            "VAL_COMISSAO" VARCHAR
        ) ON TRUE
WHERE
    UPPER(STG.TIPO) = UPPER('VENDAS')
    AND
    (
        V."DATEMISSAO" <> ''
        OR V."DATMOVIMENTO" <> ''
    )
