USE agro_sustenta;

/* 1. Nome: EntregasEmTransito
   Descrição: Retorna os detalhes de todas as distribuições que estão atualmente com o status 'Em Trânsito', formatando a data de saída. */
SELECT
    DI.idDistribuicao ID_Distribuição,DATE_FORMAT(DI.dataSaida, '%d/%m/%Y %H:%i') Data_Saida_BR,
    R.destinatario Destinatario,R.Cooperativa_CNPJ CNPJ_Cooperativa
FROM
    Distribuicao DI
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio
WHERE
    DI.statusEntrega = 'Em Trânsito';
    
/* 2. Nome: EstoqueSementesNordeste
   Descrição: Lista sementes, quantidade de lote em quilos e validade formatada, especificamente para o armazém 'Armazém Central Nordeste'. */
SELECT
    S.nome Nome_Semente,L.quantidade Quantidade_Lote_Kg,DATE_FORMAT(L.validade, '%d/%m/%Y') Validade_Lote
FROM
    Sementes S
JOIN
    Lote L ON S.Lote_idLote = L.idLote
JOIN
    Armazem A ON L.Armazem_idArmazem = A.idArmazem
WHERE
    A.nome = 'Armazém Central Nordeste'
ORDER BY
    L.validade;

/* 3. Nome: CooperativasSemTelefone
   Descrição: Identifica cooperativas sem registro de telefone, exibindo '-' no lugar do número nulo. */
SELECT
    CO.nome Nome_Cooperativa,CO.CNPJ,COUNT(T.numero) Total_Telefones
FROM
    Cooperativa CO
LEFT JOIN
    Telefone T ON CO.CNPJ = T.Cooperativa_CNPJ
GROUP BY
    CO.CNPJ, CO.nome
ORDER BY
    Total_Telefones DESC;

/* 4. Nome: ArmazensDeTransbordo
   Descrição: Lista armazéns que participaram de mais de uma distribuição, indicando uso em rotas de transbordo. */
SELECT
    A.nome Armazem,COUNT(DA.Distribuicao_idDistribuicao) Total_Rotas
FROM
    Armazem A
JOIN
    Distribuicao_Armazem DA ON A.idArmazem = DA.Armazem_idArmazem
GROUP BY
    A.nome
HAVING
    Total_Rotas > 1
ORDER BY
    Total_Rotas DESC;

/* 5. Nome: ArmazensAcimaMediaEstoque
   Descrição: Retorna a localização e saldo dos armazéns cujo estoque está acima da média geral de saldo de todos os armazéns. */
SELECT
    EA.cidade Cidade,E.saldoDisponivel Saldo_Atual_Kg
FROM
    Estoque E
JOIN
    EnderecoArmazem EA ON E.Armazem_idArmazem = EA.Armazem_idArmazem
WHERE
    E.saldoDisponivel > (SELECT AVG(saldoDisponivel) FROM Estoque)
ORDER BY
    E.saldoDisponivel DESC;

/* 6. Nome: DestinatariosEntreguesRJ
   Descrição: Busca destinatários de rastreios com status 'Entregue' e cuja cooperativa reside no estado do Rio de Janeiro (RJ). */
SELECT
    R.destinatario Destinatario,CO.nome Cooperativa,E.cidade Cidade_Destino
FROM
    Rastreio R
JOIN
    Cooperativa CO ON R.Cooperativa_CNPJ = CO.CNPJ
JOIN
    Endereco E ON CO.CNPJ = E.Cooperativa_CNPJ
JOIN
    Distribuicao DI ON R.idRastreio = DI.Rastreio_idRastreio
WHERE
    DI.statusEntrega = 'Entregue' AND E.UF = 'RJ';

/* 7. Nome: LotesSemSementes
   Descrição: Identifica lotes que não têm nenhuma semente associada, indicando possíveis inconsistências ou lotes vazios. */
SELECT
    L.idLote ID_Lote,L.especie Especie_Lote,S.nome Nome_Semente,S.quantidade Qtd_Sementes_Unidades
FROM
    Lote L
JOIN
    Sementes S ON L.idLote = S.Lote_idLote
ORDER BY
    S.quantidade DESC
LIMIT 5;

/* 8. Nome: DistribuicoesComRotaSul
   Descrição: Lista IDs de distribuições que passaram por algum armazém localizado nos estados do Sul (RS ou SC). */
SELECT DISTINCT
    DA.Distribuicao_idDistribuicao ID_Distribuição,DI.statusEntrega Status
FROM
    Distribuicao_Armazem DA
JOIN
    Armazem A ON DA.Armazem_idArmazem = A.idArmazem
JOIN
    EnderecoArmazem EA ON A.idArmazem = EA.Armazem_idArmazem
JOIN
    Distribuicao DI ON DA.Distribuicao_idDistribuicao = DI.idDistribuicao
WHERE
    EA.UF IN ('RS', 'SC');

/* 9. Nome: LotesAtivosPorEspecie
   Descrição: Calcula o total de peso (em Kg) para cada espécie de lote cuja validade ainda não expirou. */
SELECT
    especie Especie,SUM(quantidade) Total_Quantidade_Kg
FROM
    Lote
WHERE
    validade > CURDATE()
GROUP BY
    especie
ORDER BY
    Total_Quantidade_Kg DESC;

/* 10. Nome: CooperativasAtendidasSP
    Descrição: Lista cooperativas que receberam distribuições que passaram por armazéns localizados em São Paulo (SP), usando subselect. */
SELECT
    CO.nome Nome_Cooperativa,CO.CNPJ
FROM
    Cooperativa CO
WHERE
    CO.CNPJ IN (SELECT R.Cooperativa_CNPJ
        FROM
            Rastreio R
        JOIN
            Distribuicao DI ON R.idRastreio = DI.Rastreio_idRastreio
        JOIN
            Distribuicao_Armazem DA ON DI.idDistribuicao = DA.Distribuicao_idDistribuicao
        JOIN
            EnderecoArmazem EA ON DA.Armazem_idArmazem = EA.Armazem_idArmazem
        WHERE
            EA.UF = 'SP'
    )
ORDER BY
    CO.nome;

/* 11. Nome: ArmazensAltoGiro
    Descrição: Identifica os armazéns que possuem mais de 3 lotes diferentes armazenados, indicando alto volume de movimentação. */
SELECT
    A.nome Armazem,COUNT(L.idLote) Total_Lotes_Diferentes
FROM
    Armazem A
JOIN
    Lote L ON A.idArmazem = L.Armazem_idArmazem
GROUP BY
    A.nome
ORDER BY
    Total_Lotes_Diferentes DESC;

/* 12. Nome: PendentesComContato
    Descrição: Lista rastreios com status 'Pendente', mostrando o telefone de contato do destinatário (com '-' para nulo). */
SELECT
    R.idRastreio ID_Rastreio,R.destinatario Destinatario,IFNULL(T.numero, '-') Telefone_Contato
FROM
    Rastreio R
JOIN
    Cooperativa CO ON R.Cooperativa_CNPJ = CO.CNPJ
LEFT JOIN
    Telefone T ON CO.CNPJ = T.Cooperativa_CNPJ
WHERE
    R.idRastreio IN (SELECT Rastreio_idRastreio FROM Distribuicao WHERE statusEntrega = 'Pendente');

/* 13. Nome: EnderecosArmazemSoja
    Descrição: Retorna a localização (logradouro e cidade) dos armazéns que estocam a espécie 'Soja - Variedade BR 101'. */
SELECT DISTINCT
    EA.logradouro Logradouro_Armazem,EA.cidade Cidade_Armazem
FROM
    EnderecoArmazem EA
JOIN
    Armazem A ON EA.Armazem_idArmazem = A.idArmazem
JOIN
    Lote L ON A.idArmazem = L.Armazem_idArmazem
WHERE
    L.especie = 'Soja - Variedade BR 101';

/* 14. Nome: EntreguesAposData
    Descrição: Exibe data de saída formatada e destinatário para entregas com status 'Entregue' realizadas após 2025-10-20. */
SELECT
    DATE_FORMAT(DI.dataSaida, '%d/%m/%Y %H:%i') Data_Saida_Entrega,R.destinatario Destinatario
FROM
    Distribuicao DI
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio
WHERE
    DI.statusEntrega = 'Entregue' AND DI.dataSaida > '2025-10-20 00:00:00';

/* 15. Nome: ContagemPorStatus
    Descrição: Conta e agrupa o número total de distribuições por status de entrega. */
SELECT
    DI.statusEntrega Status,COUNT(DI.idDistribuicao) Total_Entregas
FROM
    Distribuicao DI
JOIN
    Rastreio R ON DI.Rastreio_idRastreio = R.idRastreio
GROUP BY
    DI.statusEntrega
ORDER BY
    Total_Entregas DESC;

/* 16. Nome: ContatoCooperativaSP
    Descrição: Lista cooperativas cujo número de telefone cadastrado começa com o prefixo de São Paulo (11). */
SELECT
    CO.nome Nome_Cooperativa,CO.email Email,T.numero Telefone
FROM
    Cooperativa CO
JOIN
    Telefone T ON CO.CNPJ = T.Cooperativa_CNPJ
WHERE
    T.numero LIKE '11 %';

/* 17. Nome: SaldoSementeEspecifica
    Descrição: Exibe a quantidade específica da semente "Soja C-300" e o saldo geral de estoque do armazém que a contém. */
SELECT
    S.nome Nome_Semente,S.quantidade Quantidade_Semente,A.nome Armazem,E.saldoDisponivel Saldo_Armazem_Kg
FROM
    Sementes S
JOIN
    Lote L ON S.Lote_idLote = L.idLote
JOIN
    Armazem A ON L.Armazem_idArmazem = A.idArmazem
JOIN
    Estoque E ON A.idArmazem = E.Armazem_idArmazem
WHERE
    S.nome = 'Soja C-300';

/* 18. Nome: ArmazensSemMilho
    Descrição: Retorna a localização dos armazéns que não possuem nenhum lote da espécie 'Milho Híbrido Tipo A' (usa subselect NOT IN). */
SELECT
    A.nome Armazem,EA.cidade Cidade,EA.UF UF
FROM
    Armazem A
JOIN
    EnderecoArmazem EA ON A.idArmazem = EA.Armazem_idArmazem
WHERE
    A.idArmazem NOT IN (
        SELECT
            Armazem_idArmazem
        FROM
            Lote
        WHERE
            especie = 'Milho Híbrido Tipo A'
    );

/* 19. Nome: EstoqueTotalPorCooperativa
    Descrição: Soma o saldo total de estoque associado (indiretamente via distribuição) a cada cooperativa. */
SELECT
    CO.nome Cooperativa,SUM(E.saldoDisponivel) Total_Estoque_Associado_Kg
FROM
    Cooperativa CO
JOIN
    Rastreio R ON CO.CNPJ = R.Cooperativa_CNPJ
JOIN
    Distribuicao DI ON R.idRastreio = DI.Rastreio_idRastreio
JOIN
    Distribuicao_Armazem DA ON DI.idDistribuicao = DA.Distribuicao_idDistribuicao
JOIN
    Estoque E ON DA.Armazem_idArmazem = E.Armazem_idArmazem
GROUP BY
    CO.nome
ORDER BY
    Total_Estoque_Associado_Kg DESC;

/* 20. Nome: DetalheLoteEstoque
    Descrição: Combina detalhes do lote com as datas de entrada e saída do estoque, formatadas no estilo brasileiro. */
SELECT
    L.idLote ID_Lote,L.especie Especie,L.quantidade Quantidade_Kg,L.descricao Descricao,
    DATE_FORMAT(E.entradaLotes, '%d/%m/%Y %H:%i') Entrada_Armazem_BR,DATE_FORMAT(E.saidaLotes, '%d/%m/%Y %H:%i') Saida_Armazem_BR
FROM
    Lote L
JOIN
    Estoque E ON L.Armazem_idArmazem = E.Armazem_idArmazem
ORDER BY
    L.idLote;