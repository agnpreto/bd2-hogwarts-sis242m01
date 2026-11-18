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
-- 1: PREPARAÇÃO DO AMBIENTE (DDL)
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
-- 2: MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
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
-- 3: REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
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


-- ============================================================================
--  4: TRIGGERS
-- ============================================================================

-- Questão 20: Taça das Casas
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21: Validação da compra
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

-- Questão 22: Baixa da compra
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

-- Questão 23: Situação automática
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota >= 6 THEN
        SET NEW.situacao = 'Aprovado';
    ELSE
        SET NEW.situacao = 'Reprovado';
    END IF;
END$$
DELIMITER ;

-- Questão 24: Auditoria de salário
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
-- Por que a validação da compra precisa ser BEFORE e a baixa do estoque precisa ser AFTER?
-- Resposta: A validação precisa ser BEFORE INSERT para interceptar a operação antes de o registro ser gravado no banco, permitindo calcular o valor_total (NEW.valor_total) e abortar a inserção via SIGNAL caso não haja saldo ou estoque. Já a baixa de estoque e saldo deve ser AFTER INSERT para garantir que os recursos só sejam descontados depois que a compra passou por todas as restrições da tabela e foi efetivamente confirmada/gravada.

-- 4.1. Testando os triggers

-- Questão 25
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

-- Testes de validação (Questão 25):
-- Teste 1: Rony Weasley (id 3) tenta comprar 1 Vassoura Nimbus 2001 (id 2)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-10');
-- Erro: Error Code: 1644. Galeões insuficientes no cofre do aluno
-- Explicação: O trigger trg_valida_compra bloqueou a inserção porque Rony possui apenas 6.00 galeões de saldo restante e a vassoura custa 300.00 galeões.

-- Teste 2: Hermione Granger (id 2) tenta comprar 1 Caldeirão de Estanho (id 6)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-10');
-- Erro: Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- Explicação: O trigger trg_valida_compra bloqueou a inserção porque o estoque do Caldeirão de Estanho é 0.

-- Teste 3: Recuperação de Poções do Rony (id_aluno = 3, id_disc = 2)
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3 AND id_disc = 2;

SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- Explicação: A coluna situacao mudou automaticamente de 'Reprovado' para 'Aprovado' por ação do trigger trg_situacao_nota.

-- Teste 4: Atualização de salário e admissão de Rúbeo Hagrid
UPDATE professor
SET salario = 5000.00
WHERE nome = 'Rúbeo Hagrid';

UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rúbeo Hagrid';

SELECT * FROM log_auditoria;
-- Explicação: Apareceu apenas 1 linha em log_auditoria (referente à alteração do salário de 4500.00 para 5000.00). A alteração da data_admissao não gerou log porque o trigger verifica IF OLD.salario <> NEW.salario. O reajuste da questão 10 também não aparece porque o trigger trg_audita_salario ainda não havia sido criado quando a questão 10 foi executada.


-- ============================================================================
-- SEÇÃO 5: CONTROLE DE TRANSAÇÕES (TCL): O BANCO GRINGOTES
-- ============================================================================

-- Questão 26: Transferência confirmada
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50.00 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50.00 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Questão 27: O Pirraça atacou
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT * FROM casa;
ROLLBACK;
SELECT * FROM casa;
-- Explicação: Sim, o placar voltou aos valores originais porque o comando ROLLBACK desfez todas as alterações realizadas dentro da transação aberta antes de um COMMIT.

-- Questão 28: Trigger dentro da transação
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
-- Explicação: Todas as alterações executadas pelos triggers (baixa no estoque da varinha e desconto no saldo de Harry) também foram desfeitas pelo ROLLBACK, pois triggers executam dentro do mesmo contexto transacional do comando que os disparou.

-- Questão 29: SAVEPOINT
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Questão 30: Pergunta conceitual
SELECT @@autocommit;
-- Explicação: O valor 1 significa que o modo autocommit está ativado (cada instrução SQL isolada é confirmada automaticamente como uma transação própria assim que executada). Se você executar um comando DDL (como CREATE TABLE, ALTER TABLE ou DROP TABLE) no meio de uma transação aberta, o MySQL realiza um COMMIT implícito automático antes de executar o comando DDL, confirmando permanentemente tudo o que foi feito na transação até aquele ponto.


-- ============================================================================
--  6: DESAFIOS DE CONSULTA 
-- ============================================================================

-- Nível 1: Filtros e operadores especiais

-- Questão 6.1: Faixa salarial (BETWEEN)
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- Questão 6.2: Anos selecionados (IN)
SELECT a.nome, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar ASC;

-- Questão 6.3: Busca por padrão (LIKE com _)
SELECT a.nome
FROM aluno a
WHERE a.nome LIKE '_a%';

-- Questão 6.4: Disciplina órfã (IS NULL)
SELECT d.nome_disc, d.ano_minimo
FROM disciplina d
WHERE d.id_prof IS NULL;

-- Questão 6.5: Fora da faixa (NOT BETWEEN)
SELECT pr.nome_produto, pr.preco
FROM produto pr
WHERE pr.preco NOT BETWEEN 5.00 AND 20.00
ORDER BY pr.preco ASC;

-- Questão 6.6: Lojas do Beco Diagonal (DISTINCT)
SELECT DISTINCT pr.loja
FROM produto pr
ORDER BY pr.loja ASC;


-- Nível 2: JOINs

-- Questão 6.7: Quem é de qual casa (INNER JOIN)
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
ORDER BY c.nome_casa ASC, a.nome ASC;
-- Explicação: Aparecem 12 alunos (e não 13) porque o INNER JOIN retorna apenas registros com correspondência nas duas tabelas; o aluno Teddy Lupin possui id_casa NULL (ainda não passou pelo Chapéu Seletor) e fica de fora.

-- Questão 6.8: Todos os alunos (LEFT JOIN)
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa;

-- Questão 6.9: Professor sem turma (RIGHT JOIN)
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- Questão 6.10: Boletim da Grifinória (JOIN com 5 tabelas)
SELECT 
    a.nome AS aluno,
    d.nome_disc AS disciplina,
    COALESCE(p.nome, 'Sem professor') AS professor,
    m.nota,
    m.situacao
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN matricula m ON a.id_aluno = m.id_aluno
INNER JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome ASC, d.nome_disc ASC;

-- Questão 6.11: Extrato do Beco Diagonal (JOIN com 3 tabelas)
SELECT 
    co.id_compra AS numero_compra,
    a.nome AS aluno,
    pr.nome_produto AS produto,
    pr.loja,
    co.quantidade,
    co.valor_total,
    co.data_compra
FROM compra co
INNER JOIN aluno a ON co.id_aluno = a.id_aluno
INNER JOIN produto pr ON co.id_produto = pr.id_produto
ORDER BY co.data_compra ASC, co.id_compra ASC;


-- Nível 3: Agrupamento e funções de agregação

-- Questão 6.12: Desempenho por disciplina
SELECT 
    d.nome_disc AS disciplina,
    COUNT(m.id_aluno) AS qtd_alunos,
    ROUND(AVG(m.nota), 2) AS media_notas,
    MAX(m.nota) AS maior_nota,
    MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media_notas DESC;

-- Questão 6.13: Livro-razão da Taça
SELECT 
    c.nome_casa AS casa,
    COUNT(rp.id_registro) AS qtd_registros,
    COALESCE(SUM(CASE WHEN rp.pontos > 0 THEN rp.pontos ELSE 0 END), 0) AS pontos_ganhos,
    COALESCE(SUM(CASE WHEN rp.pontos < 0 THEN rp.pontos ELSE 0 END), 0) AS pontos_perdidos,
    COALESCE(SUM(rp.pontos), 0) AS saldo_pontos
FROM casa c
LEFT JOIN aluno a ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno
GROUP BY c.id_casa, c.nome_casa;

-- Questão 6.14: Faturamento por loja
SELECT 
    pr.loja,
    COUNT(co.id_compra) AS qtd_compras,
    SUM(co.valor_total) AS faturamento
FROM produto pr
INNER JOIN compra co ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- Questão 6.15: Pontos por mês
SELECT 
    MONTH(rp.data_registro) AS mes,
    COUNT(rp.id_registro) AS qtd_registros,
    SUM(rp.pontos) AS total_pontos
FROM registro_pontos rp
GROUP BY MONTH(rp.data_registro)
ORDER BY mes ASC;

-- Questão 6.16: Professores mais ativos
SELECT 
    p.nome AS professor,
    COUNT(rp.id_registro) AS qtd_registros,
    SUM(rp.pontos) AS total_concedido
FROM professor p
INNER JOIN registro_pontos rp ON p.id_prof = rp.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(rp.id_registro) >= 2
ORDER BY total_concedido DESC;


-- Nível 4: Subconsultas (IN, NOT IN, escalar, ALL, ANY, EXISTS, FROM)

-- Questão 6.17: Clientes da Dedosdemel (IN)
SELECT a.nome
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

-- Questão 6.18: Encalhados (NOT IN)
SELECT pr.nome_produto, pr.estoque
FROM produto pr
WHERE pr.id_produto NOT IN (
    SELECT DISTINCT co.id_produto
    FROM compra co
);

-- Questão 6.19: Cofres cheios (subconsulta escalar)
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (
    SELECT AVG(saldo_galeoes) FROM aluno
);

-- Questão 6.20: Acima de todos (ALL)
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT salario
    FROM professor
    WHERE id_casa IS NULL
);

-- Questão 6.21: Mais rico que algum sonserino (ANY)
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  AND a.saldo_galeoes > ANY (
      SELECT saldo_galeoes
      FROM aluno
      WHERE id_casa = (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  );
-- Explicação: O operador > ANY equivale a comparar com o MENOR valor retornado pela subconsulta (basta que o saldo seja maior que o do aluno mais pobre da Sonserina para a condição ser verdadeira).

-- Questão 6.22: Casas com nota máxima (EXISTS)
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON a.id_aluno = m.id_aluno
    WHERE a.id_casa = c.id_casa
      AND m.nota = 10
);

-- Questão 6.23: Nunca foram ao Beco (NOT EXISTS)
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra co
    WHERE co.id_aluno = a.id_aluno
);

-- Questão 6.24: Média das médias (subconsulta no FROM)
SELECT 
    c.nome_casa AS casa,
    ROUND(AVG(medias_alunos.media_aluno), 2) AS media_casa
FROM (
    SELECT a.id_casa, AVG(m.nota) AS media_aluno
    FROM aluno a
    INNER JOIN matricula m ON a.id_aluno = m.id_aluno
    WHERE a.id_casa IS NOT NULL
    GROUP BY a.id_aluno, a.id_casa
) AS medias_alunos
INNER JOIN casa c ON medias_alunos.id_casa = c.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_casa DESC;


-- Nível 5: UNION ALL

-- Questão 6.25: Diretório de Hogwarts
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome ASC;

-- Questão 6.26: UNION x UNION ALL
SELECT a.nome
FROM aluno a
INNER JOIN compra co ON a.id_aluno = co.id_aluno
UNION ALL
SELECT a.nome
FROM aluno a
INNER JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno;

SELECT a.nome
FROM aluno a
INNER JOIN compra co ON a.id_aluno = co.id_aluno
UNION
SELECT a.nome
FROM aluno a
INNER JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno;
-- Explicação: A consulta com UNION ALL retornou 27 linhas, enquanto a consulta com UNION retornou 12 linhas. A diferença ocorre porque o UNION ALL mantém todas as ocorrências (inclusive duplicatas de alunos que fizeram várias compras ou receberam pontos várias vezes), enquanto o UNION elimina automaticamente as linhas duplicadas, retornando apenas nomes distintos.

-- Questão 6.27: Painel do Diretor
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja' AS indicador, SUM(valor_total) AS valor FROM compra
UNION ALL
SELECT 'Folha salarial dos professores' AS indicador, SUM(salario) AS valor FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos' AS indicador, SUM(saldo_galeoes) AS valor FROM aluno;

-- ============================================================================
-- 7: VIEWS
-- ============================================================================

-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa AS casa, pontos
FROM casa
ORDER BY pontos DESC;

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
INNER JOIN aluno a ON m.id_aluno = a.id_aluno
LEFT JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT 
    a.nome AS aluno,
    pr.nome_produto AS produto,
    pr.loja,
    co.quantidade,
    co.valor_total,
    co.data_compra
FROM compra co
INNER JOIN aluno a ON co.id_aluno = a.id_aluno
INNER JOIN produto pr ON co.id_produto = pr.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT 
    a.nome AS aluno,
    COALESCE(c.nome_casa, 'Sem casa') AS casa,
    ROUND(AVG(m.nota), 2) AS media_notas
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN matricula m ON a.id_aluno = m.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT 
    p.nome AS professor,
    COALESCE((SELECT c.nome_casa FROM casa c WHERE c.id_casa = p.id_casa), 'Não é diretor') AS casa_dirigida,
    (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
    COALESCE((SELECT SUM(rp.pontos) FROM registro_pontos rp WHERE rp.id_prof = p.id_prof), 0) AS total_pontos_concedidos
FROM professor p;

-- Questão 36: Usando as views
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim
WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja;

SELECT * FROM vw_alunos_destaque
ORDER BY media_notas DESC;

SELECT * FROM vw_quadro_professores
ORDER BY total_pontos_concedidos DESC;

-- Questão 37: A view é "viva"
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas;
-- Explicação: A Lufa-Lufa passou de 50 para 70 pontos no resultado da view. Isso acontece porque uma view não armazena dados fisicamente; ela é uma consulta armazenada que lê diretamente das tabelas base em tempo real sempre que é consultada.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa AS casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;


-- ============================================================================
-- 8: CONTROLE DE ACESSO (DCL)
-- ============================================================================

-- Garantia de execução limpa caso o script seja rodado novamente
DROP USER IF EXISTS 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE IF EXISTS 'monitor';

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

-- Questão 44: Testes conectado como filch (executados em conexão separada do Workbench)
-- SELECT * FROM hogwarts.vw_placar_casas;
-- Resultado: Funciona normalmente e exibe o placar das casas (casa, fundador, pontos).
-- SELECT * FROM hogwarts.aluno;
-- Erro: Error Code: 1142. SELECT command denied to user 'filch'@'localhost' for table 'aluno'
-- Explicação: O usuário filch recebeu apenas permissão de SELECT na view vw_placar_casas, não tendo acesso direto à tabela aluno.

-- Questão 45: Testes conectado como mcgonagall (executados em conexão separada do Workbench)
-- a) INSERT INTO hogwarts.registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- b) UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;
-- Erro no comando b: Error Code: 1142. UPDATE command denied to user 'mcgonagall'@'localhost' for table 'casa'
-- Explicação: Por padrão no MySQL, triggers executam com os privilégios do usuário que os criou (DEFINER, neste caso o root@localhost), e não com os privilégios do usuário que disparou o evento (mcgonagall). Por isso o trigger trg_pontos_casa conseguiu atualizar a tabela casa indiretamente, enquanto o UPDATE direto da McGonagall foi bloqueado.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47: Papéis (roles)
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Explicação: Usar papéis (roles) centraliza o gerenciamento de permissões: em vez de conceder ou revogar privilégios individualmente para cada usuário monitor, basta alterar as permissões do papel 'monitor' uma única vez que todos os usuários associados a ele herdam a mudança automaticamente.

-- Questão 48: Limpeza final de usuários e papéis
DROP USER 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE 'monitor';