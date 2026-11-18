-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Kauã Monteiro Coelho
-- Matrícula: 2533406
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
    id_casa   INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador  VARCHAR(60),
    pontos    INT DEFAULT 0
);

-- Tabela professor
CREATE TABLE professor (
    id_prof          INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    salario          DECIMAL(10,2),
    data_contratacao DATE,
    id_casa          INT,
    CHECK (salario > 0),
    FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc     INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc   VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo  INT,
    id_prof     INT,
    CHECK (ano_minimo BETWEEN 1 AND 7),
    FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno       INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    ano_escolar    INT,
    id_casa        INT,
    saldo_galeoes  DECIMAL(10,2) DEFAULT 0,
    CHECK (ano_escolar BETWEEN 1 AND 7),
    CHECK (saldo_galeoes >= 0),
    FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CHECK (nota BETWEEN 0 AND 10),
    FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_disc)  REFERENCES disciplina (id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro   INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno      INT NOT NULL,
    id_prof       INT NOT NULL,
    pontos        INT NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_prof)  REFERENCES professor (id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto   INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja         VARCHAR(50) NOT NULL,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    CHECK (preco > 0),
    CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra   INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno    INT,
    id_produto  INT,
    quantidade  INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CHECK (quantidade > 0),
    FOREIGN KEY (id_aluno)   REFERENCES aluno (id_aluno),
    FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log    INT AUTO_INCREMENT PRIMARY KEY,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: A PK composta (id_aluno, id_disc) garante que um aluno só possa
-- se matricular UMA vez em cada disciplina. Com um id_matricula
-- auto_increment, nada impediria inserir a mesma combinação aluno+disciplina
-- várias vezes (matrículas duplicadas, notas conflitantes), a menos que se
-- criasse também uma restrição UNIQUE(id_aluno, id_disc). Além disso, o id
-- extra seria uma coluna desnecessária, já que a própria combinação já
-- identifica a linha.


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
SELECT (SELECT COUNT(*) FROM casa)       AS casas,
       (SELECT COUNT(*) FROM professor)  AS professores,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM aluno)      AS alunos,
       (SELECT COUNT(*) FROM matricula)  AS matriculas,
       (SELECT COUNT(*) FROM produto)    AS produtos;
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

-- Questão 6
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (SELECT id_disc
                  FROM disciplina
                  WHERE id_prof IN (SELECT id_prof
                                    FROM professor
                                    WHERE nome = 'Remo Lupin'));

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


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign
--       key constraint fails (`hogwarts`.`aluno`, CONSTRAINT `aluno_ibfk_1`
--       FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: a casa Sonserina é referenciada por alunos e por um professor
--             (diretor). A chave estrangeira impede excluir a linha "pai"
--             enquanto existirem linhas "filhas" apontando para ela, para
--             não deixar registros órfãos.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Dobby', 8, 1, 0, 'dobby@hogwarts.edu');
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: o CHECK exige ano_escolar entre 1 e 7; o valor 8 viola a
--             regra, então o banco recusa o INSERT.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for
--       key 'aluno.uq_aluno_email'
-- Explicação: a restrição UNIQUE uq_aluno_email não permite dois alunos com
--             o mesmo e-mail, e o Harry verdadeiro já usa esse endereço.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign
--       key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT
--       `disciplina_ibfk_1` FOREIGN KEY (`id_prof`) REFERENCES `professor`
--       (`id_prof`))
-- Explicação: Snape ministra Poções, ou seja, existe uma disciplina que
--             referencia o id dele. A FK bloqueia a exclusão.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Por que este funciona e o anterior não: Lockhart não é referenciado por
-- nenhuma outra tabela (não ministra disciplina, não dirige casa e não tem
-- registros de pontos), então nenhuma FK é violada. Snape é referenciado
-- pela disciplina Poções.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira: 8 professores, 13 alunos, 8 disciplinas e 33 matrículas
SELECT (SELECT COUNT(*) FROM professor)  AS professores,
       (SELECT COUNT(*) FROM aluno)      AS alunos,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM matricula)  AS matriculas;


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
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
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

    SELECT estoque, preco INTO v_estoque, v_preco
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

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
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(OLD.nome, ': salário de ', OLD.salario,
                       ' para ', NEW.salario));
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: A validação precisa ser BEFORE porque deve acontecer ANTES de a
-- linha ser gravada: se o estoque ou o saldo forem insuficientes, o SIGNAL
-- cancela o INSERT e nada é gravado. Além disso, só no BEFORE é possível
-- alterar NEW.valor_total antes da gravação. A baixa precisa ser AFTER
-- porque só deve mexer no estoque e no saldo depois que a compra foi
-- efetivamente gravada (e aprovada pelas validações/constraints); se fosse
-- BEFORE, poderia descontar estoque/saldo de uma compra que acabaria
-- falhando.

-- Questão 25 - INSERT registro_pontos
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

-- Confira (placar, saldos, estoques, soma das compras, log)
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
-- Esperado: Grifinória 100, Corvinal 50, Lufa-Lufa 35, Sonserina 30
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Harry Potter');
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS soma_compras FROM compra;   -- 474.00

-- Questão 25 - Rony tenta comprar a Nimbus
-- (deixe comentado: o comando falha; descomente para testar sozinho)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno.
-- O Rony tem apenas 6.00 galeões (após comprar feijões) e a Nimbus custa
-- 300.00; o trigger BEFORE INSERT bloqueia a compra com SIGNAL.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal.
-- O Caldeirão de Estanho tem estoque 0; a verificação de estoque vem
-- primeiro no trigger, então esse é o erro mostrado (mesmo a Hermione tendo
-- saldo suficiente).

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT id_aluno, id_disc, nota, situacao FROM matricula
WHERE id_aluno = 3 AND id_disc = 2;
-- Resultado: situacao passou de 'Reprovado' para 'Aprovado' sozinha, pelo
-- trigger trg_situacao_nota.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Linhas em log_auditoria: 1 (somente a mudança de salário; a mudança de
-- data_admissao não satisfaz OLD.salario <> NEW.salario).
-- Por que o reajuste da questão 10 não aparece: porque aquele UPDATE foi
-- executado ANTES de o trigger trg_audita_salario ser criado (seção 4);
-- triggers só atuam sobre comandos executados depois de existirem.



-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');
-- Esperado: Draco 150.00 e Pansy 168.00

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;      -- tudo zerado dentro da transação
ROLLBACK;
SELECT nome_casa, pontos FROM casa;      -- placar restaurado
-- O placar voltou? Sim: o ROLLBACK desfez o UPDATE que não havia sido
-- confirmado.

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;       -- 47.00
SELECT estoque FROM produto WHERE id_produto = 1;         -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;       -- 54.00
SELECT estoque FROM produto WHERE id_produto = 1;         -- 9
-- O que aconteceu com as alterações do trigger: foram desfeitas também. Os
-- UPDATEs feitos pelo trigger fazem parte da mesma transação do INSERT, então
-- o ROLLBACK desfaz a compra e todos os efeitos do trigger (saldo e estoque).

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;
SELECT nome_casa, pontos FROM casa;
-- Esperado: Grifinória 100, Corvinal 50, Lufa-Lufa 50, Sonserina 30
SELECT COUNT(*) AS linhas_registro_pontos FROM registro_pontos;   -- 17

-- Questão 30
SELECT @@autocommit;
-- Resposta: retorna 1, ou seja, o modo autocommit está LIGADO: cada comando
-- isolado é confirmado (COMMIT) automaticamente. START TRANSACTION suspende
-- isso até o COMMIT/ROLLBACK. Executar um comando DDL (como CREATE TABLE) no
-- meio de uma transação aberta causa um COMMIT implícito: tudo o que foi
-- feito até ali é confirmado e não pode mais ser desfeito com ROLLBACK.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT nome, salario
FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- 6.2
SELECT nome, ano_escolar
FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar;

-- 6.3
SELECT nome
FROM aluno
WHERE nome LIKE '_a%';

-- 6.4
SELECT nome_disc
FROM disciplina
WHERE id_prof IS NULL;

-- 6.5
SELECT nome_produto, preco
FROM produto
WHERE preco NOT BETWEEN 5 AND 20
ORDER BY preco;

-- 6.6
SELECT DISTINCT loja
FROM produto
ORDER BY loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: 12 alunos. Não são 13 porque o Teddy Lupin tem
-- id_casa NULL (ainda não foi selecionado) e o INNER JOIN só retorna linhas
-- com correspondência nas duas tabelas.

-- 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa
ORDER BY a.nome;

-- 6.9
SELECT p.id_prof, p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome        AS aluno,
       d.nome_disc   AS disciplina,
       p.nome        AS professor,
       m.nota,
       m.situacao
FROM aluno a
JOIN casa c       ON a.id_casa = c.id_casa
JOIN matricula m  ON m.id_aluno = a.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT co.id_compra,
       a.nome         AS aluno,
       p.nome_produto AS produto,
       p.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a   ON a.id_aluno = co.id_aluno
JOIN produto p ON p.id_produto = co.id_produto
ORDER BY co.data_compra, co.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc               AS disciplina,
       COUNT(*)                  AS qtd_alunos,
       ROUND(AVG(m.nota), 2)     AS media,
       MAX(m.nota)               AS maior_nota,
       MIN(m.nota)               AS menor_nota
FROM disciplina d
JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa AS casa,
       COUNT(*)    AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo
FROM registro_pontos r
JOIN aluno a ON a.id_aluno = r.id_aluno
JOIN casa c  ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo DESC;

-- 6.14
SELECT p.loja,
       COUNT(*)            AS qtd_compras,
       SUM(co.valor_total) AS faturamento
FROM compra co
JOIN produto p ON p.id_produto = co.id_produto
GROUP BY p.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(data_registro) AS mes,
       COUNT(*)             AS qtd_registros,
       SUM(pontos)          AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome            AS professor,
       COUNT(*)          AS qtd_registros,
       SUM(r.pontos)     AS total_concedido
FROM registro_pontos r
JOIN professor p ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT nome
FROM aluno
WHERE id_aluno IN (SELECT id_aluno
                   FROM compra
                   WHERE id_produto IN (SELECT id_produto
                                        FROM produto
                                        WHERE loja = 'Dedosdemel'));

-- 6.18
SELECT nome_produto, estoque
FROM produto
WHERE id_produto NOT IN (SELECT id_produto FROM compra);

-- 6.19
SELECT nome, saldo_galeoes
FROM aluno
WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT nome, salario
FROM professor
WHERE salario > ALL (SELECT salario FROM professor WHERE id_casa IS NULL);

-- 6.21
SELECT nome, saldo_galeoes
FROM aluno
WHERE (id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
       OR id_casa IS NULL)
  AND saldo_galeoes > ANY (SELECT saldo_galeoes
                           FROM aluno
                           WHERE id_casa = (SELECT id_casa FROM casa
                                            WHERE nome_casa = 'Sonserina'));
-- > ANY equivale a: comparar com o MENOR valor da subconsulta (basta ser
-- maior que algum sonserino, ou seja, maior que o mais pobre deles).

-- 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (SELECT 1
              FROM aluno a
              JOIN matricula m ON m.id_aluno = a.id_aluno
              WHERE a.id_casa = c.id_casa
                AND m.nota = 10);

-- 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (SELECT 1 FROM compra co WHERE co.id_aluno = a.id_aluno);

-- 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(t.media_aluno), 2) AS media_da_casa
FROM (SELECT a.id_aluno, a.id_casa, AVG(m.nota) AS media_aluno
      FROM aluno a
      JOIN matricula m ON m.id_aluno = a.id_aluno
      GROUP BY a.id_aluno, a.id_casa) t
JOIN casa c ON c.id_casa = t.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- 6.26
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION ALL
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);

SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION
SELECT a.nome FROM aluno a WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);
-- Linhas com UNION ALL: 27
-- Linhas com UNION: 12
-- Explicação: UNION ALL junta os resultados mantendo TODAS as linhas,
-- inclusive os nomes repetidos (quem comprou e também recebeu pontos aparece
-- duas vezes). UNION elimina duplicatas, retornando cada nome uma única vez.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT a.nome                          AS aluno,
       COALESCE(c.nome_casa, 'Sem casa')   AS casa,
       d.nome_disc                     AS disciplina,
       COALESCE(p.nome, 'Sem professor')   AS professor,
       m.nota,
       m.situacao
FROM matricula m
JOIN aluno a       ON a.id_aluno = m.id_aluno
JOIN disciplina d  ON d.id_disc = m.id_disc
LEFT JOIN casa c   ON c.id_casa = a.id_casa
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome         AS aluno,
       p.nome_produto AS produto,
       p.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a   ON a.id_aluno = co.id_aluno
JOIN produto p ON p.id_produto = co.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome                    AS aluno,
       c.nome_casa               AS casa,
       ROUND(AVG(m.nota), 2)     AS media
FROM aluno a
JOIN casa c      ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof)
           AS qtd_disciplinas,
       COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r
                 WHERE r.id_prof = p.id_prof), 0) AS total_pontos_concedidos
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
-- O que mudou e por quê: a Lufa-Lufa passou de 50 para 70 pontos. A view
-- não guarda dados: ela apenas armazena a consulta, que é reexecutada sobre
-- as tabelas a cada uso. Como o trigger atualizou casa.pontos, a view já
-- mostra o valor novo sem precisar ser recriada.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;

SELECT * FROM vw_placar_casas;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
CREATE USER 'filch'@'localhost'      IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 41
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno      TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44
-- (execute em uma NOVA conexão, logado como filch)
-- SELECT * FROM hogwarts.vw_placar_casas;
-- SELECT * FROM hogwarts.aluno;
-- Resultado de cada comando:
--  - SELECT na view vw_placar_casas: funciona e mostra o placar.
--  - SELECT * FROM aluno: Error Code: 1142. SELECT command denied to user
--    'filch'@'localhost' for table 'aluno'. O Filch só recebeu permissão na
--    view, não na tabela.

-- Questão 45
-- (execute em uma NOVA conexão, logado como mcgonagall)
-- a) INSERT INTO hogwarts.registro_pontos
--        (id_aluno, id_prof, pontos, motivo, data_registro)
--    VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- b) UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;
--    -> Error Code: 1142. UPDATE command denied to user
--       'mcgonagall'@'localhost' for table 'casa'.
-- Como o trigger conseguiu atualizar a casa: triggers são executados com os
-- privilégios do DEFINER (por padrão, o usuário que criou o trigger, aqui
-- o administrador/root), e não com os do usuário que disparou o INSERT. Por
-- isso o trg_pontos_casa consegue fazer UPDATE em casa mesmo a McGonagall
-- não tendo essa permissão. Após o passo (a), a Grifinória tem 110 pontos.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim      TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Vantagem dos papéis: as permissões são definidas uma única vez no papel e
-- depois atribuídas a quantos usuários forem necessários. Para mudar o que
-- os monitores podem fazer, basta alterar o papel (GRANT/REVOKE nele) e
-- todos os monitores são atualizados juntos, em vez de ajustar usuário por
-- usuário. Isso reduz erros e facilita a administração.

-- Questão 48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE 'monitor';

