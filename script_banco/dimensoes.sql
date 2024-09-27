-- public.dim_empresa definition

-- Drop table

-- DROP TABLE public.dim_empresa;

CREATE TABLE public.dim_empresa (
	sk_empresa serial4 NOT NULL,
	nk_empresa varchar(100) NULL,
	cod_empresa int4 NULL,
	razao_social varchar(255) NULL,
	cod_filial int4 NULL,
	filial varchar(255) NULL,
	insc_estadual varchar(255) NULL,
	insc_municipal varchar(255) NULL,
	ramo varchar(255) NULL,
	CONSTRAINT dim_empresa_nk_empresa_key UNIQUE (nk_empresa),
	CONSTRAINT dim_empresa_pkey PRIMARY KEY (sk_empresa)
);