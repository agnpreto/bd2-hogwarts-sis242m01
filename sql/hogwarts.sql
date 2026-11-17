-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;   -- tudo zerado
ROLLBACK;
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;   -- placar restaurado
-- Sim, o placar voltou: o ROLLBACK desfez o UPDATE, pois ele ainda não havia
-- sido confirmado com COMMIT.

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;        -- 47.00
SELECT estoque FROM produto WHERE id_produto = 1;          -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;        -- 54.00
SELECT estoque FROM produto WHERE id_produto = 1;          -- 9
-- Os UPDATEs feitos pelo trigger trg_baixa_compra fazem parte da mesma
-- transação da compra; o ROLLBACK desfez tudo (a compra, o desconto do saldo
-- e a baixa do estoque). Só o contador auto_increment de compra não volta.

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS linhas_registro_pontos FROM registro_pontos;  -- 17

-- Questão 30
SELECT @@autocommit;
-- Resposta: o autocommit está LIGADO, então cada comando fora de uma transação explícita é confirmado (COMMIT) automaticamente. START TRANSACTION
-- suspende isso até o COMMIT/ROLLBACK. Se executar um CREATE TABLE (comando DDL) no meio de uma transação aberta,
-- o MySQL faz um COMMIT IMPLÍCITO antes: tudo que estava pendente é confirmado e não dá mais para dar ROLLBACK. DDL não é transacional no MySQL.
