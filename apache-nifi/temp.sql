CREATE TABLE extrato_b3 (
    id SERIAL PRIMARY KEY,
    entrada_saida TEXT,
    data DATE,
    movimentacao TEXT,
    produto TEXT,
    instituicao TEXT,
    quantidade INT,
    preco_unitario NUMERIC(15, 2),
    valor_operacao NUMERIC(15, 2)
);


SELECT * FROM public.extrato_b3 ORDER BY id ASC;


TRUNCATE TABLE extrato_b3;
