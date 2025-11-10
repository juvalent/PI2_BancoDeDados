USE agro_sustenta;

-- 1. VIEW: Rastreio detalhado das distribuições, com localização do destinatário.
CREATE VIEW Relatorio_Rastreio_Completo AS
SELECT
    R.idRastreio ID_RASTREIO,
    R.destinatario Destinatario,
    CO.nome Nome_Cooperativa,
    DI.statusEntrega Status_Entrega,
    DATE_FORMAT(DI.dataSaida, '%d/%m/%Y %H:%i') Data_Saida,
    CONCAT_WS(', ', E.logradouro, E.numero, E.bairro, E.cidade, E.UF) Endereco_Destino,
    IFNULL(T.numero, '-') Telefone_Contato
FROM
    Rastreio R
JOIN
    Cooperativa CO ON R.Cooperativa_CNPJ = CO.CNPJ
JOIN
    Distribuicao DI ON R.idRastreio = DI.Rastreio_idRastreio
JOIN
    Endereco E ON CO.CNPJ = E.Cooperativa_CNPJ
LEFT JOIN
    Telefone T ON CO.CNPJ = T.Cooperativa_CNPJ;

-- 2. VIEW: Saldo atual de estoque por armazém.
CREATE VIEW Saldo_Estoque_Armazem AS
SELECT
    A.idArmazem ID_Armazem,
    A.nome Nome_Armazem,
    E.saldoDisponivel Saldo_Atual_Kg,
    EA.cidade Cidade_Armazem,
    EA.UF UF_Armazem
FROM
    Armazem A
JOIN
    Estoque E ON A.idArmazem = E.Armazem_idArmazem
JOIN
    EnderecoArmazem EA ON A.idArmazem = EA.Armazem_idArmazem;

-- 3. VIEW: Lotes próximos ao vencimento.
CREATE VIEW Lotes_Proximo_Vencimento AS
SELECT
    L.idLote ID_Lote,
    L.especie Especie,
    L.quantidade Quantidade_Kg,
    DATE_FORMAT(L.validade, '%d/%m/%Y') Data_Validade,
    A.nome Armazem_Estocagem
FROM
    Lote L
JOIN
    Armazem A ON L.Armazem_idArmazem = A.idArmazem
WHERE
    L.validade < '2026-06-01'
ORDER BY
    L.validade;

-- 4. VIEW: Relação de Cooperativas com seus dados de contato e localização.
CREATE VIEW Dados_Cooperativas_Contato AS
SELECT
    CO.CNPJ,
    CO.nome Nome_Cooperativa,
    CO.email,
    E.cidade Cidade_Sede,
    E.UF UF_Sede,
    IFNULL(T.numero, '-') Telefone_Principal
FROM
    Cooperativa CO
JOIN
    Endereco E ON CO.CNPJ = E.Cooperativa_CNPJ
LEFT JOIN
    Telefone T ON CO.CNPJ = T.Cooperativa_CNPJ
GROUP BY
    CO.CNPJ;

-- 5. VIEW: Movimentação de Lotes por Armazém e Período.
CREATE VIEW Movimentacao_Estoque_Detalhada AS
SELECT
    A.nome Armazem,
    L.especie Especie_Lote,
    L.quantidade Quantidade_Inicial,
    DATE_FORMAT(E.entradaLotes, '%d/%m/%Y %H:%i') Entrada_BR,
    DATE_FORMAT(E.saidaLotes, '%d/%m/%Y %H:%i') Saida_BR,
    E.saldoDisponivel Saldo_Apos_Movimentacao
FROM
    Estoque E
JOIN
    Armazem A ON E.Armazem_idArmazem = A.idArmazem
JOIN
    Lote L ON A.idArmazem = L.Armazem_idArmazem;

-- 6. VIEW: Itens de sementes detalhados com informações de rastreio.
CREATE VIEW Sementes_Rastreio_Completo AS
SELECT
    S.nome Nome_Semente,
    S.especie Especie_Lote,
    S.quantidade Qtd_Sementes_Unidades,
    L.validade Data_Validade_Lote,
    R.idRastreio ID_Rastreio,
    R.destinatario Destinatario
FROM
    Sementes S
JOIN
    Lote L ON S.Lote_idLote = L.idLote
JOIN
    Estoque ES ON L.Armazem_idArmazem = ES.Armazem_idArmazem
JOIN
    Distribuicao DI ON DI.Rastreio_idRastreio = ES.Armazem_idArmazem
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio;

-- 7. VIEW: Contagem de Lotes e Saldo por UF de Armazém.
CREATE VIEW Resumo_Lotes_Por_UF AS
SELECT
    EA.UF UF_Armazem,
    COUNT(L.idLote) Total_Lotes,
    SUM(E.saldoDisponivel) Saldo_Total_Kg
FROM
    Armazem A
JOIN
    EnderecoArmazem EA ON A.idArmazem = EA.Armazem_idArmazem
JOIN
    Estoque E ON A.idArmazem = E.Armazem_idArmazem
JOIN
    Lote L ON A.idArmazem = L.Armazem_idArmazem
GROUP BY
    EA.UF
ORDER BY
    Saldo_Total_Kg DESC;

-- 8. VIEW: Rotas de Distribuição com Múltiplos Armazéns (Transbordo).
CREATE VIEW Rotas_Com_Transbordo AS
SELECT
    DA.Distribuicao_idDistribuicao ID_Distribuicao,
    R.destinatario Destinatario,
    DI.statusEntrega Status_Entrega,
    GROUP_CONCAT(A.nome SEPARATOR ' -> ') Rota_Armazens,
    COUNT(DA.Armazem_idArmazem) Qtd_Paradas
FROM
    Distribuicao_Armazem DA
JOIN
    Armazem A ON DA.Armazem_idArmazem = A.idArmazem
JOIN
    Distribuicao DI ON DA.Distribuicao_idDistribuicao = DI.idDistribuicao
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio
GROUP BY
    DA.Distribuicao_idDistribuicao
HAVING
    Qtd_Paradas > 1
ORDER BY
    Qtd_Paradas DESC;

-- 9. VIEW: Detalhe das entregas com status "Pendente" ou "Aguardando".
CREATE VIEW Entregas_Em_Espera AS
SELECT
    R.idRastreio ID_Rastreio,
    R.destinatario Destinatario,
    CO.nome Cooperativa,
    DI.statusEntrega Status_Atual,
    DATE_FORMAT(DI.dataSaida, '%d/%m/%Y') Data_Saida_BR,
    CONCAT(E.cidade, ' - ', E.UF) Local_Destino
FROM
    Distribuicao DI
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio
JOIN
    Cooperativa CO ON R.Cooperativa_CNPJ = CO.CNPJ
JOIN
    Endereco E ON CO.CNPJ = E.Cooperativa_CNPJ
WHERE
    DI.statusEntrega IN ('Pendente', 'Aguardando')
ORDER BY
    DI.dataSaida;

-- 10. VIEW: Armazéns com maior volume de estoque (Top 5).
CREATE VIEW Top_5_Armazens_Volume AS
SELECT
    A.nome Armazem,
    E.saldoDisponivel Saldo_Total_Kg,
    EA.cidade Localizacao
FROM
    Armazem A
JOIN
    Estoque E ON A.idArmazem = E.Armazem_idArmazem
JOIN
    EnderecoArmazem EA ON A.idArmazem = EA.Armazem_idArmazem
ORDER BY
    E.saldoDisponivel DESC
LIMIT 5;