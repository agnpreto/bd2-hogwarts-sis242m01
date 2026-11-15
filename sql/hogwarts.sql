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