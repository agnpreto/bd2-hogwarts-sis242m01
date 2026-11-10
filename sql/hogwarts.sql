-- ============================================================================
-- ESCOLA DE MAGIA DE HOGWARTS - BD2 (SIS242M01)
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
-- Aluno: Izabelly Cantalice
-- Matrícula: 2421950
-- ============================================================================

DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

SET SQL_SAFE_UPDATES = 0;

-- ============================================================================
-- SEÇÃO 1: DDL e Carga Inicial ( PREPARAÇÃO DO AMBIENTE (DDL)
-- ============================================================================

CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) CHECK (salario > 0),
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT CHECK (ano_minimo BETWEEN 1 AND 7),
    id_prof INT,
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT CHECK (ano_escolar BETWEEN 1 AND 7),
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0 CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);

CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_registro_professor FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) CHECK (preco > 0),
    estoque INT DEFAULT 0 CHECK (estoque >= 0)
);

CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_produto INT,
    quantidade INT CHECK (quantidade > 0),
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar (Seção 1):
-- A tabela matricula usa chave primária composta (id_aluno, id_disc) para garantir que um mesmo aluno
-- não possa ser matriculado mais de uma vez na mesma disciplina. Se ela tivesse apenas um id_matricula
-- auto_increment como chave primária (sem restrição UNIQUE em id_aluno + id_disc), o mesmo aluno
-- poderia ser inserido várias vezes na mesma disciplina, gerando duplicidade de notas no boletim.

-- 1.1. Carga Inicial de Dados (DML)

INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),   -- 1
('Sonserina',  'Salazar Slytherin'),   -- 2
('Corvinal',   'Rowena Ravenclaw'),    -- 3
('Lufa-Lufa',  'Helga Hufflepuff');    -- 4

INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),    -- 1
('Severo Snape',       8800.00, '1981-09-01', 2),    -- 2
('Fílio Flitwick',     8200.00, '1974-09-01', 3),    -- 3
('Pomona Sprout',      7900.00, '1972-09-01', 4),    -- 4
('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL), -- 5
('Remo Lupin',         6200.00, '1993-09-01', NULL), -- 6
('Sibila Trelawney',   5100.00, '1980-09-01', NULL), -- 7
('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL), -- 8
('Horácio Slughorn',   8000.00, '1996-09-01', NULL); -- 9

INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração',                    1, 1),    -- 1
('Poções',                            1, 2),    -- 2
('Feitiços',                          1, 3),    -- 3
('Herbologia',                        1, 4),    -- 4
('Trato das Criaturas Mágicas',       3, 5),    -- 5
('Defesa Contra as Artes das Trevas', 1, 6),    -- 6
('Adivinhação',                       3, 7),    -- 7
('Estudo dos Trouxas',                3, NULL), -- 8
('Runas Antigas',                     3, NULL); -- 9

INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter',       5, 1, 120.00), -- 1
('Hermione Granger',   5, 1,  85.00), -- 2
('Rony Weasley',       5, 1,  12.00), -- 3
('Neville Longbottom', 5, 1,  30.00), -- 4
('Draco Malfoy',       5, 2, 500.00), -- 5
('Pansy Parkinson',    5, 2, 150.00), -- 6
('Vicente Crabbe',     5, 2,  40.00), -- 7
('Luna Lovegood',      4, 3,  45.00), -- 8
('Cho Chang',          6, 3, 200.00), -- 9
('Padma Patil',        5, 3,  60.00), -- 10
('Cedrico Diggory',    7, 4, 180.00), -- 11
('Ana Abbott',         5, 4,  25.00), -- 12
('Ernesto Macmillan',  5, 4,  70.00), -- 13
('Teddy Lupin',        1, NULL, 0.00); -- 14 (ainda não passou pelo Chapéu Seletor)

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
('Varinha de Azevinho',              'Olivaras',             7.00,  10), -- 1
('Vassoura Nimbus 2001',             'Artigos de Quadribol', 300.00, 3), -- 2
('Sapo de Chocolate',                'Dedosdemel',           2.00, 200), -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel',           1.50, 150), -- 4
('Livro Monstruoso dos Monstros',    'Floreios e Borrões',  12.00,  20), -- 5
('Caldeirão de Estanho',             'Caldeirões Potage',    9.00,   0), -- 6
('Kit de Logros',                    'Gemialidades Weasley', 25.00, 40), -- 7
('Pena de Repetição Rápida',         'Escribbulus',         15.00,   5); -- 8

-- ============================================================================
-- SEÇÃO 2: ALTER TABLE e UPDATE (Questões 1 a 12)
-- ============================================================================

-- Q1:
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Q2:
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Q3:
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Q4:
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Q5:
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Q6:
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Q7:
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Q8:
UPDATE matricula
SET nota = LEAST(10.00, nota + 0.5)
WHERE id_disc IN (
    SELECT id_disc
    FROM disciplina
    WHERE id_prof IN (
        SELECT id_prof
        FROM professor
        WHERE nome = 'Remo Lupin'
    )
);

-- Q9:
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6.0 THEN 'Aprovado'
    ELSE 'Reprovado'
END;

-- Q10:
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
  AND data_admissao < '1980-01-01';

-- Q11:
UPDATE produto
SET ativo = 'N'
WHERE estoque = 0;

-- Q12:
UPDATE produto
SET preco = preco * 0.80
WHERE loja = 'Dedosdemel';


-- ============================================================================
-- SEÇÃO 3: DELETE e Testes de Restrições (Questões 13 a 19)
-- Lembre-se: comandos que FALHAM devem ser COMENTADOS com o erro explicado!
-- ============================================================================

-- Q13:
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`professor`, CONSTRAINT `fk_professor_casa` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`)).
-- Explicação: O banco recusa a exclusão porque a casa Sonserina (id_casa = 2) possui registros filhos vinculados por chave estrangeira nas tabelas `professor` (Severo Snape) e `aluno` (Draco, Pansy e Vicente).

-- Q14:
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro 3819 (HY000): Check constraint 'aluno_chk_1' is violated.
-- Explicação: A tabela `aluno` possui uma restrição CHECK (`ano_escolar BETWEEN 1 AND 7`) que impede o cadastro de alunos em anos escolares fora do intervalo de 1 a 7.

-- Q15:
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro 1062 (23000): Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'.
-- Explicação: A restrição UNIQUE `uq_aluno_email` criada na questão 7 impede que dois registros na tabela `aluno` possuam o mesmo endereço de e-mail.

-- Q16:
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `fk_disciplina_professor` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`)).
-- Explicação: O professor Severo Snape (id_prof = 2) está referenciado como chave estrangeira na tabela `disciplina` (Poções), impedindo sua remoção enquanto o vínculo existir.

-- Q17:
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: Este DELETE funciona porque Gilderoy Lockhart (id_prof = 8) não ministra nenhuma disciplina na tabela `disciplina` e não possui registros dependentes em `registro_pontos`.

-- Q18:
DELETE FROM matricula
WHERE id_aluno IN (
    SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe'
);

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Q19:
DELETE FROM disciplina
WHERE id_disc NOT IN (
    SELECT DISTINCT id_disc FROM matricula
);

-- ============================================================================
-- SEÇÃO 4: Triggers (Questões 20 a 25)
-- ============================================================================

-- Q20:
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (
        SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno
    );
END$$
DELIMITER ;

-- Q21:
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo DECIMAL(10,2);

    SELECT preco, estoque INTO v_preco, v_estoque
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Q22:
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

-- Q23:
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        SET NEW.situacao = CASE
            WHEN NEW.nota >= 6.0 THEN 'Aprovado'
            ELSE 'Reprovado'
        END;
    END IF;
END$$
DELIMITER ;

-- Q24:
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario)
        );
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar (Seção 4):
-- A validação da compra precisa ser BEFORE INSERT porque deve verificar estoque e saldo antes de gravar a linha
-- na tabela `compra` e também porque altera `NEW.valor_total` (o que só é permitido em triggers BEFORE).
-- Já a baixa do estoque e o desconto do saldo precisam ser AFTER INSERT para garantir que o estoque e o saldo
-- só sejam reduzidos depois que o registro da compra foi efetivamente validado e gravado com sucesso.

-- Q25:
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito',         '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções',              '2026-09-12'),
( 5, 2,  15, 'Poção do Morto-Vivo impecável',         '2026-09-12'),
( 8, 5,  10, 'Cuidou de um testrálio ferido',         '2026-09-20'),
(11, 4,  25, 'Ajudou os alunos do 1º ano',            '2026-09-25'),
( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia',  '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
( 1, 6,  50, 'Conjurou um Patrono corpóreo',          '2026-10-15'),
( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',     '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor',            '2026-10-31'),
(10, 7,   5, 'Interpretação da bola de cristal',      '2026-11-03'),
(13, 4,  10, 'Colheita de mandrágoras',               '2026-11-05'),
( 3, 9,  10, 'Identificou um bezoar',                 '2026-11-06'),
( 8, 3,  20, 'Resposta brilhante sobre o Diadema',    '2026-11-08'),
( 6, 2,  25, 'Antídoto para venenos comuns',          '2026-11-09'),
( 5, 9,  40, 'Melhor poção do Clube do Slugue',       '2026-11-09');

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

-- Teste 1 (Rony Weasley tenta comprar 1 Vassoura Nimbus 2001 - falha e fica comentado):
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-09');
-- Erro 1644 (45000): Galeões insuficientes no cofre do aluno.
-- Explicação: Rony Weasley possuía 12.00 galeões e gastou 6.00 nos Feijõezinhos, restando 6.00 galeões, valor insuficiente para comprar a Vassoura Nimbus 2001 que custa 300.00 galeões.

-- Teste 2 (Hermione Granger tenta comprar 1 Caldeirão de Estanho - falha e fica comentado):
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-09');
-- Erro 1644 (45000): Estoque insuficiente no Beco Diagonal.
-- Explicação: O produto Caldeirão de Estanho (id_produto = 6) tem estoque igual a 0, sendo bloqueado pelo trigger `trg_valida_compra`.

-- Teste 3 (Recuperação de Poções de Rony Weasley):
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3 AND id_disc = 2;
-- Explicação: O trigger `trg_situacao_nota` recalculou automaticamente a coluna `situacao` de 'Reprovado' para 'Aprovado' ao detectar que a nova nota (6.5) é maior ou igual a 6.

-- Teste 4 (Atualização de salário e data de admissão de Rúbeo Hagrid):
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
-- Explicação: Apareceu apenas 1 linha em `log_auditoria` ('Rúbeo Hagrid: salário de 4500.00 para 5000.00'), pois o segundo UPDATE alterou apenas `data_admissao` (`OLD.salario <> NEW.salario` foi falso). O reajuste da questão 10 não aparece no log porque foi executado na Seção 2, antes da criação do trigger `trg_audita_salario`.


-- ============================================================================
-- SEÇÃO 5: Transações e TCL (Questões 26 a 30)
-- ============================================================================

-- Q26:
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50.00 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50.00 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Q27:
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT id_casa, nome_casa, pontos FROM casa;
ROLLBACK;
SELECT id_casa, nome_casa, pontos FROM casa;
-- Explicação: Sim, o placar voltou integralmente aos valores anteriores (Grifinória 100, Corvinal 50, Lufa-Lufa 35, Sonserina 30), pois o ROLLBACK desfez todas as alterações não confirmadas da transação.

-- Q28:
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
-- Explicação: As alterações feitas pelos triggers (`trg_valida_compra` e `trg_baixa_compra`) fazem parte da mesma transação atômica do comando INSERT que os disparou; portanto, o ROLLBACK também desfez o desconto no saldo de Harry (voltou de 47.00 para 54.00) e a baixa de estoque da varinha (voltou de 8 para 9).

-- Q29:
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Q30:
SELECT @@autocommit;
-- Explicação: O valor retornado 1 significa que o modo autocommit está ativado por padrão na sessão, fazendo com que cada comando SQL fora de um bloco `START TRANSACTION` seja confirmado (COMMIT) automaticamente. Se você executar um comando DDL como `CREATE TABLE` no meio de uma transação aberta no MySQL, o banco realiza um COMMIT implícito antes e depois do `CREATE TABLE`, confirmando permanentemente todas as operações que estavam pendentes na transação.

-- ============================================================================
-- SEÇÃO 6: Consultas (Questões 6.1 a 6.27)
-- ============================================================================

-- Q6.1:
SELECT p.nome AS professor, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- Q6.2:
SELECT a.nome AS aluno, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar ASC, a.nome ASC;

-- Q6.3:
SELECT a.nome AS aluno
FROM aluno a
WHERE a.nome LIKE '_a%';

-- Q6.4:
SELECT d.nome_disc AS disciplina
FROM disciplina d
WHERE d.id_prof IS NULL;

-- Q6.5:
SELECT pr.nome_produto AS produto, pr.preco
FROM produto pr
WHERE pr.preco NOT BETWEEN 5.00 AND 20.00
ORDER BY pr.preco ASC;

-- Q6.6:
SELECT DISTINCT pr.loja
FROM produto pr
ORDER BY pr.loja ASC;

-- Q6.7:
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa ASC, a.nome ASC;
-- Explicação: Aparecem 12 alunos em vez de 13 porque o aluno Teddy Lupin (1º ano) possui `id_casa IS NULL` (ainda não passou pelo Chapéu Seletor), e o `INNER JOIN` retorna apenas registros que possuem correspondência em ambas as tabelas.

-- Q6.8:
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome ASC;

-- Q6.9:
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- Q6.10:
SELECT
    a.nome AS aluno,
    d.nome_disc AS disciplina,
    COALESCE(p.nome, 'Sem professor') AS professor,
    m.nota,
    m.situacao
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
INNER JOIN matricula m ON m.id_aluno = a.id_aluno
INNER JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome ASC, d.nome_disc ASC;

-- Q6.11:
SELECT
    co.id_compra AS numero_compra,
    a.nome AS aluno,
    pr.nome_produto AS produto,
    pr.loja,
    co.quantidade,
    co.valor_total,
    co.data_compra
FROM compra co
INNER JOIN aluno a ON a.id_aluno = co.id_aluno
INNER JOIN produto pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra ASC, co.id_compra ASC;

-- Q6.12:
SELECT
    d.nome_disc AS disciplina,
    COUNT(m.id_aluno) AS qtd_alunos,
    ROUND(AVG(m.nota), 2) AS media_notas,
    MAX(m.nota) AS maior_nota,
    MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7.00
ORDER BY media_notas DESC;

-- Q6.13:
SELECT
    c.nome_casa AS casa,
    COUNT(rp.id_registro) AS qtd_registros,
    SUM(CASE WHEN rp.pontos > 0 THEN rp.pontos ELSE 0 END) AS total_pontos_ganhos,
    SUM(CASE WHEN rp.pontos < 0 THEN rp.pontos ELSE 0 END) AS total_pontos_perdidos,
    SUM(rp.pontos) AS saldo_pontos
FROM casa c
LEFT JOIN aluno a ON a.id_casa = c.id_casa
LEFT JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo_pontos DESC;

-- Q6.14:
SELECT
    pr.loja,
    COUNT(co.id_compra) AS qtd_compras,
    SUM(co.valor_total) AS faturamento
FROM compra co
INNER JOIN produto pr ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20.00
ORDER BY faturamento DESC;

-- Q6.15:
SELECT
    MONTH(rp.data_registro) AS mes,
    COUNT(rp.id_registro) AS qtd_registros,
    SUM(rp.pontos) AS total_pontos
FROM registro_pontos rp
GROUP BY MONTH(rp.data_registro)
ORDER BY mes ASC;

-- Q6.16:
SELECT
    p.nome AS professor,
    COUNT(rp.id_registro) AS qtd_registros,
    SUM(rp.pontos) AS total_concedido
FROM professor p
INNER JOIN registro_pontos rp ON rp.id_prof = p.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(rp.id_registro) >= 2
ORDER BY total_concedido DESC;

-- Q6.17:
SELECT a.nome AS aluno
FROM aluno a
WHERE a.id_aluno IN (
    SELECT co.id_aluno
    FROM compra co
    WHERE co.id_produto IN (
        SELECT pr.id_produto
        FROM produto pr
        WHERE pr.loja = 'Dedosdemel'
    )
);

-- Q6.18:
SELECT pr.nome_produto AS produto, pr.estoque
FROM produto pr
WHERE pr.id_produto NOT IN (
    SELECT DISTINCT co.id_produto FROM compra co
);

-- Q6.19:
SELECT a.nome AS aluno, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (
    SELECT AVG(saldo_galeoes) FROM aluno
)
ORDER BY a.saldo_galeoes DESC;

-- Q6.20:
SELECT p.nome AS professor, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT salario FROM professor WHERE id_casa IS NULL
)
ORDER BY p.salario DESC;

-- Q6.21:
SELECT a.nome AS aluno, a.saldo_galeoes
FROM aluno a
WHERE (a.id_casa IS NULL OR a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina'))
  AND a.saldo_galeoes > ANY (
      SELECT s.saldo_galeoes
      FROM aluno s
      WHERE s.id_casa = (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  );
-- Explicação: O operador `> ANY` equivale a comparar se o valor é maior do que o MENOR valor retornado pela subconsulta (neste caso, maior que 150.00 galeões de Draco Malfoy, retornando Cho Chang com 200.00 e Cedrico Diggory com 180.00).

-- Q6.22:
SELECT c.nome_casa AS casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa
      AND m.nota = 10.00
);

-- Q6.23:
SELECT a.nome AS aluno
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra co
    WHERE co.id_aluno = a.id_aluno
);

-- Q6.24:
SELECT
    c.nome_casa AS casa,
    ROUND(AVG(medias_alunos.media_aluno), 2) AS media_da_casa
FROM (
    SELECT a.id_aluno, a.id_casa, AVG(m.nota) AS media_aluno
    FROM aluno a
    INNER JOIN matricula m ON m.id_aluno = a.id_aluno
    GROUP BY a.id_aluno, a.id_casa
) AS medias_alunos
INNER JOIN casa c ON c.id_casa = medias_alunos.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- Q6.25:
SELECT a.nome, 'Aluno' AS vinculo FROM aluno a
UNION ALL
SELECT p.nome, 'Professor' AS vinculo FROM professor p
ORDER BY nome ASC;

-- Q6.26:
-- Com UNION ALL (retorna 27 linhas):
SELECT a.nome AS aluno
FROM compra co
INNER JOIN aluno a ON a.id_aluno = co.id_aluno
UNION ALL
SELECT a.nome AS aluno
FROM registro_pontos rp
INNER JOIN aluno a ON a.id_aluno = rp.id_aluno;

-- Com UNION (retorna 12 linhas):
SELECT a.nome AS aluno
FROM compra co
INNER JOIN aluno a ON a.id_aluno = co.id_aluno
UNION
SELECT a.nome AS aluno
FROM registro_pontos rp
INNER JOIN aluno a ON a.id_aluno = rp.id_aluno;
-- Explicação: A consulta com `UNION ALL` retornou 27 linhas (10 registros de compra + 17 registros de pontos) porque concatena todos os resultados mantendo linhas repetidas. Já a consulta com `UNION` retornou 12 linhas porque remove automaticamente os nomes duplicados entre as duas listas e dentro de cada uma delas.

-- Q6.27:
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;

-- ============================================================================
-- SEÇÃO 7: Views (Questões 31 a 38)
-- ============================================================================

-- Q31:
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa AS casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Q32:
CREATE OR REPLACE VIEW vw_boletim AS
SELECT
    a.nome AS aluno,
    COALESCE(c.nome_casa, 'Sem casa') AS casa,
    d.nome_disc AS disciplina,
    COALESCE(p.nome, 'Sem professor') AS professor,
    m.nota,
    m.situacao
FROM matricula m
INNER JOIN aluno a ON a.id_aluno = m.id_aluno
LEFT JOIN casa c ON c.id_casa = a.id_casa
INNER JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Q33:
CREATE OR REPLACE VIEW vw_extrato_loja AS
SELECT
    a.nome AS aluno,
    pr.nome_produto AS produto,
    pr.loja,
    co.quantidade,
    co.valor_total,
    co.data_compra
FROM compra co
INNER JOIN aluno a ON a.id_aluno = co.id_aluno
INNER JOIN produto pr ON pr.id_produto = co.id_produto;

-- Q34:
CREATE OR REPLACE VIEW vw_alunos_destaque AS
SELECT
    a.nome AS aluno,
    c.nome_casa AS casa,
    ROUND(AVG(m.nota), 2) AS media_notas
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
INNER JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8.00;

-- Q35:
CREATE OR REPLACE VIEW vw_quadro_professores AS
SELECT
    p.nome AS professor,
    COALESCE((SELECT c.nome_casa FROM casa c WHERE c.id_casa = p.id_casa), 'Não é diretor') AS casa_que_dirige,
    (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
    COALESCE((SELECT SUM(rp.pontos) FROM registro_pontos rp WHERE rp.id_prof = p.id_prof), 0) AS total_pontos_concedidos
FROM professor p;

-- Q36:
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja
ORDER BY total_faturado DESC;

SELECT * FROM vw_alunos_destaque ORDER BY media_notas DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Q37:
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas;
-- Explicação: A Lufa-Lufa subiu de 50 para 70 pontos sem precisar recriar a view porque uma VIEW não armazena dados fisicamente; ela guarda apenas a definição da consulta SQL e lê os dados atualizados diretamente da tabela `casa` toda vez que é consultada.

-- Q38:
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa AS casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;


-- ============================================================================
-- SEÇÃO 8: DCL - Usuários, Privilégios e Papéis (Questões 39 a 48)
-- ============================================================================

-- Q39:
DROP USER IF EXISTS 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost';
CREATE USER 'filch'@'localhost' IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Q40:
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Q41:
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

-- Q42:
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Q43:
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Q44:
SELECT * FROM vw_placar_casas;
-- SELECT * FROM aluno;
-- Erro 1142 (42000): SELECT command denied to user 'filch'@'localhost' for table 'aluno'.
-- Explicação: Conectado como `filch`, a consulta à view `vw_placar_casas` funciona normalmente porque ele recebeu permissão de SELECT sobre essa view na questão 40, mas a consulta direta à tabela `aluno` é negada com o código de erro 1142 por falta de privilégio SELECT na tabela base.

-- Q45:
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');

-- UPDATE casa SET pontos = 1000 WHERE id_casa = 1;
-- Erro 1142 (42000): UPDATE command denied to user 'mcgonagall'@'localhost' for table 'casa'.
-- Explicação: O trigger `trg_pontos_casa` conseguiu atualizar a tabela `casa` porque, no MySQL, triggers são executados por padrão com o contexto de segurança do seu criador (`SQL SECURITY DEFINER`, neste caso o administrador que criou o trigger), e não com as permissões diretas do usuário que disparou o INSERT. Já o comando `UPDATE casa` direto falha porque `mcgonagall` não possui permissão de UPDATE na tabela `casa`.

-- Q46:
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Q47:
DROP ROLE IF EXISTS 'monitor';
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

DROP USER IF EXISTS 'percy'@'localhost';
CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Explicação: A vantagem de usar papéis (roles) é centralizar a administração de permissões: quando vários monitores entram ou saem, ou quando as permissões do cargo mudam, basta alterar o papel `monitor` uma única vez em vez de conceder ou revogar privilégios individualmente em cada conta de usuário.

-- Q48:
DROP USER IF EXISTS 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE IF EXISTS 'monitor';