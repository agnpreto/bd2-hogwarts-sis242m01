-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- Erro:  DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- ERRO 1451 (23000): Cannot delete or update a parent row: a foreign key
-- constraint fails (`hogwarts`.`aluno`, CONSTRAINT `fk_aluno_casa`
-- FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- (o MySQL pode citar `professor`/`fk_prof_casa`, pois o Snape dirige a casa).

--  Explicação: a Sonserina é "pai" de registros em aluno (Draco, Pansy, Crabbe) e
--  em professor (Snape). Excluí-la deixaria alunos apontando para uma casa
--  inexistente (registros órfãos); a FK protege a integridade referencial.

-- Questão 14
-- Erro:  INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes)
-- VALUES ('Dobby', 8, 1, 0);
-- ERRO 3819 (HY000): Check constraint 'chk_aluno_ano' is violated.

-- Explicação: ano_escolar deve estar entre 1 e 7 e o 8 viola o CHECK.

-- Questão 15
-- Erro:  INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0, 'harry.potter@hogwarts.edu');
-- ERRO 1062 (23000): Duplicate entry 'harry.potter@hogwarts.edu' for key
-- 'aluno.uq_aluno_email'.

-- Explicação: a restrição UNIQUE uq_aluno_email não permite e-mails repetidos, e
-- esse e-mail já pertence ao Harry Potter (id 1).

-- Questão 16
-- Erro: DELETE FROM professor WHERE nome = 'Severo Snape';
-- ERRO 1451 (23000): Cannot delete or update a parent row: a foreign key
--   constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `fk_disc_prof`
--   FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`)).

-- Explicação: Snape é o professor da disciplina Poções (disciplina.id_prof = 2).
-- Remover o professor deixaria a disciplina apontando para ninguém.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';

-- Funciona porque nenhuma outra tabela referencia o id 8 de Lockhart (ele não
-- ministra disciplina e ainda não há registro de pontos dele). Sem filhos, não
-- há violação de FK. O Snape falhou justamente por ter a disciplina Poções.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira: 8 professores, 13 alunos, 8 disciplinas, 33 matrículas
SELECT (SELECT COUNT(*) FROM professor)  AS professores,
       (SELECT COUNT(*) FROM aluno)      AS alunos,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM matricula)  AS matriculas;
