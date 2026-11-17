-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
DELIMITER $$
-- Questão 20 - trg_pontos_casa
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$

-- Questão 21 - trg_valida_compra
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT preco, estoque INTO v_preco, v_estoque
    FROM produto WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    ELSEIF v_saldo < v_preco * NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    ELSE
        SET NEW.valor_total = v_preco * NEW.quantidade;
    END IF;
END$$

-- Questão 22 - trg_baixa_compra
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE aluno
    SET saldo_galeoes = saldo_galeoes - NEW.valor_total
    WHERE id_aluno = NEW.id_aluno;
END$$

-- Questão 23 - trg_situacao_nota
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NOT (NEW.nota <=> OLD.nota) THEN
        SET NEW.situacao = IF(NEW.nota >= 6, 'Aprovado', 'Reprovado');
    END IF;
END$$
-- Questão 24 - trg_audita_salario
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$

DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: A validação precisa acontecer ANTES de gravar para poder bloquear (SIGNAL)
-- e também para preencher NEW.valor_total, pois só no BEFORE é possível
-- alterar os valores da linha que será gravada. A baixa de estoque/saldo só
-- deve ocorrer DEPOIS que a compra foi aceita e gravada: se fosse BEFORE,
-- o estoque seria descontado mesmo que a compra falhasse por outro motivo.


-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito',          '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções',               '2026-09-12'),
( 5, 2,  15, 'Poção do Morto-Vivo impecável',          '2026-09-12'),
( 8, 5,  10, 'Cuidou de um testrálio ferido',          '2026-09-20'),
(11, 4,  25, 'Ajudou os alunos do 1º ano',             '2026-09-25'),
( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia',   '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher',  '2026-10-05'),
( 1, 6,  50, 'Conjurou um Patrono corpóreo',           '2026-10-15'),
( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',      '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor',             '2026-10-31'),
(10, 7,   5, 'Interpretação da bola de cristal',       '2026-11-03'),
(13, 4,  10, 'Colheita de mandrágoras',                '2026-11-05'),
( 3, 9,  10, 'Identificou um bezoar',                  '2026-11-06'),
( 8, 3,  20, 'Resposta brilhante sobre o Diadema',     '2026-11-08'),
( 6, 2,  25, 'Antídoto para venenos comuns',           '2026-11-09'),
( 5, 9,  40, 'Melhor poção do Clube do Slugue',        '2026-11-09');

-- Questão 25 - INSERT compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
( 5, 2,  1, '2026-09-01'),
( 2, 5,  2, '2026-09-02'),
( 1, 3, 10, '2026-09-03'),
( 3, 4,  5, '2026-09-03'),
( 9, 8,  1, '2026-09-15'),
( 8, 5,  1, '2026-09-20'),
(11, 1,  1, '2026-10-01'),
( 6, 3, 20, '2026-10-10'),
( 1, 7,  2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- Resultado: Rony (id 3) tenta comprar 1 Vassoura Nimbus 2001 (id 2)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- ERRO 1644 (45000): Galeões insuficientes no cofre do aluno
-- Explicação: há estoque (a Nimbus ainda tem 2 unidades), mas o Rony tem só
-- 6.00 galeões e a vassoura custa 300.00. O trigger BEFORE INSERT bloqueou
-- a compra com SIGNAL; nada foi gravado e nada foi baixado.


-- Questão 25 - Hermione tenta comprar o caldeirão
-- Resultado: Hermione (id 2) tenta comprar 1 Caldeirão de Estanho (id 6)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- ERRO 1644 (45000): Estoque insuficiente no Beco Diagonal
-- Explicação: o Caldeirão tem estoque 0. O estoque é verificado primeiro, então
-- essa mensagem aparece mesmo que o saldo da Hermione fosse suficiente.


-- Questão 25 - Recuperação do Rony em Poções :Rony faz recuperação de Poções (id_disc 2), sem mexer em situacao 
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;

-- Resultado: situacao passou de 'Reprovado' para 'Aprovado' (6.5 >= 6),
-- recalculada automaticamente pelo trigger trg_situacao_nota

-- Questão 25 - Salário e data de admissão do Hagrid
-- Linhas em log_auditoria: UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';

UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;

-- Por que o reajuste da questão 10 não aparece: 1 linha em log_auditoria ('Rúbeo Hagrid: salário de 4500.00 para
-- 5000.00'). A mudança só da data_admissao não gera log, pois o trigger só
-- grava quando OLD.salario <> NEW.salario. O reajuste da questão 10 não
-- aparece porque aconteceu ANTES da criação do trigger (triggers só atuam
-- sobre operações feitas depois de existirem).

-- Confira: placar, saldos, estoques, soma das compras e log
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno IN (1, 5);
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS soma_compras FROM compra;
SELECT COUNT(*) AS linhas_log FROM log_auditoria;
