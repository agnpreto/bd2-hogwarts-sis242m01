-- =====================================================================
-- ESCOLA DE MAGIA DE HOGWARTS: BANCO DE DADOS COMPLETO
-- Aluno: Miguel Menezes (2537449)
-- =====================================================================

DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hogwarts;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL) & 1.1 CARGA INICIAL (DML)
-- =====================================================================

CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) NOT NULL CHECK (salario > 0),
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT fk_prof_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT CHECK (ano_minimo BETWEEN 1 AND 7),
    id_prof INT,
    CONSTRAINT fk_disc_prof FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT CHECK (ano_escolar BETWEEN 1 AND 7),
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0.00 CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT fk_mat_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_mat_disc FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);
-- Pergunta para pensar: Por que matricula usa chave primária composta?
-- R: Porque ela representa um relacionamento N:N entre aluno e disciplina. 
-- Se usasse um ID próprio auto_increment, permitiria que o mesmo aluno se matriculasse 
-- na mesma disciplina duplicadamente, burlando a restrição natural de unicidade do vínculo.

CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150) NOT NULL,
    data_registro DATE NOT NULL,
    CONSTRAINT fk_reg_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_reg_prof FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    estoque INT DEFAULT 0 CHECK (estoque >= 0)
);

CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_prod FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Carga Inicial (INSERTs)
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal', 'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');

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

INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5),(1,2,5.0), (1,6,9.8), (1,5,8.0),
(2,1,10.0),(2,2,9.5),(2,3,10.0),(2,5,9.0),(2,9,9.5),
(3,1,6.0),(3,2,4.5),(3,7,5.5),
(4,2,3.0),(4,4,10.0), (4,6,7.0),
(5,2,9.0), (5,1,7.0),(5,5,4.0),
(6,2,7.5),(6,7,6.5),
(7,2,3.5), (7,6,2.0),
(8,5,8.5), (8,3,8.0), (8,4,9.0),
(9,3,8.5), (9,6,7.5),
(10,3,9.0),(10,7,6.0),
(11,4,8.5),(11,6,9.0),(11,1,8.0),
(12,4,8.0),
(13,4,7.0), (13,3,7.5);

INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER e UPDATE)
-- =====================================================================

-- 2.1 Alterações de Estrutura
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- 2.2 Atualizações de Dados
SET SQL_SAFE_UPDATES = 0;

UPDATE aluno 
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

UPDATE matricula 
SET nota = LEAST(10.00, nota + 0.5) 
WHERE id_disc IN (SELECT id_disc FROM disciplina WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'));

UPDATE matricula 
SET situacao = CASE 
    WHEN nota >= 6.0 THEN 'Aprovado' 
    ELSE 'Reprovado' 
END;

UPDATE professor 
SET salario = salario * 1.10 
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

UPDATE produto 
SET ativo = 'N' 
WHERE estoque = 0;

UPDATE produto 


SET preco = preco * 0.80 
WHERE loja = 'Dedosdemel';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================

-- Questão 13: Teste de FK (Sonserina)
/* 
DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails...
-- Explicação: O banco recusa porque existem alunos, professores e registros vinculados à casa Sonserina, 
-- o que violaria a integridade referencial da chave estrangeira.
*/

-- Questão 14: Teste de CHECK (Dobby no 8º ano)
/*
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES ('Dobby', 8, 1, 10.00);
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: A coluna ano_escolar possui uma restrição CHECK permitindo apenas valores entre 1 e 7.
*/

-- Questão 15: Teste de UNIQUE (E-mail repetido do Harry)
/*
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email) 
VALUES ('Harry Potter (Polissuco)', 5, 1, 50.00, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: A restrição UNIQUE impede que dois registros tenham exatamente o mesmo e-mail.
*/

-- Questão 16: Teste de integridade (Excluir Severo Snape)
/*
DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row...
-- Explicação: Snape é referenciado como professor em disciplinas e registros de pontos, impedindo sua exclusão direta.
*/

-- Questão 17: Excluir Gilderoy Lockhart
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Funciona porque ele não possui vínculos ativos como chave estrangeira em tabelas dependentes (como disciplina ou registros).

-- Questão 18: Remover Vicente Crabbe
DELETE FROM matricula WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19: Excluir disciplinas sem alunos matriculados
DELETE FROM disciplina WHERE id_disc NOT IN (SELECT id_disc FROM matricula);


-- =====================================================================
-- 4. TRIGGERS: AS REGRAS QUE SE CUMPREM SOZINHAS
-- =====================================================================

DELIMITER $$

CREATE TRIGGER trg_pontos_casa 
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa SET pontos = pontos + NEW.pontos WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$

CREATE TRIGGER trg_valida_compra 
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);
    
    SELECT estoque, preco INTO v_estoque, v_preco FROM produto WHERE id_produto = NEW.id_produto;
    SELECT saldo_galeoes INTO v_saldo FROM aluno WHERE id_aluno = NEW.id_aluno;
    
    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;
    
    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;
    
    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$

CREATE TRIGGER trg_baixa_compra 
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto SET estoque = estoque - NEW.quantidade WHERE id_produto = NEW.id_produto;
    UPDATE aluno SET saldo_galeoes = saldo_galeoes - NEW.valor_total WHERE id_aluno = NEW.id_aluno;
END$$
-- Pergunta para pensar: Por que a validação precisa ser BEFORE e a baixa AFTER?
-- R: O BEFORE é necessário para cancelar a operação antes de persistir (usando SIGNAL) e calcular o valor_total. 
-- O AFTER é ideal para a baixa, pois garante que o produto só terá o estoque decrementado e o aluno debitado se a inserção for bem-sucedida.

CREATE TRIGGER trg_situacao_nota 
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        IF NEW.nota >= 6.0 THEN
            SET NEW.situacao = 'Aprovado';
        ELSE
            SET NEW.situacao = 'Reprovado';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_audita_salario 
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE', CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$

DELIMITER ;

-- 4.1 Carga e Testes dos Triggers
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
(2, 3, 20, 'Feitiço de levitação perfeito', '2026-09-10'),
(1, 2, 10, 'Atraso na aula de Poções', '2026-09-12'),
(5, 2, 15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
(8, 5, 10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
(4, 4, 30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
(6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
(1, 6, 50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
(9, 3, 15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
(5, 1, 30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'Colheita de mandrágoras', '2026-11-05'),
(3, 9, 10, 'Identificou um bezoar', '2026-11-06'),
(8, 3, 20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
(6, 2, 25, 'Antídoto para venenos comuns', '2026-11-09'),
(5, 9, 40, 'Melhor poção do Clube do Slugue', '2026-11-09');

INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
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

-- Testes descritos na atividade:
-- Rony Weasley (id 3) tenta comprar Nimbus 2001 (id 2) -> Falha por saldo insuficiente ou estoque.
-- Hermione Granger (id 2) tenta comprar Caldeirão de Estanho (id 6) -> Falha por estoque zerado.
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;

UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
-- Apenas 1 linha aparece em log_auditoria porque o trigger verifica se OLD.salario <> NEW.salario. 
-- A alteração de data não dispara o trigger. O reajuste da questão 10 não aparece porque ocorreu antes do trigger de auditoria ser criado.


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================

-- 26. Transferência Draco -> Pansy
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50.00 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50.00 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- 27. Ataque do Pirraça
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT * FROM casa;
ROLLBACK;

-- 28. Trigger na transação
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
-- As alterações feitas pelo trigger e pela transação foram revertidas conjuntamente.

-- 29. SAVEPOINT
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) 
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) 
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO sp_pontos_legitimos;
COMMIT;

-- 30. Pergunta conceitual
SELECT @@autocommit;
-- Significa que o modo de confirmação automática está ativado (1), ou seja, cada instrução SQL isolada é comitada automaticamente.
-- Executar um CREATE TABLE no meio de uma transação aberta no MySQL gera um commit implícito automático.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA (SQL AVANÇADO)
-- =====================================================================

-- 6.1
SELECT nome, salario FROM professor WHERE salario BETWEEN 6000.00 AND 9000.00 ORDER BY salario DESC;

-- 6.2
SELECT nome, ano_escolar FROM aluno WHERE ano_escolar IN (1, 4, 6, 7) ORDER BY ano_escolar;

-- 6.3
SELECT nome FROM aluno WHERE nome LIKE '_a%';

-- 6.4
SELECT * FROM disciplina WHERE id_prof IS NULL;

-- 6.5
SELECT nome_produto, preco FROM produto WHERE preco NOT BETWEEN 5.00 AND 20.00 ORDER BY preco;

-- 6.6
SELECT DISTINCT loja FROM produto ORDER BY loja;

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa 
FROM aluno a INNER JOIN casa c ON a.id_casa = c.id_casa 
ORDER BY c.nome_casa, a.nome;
-- Retorna 12 alunos porque Teddy Lupin está com id_casa NULL (não entrou no INNER JOIN).

-- 6.8
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa 
FROM aluno a LEFT JOIN casa c ON a.id_casa = c.id_casa;

-- 6.9
SELECT p.nome FROM professor p RIGHT JOIN disciplina d ON p.id_prof = d.id_prof WHERE d.id_disc IS NULL;
-- (Se todos tiverem, retornará vazio, mas segue a lógica correta solicitada).

-- 6.10
SELECT a.nome AS aluno, d.nome_disc, COALESCE(p.nome, 'Sem professor') AS professor, m.nota, m.situacao
FROM matricula m
JOIN aluno a ON m.id_aluno = a.id_aluno
JOIN casa c ON a.id_casa = c.id_casa
JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT co.id_compra, a.nome AS aluno, p.nome_produto, p.loja, co.quantidade, co.valor_total, co.data_compra
FROM compra co
JOIN aluno a ON co.id_aluno = a.id_aluno
JOIN produto p ON co.id_produto = p.id_produto
ORDER BY co.data_compra;

-- 6.12
SELECT d.nome_disc, COUNT(m.id_aluno) AS qtd_alunos, ROUND(AVG(m.nota), 2) AS media, MAX(m.nota) AS maior_nota, MIN(m.nota) AS menor_nota
FROM disciplina d
JOIN matricula m ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa, 
       COUNT(r.id_registro) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       c.pontos AS saldo
FROM casa c
LEFT JOIN aluno a ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos r ON a.id_aluno = r.id_aluno
GROUP BY c.id_casa, c.nome_casa, c.pontos;

-- 6.14
SELECT p.loja, COUNT(c.id_compra) AS qtd_compras, SUM(c.valor_total) AS faturamento
FROM compra c
JOIN produto p ON c.id_produto = p.id_produto
GROUP BY p.loja
HAVING faturamento > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(data_registro) AS mes, COUNT(id_registro) AS qtd_registros, SUM(pontos) AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome, COUNT(r.id_registro) AS qtd_registros, SUM(r.pontos) AS total_concedido
FROM professor p
JOIN registro_pontos r ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING qtd_registros >= 2
ORDER BY total_concedido DESC;

-- 6.17
SELECT DISTINCT a.nome 
FROM aluno a 
WHERE a.id_aluno IN (
    SELECT c.id_aluno FROM compra c 
    WHERE c.id_produto IN (
        SELECT p.id_produto FROM produto p WHERE p.loja = 'Dedosdemel'
    )
);

-- 6.18
SELECT nome_produto, estoque FROM produto WHERE id_produto NOT IN (SELECT id_produto FROM compra);

-- 6.19
SELECT nome, saldo_galeoes FROM aluno WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT nome, salario FROM professor WHERE salario > ALL (SELECT salario FROM professor WHERE id_casa IS NULL);

-- 6.21
SELECT a.nome, a.saldo_galeoes 
FROM aluno a 
WHERE a.id_casa <> 2 AND a.saldo_galeoes > ANY (SELECT saldo_galeoes FROM aluno WHERE id_casa = 2);
-- Explicação: > ANY equivale a comparar com o MENOR valor retornado pela subconsulta (maior que o mínimo).

-- 6.22
SELECT DISTINCT c.nome_casa 
FROM casa c 
WHERE EXISTS (
    SELECT 1 FROM aluno a 
    JOIN matricula m ON a.id_aluno = m.id_aluno 
    WHERE a.id_casa = c.id_casa AND m.nota = 10
);

-- 6.23
SELECT nome FROM aluno WHERE NOT EXISTS (SELECT 1 FROM compra c WHERE c.id_aluno = aluno.id_aluno);

-- 6.24
SELECT casa, ROUND(AVG(media_aluno), 2) AS media_casa
FROM (
    SELECT a.id_casa, c.nome_casa AS casa, AVG(m.nota) AS media_aluno
    FROM aluno a
    JOIN matricula m ON a.id_aluno = m.id_aluno
    JOIN casa c ON a.id_casa = c.id_casa
    GROUP BY a.id_aluno, a.id_casa, c.nome_casa
) as medias_alunos
GROUP BY casa
ORDER BY media_casa DESC;

-- 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- 6.26
SELECT nome FROM aluno WHERE id_aluno IN (SELECT id_aluno FROM compra)
UNION ALL
SELECT nome FROM aluno WHERE id_aluno IN (SELECT id_aluno FROM registro_pontos);
-- UNION ALL retorna duplicatas, enquanto UNION remove as duplicatas.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;


-- =====================================================================
-- 7. VIEWS: OS QUADROS DE AVISOS DE HOGWARTS
-- =====================================================================

CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;

CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno, 
       COALESCE(c.nome_casa, 'Sem casa') AS casa, 
       d.nome_disc AS disciplina, 
       COALESCE(p.nome, 'Sem professor') AS professor, 
       m.nota, 
       m.situacao
FROM matricula m
JOIN aluno a ON m.id_aluno = a.id_aluno
LEFT JOIN casa c ON a.id_casa = c.id_casa
JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof;

CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno, p.nome_produto AS produto, p.loja, c.quantidade, c.valor_total, c.data_compra
FROM compra c
JOIN aluno a ON c.id_aluno = a.id_aluno
JOIN produto p ON c.id_produto = p.id_produto;

CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno, c.nome_casa AS casa, ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN casa c ON a.id_casa = c.id_casa
JOIN matricula m ON a.id_aluno = m.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

CREATE VIEW vw_quadro_professores AS
SELECT p.nome,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r WHERE r.id_prof = p.id_prof), 0) AS total_pontos
FROM professor p
LEFT JOIN casa c ON p.id_casa = c.id_casa;

-- 36. Consultas utilizando as Views
SELECT * FROM vw_placar_casas;
SELECT * FROM vw_boletim WHERE casa = 'Corvinal';
SELECT loja, SUM(valor_total) AS total_faturado FROM vw_extrato_loja GROUP BY loja;
SELECT * FROM vw_alunos_destaque ORDER BY media DESC;
SELECT * FROM vw_quadro_professores ORDER BY total_pontos DESC;

-- 37. View Viva (Teste)
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) 
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT * FROM vw_placar_casas;
-- O placar mudou automaticamente porque as views executam a consulta base em tempo real a cada chamada.

-- 38. Alterar View com CREATE OR REPLACE
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos FROM casa ORDER BY pontos DESC;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================

CREATE USER 'filch'@'localhost' IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Teste com o Filch (simular em outra conexão):
-- SELECT * FROM vw_placar_casas; -> Funciona.
-- SELECT * FROM aluno; -> Erro 1142 (SELECT command denied).

-- Teste com a McGonagall:
-- INSERT INTO registro_pontos ... -> Funciona.
-- UPDATE casa SET pontos = 1000 WHERE id_casa = 1; -> Negado.
-- O trigger funcionou mesmo sem ela ter permissão direta em 'casa' porque os triggers 
-- executam com os privilégios do usuário definidor (Definer).

REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Papéis (Roles)
CREATE ROLE monitor;
GRANT SELECT ON hogwarts.vw_boletim TO monitor;
GRANT SELECT ON hogwarts.vw_placar_casas TO monitor;

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT monitor TO 'percy'@'localhost';
SET DEFAULT ROLE ALL TO 'percy'@'localhost';
-- Vantagem dos papéis: Permite agrupar privilégios e atribuí-los em massa a vários usuários, 
-- facilitando a manutenção futura de segurança.

-- Limpeza final dos usuários e papéis criados
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE monitor;
