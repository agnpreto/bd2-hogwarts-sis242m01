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

-- Conferência das alterações
DESC aluno;
DESC matricula;
DESC produto;
DESC casa;
DESC professor;


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
                  WHERE id_prof = (SELECT id_prof
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

-- Confira: Harry = 10.00 em Defesa; 7 reprovadas; McGonagall = 10450.00; Sapo = 1.60
SELECT nota FROM matricula WHERE id_aluno = 1 AND id_disc = 6;
SELECT COUNT(*) AS reprovadas FROM matricula WHERE situacao = 'Reprovado';
SELECT salario FROM professor WHERE nome = 'Minerva McGonagall';
SELECT preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';
