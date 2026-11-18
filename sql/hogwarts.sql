-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno:Ian Shunichi
-- Matrícula:2538587
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

-- ============================================================================
-- ATIVIDADE PRÁTICA: BANCO DE DADOS HOGWARTS
-- ============================================================================

-- Configurações iniciais para execução limpa e sem bloqueios do Workbench
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hogwarts;

SET SQL_SAFE_UPDATES = 0;

-- ============================================================================
-- SEÇÃO 1: PREPARAÇÃO DO AMBIENTE (DDL)
-- ============================================================================

-- 1. Tabela casa (independente)
CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

-- 2. Tabela professor (referencia casa)
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) CHECK (salario > 0),
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

-- 3. Tabela disciplina (referencia professor)
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT CHECK (ano_minimo BETWEEN 1 AND 7),
    id_prof INT,
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

-- 4. Tabela aluno (referencia casa)
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT CHECK (ano_escolar BETWEEN 1 AND 7),
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0 CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

-- 5. Tabela matricula (referencia aluno e disciplina; PK composta)
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);

-- 6. Tabela registro_pontos (referencia aluno e professor)
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_pontos_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_pontos_professor FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

-- 7. Tabela produto (independente)
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) CHECK (preco > 0),
    estoque INT DEFAULT 0 CHECK (estoque >= 0)
);

-- 8. Tabela compra (referencia aluno e produto)
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT CHECK (quantidade > 0),
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- 9. Tabela log_auditoria (independente)
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar (Seção 1):
-- Por que matricula usa chave primária composta em vez de um id próprio? O que poderia acontecer se ela tivesse um id_matricula auto_increment?
-- Resposta: A chave primária composta (id_aluno, id_disc) garante a unicidade da relação, impedindo que um mesmo aluno seja matriculado mais de uma vez na mesma disciplina. Se houvesse apenas um id_matricula AUTO_INCREMENT sem restrição UNIQUE na dupla (id_aluno, id_disc), o banco permitiria duplicar matrículas do mesmo aluno na mesma matéria, gerando inconsistência nas notas e médias.

-- ============================================================================
-- SEÇÃO 1.1: CARGA INICIAL DE DADOS (DML)
-- ============================================================================

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
('Transfiguração',             1, 1),    -- 1
('Poções',                     1, 2),    -- 2
('Feitiços',                   1, 3),    -- 3
('Herbologia',                 1, 4),    -- 4
('Trato das Criaturas Mágicas',3, 5),    -- 5
('Defesa Contra as Artes das Trevas', 1, 6), -- 6
('Adivinhação',                3, 7),    -- 7
('Estudo dos Trouxas',         3, NULL), -- 8
('Runas Antigas',              3, NULL); -- 9

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
('Teddy Lupin',        1, NULL, 0.00); -- 14

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
('Varinha de Azevinho',           'Olivaras',            7.00,  10), -- 1
('Vassoura Nimbus 2001',          'Artigos de Quadribol',300.00, 3), -- 2
('Sapo de Chocolate',             'Dedosdemel',          2.00, 200), -- 3
('Feijõezinhos de Todos os Sabores','Dedosdemel',        1.50, 150), -- 4
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00,  20), -- 5
('Caldeirão de Estanho',          'Caldeirões Potage',   9.00,   0), -- 6
('Kit de Logros',                 'Gemialidades Weasley',25.00, 40), -- 7
('Pena de Repetição Rápida',      'Escribbulus',        15.00,   5); -- 8

-- Confira Seção 1.1:
SELECT 
    (SELECT COUNT(*) FROM casa) AS casas,
    (SELECT COUNT(*) FROM professor) AS professores,
    (SELECT COUNT(*) FROM disciplina) AS disciplinas,
    (SELECT COUNT(*) FROM aluno) AS alunos,
    (SELECT COUNT(*) FROM matricula) AS matriculas,
    (SELECT COUNT(*) FROM produto) AS produtos;


-- ============================================================================
-- SEÇÃO 2: MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- ============================================================================

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
SET nota = LEAST(nota + 0.5, 10.00)
WHERE id_disc IN (
    SELECT id_disc 
    FROM disciplina 
    WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin')
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

-- ============================================================================
-- SEÇÃO 3: REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- ============================================================================

-- Questão 13: Teste de chave estrangeira
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`professor`, CONSTRAINT `fk_professor_casa` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: O banco recusa a exclusão para manter a integridade referencial, pois existem professores (como Severo Snape) e alunos vinculados ao id_casa da Sonserina.

-- Questão 14: Teste de CHECK
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: A tabela aluno possui uma restrição CHECK que exige que o ano_escolar esteja entre 1 e 7. O valor 8 viola essa regra de domínio.

-- Questão 15: Teste de UNIQUE
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: A restrição UNIQUE (uq_aluno_email) impede que dois registros possuam o mesmo endereço de e-mail na tabela aluno.

-- Questão 16: Teste de integridade
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `fk_disciplina_professor` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: Severo Snape está referenciado como chave estrangeira na tabela disciplina (ministra 'Poções'), impedindo sua exclusão enquanto houver disciplinas vinculadas a ele.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: Este comando funciona porque Gilderoy Lockhart não possui nenhum registro filho apontando para o seu id_prof nas tabelas disciplina ou registro_pontos, não violando nenhuma chave estrangeira.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT DISTINCT id_disc FROM matricula);


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa

-- Questão 21 - trg_valida_compra

-- Questão 22 - trg_baixa_compra

-- Questão 23 - trg_situacao_nota

-- Questão 24 - trg_audita_salario

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta:

-- Questão 25 - INSERT registro_pontos

-- Questão 25 - INSERT compra

-- Questão 25 - Rony tenta comprar a Nimbus
-- Resultado:

-- Questão 25 - Hermione tenta comprar o caldeirão
-- Resultado:

-- Questão 25 - Recuperação do Rony em Poções

-- Questão 25 - Salário e data de admissão do Hagrid
-- Linhas em log_auditoria:
-- Por que o reajuste da questão 10 não aparece:


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26

-- Questão 27

-- Questão 28

-- Questão 29

-- Questão 30
-- Resposta:


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1

-- 6.2

-- 6.3

-- 6.4

-- 6.5

-- 6.6

-- ---------- Nível 2: JOINs ----------

-- 6.7
-- Quantos alunos e por quê:

-- 6.8

-- 6.9

-- 6.10

-- 6.11

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12

-- 6.13

-- 6.14

-- 6.15

-- 6.16

-- ---------- Nível 4: subconsultas ----------

-- 6.17

-- 6.18

-- 6.19

-- 6.20

-- 6.21
-- > ANY equivale a:

-- 6.22

-- 6.23

-- 6.24

-- ---------- Nível 5: UNION ALL ----------

-- 6.25

-- 6.26
-- Linhas com UNION ALL:
-- Linhas com UNION:
-- Explicação:

-- 6.27


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31

-- Questão 32

-- Questão 33

-- Questão 34

-- Questão 35

-- Questão 36

-- Questão 37
-- O que mudou e por quê:

-- Questão 38


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39

-- Questão 40

-- Questão 41

-- Questão 42

-- Questão 43

-- Questão 44
-- Resultado de cada comando:

-- Questão 45
-- Como o trigger conseguiu atualizar a casa:

-- Questão 46

-- Questão 47
-- Vantagem dos papéis:

-- Questão 48

