-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Mikael Coelho Ramos
-- Matrícula: 2388326
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
    CONSTRAINT pk_casa PRIMARY KEY (id_casa),
    CONSTRAINT uq_casa_nome UNIQUE (nome_casa)
);
-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT,  
    CONSTRAINT pk_professor PRIMARY KEY (id_prof),
    CONSTRAINT ck_professor_salario CHECK (salario > 0),
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);
-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT,
    nome_disc VARCHAR(60) NOT NULL,
    ano_minimo INT,
    id_prof INT,
    CONSTRAINT pk_disciplina PRIMARY KEY (id_disc),
    CONSTRAINT uq_disciplina_nome UNIQUE (nome_disc),
    CONSTRAINT ck_disciplina_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disciplina_prof FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT pk_aluno PRIMARY KEY (id_aluno),
    CONSTRAINT ck_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT ck_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela matricula

CREATE TABLE matricula (
    id_aluno INT NOT NULL,
    id_disc INT NOT NULL,
    nota DECIMAL(4,2),
    CONSTRAINT pk_matricula PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT ck_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_matricula_disc FOREIGN KEY (id_disc) REFERENCES disciplina (id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT pk_registro_pontos PRIMARY KEY (id_registro),
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_registro_prof FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);
-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT ck_produto_preco CHECK (preco > 0),
    CONSTRAINT ck_produto_estoque CHECK (estoque >= 0)
);
-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT ck_compra_quantidade CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log)
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: Porque a matricula é a ligação entre um aluno e uma disciplina, e essa
-- combinação já identifica a linhas de forma unica, não sendo necessário um id separado.


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória','Godric Gryffindor'),  
('Sonserina','Salazar Slytherin'),  
('Corvinal','Rowena Ravenclaw'),   
('Lufa-Lufa','Helga Hufflepuff');   
-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),    
('Severo Snape',8800.00, '1981-09-01', 2),    
('Fílio Flitwick',8200.00, '1974-09-01', 3),    
('Pomona Sprout',7900.00, '1972-09-01', 4),    
('Rúbeo Hagrid',4500.00, '1993-09-01', NULL), 
('Remo Lupin',6200.00, '1993-09-01', NULL), 
('Sibila Trelawney',5100.00, '1980-09-01', NULL), 
('Gilderoy Lockhart',7000.00, '1992-09-01', NULL), 
('Horácio Slughorn',8000.00, '1996-09-01', NULL); 
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
('Harry Potter',5, 1, 120.00),  
('Hermione Granger',5, 1,  85.00),  
('Rony Weasley',5, 1,  12.00),  
('Neville Longbottom', 5, 1,  30.00),  
('Draco Malfoy',5, 2, 500.00),  
('Pansy Parkinson',5, 2, 150.00),  
('Vicente Crabbe',5, 2,  40.00),  
('Luna Lovegood',4, 3,  45.00),  
('Cho Chang',6, 3, 200.00),  
('Padma Patil',5, 3,  60.00),  
('Cedrico Diggory',7, 4, 180.00),  
('Ana Abbott',5, 4,  25.00),  
('Ernesto Macmillan',5, 4,  70.00),  
('Teddy Lupin',1, NULL, 0.00); 
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
('Varinha de Azevinho','Olivaras',7.00,  10),  
('Vassoura Nimbus 2001','Artigos de Quadribol', 300.00, 3),  
('Sapo de Chocolate','Dedosdemel',2.00, 200),  
('Feijõezinhos de Todos os Sabores','Dedosdemel',1.50, 150),  
('Livro Monstruoso dos Monstros','Floreios e Borrões',12.00, 20),  
('Caldeirão de Estanho','Caldeirões Potage',9.00,0),  
('Kit de Logros','Gemialidades Weasley', 25.00, 40),  
('Pena de Repetição Rápida','Escribbulus',15.00,5);  
-- Confira: SELECT COUNT(*) de cada tabela

SELECT 'casa' AS tabela, COUNT(*) AS total FROM casa
UNION ALL SELECT 'professor',COUNT(*) FROM professor
UNION ALL SELECT 'disciplina',COUNT(*) FROM disciplina
UNION ALL SELECT 'aluno',COUNT(*) FROM aluno
UNION ALL SELECT 'matricula',COUNT(*) FROM matricula
UNION ALL SELECT 'produto',COUNT(*) FROM produto;

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);
DESC aluno;

-- Questão 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
DESC matricula;

-- Questão 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';
DESC produto;

-- Questão 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);
DESC casa;

-- Questão 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;
DESC professor;

-- Questão 6
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (SELECT id_disc FROM disciplina
WHERE id_prof IN (SELECT id_prof FROM professor
WHERE nome = 'Remo Lupin'));

-- Questão 9
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado'
ELSE 'Reprovado'END;
-- Questão 10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

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
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key
-- constraint fails (`hogwarts`.`aluno`, CONSTRAINT `fk_aluno_casa` FOREIGN KEY
-- (`id_casa`) REFERENCES `casa` (`id_casa`))

-- Explicação: A Sonserina é a casa pai de outras linhas: Draco e Pansy da tabela aluno
-- e o professor Snape, que a dirige, guardam o id_casa dela em uma chave estrangeira.
-- Para garantir a integridade referencial, o banco não deixa excluir
-- a linha referenciada enquanto existirem linhas filhas apontando para ela, senão
-- alunos e professores ficariam com um id_casa que não existe mais. Para
-- excluir, seria preciso antes remover ou reatribuir esses alunos e professores.

-- Questão 14
-- Erro: Error Code: 3819. Check constraint 'ck_aluno_ano' is violated.
-- Explicação: A tabela aluno tem CHECK (ano_escolar BETWEEN 1 AND 7). Hogwarts tem
-- apenas 7 anos, então o 8º ano do Dobby viola a regra de domínio e o MySQL rejeita o insert

-- Questão 15
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: A restrição UNIQUE uq_aluno_email criada na questão 7 não permite dois
-- alunos com o mesmo e-mail, e o Harry Potter verdadeiro já usa harry.potter@hogwarts.edu. 
-- Mesmo com o nome diferente, o e-mail repetido faz o insert falhar.

-- Questão 16
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key
-- constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `fk_disciplina_prof` FOREIGN
-- KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: O Snape é o professor de Poções: a disciplina 2 tem id_prof = 2.
-- Excluir ele deixaria essa disciplina apontando para um professor que não existe, então
-- a chave estrangeira fk_disciplina_prof bloqueia a exclusão

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Por que este funciona e o anterior não?
-- O Lockhart não é referenciado por nenhuma linha de tabela filha onde nenhuma disciplina
-- tem id_prof = 8 (as disciplinas sem professor estão com id_prof NULL) e ele não tem
-- registros de pontos. Sem filhos apontando para ele, a exclusão não quebra nenhuma
-- chave estrangeira e é aceita. O Snape, ao contrário, ainda era o professor de Poções.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira: após a seção 3 devem restar 8 professores, 13 alunos, 8 disciplinas (Estudo dos
-- Trouxas foi removida) e 33 matrículas
SELECT 'professor' AS tabela, COUNT(*) AS total FROM professor
UNION ALL SELECT 'aluno',COUNT(*) FROM aluno
UNION ALL SELECT 'disciplina',COUNT(*) FROM disciplina
UNION ALL SELECT 'matricula',COUNT(*) FROM matricula;


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa

DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN UPDATE casa SET pontos = pontos + NEW.pontos
WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21 - trg_valida_compra

DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN DECLARE v_preco   DECIMAL(10,2); 
DECLARE v_estoque INT;
DECLARE v_saldo   DECIMAL(10,2);

SELECT preco, estoque INTO v_preco, v_estoque FROM produto
WHERE id_produto = NEW.id_produto;

SELECT saldo_galeoes INTO v_saldo FROM aluno
WHERE id_aluno = NEW.id_aluno;

IF v_estoque < NEW.quantidade THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
END IF;

IF v_saldo < v_preco * NEW.quantidade THEN SIGNAL SQLSTATE '45000'
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
BEGIN UPDATE produto SET estoque = estoque - NEW.quantidade
WHERE id_produto = NEW.id_produto;

UPDATE aluno SET saldo_galeoes = saldo_galeoes - NEW.valor_total
WHERE id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questão 23 - trg_situacao_nota

DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN IF NOT (NEW.nota <=> OLD.nota) THEN
IF NEW.nota >= 6 THEN SET NEW.situacao = 'Aprovado';
ELSE SET NEW.situacao = 'Reprovado';
END IF;
END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario

DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN IF OLD.salario <> NEW.salario THEN
INSERT INTO log_auditoria (tabela, operacao, descricao) VALUES 
('professor', 'UPDATE', CONCAT(OLD.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: A validação precisa ser BEFORE porque ela decide se a compra pode ser gravada, 
-- ou seja,o SIGNAL cancela o INSERT antes de a linha existir, e só em um BEFORE INSERT
-- é possível alterar o NEW (preencher NEW.valor_total) antes da gravação. Em um
-- trigger AFTER o NEW é somente leitura e a linha já foi gravada.
-- A baixa precisa ser AFTER porque só deve mexer no estoque e no saldo quando a
-- compra já foi aceita e gravada, ou seja, depois de passar pela validação e
-- pelas demais restrições (CHECK, FK). Se a baixa fosse BEFORE, o estoque e o
-- saldo seriam alterados para uma compra que ainda poderia ser recusada.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2,3,20,'Feitiço de levitação perfeito','2026-09-10'),
( 1,2,-10,'Atraso na aula de Poções','2026-09-12'),
( 5,2,15,'Poção do Morto-Vivo impecável','2026-09-12'),
( 8,5,10,'Cuidou de um testrálio ferido','2026-09-20'),
(11,4,25,'Ajudou os alunos do 1º ano','2026-09-25'),
( 4,4,30,'Identificou uma Mimbulus mimbletonia','2026-10-02'),
( 6,1,-20,'Fora da cama após o toque de recolher','2026-10-05'),
( 1,6,50,'Conjurou um Patrono corpóreo','2026-10-15'),
( 9,3,15,'Duelo exemplar no Clube de Duelos','2026-10-18'),
( 5,1,-30,'Duelo proibido no corredor','2026-10-31'),
(10,7,5,'Interpretação da bola de cristal','2026-11-03'),
(13,4,10,'Colheita de mandrágoras','2026-11-05'),
( 3,9,10,'Identificou um bezoar','2026-11-06'),
( 8,3,20,'Resposta brilhante sobre o Diadema','2026-11-08'),
( 6,2,25,'Antídoto para venenos comuns','2026-11-09'),
( 5,9,40,'Melhor poção do Clube do Slugue','2026-11-09');

SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;

-- Questão 25 - INSERT compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
(5,2,1,'2026-09-01'),
(2,5,2,'2026-09-02'),
(1,3,10,'2026-09-03'),
(3,4,5,'2026-09-03'),
(9,8,1,'2026-09-15'),
(8,5,1,'2026-09-20'),
(11,1,1,'2026-10-01'),
(6,3,20,'2026-10-10'),
(1,7,2,'2026-10-20'),
(13,4,10,'2026-11-02');

SELECT nome, saldo_galeoes FROM aluno 
WHERE nome IN ('Draco Malfoy', 'Harry Potter');

SELECT nome_produto, estoque FROM produto 
WHERE id_produto IN (2, 3);

SELECT SUM(valor_total) AS soma_valor_total FROM compra;

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno
-- O trg_valida_compra (BEFORE INSERT) viu que a Nimbus tem estoque mas o saldo 
-- do Rony é de apenas 6.00 galeões e a vassoura custa 300.00.
-- O SIGNAL SQLSTATE '45000' cancelou o INSERT: a compra não foi gravada e, como
-- o INSERT não aconteceu, o trg_baixa_compra (AFTER) nem chegou a executar (estoque e
-- saldo ficaram intactos).

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- O Caldeirão de Estanho tem estoque 0, então estoque < quantidade e o trigger bloqueia
-- a compra. A checagem de estoque vem antes da de saldo; a Hermione até teria galeões
-- suficientes (61.00 contra 9.00 do caldeirão), mas o produto não existe na prateleira.

-- Questão 25 - Recuperação do Rony em Poções
-- A coluna situacao não é mencionada: quem a recalcula é o trg_situacao_nota.
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- Resultado: a nota foi de 4.50 para 6.50 e a situação mudou sozinha de
-- 'Reprovado' para 'Aprovado' (nota >= 6), sem o UPDATE tocar em situacao.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 
WHERE nome = 'Rúbeo Hagrid';

UPDATE professor SET data_admissao = '1993-08-15' 
WHERE nome = 'Rúbeo Hagrid';

SELECT * FROM log_auditoria;
-- Linhas em log_auditoria: 1 linha: 'Rúbeo Hagrid: salário de 4500.00 para 5000.00'. O
-- segundo UPDATE (apenas data_admissao) não gerou linha porque o trigger só grava
-- quando OLD.salario <> NEW.salario, e o salário não mudou.
-- Por que o reajuste da questão 10 não aparece: O reajuste de 10% foi
-- executado antes de o trigger trg_audita_salario existir 
-- Um trigger só reage às operações feitas depois de criado; ele não enxerga o
-- passado. Por isso nem McGonagall, Flitwick e Sprout (os reajustados) aparecem no log.


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 
WHERE nome = 'Draco Malfoy';

UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 
WHERE nome = 'Pansy Parkinson';

COMMIT;

SELECT nome, saldo_galeoes FROM aluno 
WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 27

START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;   
ROLLBACK;
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
-- O placar voltou? Sim. O ROLLBACK desfez o UPDATE que zerava os pontos, porque
-- ele ainda não tinha sido confirmado com COMMIT.

-- Questão 28

START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;          -- 47.00
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;    -- 8
ROLLBACK;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;          -- 54.00
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;    -- 9
-- O que aconteceu com as alterações que o trigger tinha feito?
-- Foram desfeitas junto com a compra. O trg_baixa_compra executa dentro da mesma
-- transação do INSERT que o disparou; por isso o desconto do saldo do Harry e a
-- baixa no estoque da varinha também sofreram ROLLBACK (saldo voltou a 54.00 e
-- estoque a 9).

-- Questão 29
START TRANSACTION;

INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS linhas_registro_pontos FROM registro_pontos;

-- Questão 30
SELECT @@autocommit;
-- Resposta: O valor 1 significa que o autocommit está ligado: cada comando fora de uma
-- transação explícita é confirmado automaticamente assim que termina, não dá para dar
-- ROLLBACK depois. Dentro de START TRANSACTION o autocommit fica suspenso até o COMMIT
-- ou ROLLBACK.
-- Se um CREATE TABLE for executado no meio de uma transação aberta, o MySQL faz um
-- COMMIT implícito: tudo o que estava pendente é confirmado antes do CREATE TABLE e a
-- transação é encerrada. Comandos DDL não são transacionais, então depois
-- deles não é mais possível desfazer com ROLLBACK as alterações anteriores.


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
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: 12 alunos. O INNER JOIN só devolve linhas que têm
-- correspondência nas duas tabelas. A tabela aluno tem 13 registros (depois da expulsão
-- do Crabbe), mas o Teddy Lupin tem id_casa NULL (ainda não passou pelo Chapéu
-- Seletor), logo não encontra nenhuma casa e fica de fora. Por isso são 12 e não 13.

-- 6.8
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- 6.9
SELECT p.nome AS professor_sem_turma
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno, d.nome_disc AS disciplina, 
COALESCE(p.nome, 'Sem professor') AS professor, m.nota, m.situacao
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
INNER JOIN matricula m  ON m.id_aluno = a.id_aluno
INNER JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p   ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT c.id_compra AS numero_compra, a.nome AS aluno, p.nome_produto 
AS produto, p.loja, c.quantidade, c.valor_total, c.data_compra
FROM compra c
INNER JOIN aluno a ON a.id_aluno = c.id_aluno
INNER JOIN produto p ON p.id_produto = c.id_produto
ORDER BY c.data_compra, c.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina, COUNT(*) AS qtd_alunos, ROUND(AVG(m.nota), 2) AS media,
MAX(m.nota) AS maior_nota, MIN(m.nota) AS menor_nota
FROM matricula m
INNER JOIN disciplina d ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa AS casa, COUNT(*) AS qtd_registros,
SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
SUM(r.pontos) AS saldo
FROM registro_pontos r
INNER JOIN aluno a ON a.id_aluno = r.id_aluno
INNER JOIN casa c  ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY saldo DESC;

-- 6.14
SELECT p.loja, COUNT(*) AS qtd_compras, SUM(c.valor_total) AS faturamento
FROM compra c
INNER JOIN produto p ON p.id_produto = c.id_produto
GROUP BY p.loja
HAVING SUM(c.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(data_registro) AS mes, COUNT(*) AS qtd_registros,
SUM(pontos) AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes;

-- 6.16
SELECT p.nome AS professor, COUNT(*) AS qtd_registros,
SUM(r.pontos) AS total_concedido
FROM registro_pontos r
INNER JOIN professor p ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT nome
FROM aluno
WHERE id_aluno IN (SELECT id_aluno FROM compra
WHERE id_produto IN (SELECT id_produto FROM produto
WHERE loja = 'Dedosdemel'));

-- 6.18
SELECT nome_produto, estoque
FROM produto
WHERE id_produto NOT IN (SELECT id_produto FROM compra
WHERE id_produto IS NOT NULL);

-- 6.19
SELECT nome, saldo_galeoes
FROM aluno
WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT nome, salario
FROM professor
WHERE salario > ALL (SELECT salario FROM professor
WHERE id_casa IS NULL);

-- 6.21
SELECT nome, saldo_galeoes
FROM aluno
WHERE (id_casa IS NULL OR id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina'))
AND saldo_galeoes > ANY (SELECT a2.saldo_galeoes FROM aluno a2
INNER JOIN casa c2 ON c2.id_casa = a2.id_casa
WHERE c2.nome_casa = 'Sonserina');
-- > ANY equivale a: comparar com o MENOR valor da subconsulta. "saldo > ANY (lista)" é
-- verdadeiro quando o saldo é maior que pelo menos um valor da lista, ou seja, basta
-- superar o menor deles. Aqui o menor saldo da Sonserina é 150.00 (Draco), por isso
-- aparecem Cho Chang (185.00) e Cedrico Diggory (173.00). Já > ALL exigiria superar o
-- MAIOR valor da lista.

-- 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (SELECT 1 FROM aluno a
INNER JOIN matricula m ON m.id_aluno = a.id_aluno WHERE a.id_casa = c.id_casa
AND m.nota = 10);

-- 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (SELECT 1 FROM compra c
WHERE c.id_aluno = a.id_aluno);

-- 6.24
SELECT c.nome_casa AS casa, ROUND(AVG(t.media_aluno), 2) AS media_da_casa
FROM (SELECT id_aluno, AVG(nota) AS media_aluno
FROM matricula GROUP BY id_aluno) t
INNER JOIN aluno a ON a.id_aluno = t.id_aluno
INNER JOIN casa c  ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- 6.26
-- Linhas com UNION ALL:
SELECT a.nome
FROM compra c
INNER JOIN aluno a ON a.id_aluno = c.id_aluno
UNION ALL
SELECT a.nome
FROM registro_pontos r
INNER JOIN aluno a ON a.id_aluno = r.id_aluno;

-- Linhas com UNION:
SELECT a.nome
FROM compra c
INNER JOIN aluno a ON a.id_aluno = c.id_aluno
UNION
SELECT a.nome
FROM registro_pontos r
INNER JOIN aluno a ON a.id_aluno = r.id_aluno;
-- Linhas com UNION ALL: 27 (10 compras + 17 registros de pontos).
-- Linhas com UNION: 12.
-- Explicação: UNION ALL apenas empilha os dois resultados e mantém as duplicatas, ja que a cada
-- compra e cada registro de pontos gera uma linha, então o mesmo aluno aparece várias
-- vezes. UNION, além de empilhar, elimina as linhas repetidas e devolve
-- cada nome uma única vez: são 12 alunos diferentes que compraram ou receberam pontos
-- (só o Teddy Lupin não aparece em nenhum dos dois). Como o UNION precisa
-- ordenar/comparar para remover duplicatas, ele é mais custoso; o UNION ALL é mais
-- rápido quando as duplicatas não importam.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja' AS indicador, SUM(valor_total) AS valor FROM compra
UNION ALL
SELECT 'Folha salarial dos professores' AS indicador, SUM(salario) AS valor FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos' AS indicador, SUM(saldo_galeoes) AS valor FROM aluno;

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

