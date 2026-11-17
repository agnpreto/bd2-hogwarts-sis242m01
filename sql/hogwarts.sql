-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- 6.2
SELECT a.nome, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar;

-- 6.3
SELECT a.nome
FROM aluno a
WHERE a.nome LIKE '_a%';

-- 6.4
SELECT d.id_disc, d.nome_disc
FROM disciplina d
WHERE d.id_prof IS NULL;

-- 6.5
SELECT p.nome_produto, p.preco
FROM produto p
WHERE p.preco NOT BETWEEN 5 AND 20
ORDER BY p.preco;

-- 6.6
SELECT DISTINCT p.loja
FROM produto p
ORDER BY p.loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê:  Aparecem 12 alunos, não 13: o INNER JOIN só traz alunos que têm casa
-- correspondente. Teddy Lupin tem id_casa NULL (ainda não passou pelo Chapéu
-- Seletor) e é descartado.

-- 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;


-- 6.9
SELECT p.id_prof, p.nome
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM aluno a
JOIN casa c       ON c.id_casa  = a.id_casa
JOIN matricula m  ON m.id_aluno = a.id_aluno
JOIN disciplina d ON d.id_disc  = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT co.id_compra,
       a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a    ON a.id_aluno    = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra, co.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(*) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM matricula m
JOIN disciplina d ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa AS casa,
       COUNT(r.id_registro) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN -r.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo
FROM registro_pontos r
JOIN aluno a ON a.id_aluno = r.id_aluno
JOIN casa c  ON c.id_casa  = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo DESC;

-- 6.14
SELECT pr.loja,
       COUNT(*) AS qtd_compras,
       SUM(co.valor_total) AS faturamento
FROM compra co
JOIN produto pr ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS qtd_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome AS professor,
       COUNT(*) AS qtd_registros,
       SUM(r.pontos) AS total_concedido
FROM professor p
JOIN registro_pontos r ON r.id_prof = p.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT co.id_aluno
                     FROM compra co
                     WHERE co.id_produto IN (SELECT pr.id_produto
                                             FROM produto pr
                                             WHERE pr.loja = 'Dedosdemel'));

-- 6.18
SELECT pr.nome_produto, pr.estoque
FROM produto pr
WHERE pr.id_produto NOT IN (SELECT co.id_produto FROM compra co);

-- 6.19
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (SELECT p2.salario
                       FROM professor p2
                       WHERE p2.id_casa IS NULL);

-- 6.21
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  AND a.saldo_galeoes > ANY (SELECT a2.saldo_galeoes
                             FROM aluno a2
                             JOIN casa c2 ON c2.id_casa = a2.id_casa
                             WHERE c2.nome_casa = 'Sonserina');

-- > ANY equivale a: ANY equivale a comparar com o MENOR valor da subconsulta: basta o saldo
-- ser maior que o de ALGUM sonserino, ou seja, maior que o mínimo.
-- (> ALL é que equivale a comparar com o maior valor.)

-- 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (SELECT 1
              FROM aluno a
              JOIN matricula m ON m.id_aluno = a.id_aluno
              WHERE a.id_casa = c.id_casa
                AND m.nota = 10);


-- 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (SELECT 1 FROM compra co WHERE co.id_aluno = a.id_aluno);

-- 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(t.media_aluno), 2) AS media_da_casa
FROM (SELECT m.id_aluno, AVG(m.nota) AS media_aluno
      FROM matricula m
      GROUP BY m.id_aluno) t
JOIN aluno a ON a.id_aluno = t.id_aluno
JOIN casa c  ON c.id_casa  = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT a.nome, 'Aluno' AS vinculo FROM aluno a
UNION ALL
SELECT p.nome, 'Professor' AS vinculo FROM professor p
ORDER BY nome;

-- 6.26
-- Linhas com UNION ALL: 
SELECT a.nome
FROM compra co JOIN aluno a ON a.id_aluno = co.id_aluno
UNION ALL
SELECT a.nome
FROM registro_pontos r JOIN aluno a ON a.id_aluno = r.id_aluno;

-- UNION ALL: 27 linhas (10 compras + 17 registros de pontos), mantendo repetidos.

-- Linhas com UNION: 
SELECT a.nome
FROM compra co JOIN aluno a ON a.id_aluno = co.id_aluno
UNION
SELECT a.nome

-- Explicação: 12 linhas. A diferença: UNION remove linhas duplicadas (cada aluno
-- aparece uma única vez, o que exige uma etapa extra de eliminação); UNION ALL
-- apenas concatena os resultados, sem remover nada, e por isso é mais rápido.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total)
FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario)
FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes)
FROM aluno;
