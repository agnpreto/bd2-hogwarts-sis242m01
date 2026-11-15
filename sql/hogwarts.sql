DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

CREATE TABLE casa(
  id_casa INT AUTO_INCREMENT PRIMARY KEY,
  nome_casa VARCHAR(30) NOT NULL UNIQUE,
  fundador VARCHAR(60),
  pontos INT DEFAULT 0
);

CREATE TABLE professor(
  id_prof INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  salario DECIMAL(10,2) CHECK(salario > 0),
  data_contratacao DATE,
  id_casa INT,
  FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE disciplina(
  id_disc INT AUTO_INCREMENT PRIMARY KEY,
  nome_disc VARCHAR(60) NOT NULL UNIQUE,
  ano_minimo INT CHECK(ano_minimo BETWEEN 1 AND 7),
  id_prof INT,
  FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE aluno(
  id_aluno INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  ano_escolar INT CHECK(ano_escolar BETWEEN 1 AND 7),
  id_casa INT,
  saldo_galeoes DECIMAL(10,2) DEFAULT 0 CHECK(saldo_galeoes >= 0),
  FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE matricula(
  id_aluno INT,
  id_disc INT,
  nota DECIMAL(4,2) CHECK(nota BETWEEN 0 AND 10),
  PRIMARY KEY (id_aluno, id_disc),
  FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
  FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);

CREATE TABLE registro_pontos(
  id_registro INT AUTO_INCREMENT PRIMARY KEY,
  id_aluno INT NOT NULL,
  id_prof INT NOT NULL,
  pontos INT NOT NULL,
  motivo VARCHAR(150),
  data_registro DATE NOT NULL,
  FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
  FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE produto(
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  nome_produto VARCHAR(100) NOT NULL,
  loja VARCHAR(50) NOT NULL,
  preco DECIMAL(10,2) CHECK(preco > 0),
  estoque INT DEFAULT 0 CHECK(estoque >= 0)
);

CREATE TABLE compra(
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_aluno INT,
  id_produto INT,
  quantidade INT CHECK(quantidade > 0),
  valor_total DECIMAL(10,2),
  data_compra DATE NOT NULL,
  FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

CREATE TABLE log_auditoria(
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  tabela VARCHAR(30),
  operacao VARCHAR(10),
  descricao VARCHAR(255),
  data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),  -- 1
('Sonserina',  'Salazar Slytherin'),  -- 2
('Corvinal',   'Rowena Ravenclaw'),   -- 3
('Lufa-Lufa',  'Helga Hufflepuff');   -- 4

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
('Transfiguração', 1, 1),                      -- 1
('Poções', 1, 2),                              -- 2
('Feitiços', 1, 3),                            -- 3
('Herbologia', 1, 4),                          -- 4
('Trato das Criaturas Mágicas', 3, 5),         -- 5
('Defesa Contra as Artes das Trevas', 1, 6),   -- 6
('Adivinhação', 3, 7),                         -- 7
('Estudo dos Trouxas', 3, NULL),               -- 8
('Runas Antigas', 3, NULL);                    -- 9

INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter',       5, 1, 120.00),  -- 1
('Hermione Granger',   5, 1,  85.00),  -- 2
('Rony Weasley',       5, 1,  12.00),  -- 3
('Neville Longbottom', 5, 1,  30.00),  -- 4
('Draco Malfoy',       5, 2, 500.00),  -- 5
('Pansy Parkinson',    5, 2, 150.00),  -- 6
('Vicente Crabbe',     5, 2,  40.00),  -- 7
('Luna Lovegood',      4, 3,  45.00),  -- 8
('Cho Chang',          6, 3, 200.00),  -- 9
('Padma Patil',        5, 3,  60.00),  -- 10
('Cedrico Diggory',    7, 4, 180.00),  -- 11
('Ana Abbott',         5, 4,  25.00),  -- 12
('Ernesto Macmillan',  5, 4,  70.00),  -- 13
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
('Varinha de Azevinho',              'Olivaras',              7.00,  10),  -- 1
('Vassoura Nimbus 2001',             'Artigos de Quadribol',  300.00, 3),  -- 2
('Sapo de Chocolate',                'Dedosdemel',            2.00, 200),  -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel',            1.50, 150),  -- 4
('Livro Monstruoso dos Monstros',    'Floreios e Borrões',   12.00,  20),  -- 5
('Caldeirão de Estanho',             'Caldeirões Potage',     9.00,   0),  -- 6
('Kit de Logros',                    'Gemialidades Weasley', 25.00,  40),  -- 7
('Pena de Repetição Rápida',         'Escribbulus',          15.00,   5); -- 8

SELECT 'casa' AS tabela, COUNT(*) AS total FROM casa
UNION ALL SELECT 'professor',  COUNT(*) FROM professor
UNION ALL SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL SELECT 'aluno',      COUNT(*) FROM aluno
UNION ALL SELECT 'matricula',  COUNT(*) FROM matricula
UNION ALL SELECT 'produto',    COUNT(*) FROM produto;

SET SQL_SAFE_UPDATES = 0;
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
-- Questão 6
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');
-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);
-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc FROM disciplina
    WHERE id_prof IN (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin')
);

-- Questão 9
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;
-- Questão 10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
  AND data_admissao < '1980-01-01';
-- Questão 11
UPDATE produto SET ativo = 'N' WHERE estoque = 0;
-- Questão 12
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';

-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`aluno`, CONSTRAINT `aluno_ibfk_1` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: a casa Sonserina é referenciada por alunos (e por um professor) através da chave estrangeira id_casa. O banco não deixa apagar a linha "pai" enquanto existirem linhas "filhas" apontando para ela, para não deixar registros órfãos.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: a coluna ano_escolar tem um CHECK que só aceita valores entre 1 e 7. O 8º ano viola essa regra, então o banco recusa o cadastro.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: a restrição UNIQUE uq_aluno_email não permite dois alunos com o mesmo e-mail, e esse e-mail já pertence ao Harry Potter verdadeiro.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `disciplina_ibfk_1` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: Snape é o professor da disciplina Poções, que o referencia pela chave estrangeira id_prof. Enquanto houver disciplina apontando para ele, o banco não permite a exclusão.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: este funciona porque nenhuma outra tabela referencia Lockhart (ele não ministra nenhuma disciplina nem tem registros de pontos). Sem linhas filhas, não há violação de chave estrangeira. O Snape não podia ser excluído porque a disciplina Poções dependia dele.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Questão 20
DELIMITER //
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END//
DELIMITER ;

-- Questão 21
DELIMITER //
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);

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
END//
DELIMITER ;

-- Questão 22
DELIMITER //
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
END//
DELIMITER ;

-- Questão 23
DELIMITER //
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NOT (NEW.nota <=> OLD.nota) THEN
        SET NEW.situacao = CASE WHEN NEW.nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;
    END IF;
END//
DELIMITER ;

-- Questão 24
DELIMITER //
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END//
DELIMITER ;

-- Questão 25
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

-- Questão 25 (testes dos triggers)

-- Teste 1: Rony Weasley (id 3) tenta comprar 1 Vassoura Nimbus 2001 (id 2)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-10');
-- Error Code: 1644. Galeões insuficientes no cofre do aluno
-- Explicação: a Nimbus tem estoque, mas custa 300 galeões e o Rony tem 12. O trigger trg_valida_compra (BEFORE INSERT) compara o saldo com preço x quantidade e bloqueia a compra com SIGNAL SQLSTATE '45000'.

-- Teste 2: Hermione Granger (id 2) tenta comprar 1 Caldeirão de Estanho (id 6)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-10');
-- Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- Explicação: a Hermione tem saldo, mas o Caldeirão tem estoque 0. O trigger verifica o estoque primeiro e bloqueia a compra.

-- Teste 3: recuperação do Rony em Poções, sem mexer em situacao
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- Explicação: a nota passou de 4.5 para 6.5 e a situacao mudou sozinha de 'Reprovado' para 'Aprovado', porque o trigger trg_situacao_nota (BEFORE UPDATE) recalcula a situação sempre que a nota muda.

-- Teste 4: salário e depois data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Explicação: apareceu 1 linha em log_auditoria. Só o primeiro UPDATE mudou o salário, então o trigger trg_audita_salario (condição OLD.salario <> NEW.salario) gravou o log. O segundo UPDATE alterou apenas a data_admissao, o salário continuou igual e nada foi gravado. O reajuste da questão 10 não aparece no log porque, naquele momento, o trigger ainda não existia: ele só foi criado na seção 4, depois da questão 10.

-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;
ROLLBACK;
SELECT nome_casa, pontos FROM casa;
-- Resposta: sim, o placar voltou. Dentro da transação todas as casas ficaram com 0 pontos, mas o ROLLBACK desfez a alteração e os pontos anteriores foram restaurados.

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
-- Resposta: as alterações feitas pelo trigger (baixa do estoque e desconto do saldo) também foram desfeitas. O trigger roda dentro da mesma transação do INSERT, então o ROLLBACK desfaz a compra e tudo o que o trigger fez. O saldo do Harry voltou a 54.00 e o estoque da varinha a 9.

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO sp_pontos_legitimos;
COMMIT;

-- Questão 30
SELECT @@autocommit;
-- Resposta: o valor 1 significa que o autocommit está ligado: cada comando é confirmado automaticamente assim que executa, a não ser que se abra uma transação com START TRANSACTION. Se um CREATE TABLE for executado no meio de uma transação aberta, o MySQL faz um commit implícito antes do comando (comandos DDL não podem ser desfeitos), então tudo o que estava pendente é confirmado e um ROLLBACK posterior não desfaz mais nada.

-- Questão 6.1
SELECT nome, salario
FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- Questão 6.2
SELECT nome, ano_escolar
FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar;

-- Questão 6.3
SELECT nome
FROM aluno
WHERE nome LIKE '_a%';

-- Questão 6.4
SELECT nome_disc
FROM disciplina
WHERE id_prof IS NULL;

-- Questão 6.5
SELECT nome_produto, preco
FROM produto
WHERE preco NOT BETWEEN 5 AND 20
ORDER BY preco;

-- Questão 6.6
SELECT DISTINCT loja
FROM produto
ORDER BY loja;

-- Questão 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
ORDER BY c.nome_casa, a.nome;
-- Resposta: aparecem 12 alunos. Não são 13 porque o Teddy Lupin ainda não tem casa (id_casa é NULL), e o INNER JOIN só retorna linhas que têm correspondência nas duas tabelas.

-- Questão 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa
ORDER BY a.nome;

-- Questão 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- Questão 6.10
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       p.nome AS professor,
       m.nota,
       m.situacao
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN matricula m ON m.id_aluno = a.id_aluno
INNER JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- Questão 6.11
SELECT c.id_compra AS numero_compra,
       a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       c.quantidade,
       c.valor_total,
       c.data_compra
FROM compra c
INNER JOIN aluno a ON a.id_aluno = c.id_aluno
INNER JOIN produto p ON p.id_produto = c.id_produto
ORDER BY c.data_compra, c.id_compra;

-- Questão 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- Questão 6.13
SELECT c.nome_casa AS casa,
       COUNT(r.id_registro) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo
FROM casa c
INNER JOIN aluno a ON a.id_casa = c.id_casa
INNER JOIN registro_pontos r ON r.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa;

-- Questão 6.14
SELECT p.loja,
       COUNT(c.id_compra) AS qtd_compras,
       SUM(c.valor_total) AS faturamento
FROM compra c
INNER JOIN produto p ON p.id_produto = c.id_produto
GROUP BY p.loja
HAVING SUM(c.valor_total) > 20
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
       COUNT(r.id_registro) AS qtd_registros,
       SUM(r.pontos) AS total_concedido
FROM registro_pontos r
INNER JOIN professor p ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;

-- Questão 6.17
SELECT nome
FROM aluno
WHERE id_aluno IN (
    SELECT id_aluno FROM compra
    WHERE id_produto IN (
        SELECT id_produto FROM produto WHERE loja = 'Dedosdemel'
    )
);

-- Questão 6.18
SELECT nome_produto, estoque
FROM produto
WHERE id_produto NOT IN (SELECT id_produto FROM compra);

-- Questão 6.19
SELECT nome, saldo_galeoes
FROM aluno
WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- Questão 6.20
SELECT nome, salario
FROM professor
WHERE salario > ALL (SELECT salario FROM professor WHERE id_casa IS NULL);

-- Questão 6.21
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  AND saldo_galeoes > ANY (
      SELECT saldo_galeoes FROM aluno
      WHERE id_casa = (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  );
-- Resposta: > ANY equivale a comparar com o menor valor da subconsulta. Basta o saldo ser maior que o de algum sonserino, ou seja, maior que o do sonserino mais pobre.

-- Questão 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa AND m.nota = 10
);

-- Questão 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1 FROM compra c WHERE c.id_aluno = a.id_aluno
);

-- Questão 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(t.media_aluno), 2) AS media_casa
FROM (
    SELECT id_aluno, AVG(nota) AS media_aluno
    FROM matricula
    GROUP BY id_aluno
) t
INNER JOIN aluno a ON a.id_aluno = t.id_aluno
INNER JOIN casa c ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_casa DESC;

-- Questão 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- Questão 6.26
SELECT a.nome FROM aluno a INNER JOIN compra c ON c.id_aluno = a.id_aluno
UNION ALL
SELECT a.nome FROM aluno a INNER JOIN registro_pontos r ON r.id_aluno = a.id_aluno;

SELECT a.nome FROM aluno a INNER JOIN compra c ON c.id_aluno = a.id_aluno
UNION
SELECT a.nome FROM aluno a INNER JOIN registro_pontos r ON r.id_aluno = a.id_aluno;
-- Resposta: o UNION ALL retornou 27 linhas e o UNION retornou 12. O UNION ALL mantém todas as linhas, inclusive as repetidas (um aluno com várias compras e vários registros aparece várias vezes). O UNION elimina as duplicatas e devolve cada nome uma vez só.

-- Questão 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;

-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
INNER JOIN aluno a ON a.id_aluno = m.id_aluno
INNER JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN casa c ON c.id_casa = a.id_casa
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       c.quantidade,
       c.valor_total,
       c.data_compra
FROM compra c
INNER JOIN aluno a ON a.id_aluno = c.id_aluno
INNER JOIN produto p ON p.id_produto = c.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
INNER JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       (SELECT COALESCE(SUM(r.pontos), 0) FROM registro_pontos r WHERE r.id_prof = p.id_prof) AS total_pontos_concedidos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questão 36
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja;

SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT * FROM vw_placar_casas;
-- Resposta: a Lufa-Lufa passou de 50 para 70 pontos. A view não guarda dados, ela guarda apenas a consulta. Cada vez que é consultada, executa o SELECT de novo sobre a tabela casa, que já foi atualizada pelo trigger trg_pontos_casa. Por isso o novo placar aparece sem precisar recriar a view.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 39
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
SHOW FULL TABLES IN hogwarts WHERE Table_type = 'VIEW';

-- Questão 44
-- (conectado como filch)
-- SELECT * FROM vw_placar_casas;
-- Resultado: funcionou e mostrou o placar das 4 casas.
-- SELECT * FROM aluno;
-- Error Code: 1142. SELECT command denied to user 'filch'@'localhost' for table 'aluno'
-- Explicação: o filch só recebeu SELECT na view vw_placar_casas. Ele não tem permissão sobre a tabela aluno, então o banco nega o acesso.

-- Questão 45
-- (conectado como mcgonagall)
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');

-- UPDATE casa SET pontos = 1000 WHERE id_casa = 1;
-- Error Code: 1142. UPDATE command denied to user 'mcgonagall'@'localhost' for table 'casa'
-- Explicação: a McGonagall não tem permissão de UPDATE na tabela casa, então o banco nega o comando.
-- Resposta: o trigger trg_pontos_casa roda com os privilégios do usuário que o criou (o definer, aqui o root), e não com os de quem disparou o INSERT. Por isso ele consegue atualizar a tabela casa, mesmo que a McGonagall não tenha esse direito.

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
-- Resposta: com o papel, as permissões são definidas uma vez só e atribuídas a cada monitor com um único GRANT. Se as permissões mudarem, basta alterar o papel e todos os monitores são atualizados. Dar as permissões direto para cada usuário exigiria repetir os comandos para cada monitor e corrigir um por um a cada mudança.

-- Questão 48
DROP USER 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE 'monitor';
