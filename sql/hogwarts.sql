=====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (SIS242M01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Julyan Eric Lopes Pinto
-- Matrícula: 2422084
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
create table casa (
  id_casa   int auto_increment primary key,
  nome_casa varchar(30) not null unique,
  fundador  varchar(60),
  pontos    int default 0
);
-- Tabela professor
create table professor (
  id_prof          int auto_increment primary key,
  nome             varchar(100) not null,
  salario          decimal(10,2),
  data_contratacao date,
  id_casa          int,
  constraint ck_prof_salario check (salario > 0),
  constraint fk_prof_casa foreign key (id_casa) references casa(id_casa)
);
-- Tabela disciplina
create table disciplina (
  id_disc    int auto_increment primary key,
  nome_disc  varchar(60) not null unique,
  ano_minimo int,
  id_prof    int,
  constraint ck_disc_ano check (ano_minimo between 1 and 7),
  constraint fk_disc_prof foreign key (id_prof) references professor(id_prof)
);
-- Tabela aluno
create table aluno (
  id_aluno      int auto_increment primary key,
  nome          varchar(100) not null,
  ano_escolar   int,
  id_casa       int,
  saldo_galeoes decimal(10,2) default 0,
  constraint ck_aluno_ano check (ano_escolar between 1 and 7),
  constraint ck_aluno_saldo check (saldo_galeoes >= 0),
  constraint fk_aluno_casa foreign key (id_casa) references casa(id_casa)
);
-- Tabela matricula
create table matricula (
  id_aluno int,
  id_disc  int,
  nota     decimal(4,2),
  constraint pk_matricula primary key (id_aluno, id_disc),
  constraint ck_matricula_nota check (nota between 0 and 10),
  constraint fk_matricula_aluno foreign key (id_aluno) references aluno(id_aluno),
  constraint fk_matricula_disc foreign key (id_disc) references disciplina(id_disc)
);
-- Tabela registro_pontos
create table registro_pontos (
  id_registro   int auto_increment primary key,
  id_aluno      int not null,
  id_prof       int not null,
  pontos        int not null,
  motivo        varchar(150),
  data_registro date not null,
  constraint fk_pontos_aluno foreign key (id_aluno) references aluno(id_aluno),
  constraint fk_pontos_prof foreign key (id_prof) references professor(id_prof)
);
-- Tabela produto
create table produto (
  id_produto   int auto_increment primary key,
  nome_produto varchar(100) not null,
  loja         varchar(50) not null,
  preco        decimal(10,2),
  estoque      int default 0,
  constraint ck_produto_preco check (preco > 0),
  constraint ck_produto_estoque check (estoque >= 0)
);
-- Tabela compra
create table compra (
  id_compra   int auto_increment primary key,
  id_aluno    int,
  id_produto  int,
  quantidade  int,
  valor_total decimal(10,2),
  data_compra date not null,
  constraint ck_compra_quantidade check (quantidade > 0),
  constraint fk_compra_aluno foreign key (id_aluno) references aluno(id_aluno),
  constraint fk_compra_produto foreign key (id_produto) references produto(id_produto)
);
-- Tabela log_auditoria
create table log_auditoria (
  id_log    int auto_increment primary key,
  tabela    varchar(30),
  operacao  varchar(10),
  descricao varchar(255),
  data_hora datetime default current_timestamp
);
-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: A chave composta (id_aluno, id_disc) resolve a relação N:N e garante que um mesmo aluno não seja matriculado duas vezes na mesma disciplina, evitando dados duplicados e colunas extras desnecessárias.

show tables;

-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
insert into casa (nome_casa, fundador) values
('grifinória', 'godric gryffindor'),    -- 1
('sonserina', 'salazar slytherin'),     -- 2
('corvinal', 'rowena ravenclaw'),       -- 3
('lufa-lufa', 'helga hufflepuff');      -- 4
-- INSERT professor
insert into professor (nome, salario, data_contratacao, id_casa) values
('minerva mcgonagall', 9500.00, '1956-12-01', 1),   -- 1
('severo snape', 8800.00, '1981-09-01', 2),         -- 2
('fílio flitwick', 8200.00, '1974-09-01', 3),       -- 3
('pomona sprout', 7900.00, '1972-09-01', 4),        -- 4
('rúbeo hagrid', 4500.00, '1993-09-01', null),      -- 5
('remo lupin', 6200.00, '1993-09-01', null),        -- 6
('sibila trelawney', 5100.00, '1980-09-01', null),  -- 7
('gilderoy lockhart', 7000.00, '1992-09-01', null), -- 8
('horácio slughorn', 8000.00, '1996-09-01', null);  -- 9
-- INSERT disciplina
insert into disciplina (nome_disc, ano_minimo, id_prof) values
('transfiguração', 1, 1),                        -- 1
('poções', 1, 2),                                -- 2
('feitiços', 1, 3),                              -- 3
('herbologia', 1, 4),                            -- 4
('trato das criaturas mágicas', 3, 5),           -- 5
('defesa contra as artes das trevas', 1, 6),     -- 6
('adivinhação', 3, 7),                           -- 7
('estudo dos trouxas', 3, null),                 -- 8
('runas antigas', 3, null);                      -- 9
-- INSERT aluno
insert into aluno (nome, ano_escolar, id_casa, saldo_galeoes) values
('harry potter', 5, 1, 120.00),         -- 1
('hermione granger', 5, 1, 85.00),      -- 2
('rony weasley', 5, 1, 12.00),          -- 3
('neville longbottom', 5, 1, 30.00),    -- 4
('draco malfoy', 5, 2, 500.00),         -- 5
('pansy parkinson', 5, 2, 150.00),      -- 6
('vicente crabbe', 5, 2, 40.00),        -- 7
('luna lovegood', 4, 3, 45.00),         -- 8
('cho chang', 6, 3, 200.00),            -- 9
('padma patil', 5, 3, 60.00),           -- 10
('cedrico diggory', 7, 4, 180.00),      -- 11
('ana abbott', 5, 4, 25.00),            -- 12
('ernesto macmillan', 5, 4, 70.00),     -- 13
('teddy lupin', 1, null, 0.00);         -- 14 (ainda não passou pelo chapéu seletor)
-- INSERT matricula
insert into matricula (id_aluno, id_disc, nota) values
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
insert into produto (nome_produto, loja, preco, estoque) values
('varinha de azevinho', 'olivaras', 7.00, 10),                        -- 1
('vassoura nimbus 2001', 'artigos de quadribol', 300.00, 3),          -- 2
('sapo de chocolate', 'dedosdemel', 2.00, 200),                       -- 3
('feijõezinhos de todos os sabores', 'dedosdemel', 1.50, 150),        -- 4
('livro monstruoso dos monstros', 'floreios e borrões', 12.00, 20),   -- 5
('caldeirão de estanho', 'caldeirões potage', 9.00, 0),               -- 6
('kit de logros', 'gemialidades weasley', 25.00, 40),                 -- 7
('pena de repetição rápida', 'escribbulus', 15.00, 5);                -- 8
-- Confira: SELECT COUNT(*) de cada tabela
select count(*) from casa;        -- 4
select count(*) from professor;   -- 9
select count(*) from disciplina;  -- 9
select count(*) from aluno;       -- 14
select count(*) from matricula;   -- 35
select count(*) from produto;     -- 8


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
insert into casa (nome_casa, fundador) values
('grifinória', 'godric gryffindor'),    -- 1
('sonserina', 'salazar slytherin'),     -- 2
('corvinal', 'rowena ravenclaw'),       -- 3
('lufa-lufa', 'helga hufflepuff');      -- 4
-- INSERT professor
insert into professor (nome, salario, data_contratacao, id_casa) values
('minerva mcgonagall', 9500.00, '1956-12-01', 1),   -- 1
('severo snape', 8800.00, '1981-09-01', 2),         -- 2
('fílio flitwick', 8200.00, '1974-09-01', 3),       -- 3
('pomona sprout', 7900.00, '1972-09-01', 4),        -- 4
('rúbeo hagrid', 4500.00, '1993-09-01', null),      -- 5
('remo lupin', 6200.00, '1993-09-01', null),        -- 6
('sibila trelawney', 5100.00, '1980-09-01', null),  -- 7
('gilderoy lockhart', 7000.00, '1992-09-01', null), -- 8
('horácio slughorn', 8000.00, '1996-09-01', null);  -- 9
-- INSERT disciplina
insert into disciplina (nome_disc, ano_minimo, id_prof) values
('transfiguração', 1, 1),                        -- 1
('poções', 1, 2),                                -- 2
('feitiços', 1, 3),                              -- 3
('herbologia', 1, 4),                            -- 4
('trato das criaturas mágicas', 3, 5),           -- 5
('defesa contra as artes das trevas', 1, 6),     -- 6
('adivinhação', 3, 7),                           -- 7
('estudo dos trouxas', 3, null),                 -- 8
('runas antigas', 3, null);                      -- 9
-- INSERT aluno
insert into aluno (nome, ano_escolar, id_casa, saldo_galeoes) values
('harry potter', 5, 1, 120.00),         -- 1
('hermione granger', 5, 1, 85.00),      -- 2
('rony weasley', 5, 1, 12.00),          -- 3
('neville longbottom', 5, 1, 30.00),    -- 4
('draco malfoy', 5, 2, 500.00),         -- 5
('pansy parkinson', 5, 2, 150.00),      -- 6
('vicente crabbe', 5, 2, 40.00),        -- 7
('luna lovegood', 4, 3, 45.00),         -- 8
('cho chang', 6, 3, 200.00),            -- 9
('padma patil', 5, 3, 60.00),           -- 10
('cedrico diggory', 7, 4, 180.00),      -- 11
('ana abbott', 5, 4, 25.00),            -- 12
('ernesto macmillan', 5, 4, 70.00),     -- 13
('teddy lupin', 1, null, 0.00);         -- 14 (ainda não passou pelo chapéu seletor)
-- INSERT matricula
insert into matricula (id_aluno, id_disc, nota) values
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
insert into produto (nome_produto, loja, preco, estoque) values
('varinha de azevinho', 'olivaras', 7.00, 10),                        -- 1
('vassoura nimbus 2001', 'artigos de quadribol', 300.00, 3),          -- 2
('sapo de chocolate', 'dedosdemel', 2.00, 200),                       -- 3
('feijõezinhos de todos os sabores', 'dedosdemel', 1.50, 150),        -- 4
('livro monstruoso dos monstros', 'floreios e borrões', 12.00, 20),   -- 5
('caldeirão de estanho', 'caldeirões potage', 9.00, 0),               -- 6
('kit de logros', 'gemialidades weasley', 25.00, 40),                 -- 7
('pena de repetição rápida', 'escribbulus', 15.00, 5);                -- 8
-- Confira: SELECT COUNT(*) de cada tabela
select count(*) from casa;        -- 4
select count(*) from professor;   -- 9
select count(*) from disciplina;  -- 9
select count(*) from aluno;       -- 14
select count(*) from matricula;   -- 35
select count(*) from produto;     -- 8

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- 2.1 alterações de estrutura (alter table)
-- Questão 1
alter table aluno add column email varchar(100);
-- Questão 2
alter table matricula add column situacao varchar(20) default 'cursando';
-- Questão 3
alter table produto add column ativo char(1) default 's';
-- Questão 4
alter table casa modify column fundador varchar(100);
-- Questão 5
alter table professor rename column data_contratacao to data_admissao;
-- confira
desc aluno;
desc matricula;
desc produto;
desc casa;
desc professor;
-- 2.2 atualizações de dados (update)
-- Questão 6
update aluno
set email = concat(lower(replace(nome, ' ', '.')), '@hogwarts.edu');
-- Questão 7
alter table aluno
add constraint uq_aluno_email unique (email);
-- Questão 8
update matricula
set nota = least(nota + 0.5, 10)
 where id_disc in (
 select id_disc
 from disciplina
 where id_prof in (select id_prof from professor where nome = 'remo lupin')
 );
-- Questão 9
update matricula
set situacao = case
when nota >= 6 then 'aprovado'
else 'reprovado'
end;
-- Questão 10
update professor
set salario = salario * 1.10
where id_casa is not null
and data_admissao < '1980-01-01';
-- Questão 11
update produto
set ativo = 'n'
 where estoque = 0;
-- Questão 12
update produto
set preco = preco * 0.80
where loja = 'dedosdemel';
-- confira
select nota from matricula where id_aluno = 1 and id_disc = 6;       -- 10.00
select count(*) from matricula where situacao = 'reprovado';         -- 7
select salario from professor where nome = 'minerva mcgonagall';     -- 10450.00
select preco from produto where nome_produto = 'sapo de chocolate';  -- 1.60

-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- Erro:
-- Explicação:

-- Questão 14
-- Erro:
-- Explicação:

-- Questão 15
-- Erro:
-- Explicação:

-- Questão 16
-- Erro:
-- Explicação:

-- Questão 17

-- Questão 18

-- Questão 19


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

