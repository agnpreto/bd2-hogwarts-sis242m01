-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Harrison Ambrozio
-- Matrícula: 2534655
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

DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts CHARACTER SET utf8mb4;
USE hogwarts;

CREATE TABLE casa (
    id_casa   INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador  VARCHAR(60),
    pontos    INT DEFAULT 0
);

CREATE TABLE professor (
    id_prof          INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    salario          DECIMAL(10,2),
    data_contratacao DATE,
    id_casa          INT,
    CONSTRAINT ck_prof_salario CHECK (salario > 0),
    CONSTRAINT fk_prof_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

CREATE TABLE disciplina (
    id_disc    INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc  VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof    INT,
    CONSTRAINT ck_disc_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disc_prof FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

CREATE TABLE aluno (
    id_aluno      INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    ano_escolar   INT,
    id_casa       INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT ck_aluno_ano   CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT ck_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa  FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT ck_matr_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matr_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_matr_disc  FOREIGN KEY (id_disc)  REFERENCES disciplina (id_disc)
);

CREATE TABLE registro_pontos (
    id_registro   INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno      INT NOT NULL,
    id_prof       INT NOT NULL,
    pontos        INT NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_reg_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_reg_prof  FOREIGN KEY (id_prof)  REFERENCES professor (id_prof)
);

CREATE TABLE produto (
    id_produto   INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja         VARCHAR(50) NOT NULL,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    CONSTRAINT ck_prod_preco   CHECK (preco > 0),
    CONSTRAINT ck_prod_estoque CHECK (estoque >= 0)
);

CREATE TABLE compra (
    id_compra   INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno    INT,
    id_produto  INT,
    quantidade  INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT ck_compra_qtd CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno   FOREIGN KEY (id_aluno)   REFERENCES aluno (id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

CREATE TABLE log_auditoria (
    id_log    INT AUTO_INCREMENT PRIMARY KEY,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar: por que matricula usa PK composta?
-- R: a PK composta (id_aluno, id_disc) garante que o mesmo aluno não seja
--    matriculado duas vezes na mesma disciplina. Com um id_matricula
--    auto_increment, o banco aceitaria linhas duplicadas (mesmo aluno +
--    mesma disciplina, com notas diferentes), a menos que se criasse
--    também uma restrição UNIQUE(id_aluno, id_disc).

-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================

INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),   -- 1
('Sonserina',  'Salazar Slytherin'),   -- 2
('Corvinal',   'Rowena Ravenclaw'),    -- 3
('Lufa-Lufa',  'Helga Hufflepuff');    -- 4

INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1), -- 1
('Severo Snape',       8800.00, '1981-09-01', 2), -- 2
('Fílio Flitwick',     8200.00, '1974-09-01', 3), -- 3
('Pomona Sprout',      7900.00, '1972-09-01', 4), -- 4
('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL), -- 5
('Remo Lupin',         6200.00, '1993-09-01', NULL), -- 6
('Sibila Trelawney',   5100.00, '1980-09-01', NULL), -- 7
('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL), -- 8
('Horácio Slughorn',   8000.00, '1996-09-01', NULL); -- 9

INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração', 1, 1),                  -- 1
('Poções', 1, 2),                          -- 2
('Feitiços', 1, 3),                        -- 3
('Herbologia', 1, 4),                      -- 4
('Trato das Criaturas Mágicas', 3, 5),     -- 5
('Defesa Contra as Artes das Trevas', 1, 6), -- 6
('Adivinhação', 3, 7),                     -- 7
('Estudo dos Trouxas', 3, NULL),           -- 8
('Runas Antigas', 3, NULL);                -- 9

INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter', 5, 1, 120.00),       -- 1
('Hermione Granger', 5, 1, 85.00),    -- 2
('Rony Weasley', 5, 1, 12.00),        -- 3
('Neville Longbottom', 5, 1, 30.00),  -- 4
('Draco Malfoy', 5, 2, 500.00),       -- 5
('Pansy Parkinson', 5, 2, 150.00),    -- 6
('Vicente Crabbe', 5, 2, 40.00),      -- 7
('Luna Lovegood', 4, 3, 45.00),       -- 8
('Cho Chang', 6, 3, 200.00),          -- 9
('Padma Patil', 5, 3, 60.00),         -- 10
('Cedrico Diggory', 7, 4, 180.00),    -- 11
('Ana Abbott', 5, 4, 25.00),          -- 12
('Ernesto Macmillan', 5, 4, 70.00),   -- 13
('Teddy Lupin', 1, NULL, 0.00);       -- 14 (ainda não passou pelo Chapéu Seletor)

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

INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),                    -- 1
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),      -- 2
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),                   -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),    -- 4
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20), -- 5
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),           -- 6
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),             -- 7
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);            -- 8

-- Confira: 4 casas, 9 professores, 9 disciplinas, 14 alunos, 35 matrículas, 8 produtos
SELECT (SELECT COUNT(*) FROM casa) AS casas,
       (SELECT COUNT(*) FROM professor) AS professores,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM aluno) AS alunos,
       (SELECT COUNT(*) FROM matricula) AS matriculas,
       (SELECT COUNT(*) FROM produto) AS produtos;


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 2.1 (1)
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);
-- Questão 2.1 (2)
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
-- Questão 2.1 (3)
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';
-- Questão 2.1 (4)
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);
-- Questão 2.1 (5)
ALTER TABLE professor CHANGE COLUMN data_contratacao data_admissao DATE;

DESC aluno; DESC matricula; DESC produto; DESC casa; DESC professor;

-- Questão 2.2 (6)
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 2.2 (7)
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 2.2 (8)  Bônus do Prof. Lupin (limitado a 10)
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (SELECT id_disc FROM disciplina
                  WHERE id_prof = (SELECT id_prof FROM professor
                                   WHERE nome = 'Remo Lupin'));

-- Questão 2.2 (9)
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;

-- Questão 2.2 (10)
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

-- Questão 2.2 (11)
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 2.2 (12)
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';

-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================

-- Questão 3.13 (DEVE FALHAR - erro 1451)
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Por quê: há alunos e professores (FK id_casa) que referenciam a Sonserina;
-- a integridade referencial impede deixar registros "órfãos".

-- Questão 3.14 (DEVE FALHAR - erro 3819, CHECK violada)
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Dobby', 8, 1, 0, 'dobby@hogwarts.edu');
-- Por quê: ano_escolar só aceita valores de 1 a 7.

-- Questão 3.15 (DEVE FALHAR - erro 1062, entrada duplicada)
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0, 'harry.potter@hogwarts.edu');
-- Por quê: uq_aluno_email proíbe e-mails repetidos.

-- Questão 3.16 (DEVE FALHAR - erro 1451)
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Por quê: Snape é referenciado por disciplina (Poções) e por registro_pontos (FK).

-- Questão 3.17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Funciona porque nenhuma disciplina nem registro de pontos referencia
-- o Lockhart (id 8): não há filhos dependentes dele.

-- Questão 3.18  (filhos primeiro, depois o pai)
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 3.19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT DISTINCT id_disc FROM matricula);

-- Confira: 8 professores, 13 alunos, 8 disciplinas, 33 matrículas
SELECT (SELECT COUNT(*) FROM professor) AS professores,
       (SELECT COUNT(*) FROM aluno) AS alunos,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM matricula) AS matriculas;


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
DELIMITER $$

-- Questão 4.20
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$

-- Questão 4.21
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco
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

-- Questão 4.22
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

-- Questão 4.23
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NOT (NEW.nota <=> OLD.nota) THEN
        SET NEW.situacao = CASE WHEN NEW.nota >= 6 THEN 'Aprovado'
                                ELSE 'Reprovado' END;
    END IF;
END$$

-- Questão 4.24
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(OLD.nome, ': salário de ', OLD.salario,
                       ' para ', NEW.salario));
    END IF;
END$$

DELIMITER ;

-- Pergunta para pensar: BEFORE x AFTER
-- R: a validação precisa ser BEFORE porque só assim é possível barrar a
--    compra (SIGNAL) e preencher NEW.valor_total ANTES de a linha ser
--    gravada. A baixa do estoque/saldo é AFTER porque só deve acontecer
--    depois que a compra foi validada e efetivamente gravada.

-- Questão 4.25 (registro_pontos)
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito', '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções', '2026-09-12'),
( 5, 2,  15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
( 8, 5,  10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4,  25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
( 1, 6,  50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
( 9, 3,  15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7,   5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4,  10, 'Colheita de mandrágoras', '2026-11-05'),
( 3, 9,  10, 'Identificou um bezoar', '2026-11-06'),
( 8, 3,  20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
( 6, 2,  25, 'Antídoto para venenos comuns', '2026-11-09'),
( 5, 9,  40, 'Melhor poção do Clube do Slugue', '2026-11-09');

-- Questão 4.25 (compra) - valor_total é calculado pelo trigger
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

-- Teste A: Rony tenta comprar 1 Nimbus 2001 (DEVE FALHAR)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: 'Galeões insuficientes no cofre do aluno' (saldo ~6.00 < 300.00).

-- Teste B: Hermione tenta comprar 1 Caldeirão de Estanho (DEVE FALHAR)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: 'Estoque insuficiente no Beco Diagonal' (estoque 0). O estoque é
-- verificado primeiro, por isso essa mensagem aparece (Hermione tem saldo).

-- Teste C: recuperação de Poções do Rony (sem mexer em situacao)
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT * FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- A situação virou 'Aprovado' automaticamente (trg_situacao_nota).

-- Teste D: salário do Hagrid e depois data_admissao
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Aparece 1 linha: o 2º UPDATE não alterou o salário (OLD.salario = NEW.salario).
-- O reajuste da questão 10 não aparece porque foi feito ANTES de o trigger
-- trg_audita_salario ser criado.

-- Confira: placar, saldos, estoques e total de compras
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno IN (1,5);
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2,3);
SELECT SUM(valor_total) AS soma_compras FROM compra;    -- 474.00
SELECT COUNT(*) AS linhas_log FROM log_auditoria;       -- 1


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 5.26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Questão 5.27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;      -- tudo zerado
ROLLBACK;
SELECT nome_casa, pontos FROM casa;      -- placar voltou ao normal

-- Questão 5.28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;          -- 47.00
SELECT estoque FROM produto WHERE id_produto = 1;            -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;          -- 54.00
SELECT estoque FROM produto WHERE id_produto = 1;            -- 9
-- Os UPDATEs feitos pelo trigger fazem parte da mesma transação, então o
-- ROLLBACK também os desfez (saldo e estoque voltaram ao valor anterior).

-- Questão 5.29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Questão 5.30
SELECT @@autocommit;
-- 1 = autocommit LIGADO: cada comando é confirmado automaticamente, a menos
-- que se abra uma transação com START TRANSACTION.
-- Um CREATE TABLE (DDL) causa COMMIT IMPLÍCITO: a transação aberta é
-- confirmada antes do comando e não pode mais ser desfeita com ROLLBACK.

-- Confira: placar Grifinória 100, Corvinal 50, Lufa-Lufa 50, Sonserina 30
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS linhas_registro FROM registro_pontos;   -- 17

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================


-- ---- Nível 1 ----
-- Questão 6.1
SELECT nome, salario FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- Questão 6.2
SELECT nome, ano_escolar FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar;

-- Questão 6.3
SELECT nome FROM aluno WHERE nome LIKE '_a%';

-- Questão 6.4
SELECT nome_disc FROM disciplina WHERE id_prof IS NULL;

-- Questão 6.5
SELECT nome_produto, preco FROM produto
WHERE preco NOT BETWEEN 5 AND 20
ORDER BY preco;

-- Questão 6.6
SELECT DISTINCT loja FROM produto ORDER BY loja;

-- ---- Nível 2 ----
-- Questão 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- 12 alunos: Teddy Lupin tem id_casa NULL e o INNER JOIN descarta quem não
-- tem correspondência na outra tabela.

-- Questão 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- Questão 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- Questão 6.10
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

-- Questão 6.11
SELECT co.id_compra AS numero_compra,
       a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a   ON a.id_aluno   = co.id_aluno
JOIN produto p ON p.id_produto = co.id_produto
ORDER BY co.data_compra, co.id_compra;

-- ---- Nível 3 ----
-- Questão 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(*) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- Questão 6.13
SELECT c.nome_casa AS casa,
       COUNT(*) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END)  AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN -r.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo
FROM registro_pontos r
JOIN aluno a ON a.id_aluno = r.id_aluno
JOIN casa c  ON c.id_casa  = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo DESC;

-- Questão 6.14
SELECT p.loja,
       COUNT(*) AS qtd_compras,
       SUM(co.valor_total) AS faturamento
FROM compra co
JOIN produto p ON p.id_produto = co.id_produto
GROUP BY p.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- Questão 6.15
SELECT MONTH(data_registro) AS mes,
       COUNT(*) AS qtd_registros,
       SUM(pontos) AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes;

-- Questão 6.16
SELECT p.nome AS professor,
       COUNT(*) AS qtd_registros,
       SUM(r.pontos) AS total_concedido
FROM registro_pontos r
JOIN professor p ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_concedido DESC;

-- ---- Nível 4 ----
-- Questão 6.17
SELECT nome FROM aluno
WHERE id_aluno IN (SELECT id_aluno FROM compra
                   WHERE id_produto IN (SELECT id_produto FROM produto
                                        WHERE loja = 'Dedosdemel'));

-- Questão 6.18
SELECT nome_produto, estoque FROM produto
WHERE id_produto NOT IN (SELECT id_produto FROM compra);

-- Questão 6.19
SELECT nome, saldo_galeoes FROM aluno
WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- Questão 6.20
SELECT nome, salario FROM professor
WHERE salario > ALL (SELECT salario FROM professor WHERE id_casa IS NULL);

-- Questão 6.21
SELECT nome, saldo_galeoes FROM aluno
WHERE (id_casa IS NULL OR id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina'))
  AND saldo_galeoes > ANY (SELECT saldo_galeoes FROM aluno
                           WHERE id_casa = (SELECT id_casa FROM casa
                                            WHERE nome_casa = 'Sonserina'));
-- > ANY equivale a comparar com o MENOR valor da subconsulta: basta ser maior
-- que ALGUM sonserino, ou seja, maior que o que tem menos galeões.

-- Questão 6.22
SELECT c.nome_casa FROM casa c
WHERE EXISTS (SELECT 1
              FROM aluno a
              JOIN matricula m ON m.id_aluno = a.id_aluno
              WHERE a.id_casa = c.id_casa AND m.nota = 10);

-- Questão 6.23
SELECT a.nome FROM aluno a
WHERE NOT EXISTS (SELECT 1 FROM compra co WHERE co.id_aluno = a.id_aluno);

-- Questão 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(t.media_aluno), 2) AS media_da_casa
FROM (SELECT id_aluno, AVG(nota) AS media_aluno
      FROM matricula
      GROUP BY id_aluno) t
JOIN aluno a ON a.id_aluno = t.id_aluno
JOIN casa c  ON c.id_casa  = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- ---- Nível 5 ----
-- Questão 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- Questão 6.26
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION ALL
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);
-- 27 linhas

SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);
-- 12 linhas
-- UNION ALL mantém todas as linhas (inclusive repetidas); UNION remove
-- duplicatas, então quem aparece nas duas consultas conta só uma vez.

-- Questão 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;

-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 7.31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 7.32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
JOIN aluno a       ON a.id_aluno = m.id_aluno
JOIN disciplina d  ON d.id_disc  = m.id_disc
LEFT JOIN casa c   ON c.id_casa  = a.id_casa
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 7.33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a   ON a.id_aluno   = co.id_aluno
JOIN produto p ON p.id_produto = co.id_produto;

-- Questão 7.34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN matricula m ON m.id_aluno = a.id_aluno
LEFT JOIN casa c ON c.id_casa  = a.id_casa
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 7.35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*) FROM disciplina d
         WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       (SELECT COALESCE(SUM(r.pontos), 0) FROM registro_pontos r
         WHERE r.id_prof = p.id_prof) AS total_pontos_concedidos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questão 7.36
SELECT * FROM vw_placar_casas;
SELECT * FROM vw_boletim WHERE casa = 'Corvinal';
SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja GROUP BY loja ORDER BY total_faturado DESC;
SELECT * FROM vw_alunos_destaque ORDER BY media DESC;
SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 7.37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT * FROM vw_placar_casas;
-- A Lufa-Lufa passou a 70. A view não guarda dados: é uma consulta salva,
-- reexecutada a cada uso; o trigger atualizou casa.pontos e a view reflete isso.

-- Questão 7.38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;
SELECT * FROM vw_placar_casas;



-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 8.39
CREATE USER 'filch'@'localhost'       IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost'  IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost'  IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 8.40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 8.41
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno       TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim  TO 'mcgonagall'@'localhost';

-- Questão 8.42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 8.43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 8.44 (em uma conexão como filch)
-- SELECT * FROM hogwarts.vw_placar_casas;   -- funciona
-- SELECT * FROM hogwarts.aluno;             -- ERRO 1142: SELECT command denied

-- Questão 8.45 (em uma conexão como mcgonagall)
-- INSERT INTO hogwarts.registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;   -- NEGADO
-- Como o trigger conseguiu? Triggers executam com os privilégios do DEFINER
-- (quem os criou, aqui o administrador), e não do usuário que disparou o
-- INSERT. A McGonagall só precisa de INSERT em registro_pontos.

-- Para manter a conferência (Grifinória = 110) rodando só como administrador:
-- INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');

-- Questão 8.46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 8.47
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim      TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';
CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Vantagem dos papéis: as permissões são definidas uma vez e atribuídas a
-- vários usuários; mudar o papel atualiza todos os monitores de uma vez, o
-- que facilita a administração e reduz erros.

-- Questão 8.48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE 'monitor';
