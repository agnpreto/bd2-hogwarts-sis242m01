-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Renison Carlos Brilhante Ribeiro Júnior 
-- Matrícula:2535023
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
        id_casa INT AUTO_INCREMENT PRIMARY KEY,
            nome_casa VARCHAR(30) NOT NULL UNIQUE,
                fundador VARCHAR(60),
                    pontos INT DEFAULT 0
                    );


-- Tabela professor
CREATE TABLE professor (
        id_prof INT AUTO_INCREMENT PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
                salario DECIMAL(10,2),
                    data_contratacao DATE,
                        id_casa INT,
                            CONSTRAINT chk_professor_salario CHECK (salario > 0),
                                CONSTRAINT fk_professor_casa
                                        FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
                                        );


-- Tabela disciplina
CREATE TABLE disciplina (
        id_disc INT AUTO_INCREMENT PRIMARY KEY,
            nome_disc VARCHAR(60) NOT NULL UNIQUE,
                ano_minimo INT,
                    id_prof INT,
                        CONSTRAINT chk_disciplina_ano
                                CHECK (ano_minimo BETWEEN 1 AND 7),
                                    CONSTRAINT fk_disciplina_professor
                                            FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
                                            );







-- Tabela aluno

CREATE TABLE aluno (
        id_aluno INT AUTO_INCREMENT PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
                ano_escolar INT,
                    id_casa INT,
                        saldo_galeoes DECIMAL(10,2) DEFAULT 0,
                            CONSTRAINT chk_aluno_ano
                                    CHECK (ano_escolar BETWEEN 1 AND 7),
                                        CONSTRAINT chk_aluno_saldo
                                                CHECK (saldo_galeoes >= 0),
                                                    CONSTRAINT fk_aluno_casa
                                                            FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
                                                            );


-- Tabela matricula

CREATE TABLE matricula (
        id_aluno INT,
            id_disc INT,
                nota DECIMAL(4,2),
                    PRIMARY KEY (id_aluno, id_disc),
                        CONSTRAINT chk_matricula_nota
                                CHECK (nota BETWEEN 0 AND 10),
                                    CONSTRAINT fk_matricula_aluno
                                            FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
                                                CONSTRAINT fk_matricula_disciplina
                                                        FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
                                                        );

-- Tabela registro_pontos

CREATE TABLE registro_pontos (
        id_registro INT AUTO_INCREMENT PRIMARY KEY,
            id_aluno INT NOT NULL,
                id_prof INT NOT NULL,
                    pontos INT NOT NULL,
                        motivo VARCHAR(150),
                            data_registro DATE NOT NULL,
                                CONSTRAINT fk_registro_aluno
                                        FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
                                            CONSTRAINT fk_registro_professor
                                                    FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
                                                    );




-- Tabela produto
CREATE TABLE produto (
        id_produto INT AUTO_INCREMENT PRIMARY KEY,
            nome_produto VARCHAR(100) NOT NULL,
                loja VARCHAR(50) NOT NULL,
                    preco DECIMAL(10,2),
                        estoque INT DEFAULT 0,
                            CONSTRAINT chk_produto_preco CHECK (preco > 0),
                                CONSTRAINT chk_produto_estoque CHECK (estoque >= 0)
                                );




-- Tabela compra

CREATE TABLE compra (
        id_compra INT AUTO_INCREMENT PRIMARY KEY,
            id_aluno INT,
                id_produto INT,
                    quantidade INT,
                        valor_total DECIMAL(10,2),
                            data_compra DATE NOT NULL,
                                CONSTRAINT chk_compra_quantidade CHECK (quantidade > 0),
                                    CONSTRAINT fk_compra_aluno
                                            FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
                                                CONSTRAINT fk_compra_produto
                                                        FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
                                                        );




-- Tabela log_auditoria
CREATE TABLE log_auditoria (
        id_log INT AUTO_INCREMENT PRIMARY KEY,
            tabela VARCHAR(30),
                operacao VARCHAR(10),
                    descricao VARCHAR(255),
                        data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
                        );









-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta:
-- A chave primária composta impede que o mesmo aluno seja matriculado
-- duas vezes na mesma disciplina. Se fosse usado apenas um id próprio,
-- seria necessária uma restrição UNIQUE para impedir matrículas duplicadas.



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
INSERT INTO professor
(nome, salario, data_contratacao, id_casa) VALUES
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
INSERT INTO aluno
(nome, ano_escolar, id_casa, saldo_galeoes) VALUES
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
ALTER TABLE aluno
ADD COLUMN email VARCHAR(100);


-- Questão 2
ALTER TABLE matricula
ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 3
ALTER TABLE produto
ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 4
ALTER TABLE casa
MODIFY COLUMN fundador VARCHAR(100);
-- Questão 5
ALTER TABLE professor
RENAME COLUMN data_contratacao TO data_admissao;
-- Questão 6
UPDATE aluno
SET email = LOWER(
    CONCAT(REPLACE(nome, ' ', '.'), '@hogwarts.edu')
    );

-- Questão 7
ALTER TABLE aluno
ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc
        FROM disciplina
            WHERE id_prof = (
                    SELECT id_prof
                            FROM professor
                                    WHERE nome = 'Remo Lupin'
                                        )
                                        );

-- Questão 9
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6 THEN 'Aprovado'
        ELSE 'Reprovado'
        END;

-- Questão 10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
AND data_admissao < '1980-01-01';

-- Questão 11
UPDATE produto
SET ativo = 'N'
WHERE estoque = 0;

-- Questão 12
UPDATE produto
SET preco = preco * 0.80
WHERE loja = 'Dedosdemel';




-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================

-- Questão 13
-- DELETE FROM casa
-- WHERE nome_casa = 'Sonserina';
-- Erro:
-- Código: 1451
-- Mensagem: Cannot delete or update a parent row:
-- a foreign key constraint fails.
-- Explicação:
-- A casa não pode ser excluída porque existem
-- alunos e professores vinculados a ela.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa)
-- VALUES ('Dobby', 8, 1);
-- Erro:
-- Código: 3819
-- Mensagem: Check constraint
-- 'chk_aluno_ano' is violated.
-- Explicação:
-- O ano escolar deve estar entre 1 e 7,
-- conforme a restrição CHECK da tabela aluno.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1,
-- 'harry.potter@hogwarts.edu');
-- Erro:
-- Código: 1062
-- Mensagem: Duplicate entry
-- 'harry.potter@hogwarts.edu' for key 'uq_aluno_email'.
-- Explicação:
-- O e-mail já pertence ao Harry Potter,
-- violando a restrição UNIQUE da tabela aluno.

-- Questão 16
-- DELETE FROM professor
-- WHERE nome = 'Severo Snape';
-- Erro:
-- Código: 1451
-- Mensagem: Cannot delete or update a parent row:
-- a foreign key constraint fails.
-- Explicação:
-- Snape não pode ser excluído porque existem
-- disciplinas vinculadas a ele por chave estrangeira,
-- como a disciplina de Poções.

-- Questão 17
DELETE FROM professor
WHERE nome = 'Gilderoy Lockhart';

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (
    SELECT id_aluno
    FROM aluno
    WHERE nome = 'Vicente Crabbe'
);

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (
    SELECT id_disc
    FROM matricula
);


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$

CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (
        SELECT id_casa
        FROM aluno
        WHERE id_aluno = NEW.id_aluno
    );
END$$

DELIMITER ;

-- Questão 21 - trg_valida_compra
DELIMITER $$

CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo DECIMAL(10,2);

    SELECT preco, estoque
    INTO v_preco, v_estoque
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes
    INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < v_preco * NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$

DELIMITER ;

-- Questão 22 - trg_baixa_compra
DELIMITER $$

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

DELIMITER ;

-- Questão 23 - trg_situacao_nota
DELIMITER $$

CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        SET NEW.situacao = CASE
            WHEN NEW.nota >= 6 THEN 'Aprovado'
            ELSE 'Reprovado'
        END;
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
        INSERT INTO log_auditoria
        (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(
                NEW.nome,
                ': salário de ',
                OLD.salario,
                ' para ',
                NEW.salario
            )
        );
    END IF;
END$$

DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta:
-- A validação é BEFORE porque verifica o estoque e
-- o saldo antes de permitir a compra.
-- A baixa é AFTER porque desconta o estoque e
-- o saldo depois que a compra é registrada.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(2, 3, 20, 'Feitiço de levitação perfeito', '2026-09-10'),
(1, 2, -10, 'Atraso na aula de Poções', '2026-09-12'),
(5, 2, 15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
(8, 5, 10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
(4, 4, 30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
(6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
(1, 6, 50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
(9, 3, 15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
(5, 1, -30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'Colheita de mandrágoras', '2026-11-05'),
(3, 9, 10, 'Identificou um bezoar', '2026-11-06'),
(8, 3, 20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
(6, 2, 25, 'Antídoto para venenos comuns', '2026-11-09'),
(5, 9, 40, 'Melhor poção do Clube do Slugue', '2026-11-09');

-- Questão 25 - INSERT compra
INSERT INTO compra
(id_aluno, id_produto, quantidade, data_compra)
VALUES
(5, 2, 1, '2026-09-01'),
(2, 5, 2, '2026-09-02'),
(1, 3, 10, '2026-09-03'),
(3, 4, 5, '2026-09-03'),
(9, 8, 1, '2026-09-15'),
(8, 5, 1, '2026-09-20'),
(11, 1, 1, '2026-10-01'),
(6, 3, 20, '2026-10-10'),
(1, 7, 2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra
-- (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado:
-- Erro: 1644, SQLSTATE 45000.
-- Galeões insuficientes no cofre do aluno.
-- Rony não possui saldo para comprar a Nimbus.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra
-- (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado:
-- Erro: 1644, SQLSTATE 45000.
-- Estoque insuficiente no Beco Diagonal.
-- O caldeirão possui estoque zero.

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3
AND id_disc = 2;

SELECT nota, situacao
FROM matricula
WHERE id_aluno = 3
AND id_disc = 2;

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor
SET salario = 5000.00
WHERE nome = 'Rúbeo Hagrid';

UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rúbeo Hagrid';

SELECT * FROM log_auditoria;

-- Linhas em log_auditoria:
-- Resultado: 1 linha.
-- Apenas a alteração do salário gera registro.

-- Por que o reajuste da questão 10 não aparece:
-- Porque aconteceu antes da criação do trigger.
-- O trigger não registra alterações anteriores.


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;

UPDATE aluno
SET saldo_galeoes = saldo_galeoes - 50
WHERE nome = 'Draco Malfoy';

UPDATE aluno
SET saldo_galeoes = saldo_galeoes + 50
WHERE nome = 'Pansy Parkinson';

COMMIT;

SELECT nome, saldo_galeoes
FROM aluno
WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 27
START TRANSACTION;

UPDATE casa
SET pontos = 0;

SELECT nome_casa, pontos
FROM casa;

ROLLBACK;

SELECT nome_casa, pontos
FROM casa;

-- Questão 28
START TRANSACTION;

INSERT INTO compra
(id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');

SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno = 1;

SELECT nome_produto, estoque
FROM produto
WHERE id_produto = 1;

ROLLBACK;

SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno = 1;

SELECT nome_produto, estoque
FROM produto
WHERE id_produto = 1;

-- Questão 29
START TRANSACTION;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;

COMMIT;

SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

SELECT COUNT(*) AS total_registros
FROM registro_pontos;

-- Questão 30
SELECT @@autocommit;

-- Resposta:
-- O valor 1 indica que o autocommit está ativado,
-- confirmando automaticamente os comandos fora
-- de uma transação explícita.
-- O valor 0 indica que o autocommit está desativado.
-- Um CREATE TABLE provoca um COMMIT implícito,
-- confirmando a transação aberta antes de criar
-- a tabela, mesmo sem executar COMMIT manualmente.


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
SELECT d.nome_disc
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
INNER JOIN casa c
ON a.id_casa = c.id_casa
ORDER BY c.nome_casa, a.nome;

-- Quantos alunos e por quê:
-- Aparecem 12 alunos porque Teddy Lupin ainda
-- não possui casa e o INNER JOIN não inclui
-- registros sem correspondência entre as tabelas.

-- 6.8
SELECT a.nome AS aluno,
COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c
ON a.id_casa = c.id_casa
ORDER BY a.nome;

-- 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p
ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno,
d.nome_disc AS disciplina,
p.nome AS professor,
m.nota,
m.situacao
FROM casa c
INNER JOIN aluno a
ON c.id_casa = a.id_casa
INNER JOIN matricula m
ON a.id_aluno = m.id_aluno
INNER JOIN disciplina d
ON m.id_disc = d.id_disc
LEFT JOIN professor p
ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT cp.id_compra AS numero_compra,
a.nome AS aluno,
p.nome_produto AS produto,
p.loja,
cp.quantidade,
cp.valor_total,
cp.data_compra AS data
FROM compra cp
INNER JOIN aluno a
ON cp.id_aluno = a.id_aluno
INNER JOIN produto p
ON cp.id_produto = p.id_produto
ORDER BY cp.data_compra, cp.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS quantidade_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m
ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa AS casa,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN ABS(r.pontos) ELSE 0 END) AS pontos_perdidos,
       COALESCE(SUM(r.pontos), 0) AS saldo
FROM casa c
LEFT JOIN aluno a
ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos r
ON a.id_aluno = r.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo DESC;

-- 6.14
SELECT p.loja,
       COUNT(cp.id_compra) AS quantidade_compras,
       SUM(cp.valor_total) AS faturamento
FROM compra cp
INNER JOIN produto p
ON cp.id_produto = p.id_produto
GROUP BY p.loja
HAVING SUM(cp.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS quantidade_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome AS professor,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(r.pontos) AS total_concedido
FROM professor p
INNER JOIN registro_pontos r
ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT a.nome AS aluno
FROM aluno a
WHERE a.id_aluno IN (
    SELECT c.id_aluno
    FROM compra c
    WHERE c.id_produto IN (
        SELECT p.id_produto
        FROM produto p
        WHERE p.loja = 'Dedosdemel'
    )
)
ORDER BY a.nome;

-- 6.18
SELECT p.nome_produto, p.estoque
FROM produto p
WHERE p.id_produto NOT IN (
    SELECT c.id_produto
    FROM compra c
    WHERE c.id_produto IS NOT NULL
)
ORDER BY p.nome_produto;

-- 6.19
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (
    SELECT AVG(a2.saldo_galeoes)
    FROM aluno a2
)
ORDER BY a.saldo_galeoes DESC;

-- 6.20
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT p2.salario
    FROM professor p2
    WHERE p2.id_casa IS NULL
)
ORDER BY p.salario DESC;

-- 6.21
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.id_casa <> (
    SELECT c.id_casa
    FROM casa c
    WHERE c.nome_casa = 'Sonserina'
)
AND a.saldo_galeoes > ANY (
    SELECT a2.saldo_galeoes
    FROM aluno a2
    WHERE a2.id_casa = (
        SELECT c2.id_casa
        FROM casa c2
        WHERE c2.nome_casa = 'Sonserina'
    )
)
ORDER BY a.saldo_galeoes DESC;

-- > ANY equivale a:
-- Comparar com o menor valor da subconsulta.
-- Basta que o saldo seja maior que pelo menos
-- um dos valores retornados.


-- 6.22
SELECT c.nome_casa AS casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m
    ON a.id_aluno = m.id_aluno
    WHERE a.id_casa = c.id_casa
    AND m.nota = 10
)
ORDER BY c.nome_casa;

-- 6.23
SELECT a.nome AS aluno
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra c
    WHERE c.id_aluno = a.id_aluno
)
ORDER BY a.nome;

-- 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(med.media_aluno), 2) AS media_casa
FROM casa c
INNER JOIN aluno a
ON c.id_casa = a.id_casa
INNER JOIN (
    SELECT m.id_aluno,
           AVG(m.nota) AS media_aluno
    FROM matricula m
    GROUP BY m.id_aluno
) med
ON a.id_aluno = med.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------


-- 6.25
SELECT a.nome AS nome, 'Aluno' AS vinculo
FROM aluno a
UNION ALL
SELECT p.nome AS nome, 'Professor' AS vinculo
FROM professor p
ORDER BY nome;

-- 6.26
SELECT a.nome AS aluno
FROM aluno a
INNER JOIN compra c
ON a.id_aluno = c.id_aluno
UNION ALL
SELECT a.nome AS aluno
FROM aluno a
INNER JOIN registro_pontos r
ON a.id_aluno = r.id_aluno;

SELECT a.nome AS aluno
FROM aluno a
INNER JOIN compra c
ON a.id_aluno = c.id_aluno
UNION
SELECT a.nome AS aluno
FROM aluno a
INNER JOIN registro_pontos r
ON a.id_aluno = r.id_aluno;

-- Linhas com UNION ALL:
-- 27 linhas.

-- Linhas com UNION:
-- 12 linhas.

-- Explicação:
-- UNION ALL mantém os registros repetidos,
-- enquanto UNION elimina as duplicações.
-- Por isso, UNION ALL retorna 27 linhas
-- e UNION retorna apenas 12.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador,
       SUM(r.pontos) AS valor
FROM registro_pontos r

UNION ALL

SELECT 'Total de galeões gastos na loja' AS indicador,
       SUM(c.valor_total) AS valor
FROM compra c

UNION ALL

SELECT 'Folha salarial dos professores' AS indicador,
       SUM(p.salario) AS valor
FROM professor p

UNION ALL

SELECT 'Total de galeões nos cofres' AS indicador,
       SUM(a.saldo_galeoes) AS valor
FROM aluno a;



-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT c.nome_casa, c.pontos
FROM casa c
ORDER BY c.pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT
    a.nome AS aluno,
    COALESCE(c.nome_casa, 'Sem casa') AS casa,
    d.nome_disc AS disciplina,
    COALESCE(p.nome, 'Sem professor') AS professor,
    m.nota,
    m.situacao
FROM matricula m
INNER JOIN aluno a
ON m.id_aluno = a.id_aluno
LEFT JOIN casa c
ON a.id_casa = c.id_casa
INNER JOIN disciplina d
ON m.id_disc = d.id_disc
LEFT JOIN professor p
ON d.id_prof = p.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT
    a.nome AS aluno,
    p.nome_produto AS produto,
    p.loja,
    cp.quantidade,
    cp.valor_total,
    cp.data_compra AS data
FROM compra cp
INNER JOIN aluno a
ON cp.id_aluno = a.id_aluno
INNER JOIN produto p
ON cp.id_produto = p.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT
    a.nome AS aluno,
    c.nome_casa AS casa,
    ROUND(AVG(m.nota), 2) AS media
FROM aluno a
INNER JOIN casa c
ON a.id_casa = c.id_casa
INNER JOIN matricula m
ON a.id_aluno = m.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT
    p.nome AS professor,
    COALESCE(c.nome_casa, 'Não é diretor') AS casa,
    (
        SELECT COUNT(*)
        FROM disciplina d
        WHERE d.id_prof = p.id_prof
    ) AS quantidade_disciplinas,
    (
        SELECT COALESCE(SUM(r.pontos), 0)
        FROM registro_pontos r
        WHERE r.id_prof = p.id_prof
    ) AS total_pontos
FROM professor p
LEFT JOIN casa c
ON p.id_casa = c.id_casa;

-- Questão 36
SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;

SELECT *
FROM vw_boletim
WHERE casa = 'Corvinal';

SELECT loja,
       SUM(valor_total) AS faturamento
FROM vw_extrato_loja
GROUP BY loja
ORDER BY faturamento DESC;

SELECT *
FROM vw_alunos_destaque
ORDER BY media DESC;

SELECT *
FROM vw_quadro_professores
ORDER BY total_pontos DESC;

-- Questão 37
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;

-- O que mudou e por quê:
-- A Lufa-Lufa passou de 50 para 70 pontos.
-- O trigger atualizou a pontuação da casa
-- quando os pontos de Cedrico foram registrados.
-- A view mostra os dados atualizados automaticamente,
-- sem precisar ser criada novamente.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT
    c.nome_casa,
    c.fundador,
    c.pontos
FROM casa c
ORDER BY c.pontos DESC;

SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================

-- Questão 39
CREATE USER 'filch'@'localhost'
IDENTIFIED BY 'MadameNorra#1';

CREATE USER 'mcgonagall'@'localhost'
IDENTIFIED BY 'Animago#Gato1';

CREATE USER 'dumbledore'@'localhost'
IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas
TO 'filch'@'localhost';

-- Questão 41
GRANT SELECT, INSERT ON hogwarts.registro_pontos
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.aluno
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.vw_boletim
TO 'mcgonagall'@'localhost';

-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.*
TO 'dumbledore'@'localhost'
WITH GRANT OPTION;

-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';

SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44
-- Executar conectado como filch:
-- SELECT * FROM hogwarts.vw_placar_casas;
-- SELECT * FROM hogwarts.aluno;

-- Resultado de cada comando:
-- O primeiro SELECT funciona porque Filch
-- recebeu permissão para consultar a view.
-- O segundo SELECT falha com o erro 1142,
-- SELECT command denied, porque Filch
-- não possui permissão na tabela aluno.

-- Questão 45
-- Executar conectado como mcgonagall:
-- INSERT INTO hogwarts.registro_pontos
-- (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES
-- (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');

-- UPDATE hogwarts.casa
-- SET pontos = 1000
-- WHERE id_casa = 1;

-- O INSERT funciona e a Grifinória
-- passa de 100 para 110 pontos.
-- O UPDATE falha com o erro 1142,
-- UPDATE command denied.

-- Como o trigger conseguiu atualizar a casa:
-- O trigger executa com os privilégios
-- do usuário que o definiu.
-- Por isso, a atualização da casa funciona
-- mesmo sem McGonagall ter permissão de UPDATE.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos
FROM 'mcgonagall'@'localhost';

SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47
CREATE ROLE 'monitor';

GRANT SELECT ON hogwarts.vw_boletim
TO 'monitor';

GRANT SELECT ON hogwarts.vw_placar_casas
TO 'monitor';

CREATE USER 'percy'@'localhost'
IDENTIFIED BY 'Monitor#Chefe1';

GRANT 'monitor'
TO 'percy'@'localhost';

SET DEFAULT ROLE 'monitor'
TO 'percy'@'localhost';

-- Vantagem dos papéis:
-- Os papéis agrupam permissões.
-- Assim, vários usuários podem receber
-- as mesmas permissões de uma só vez.

-- Questão 48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';

DROP ROLE 'monitor';


