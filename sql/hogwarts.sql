-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Maria Luiza O. Teodoro
-- Matrícula: 2538557
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT,
    nome_casa VARCHAR(30) NOT NULL,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0,
    PRIMARY KEY (id_casa),
    UNIQUE (nome_casa)
);

-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT,
    PRIMARY KEY (id_prof),
    CHECK (salario > 0),
    FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT,
    nome_disc VARCHAR(60) NOT NULL,
    ano_minimo INT,
    id_prof INT,
    PRIMARY KEY (id_disc),
    UNIQUE (nome_disc),
    CHECK (ano_minimo BETWEEN 1 AND 7),
    FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    PRIMARY KEY (id_aluno),
    CHECK (ano_escolar BETWEEN 1 AND 7),
    CHECK (saldo_galeoes >= 0),
    FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CHECK (nota BETWEEN 0 AND 10),
    FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_disc) REFERENCES disciplina (id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    PRIMARY KEY (id_registro),
    FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    PRIMARY KEY (id_produto),
    CHECK (preco > 0),
    CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    PRIMARY KEY (id_compra),
    CHECK (quantidade > 0),
    FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_log)
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: porque um aluno cursa várias disciplinas e uma disciplina tem vários alunos. Assim, o que identifica uma matrícula é o par 
-- (id_aluno, id_disc), e a chave composta impede que o mesmo aluno seja matriculado duas vezes na mesma disciplina.


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal', 'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),
('Severo Snape', 8800.00, '1981-09-01', 2),
('Fílio Flitwick', 8200.00, '1974-09-01', 3),
('Pomona Sprout', 7900.00, '1972-09-01', 4),
('Rúbeo Hagrid', 4500.00, '1993-09-01', NULL),
('Remo Lupin', 6200.00, '1993-09-01', NULL),
('Sibila Trelawney', 5100.00, '1980-09-01', NULL),
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL),
('Horácio Slughorn', 8000.00, '1996-09-01', NULL);

-- INSERT disciplina
INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração', 1, 1),
('Poções', 1, 2),
('Feitiços', 1, 3),
('Herbologia', 1, 4),
('Trato das Criaturas Mágicas', 3, 5),
('Defesa Contra as Artes das Trevas', 1, 6),
('Adivinhação', 3, 7),
('Estudo dos Trouxas', 3, NULL),
('Runas Antigas', 3, NULL);

-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter', 5, 1, 120.00),
('Hermione Granger', 5, 1, 85.00),
('Rony Weasley', 5, 1, 12.00),
('Neville Longbottom', 5, 1, 30.00),
('Draco Malfoy', 5, 2, 500.00),
('Pansy Parkinson', 5, 2, 150.00),
('Vicente Crabbe', 5, 2, 40.00),
('Luna Lovegood', 4, 3, 45.00),
('Cho Chang', 6, 3, 200.00),
('Padma Patil', 5, 3, 60.00),
('Cedrico Diggory', 7, 4, 180.00),
('Ana Abbott', 5, 4, 25.00),
('Ernesto Macmillan', 5, 4, 70.00),
('Teddy Lupin', 1, NULL, 0.00);

-- INSERT matricula
INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5),(1,2,5.0),(1,6,9.8),(1,5,8.0),
(2,1,10.0),(2,2,9.5),(2,3,10.0),(2,5,9.0),(2,9,9.5),
(3,1,6.0),(3,2,4.5),(3,7,5.5),
(4,2,3.0),(4,4,10.0),(4,6,7.0),
(5,2,9.0),(5,1,7.0),(5,5,4.0),
(6,2,7.5),(6,7,6.5),
(7,2,3.5),(7,6,2.0),
(8,5,8.5),(8,3,8.0),(8,4,9.0),
(9,3,8.5),(9,6,7.5),
(10,3,9.0),(10,7,6.0),
(11,4,8.5),(11,6,9.0),(11,1,8.0),
(12,4,8.0),
(13,4,7.0),(13,3,7.5);

-- INSERT produto
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);

-- Confira: SELECT COUNT(*) de cada tabela
SELECT COUNT(*) FROM casa;
SELECT COUNT(*) FROM professor;
SELECT COUNT(*) FROM disciplina;
SELECT COUNT(*) FROM aluno;
SELECT COUNT(*) FROM matricula;
SELECT COUNT(*) FROM produto;


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questão 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questão 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Confira a estrutura das tabelas alteradas
DESC aluno;
DESC matricula;
DESC produto;
DESC casa;
DESC professor;

-- Questão 6
UPDATE aluno SET email = LOWER(CONCAT(REPLACE(nome, ' ', '.'), '@hogwarts.edu'));

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula SET nota = LEAST(nota + 0.5, 10) WHERE id_disc IN (SELECT id_disc FROM disciplina
WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'));

-- Questão 9
UPDATE matricula SET situacao = CASE
	WHEN nota >= 6 THEN 'Aprovado'
    ELSE 'Reprovado'
END;

-- Questão 10
UPDATE professor SET salario = salario * 1.10 WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

-- Questão 11
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 12
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';

-- Confira
SELECT nota FROM matricula WHERE id_aluno = 1 AND id_disc = 6;
SELECT COUNT(*) FROM matricula WHERE situacao = 'Reprovado';
SELECT salario FROM professor WHERE nome = 'Minerva McGonagall';
SELECT preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: a Sonserina é referenciada por alunos e pelo professor Snape (chave estrangeira id_casa),
-- então o banco não deixa apagá-la enquanto houver registros ligados a ela.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: o CHECK da tabela aluno só aceita ano_escolar de 1 a 7, e o Dobby foi cadastrado no 8º ano.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: o e-mail já pertence ao Harry Potter, e a restrição UNIQUE uq_aluno_email não permite repetir.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: o Snape é o professor de Poções, e a tabela disciplina referencia ele pela chave estrangeira id_prof.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Por que funciona: nenhuma tabela referencia o Lockhart (ele não ministra disciplina), então não há chave estrangeira impedindo.

-- Questão 18
DELETE FROM matricula WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira
SELECT COUNT(*) FROM professor;
SELECT COUNT(*) FROM aluno;
SELECT COUNT(*) FROM disciplina;
SELECT COUNT(*) FROM matricula;


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa SET pontos = pontos + NEW.pontos WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21 - trg_valida_compra
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco FROM produto WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo FROM aluno WHERE id_aluno = NEW.id_aluno;

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
DELIMITER ;

-- Questão 22 - trg_baixa_compra
DELIMITER $$
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto SET estoque = estoque - NEW.quantidade WHERE id_produto = NEW.id_produto;
    UPDATE aluno SET saldo_galeoes = saldo_galeoes - NEW.valor_total WHERE id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questão 23 - trg_situacao_nota
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NOT (NEW.nota <=> OLD.nota) THEN
        IF NEW.nota >= 6 THEN
            SET NEW.situacao = 'Aprovado';
        ELSE
            SET NEW.situacao = 'Reprovado';
        END IF;
    END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao) VALUES ('professor', 'UPDATE', CONCAT(OLD.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: a validação precisa ser BEFORE para barrar a compra e calcular o valor_total antes de a linha ser gravada. A baixa precisa ser AFTER para só diminuir o estoque e o saldo
-- depois que a compra foi gravada de fato (se a compra for bloqueada, nada é descontado).

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito',        '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções',             '2026-09-12'),
( 5, 2,  15, 'Poção do Morto-Vivo impecável',        '2026-09-12'),
( 8, 5,  10, 'Cuidou de um testrálio ferido',        '2026-09-20'),
(11, 4,  25, 'Ajudou os alunos do 1º ano',           '2026-09-25'),
( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher','2026-10-05'),
( 1, 6,  50, 'Conjurou um Patrono corpóreo',         '2026-10-15'),
( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',    '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor',           '2026-10-31'),
(10, 7,   5, 'Interpretação da bola de cristal',     '2026-11-03'),
(13, 4,  10, 'Colheita de mandrágoras',              '2026-11-05'),
( 3, 9,  10, 'Identificou um bezoar',                '2026-11-06'),
( 8, 3,  20, 'Resposta brilhante sobre o Diadema',   '2026-11-08'),
( 6, 2,  25, 'Antídoto para venenos comuns',         '2026-11-09'),
( 5, 9,  40, 'Melhor poção do Clube do Slugue',      '2026-11-09');

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
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno
-- A compra foi bloqueada pelo trg_valida_compra: o saldo do Rony é menor que 300 galeões, o preço da Nimbus.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- A compra foi bloqueada pelo trg_valida_compra: o Caldeirão de Estanho está com estoque 0.

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- A situação virou 'Aprovado' sem mexer na coluna: o trg_situacao_nota recalculou ao mudar a nota.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Linhas em log_auditoria: 1 (só o reajuste do salário; o 2º UPDATE não mudou o salário, então o trigger não gravou nada).
-- Por que o reajuste da questão 10 não aparece: porque o trigger trg_audita_salario só foi criado depois da questão 10.

-- Confira
SELECT nome_casa, pontos FROM casa;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Harry Potter');
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) FROM compra;
SELECT COUNT(*) FROM log_auditoria;


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
SELECT nome_casa, pontos FROM casa;
ROLLBACK;
SELECT nome_casa, pontos FROM casa;
-- O placar voltou? Sim: o ROLLBACK desfez o UPDATE, e as casas voltaram aos pontos de antes.

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
-- O que aconteceu: o ROLLBACK também desfez o que o trigger tinha feito; o saldo do Harry
-- e o estoque da varinha voltaram aos valores de antes, porque o trigger faz parte da mesma transação.

-- Questão 29
START TRANSACTION;

INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;

COMMIT;

-- Confira
SELECT nome_casa, pontos FROM casa;
SELECT COUNT(*) FROM registro_pontos;

-- Questão 30
SELECT @@autocommit;
-- Resposta: o valor 1 significa que o autocommit está ligado, ou seja, cada comando é confirmado
-- sozinho, sem precisar de COMMIT. Um CREATE TABLE no meio de uma transação aberta faz um COMMIT implícito: tudo o que estava pendente é confirmado e não dá mais para desfazer com ROLLBACK.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT p.nome, p.salario FROM professor p WHERE p.salario BETWEEN 6000.00 AND 9000.00 ORDER BY p.salario DESC;

-- 6.2
SELECT a.nome, a.ano_escolar FROM aluno a WHERE a.ano_escolar IN (1, 4, 6, 7) ORDER BY a.ano_escolar;

-- 6.3
SELECT a.nome FROM aluno a WHERE a.nome LIKE '_a%';

-- 6.4
SELECT d.nome_disc FROM disciplina d WHERE d.id_prof IS NULL;

-- 6.5
SELECT p.nome_produto, p.preco FROM produto p WHERE p.preco NOT BETWEEN 5 AND 20 ORDER BY p.preco;

-- 6.6
SELECT DISTINCT p.loja FROM produto p ORDER BY p.loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: 12 alunos. O Teddy Lupin não tem casa (id_casa NULL),
-- e o INNER JOIN só traz as linhas que têm correspondência nas duas tabelas, então ele fica de fora.

-- 6.8
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa FROM aluno a 
LEFT JOIN casa c ON a.id_casa = c.id_casa ORDER BY a.nome;

-- 6.9
SELECT p.nome AS professor FROM disciplina d RIGHT JOIN professor p ON d.id_prof = p.id_prof WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno, d.nome_disc AS disciplina, COALESCE(p.nome, 'Sem professor') AS professor, m.nota, m.situacao FROM aluno a
JOIN casa c ON a.id_casa = c.id_casa
JOIN matricula m ON a.id_aluno = m.id_aluno
JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof WHERE c.nome_casa = 'Grifinória' ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT c.id_compra AS numero_compra, a.nome AS aluno, p.nome_produto AS produto, p.loja, c.quantidade, c.valor_total, c.data_compra
FROM compra c JOIN aluno a   ON c.id_aluno = a.id_aluno
JOIN produto p ON c.id_produto = p.id_produto ORDER BY c.data_compra, c.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina, COUNT(*) AS qtd_alunos, ROUND(AVG(m.nota), 2) AS media, MAX(m.nota) AS maior_nota, MIN(m.nota) AS menor_nota
FROM disciplina d JOIN matricula m ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc HAVING AVG(m.nota) >= 7 ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa AS casa, COUNT(*) AS qtd_registros, SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos, 
SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,SUM(r.pontos) AS saldo
FROM registro_pontos r JOIN aluno a ON r.id_aluno = a.id_aluno
JOIN casa c  ON a.id_casa = c.id_casa GROUP BY c.id_casa, c.nome_casa ORDER BY saldo DESC;

-- 6.14
SELECT p.loja, COUNT(*) AS qtd_compras, SUM(c.valor_total) AS faturamento FROM compra c
JOIN produto p ON c.id_produto = p.id_produto GROUP BY p.loja HAVING SUM(c.valor_total) > 20 ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(r.data_registro) AS mes, COUNT(*) AS qtd_registros, SUM(r.pontos) AS total_pontos FROM registro_pontos r
GROUP BY MONTH(r.data_registro) ORDER BY mes;

-- 6.16
SELECT p.nome AS professor, COUNT(*) AS qtd_registros, SUM(r.pontos) AS total_concedido FROM registro_pontos r
JOIN professor p ON r.id_prof = p.id_prof GROUP BY p.id_prof, p.nome HAVING COUNT(*) >= 2 ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT c.id_aluno FROM compra c WHERE c.id_produto IN 
(SELECT p.id_produto FROM produto p WHERE p.loja = 'Dedosdemel'));

-- 6.18
SELECT p.nome_produto, p.estoque FROM produto p WHERE p.id_produto NOT IN (SELECT c.id_produto FROM compra c);

-- 6.19
SELECT a.nome, a.saldo_galeoes FROM aluno a WHERE a.saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT p.nome, p.salario FROM professor p WHERE p.salario > ALL (SELECT salario FROM professor WHERE id_casa IS NULL);

-- 6.21
SELECT a.nome, a.saldo_galeoes FROM aluno a WHERE (a.id_casa IS NULL OR a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')) AND a.saldo_galeoes > ANY (
SELECT a2.saldo_galeoes FROM aluno a2 JOIN casa c ON a2.id_casa = c.id_casa WHERE c.nome_casa = 'Sonserina');
-- > ANY equivale a: comparar com o MENOR valor da subconsulta (basta ser maior que pelo menos um deles).

-- 6.22
SELECT c.nome_casa FROM casa c WHERE EXISTS (SELECT 1 FROM aluno a
JOIN matricula m ON a.id_aluno = m.id_aluno WHERE a.id_casa = c.id_casa AND m.nota = 10);

-- 6.23
SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM compra c WHERE c.id_aluno = a.id_aluno);

-- 6.24
SELECT c.nome_casa AS casa, ROUND(AVG(t.media_aluno), 2) AS media_casa
FROM (SELECT m.id_aluno, AVG(m.nota) AS media_aluno FROM matricula m GROUP BY m.id_aluno) t JOIN aluno a ON t.id_aluno = a.id_aluno
JOIN casa c  ON a.id_casa = c.id_casa GROUP BY c.id_casa, c.nome_casa ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno UNION ALL SELECT nome, 'Professor' AS vinculo FROM professor ORDER BY nome;

-- 6.26
SELECT a.nome FROM compra c JOIN aluno a ON c.id_aluno = a.id_aluno UNION ALL SELECT a.nome FROM registro_pontos r JOIN aluno a ON r.id_aluno = a.id_aluno;

SELECT a.nome FROM compra c JOIN aluno a ON c.id_aluno = a.id_aluno UNION SELECT a.nome FROM registro_pontos r JOIN aluno a ON r.id_aluno = a.id_aluno;
-- Linhas com UNION ALL: 27
-- Linhas com UNION: 12
-- Explicação: o UNION ALL junta os dois resultados e mantém os nomes repetidos (um aluno aparece
-- uma vez para cada compra e para cada registro de pontos). O UNION remove as linhas duplicadas,
-- então cada aluno aparece uma vez só.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS SELECT c.nome_casa, c.pontos FROM casa c ORDER BY c.pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Sem casa') AS casa, d.nome_disc AS disciplina,
COALESCE(p.nome, 'Sem professor') AS professor, m.nota, m.situacao FROM matricula m
JOIN aluno a ON m.id_aluno = a.id_aluno
LEFT JOIN casa c ON a.id_casa = c.id_casa
JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno, p.nome_produto AS produto, p.loja, c.quantidade, c.valor_total, c.data_compra FROM compra c
JOIN aluno a ON c.id_aluno = a.id_aluno
JOIN produto p ON c.id_produto = p.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS SELECT a.nome AS aluno, c.nome_casa AS casa, ROUND(AVG(m.nota), 2) AS media FROM aluno a
JOIN casa c ON a.id_casa = c.id_casa
JOIN matricula m ON a.id_aluno = m.id_aluno GROUP BY a.id_aluno, a.nome, c.nome_casa HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS SELECT p.nome AS professor, COALESCE((SELECT c.nome_casa FROM casa c WHERE c.id_casa = p.id_casa), 'Não é diretor') AS casa_dirigida,
(SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r WHERE r.id_prof = p.id_prof), 0) AS total_pontos_concedidos FROM professor p;

-- Questão 36
-- Placar
SELECT * FROM vw_placar_casas;

-- Boletim apenas dos alunos da Corvinal
SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

-- Total faturado por loja, a partir de vw_extrato_loja
SELECT loja, SUM(valor_total) AS total_faturado FROM vw_extrato_loja GROUP BY loja;

-- Alunos destaque, da maior para a menor média
SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

-- Quadro de professores, do que mais concedeu pontos para o que menos concedeu
SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) 
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas;
-- O que mudou e por quê: a Lufa-Lufa passou de 50 para 70 pontos. A view não guarda dados,
-- ela é só uma consulta salva: toda vez que é consultada, lê a tabela casa atualizada (que o trg_pontos_casa já tinha somado), então não precisa ser recriada.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS SELECT c.nome_casa, c.fundador, c.pontos FROM casa c ORDER BY c.pontos DESC;
SELECT * FROM vw_placar_casas;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
-- Limpeza: garante que o script rode do zero mesmo se os usuários ficaram de uma execução anterior
DROP USER IF EXISTS 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE IF EXISTS 'monitor';

CREATE USER 'filch'@'localhost' IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 41
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44 (executar em uma conexão aberta com o usuário filch)
-- SELECT * FROM hogwarts.vw_placar_casas;
-- SELECT * FROM hogwarts.aluno;
-- Resultado de cada comando: a consulta à view vw_placar_casas funcionou e mostrou o placar, porque o filch tem SELECT nela. O SELECT * FROM aluno foi negado:
-- Error Code: 1142. SELECT command denied to user 'filch'@'localhost' for table 'aluno'

-- Questão 45 (executar em uma conexão aberta com o usuário mcgonagall)
-- INSERT INTO hogwarts.registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;
-- Resultado: o INSERT funcionou e a Grifinória ganhou os 10 pontos. O UPDATE foi negado:
-- Error Code: 1142. UPDATE command denied to user 'mcgonagall'@'localhost' for table 'casa'
-- Como o trigger conseguiu atualizar a casa: o trigger roda com as permissões do DEFINER (o usuário que criou o trigger), e não com as de quem fez o INSERT. Por isso o
-- trg_pontos_casa conseguiu atualizar a tabela casa mesmo a McGonagall não tendo UPDATE nela.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Vantagem dos papéis: as permissões ficam definidas em um lugar só. Para um novo monitor basta
-- atribuir o papel, e qualquer mudança no papel vale para todos os monitores de uma vez, sem precisar dar ou tirar GRANT de cada usuário individualmente.

-- Questão 48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE 'monitor';

