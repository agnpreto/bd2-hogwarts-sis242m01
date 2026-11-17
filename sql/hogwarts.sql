-- =====================================================================
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

-- confirmação das tabelas
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
-- Confirmação: SELECT COUNT(*) de cada tabela
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
-- confirmação
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
-- confirmação
select nota from matricula where id_aluno = 1 and id_disc = 6;       -- 10.00
select count(*) from matricula where situacao = 'reprovado';         -- 7
select salario from professor where nome = 'minerva mcgonagall';     -- 10450.00
select preco from produto where nome_produto = 'sapo de chocolate';  -- 1.60

-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
delete from casa where nome_casa = 'sonserina';
-- Erro: error code 1451. cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: a sonserina tem alunos e um professor ligados a ela, e a chave estrangeira impede apagar a casa (pai) enquanto existirem filhos.
-- Questão 14
insert into aluno (nome, ano_escolar, id_casa) values ('dobby', 8, 1);
-- Erro: error code 3819. check constraint 'ck_aluno_ano' is violated
-- Explicação: o check só aceita ano_escolar entre 1 e 7, e o 8º ano está fora da faixa.
-- Questão 15
insert into aluno (nome, ano_escolar, id_casa, email)
values ('harry potter (polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- erro: error code 1062. duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- explicação: esse e-mail já pertence ao harry, e a restrição unique não permite e-mails repetidos.
-- Questão 16
delete from professor where nome = 'severo snape';
-- erro: error code 1451. cannot delete or update a parent row: a foreign key constraint fails
-- explicação: o snape é professor de poções (tabela disciplina), então a chave estrangeira bloqueia a exclusão.
-- Questão 17
delete from professor where nome = 'gilderoy lockhart';
-- explicação: funciona porque nenhuma disciplina nem registro de pontos aponta para ele. sem filhos, a chave estrangeira não é violada.
-- Questão 18
delete from matricula
where id_aluno in (select id_aluno from aluno where nome = 'vicente crabbe');
delete from aluno
where nome = 'vicente crabbe';
-- Questão 19
delete from disciplina
where id_disc not in (select id_disc from matricula);
-- confirmação
select count(*) from professor;   -- 8
select count(*) from aluno;       -- 13
select count(*) from disciplina;  -- 8
select count(*) from matricula;   -- 33
  
-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
delimiter $$
create trigger trg_pontos_casa
after insert on registro_pontos
for each row
begin
update casa
set pontos = pontos + new.pontos
where id_casa = (select id_casa from aluno where id_aluno = new.id_aluno);
end$$
delimiter ;
-- Questão 21 - trg_valida_compra
delimiter $$
create trigger trg_valida_compra
before insert on compra
for each row
begin
declare v_estoque int;
declare v_preco   decimal(10,2);
declare v_saldo   decimal(10,2);
select estoque, preco into v_estoque, v_preco
from produto
where id_produto = new.id_produto;
select saldo_galeoes into v_saldo
from aluno
where id_aluno = new.id_aluno;
if v_estoque < new.quantidade then
signal sqlstate '45000'
set message_text = 'estoque insuficiente no beco diagonal';
end if;
if v_saldo < v_preco * new.quantidade then
signal sqlstate '45000'
set message_text = 'galeões insuficientes no cofre do aluno';
end if;
set new.valor_total = v_preco * new.quantidade;
end$$
delimiter ;
-- Questão 22 - trg_baixa_compra
delimiter $$
create trigger trg_baixa_compra
after insert on compra
for each row
begin
update produto
set estoque = estoque - new.quantidade
where id_produto = new.id_produto;
update aluno
set saldo_galeoes = saldo_galeoes - new.valor_total
where id_aluno = new.id_aluno;
end$$
delimiter ;
-- Questão 23 - trg_situacao_nota
delimiter $$
create trigger trg_situacao_nota
before update on matricula
for each row
begin
if not (old.nota <=> new.nota) then
if new.nota >= 6 then
set new.situacao = 'aprovado';
else
set new.situacao = 'reprovado';
end if;
end if;
end$$
delimiter ;
-- Questão 24 - trg_audita_salario
delimiter $$
create trigger trg_audita_salario
after update on professor
for each row
begin
if old.salario <> new.salario then
insert into log_auditoria (tabela, operacao, descricao)
values ('professor', 'update',
concat(new.nome, ': salário de ', old.salario, ' para ', new.salario));
end if;
end$$
delimiter ;
-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: O BEFORE valida os dados (SIGNAL) e calcula o total antes de salvar, enquanto o AFTER dá baixa no estoque e no saldo apenas se a compra for confirmada.
-- testando os triggers
-- Questão 25 - INSERT registro_pontos
insert into registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) values
( 2, 3, 20, 'feitiço de levitação perfeito', '2026-09-10'),
( 1, 2, -10, 'atraso na aula de poções', '2026-09-12'),
( 5, 2, 15, 'poção do morto-vivo impecável', '2026-09-12'),
( 8, 5, 10, 'cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'ajudou os alunos do 1º ano', '2026-09-25'),
( 4, 4, 30, 'identificou uma mimbulus mimbletonia', '2026-10-02'),
( 6, 1, -20, 'fora da cama após o toque de recolher', '2026-10-05'),
( 1, 6, 50, 'conjurou um patrono corpóreo', '2026-10-15'),
( 9, 3, 15, 'duelo exemplar no clube de duelos', '2026-10-18'),
( 5, 1, -30, 'duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'colheita de mandrágoras', '2026-11-05'),
( 3, 9, 10, 'identificou um bezoar', '2026-11-06'),
( 8, 3, 20, 'resposta brilhante sobre o diadema', '2026-11-08'),
( 6, 2, 25, 'antídoto para venenos comuns', '2026-11-09'),
( 5, 9, 40, 'melhor poção do clube do slugue', '2026-11-09');
-- Questão 25 - INSERT compra
insert into compra (id_aluno, id_produto, quantidade, data_compra) values
( 5, 2, 1, '2026-09-01'),
( 2, 5, 2, '2026-09-02'),
( 1, 3, 10, '2026-09-03'),
( 3, 4, 5, '2026-09-03'),
( 9, 8, 1, '2026-09-15'),
( 8, 5, 1, '2026-09-20'),
(11, 1, 1, '2026-10-01'),
( 6, 3, 20, '2026-10-10'),
( 1, 7, 2, '2026-10-20'),
(13, 4, 10, '2026-11-02');
-- Questão 25 - Rony tenta comprar a Nimbus
insert into compra (id_aluno, id_produto, quantidade, data_compra)
-- values (3, 2, 1, '2026-11-10');
-- resultado: error code 1644. galeões insuficientes no cofre do aluno
-- (o estoque da nimbus ainda tinha 2, mas o rony só tem 12 galeões e a vassoura custa 300.)
-- Questão 25 - Hermione tenta comprar o caldeirão
insert into compra (id_aluno, id_produto, quantidade, data_compra)
-- values (2, 6, 1, '2026-11-10');
-- resultado: error code 1644. estoque insuficiente no beco diagonal
-- (o caldeirão tem estoque 0. o estoque é verificado primeiro, por isso o erro não é de saldo.)
-- Questão 25 - Recuperação do Rony em Poções
update matricula
set nota = 6.5
where id_aluno = 3 and id_disc = 2;
select id_aluno, id_disc, nota, situacao
from matricula
where id_aluno = 3 and id_disc = 2;
-- resultado: situacao passou de 'reprovado' para 'aprovado', sem mexer na coluna situacao (trg_situacao_nota).
-- Questão 25 - Salário e data de admissão do Hagrid
update professor set salario = 5000.00 where nome = 'rúbeo hagrid';
update professor set data_admissao = '1993-08-15' where nome = 'rúbeo hagrid';
select * from log_auditoria;
-- Linhas em log_auditoria:
-- Por que o reajuste da questão 10 não aparece:
-- O reajuste anterior não aparece porque foi feito antes da criação do trigger, e a alteração na data de admissão também não gera log porque não mudou o salário.
-- confirmação
select nome_casa, pontos from casa order by pontos desc;
-- grifinória 100, corvinal 50, lufa-lufa 35, sonserina 30
select nome, saldo_galeoes from aluno where id_aluno in (1, 5);
-- draco 200.00, harry 54.00
select nome_produto, estoque from produto where id_produto in (2, 3);
-- nimbus 2, sapo de chocolate 170
select sum(valor_total) from compra;   -- 474.00
select count(*) from log_auditoria;    -- 1

-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
start transaction;
update aluno set saldo_galeoes = saldo_galeoes - 50 where nome = 'draco malfoy';
update aluno set saldo_galeoes = saldo_galeoes + 50 where nome = 'pansy parkinson';
commit;
select nome, saldo_galeoes from aluno where nome in ('draco malfoy', 'pansy parkinson');
-- draco 150.00, pansy 168.00
-- Questão 27
start transaction;
update casa set pontos = 0;
select nome_casa, pontos from casa;   -- todas zeradas
rollback;
select nome_casa, pontos from casa;   -- o placar voltou ao que era antes
-- Questão 28
start transaction;
insert into compra (id_aluno, id_produto, quantidade, data_compra)
values (1, 1, 1, '2026-11-10');
select saldo_galeoes from aluno where id_aluno = 1;       -- 47.00
select estoque from produto where id_produto = 1;         -- 8
rollback;
select saldo_galeoes from aluno where id_aluno = 1;       -- 54.00
select estoque from produto where id_produto = 1;         -- 9
-- Questão 29
start transaction;
insert into registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
values (12, 4, 15, 'cuidou das estufas no feriado', '2026-11-10');
savepoint sp_pontos_legitimos;
insert into registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
values (6, 2, 100, 'favoritismo descarado', '2026-11-10');
rollback to sp_pontos_legitimos;
commit;
select nome_casa, pontos from casa;
-- grifinória 100, corvinal 50, lufa-lufa 50, sonserina 30
select count(*) from registro_pontos;  
-- Questão 30
select @@autocommit;
-- Resposta: O valor 1 indica que o autocommit está ligado, exigindo START TRANSACTION para agrupar comandos, mas usar um comando DDL (como CREATE TABLE) no meio gera um commit implícito e impede que o ROLLBACK desfaça as ações anteriores.

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------
-- 6.1
select p.nome, p.salario
from professor p
where p.salario between 6000.00 and 9000.00
order by p.salario desc;
-- 6.2
select a.nome, a.ano_escolar
from aluno a
where a.ano_escolar in (1, 4, 6, 7)
order by a.ano_escolar;
-- 6.3
select a.nome
from aluno a
where a.nome like '_a%';
-- 6.4
select d.nome_disc
from disciplina d
where d.id_prof is null;
-- 6.5
select p.nome_produto, p.preco
from produto p
where p.preco not between 5 and 20
order by p.preco;
-- 6.6
select distinct p.loja
from produto p
order by p.loja;
-- ---------- Nível 2: JOINs ----------
-- 6.7
select a.nome as aluno, c.nome_casa as casa
from aluno a
inner join casa c on c.id_casa = a.id_casa
order by c.nome_casa, a.nome;
-- Quantos alunos e por quê: São 12 alunos, pois o INNER JOIN traz apenas registros com correspondência nas duas tabelas, deixando de fora o Teddy Lupin (que está com id_casa nulo).
-- 6.8
select a.nome as aluno,
coalesce(c.nome_casa, 'aguardando o chapéu seletor') as casa
from aluno a
left join casa c on c.id_casa = a.id_casa
order by a.nome;
-- 6.9
select p.nome as professor
from disciplina d
right join professor p on p.id_prof = d.id_prof
where d.id_disc is null;
-- 6.10
select a.nome as aluno,
d.nome_disc as disciplina,
p.nome as professor,
m.nota,
m.situacao
from aluno a
inner join casa c       on c.id_casa = a.id_casa
inner join matricula m  on m.id_aluno = a.id_aluno
inner join disciplina d on d.id_disc = m.id_disc
left join professor p  on p.id_prof = d.id_prof
where c.nome_casa = 'grifinória'
order by a.nome, d.nome_disc;
-- 6.11
select c.id_compra as numero_compra,
a.nome as aluno,
p.nome_produto as produto,
p.loja,
c.quantidade,
c.valor_total,
c.data_compra
from compra c
inner join aluno a   on a.id_aluno = c.id_aluno
inner join produto p on p.id_produto = c.id_produto
order by c.data_compra, c.id_compra;
-- ---------- Nível 3: agrupamento e agregação ----------
-- 6.12
select d.nome_disc as disciplina,
count(*) as qtd_alunos,
round(avg(m.nota), 2) as media,
max(m.nota) as maior_nota,
min(m.nota) as menor_nota
from disciplina d
inner join matricula m on m.id_disc = d.id_disc
group by d.id_disc, d.nome_disc
having avg(m.nota) >= 7
order by media desc;
-- 6.13
select c.nome_casa as casa,
count(*) as qtd_registros,
sum(case when r.pontos > 0 then r.pontos else 0 end) as pontos_ganhos,
sum(case when r.pontos < 0 then r.pontos else 0 end) as pontos_perdidos,
sum(r.pontos) as saldo
from registro_pontos r
inner join aluno a on a.id_aluno = r.id_aluno
inner join casa c  on c.id_casa = a.id_casa
group by c.id_casa, c.nome_casa
order by saldo desc;
-- 6.14
select p.loja,
count(*) as qtd_compras,
sum(c.valor_total) as faturamento
from compra c
inner join produto p on p.id_produto = c.id_produto
group by p.loja
having sum(c.valor_total) > 20
order by faturamento desc;
-- 6.15
select month(r.data_registro) as mes,
count(*) as qtd_registros,
sum(r.pontos) as total_pontos
from registro_pontos r
group by month(r.data_registro)
order by mes;
-- 6.16
select p.nome as professor,
count(*) as qtd_registros,
sum(r.pontos) as total_concedido
from registro_pontos r
inner join professor p on p.id_prof = r.id_prof
group by p.id_prof, p.nome
having count(*) >= 2
order by total_concedido desc;
-- ---------- Nível 4: subconsultas ----------
-- 6.17
select a.nome
from aluno a
 where a.id_aluno in (
select c.id_aluno
from compra c
where c.id_produto in (
select p.id_produto
from produto p
where p.loja = 'dedosdemel'));
-- 6.18
select p.nome_produto, p.estoque
from produto p
where p.id_produto not in (select c.id_produto from compra c);
-- 6.19
select a.nome, a.saldo_galeoes
from aluno a
where a.saldo_galeoes > (select avg(saldo_galeoes) from aluno);
-- 6.20
select p.nome, p.salario
from professor p
where p.salario > all (select salario from professor where id_casa is null);
-- 6.21
select a.nome, a.saldo_galeoes
from aluno a
where a.id_casa <> (select id_casa from casa where nome_casa = 'sonserina')
and a.saldo_galeoes > any (
select a2.saldo_galeoes
from aluno a2
where a2.id_casa = (select id_casa from casa where nome_casa = 'sonserina'));
-- > ANY equivale a: comparar com o menor valor da subconsulta (basta ser maior que algum, ou seja, maior que o mínimo). aqui o menor saldo da sonserina é 150.
-- 6.22
select c.nome_casa
from casa c
where exists (
select 1
from aluno a
inner join matricula m on m.id_aluno = a.id_aluno
where a.id_casa = c.id_casa
and m.nota = 10);
-- 6.23
select a.nome
from aluno a
where not exists (
select 1
from compra c
where c.id_aluno = a.id_aluno);
-- 6.24
select c.nome_casa as casa,
round(avg(t.media_aluno), 2) as media_casa
from (select a.id_aluno, a.id_casa, avg(m.nota) as media_aluno
from aluno a
inner join matricula m on m.id_aluno = a.id_aluno
group by a.id_aluno, a.id_casa) t
inner join casa c on c.id_casa = t.id_casa
group by c.id_casa, c.nome_casa
order by media_casa desc;
-- ---------- Nível 5: UNION ALL ----------
-- 6.25
select a.nome, 'aluno' as vinculo from aluno a
union all
select p.nome, 'professor' as vinculo from professor p
order by nome;
-- 6.26
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from compra)
union all
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from registro_pontos);
-- Linhas com UNION ALL:
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from compra)
union all
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from registro_pontos);
-- Linhas com UNION:
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from compra)
union
select a.nome
from aluno a
where a.id_aluno in (select id_aluno from registro_pontos);
-- Explicação: O UNION ALL mantém todas as linhas (inclusive duplicadas), enquanto o UNION remove as repetições e exibe cada aluno apenas uma vez.
-- 6.27
select 'total de pontos distribuídos' as indicador, sum(pontos) as valor from registro_pontos
union all
select 'total de galeões gastos na loja', sum(valor_total) from compra
union all
select 'folha salarial dos professores', sum(salario) from professor
union all
select 'total de galeões nos cofres dos alunos', sum(saldo_galeoes) from aluno;
-- folha salarial: 61260.00

-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
create view vw_placar_casas as
select c.nome_casa, c.pontos
from casa c
order by c.pontos desc;
-- Questão 32
create view vw_boletim as
select a.nome as aluno,
coalesce(c.nome_casa, 'sem casa') as casa,
d.nome_disc as disciplina,
coalesce(p.nome, 'sem professor') as professor,
m.nota,
m.situacao
from matricula m
inner join aluno a      on a.id_aluno = m.id_aluno
inner join disciplina d on d.id_disc = m.id_disc
left join casa c       on c.id_casa = a.id_casa
left join professor p  on p.id_prof = d.id_prof;
-- Questão 33
create view vw_extrato_loja as
select a.nome as aluno,
p.nome_produto as produto,
p.loja,
c.quantidade,
c.valor_total,
c.data_compra
from compra c
inner join aluno a   on a.id_aluno = c.id_aluno
inner join produto p on p.id_produto = c.id_produto;
-- Questão 34
create view vw_alunos_destaque as
select a.nome as aluno,
c.nome_casa as casa,
round(avg(m.nota), 2) as media
from aluno a
inner join matricula m on m.id_aluno = a.id_aluno
left join casa c      on c.id_casa = a.id_casa
group by a.id_aluno, a.nome, c.nome_casa
having avg(m.nota) >= 8;
-- Questão 35
create view vw_quadro_professores as
select p.nome as professor,
coalesce(c.nome_casa, 'não é diretor') as casa_que_dirige,
(select count(*) from disciplina d where d.id_prof = p.id_prof) as qtd_disciplinas,
coalesce((select sum(r.pontos) from registro_pontos r where r.id_prof = p.id_prof), 0) as total_pontos_concedidos
from professor p
left join casa c on c.id_casa = p.id_casa;
-- Questão 36
select * from vw_placar_casas;
select * from vw_boletim where casa = 'corvinal';
select loja, sum(valor_total) as total_faturado
from vw_extrato_loja
group by loja
order by total_faturado desc;
select * from vw_alunos_destaque order by media desc;
select * from vw_quadro_professores order by total_pontos_concedidos desc;
-- Questão 37
insert into registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
values (11, 1, 20, 'venceu a primeira tarefa do torneio', '2026-11-10');
select * from vw_placar_casas;
-- O que mudou e por quê: O trigger trg_pontos_casa atualizou a pontuação da Lufa-Lufa de 50 para 70 na tabela casa, e a view já exibe o novo valor automaticamente por não armazenar dados e reexecutar a consulta a cada acesso.
-- Questão 38
create or replace view vw_placar_casas as
select c.nome_casa, c.fundador, c.pontos
from casa c
order by c.pontos desc;
select * from vw_placar_casas;

-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
create user 'filch'@'localhost' identified by 'MadameNorra#1';
create user 'mcgonagall'@'localhost' identified by 'Animago#Gato1';
create user 'dumbledore'@'localhost' identified by 'Fenix#Fawkes1';
-- Questão 40
grant select on hogwarts.vw_placar_casas to 'filch'@'localhost';
-- Questão 41
grant select, insert on hogwarts.registro_pontos to 'mcgonagall'@'localhost';
grant select on hogwarts.aluno to 'mcgonagall'@'localhost';
grant select on hogwarts.vw_boletim to 'mcgonagall'@'localhost';
-- Questão 42
grant all privileges on hogwarts.* to 'dumbledore'@'localhost' with grant option;
-- Questão 43
show grants for 'filch'@'localhost';
show grants for 'mcgonagall'@'localhost';
-- Questão 44
select * from vw_placar_casas;
-- resultado: funciona e mostra o placar.
select * from aluno;
-- Questão 45
insert into registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
values (2, 1, 10, 'ajudou um colega em transfiguração', '2026-11-10');
update casa set pontos = 1000 where id_casa = 1;
select nome_casa, pontos from casa;   -- grifinória 110
-- Questão 46
revoke insert on hogwarts.registro_pontos from 'mcgonagall'@'localhost';
show grants for 'mcgonagall'@'localhost';
-- Questão 47
create role 'monitor';
grant select on hogwarts.vw_boletim to 'monitor';
grant select on hogwarts.vw_placar_casas to 'monitor';
create user 'percy'@'localhost' identified by 'Monitor#Chefe1';
grant 'monitor' to 'percy'@'localhost';
set default role 'monitor' to 'percy'@'localhost';
show grants for 'percy'@'localhost' using 'monitor';
-- Vantagem dos papéis: Centralizar permissões em um único papel (role) permite conceder e atualizar o acesso de todos os monitores de uma vez, sem repetir GRANT por usuário.
-- Questão 48
drop user 'filch'@'localhost';
drop user 'mcgonagall'@'localhost';
drop user 'dumbledore'@'localhost';
drop user 'percy'@'localhost';
drop role 'monitor';