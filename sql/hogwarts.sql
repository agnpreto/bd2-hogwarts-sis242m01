-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT c.nome_casa, c.pontos
FROM casa c
ORDER BY c.pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
JOIN aluno a       ON a.id_aluno = m.id_aluno
JOIN disciplina d  ON d.id_disc  = m.id_disc
LEFT JOIN casa c   ON c.id_casa  = a.id_casa
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a    ON a.id_aluno    = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN casa c      ON c.id_casa  = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;


-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*)
        FROM disciplina d
        WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       (SELECT COALESCE(SUM(r.pontos), 0)
        FROM registro_pontos r
        WHERE r.id_prof = p.id_prof) AS total_pontos_concedidos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questão 36
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja
ORDER BY total_faturado DESC;

SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas;

-- O que mudou e por quê: a Lufa-Lufa passou de 50 para 70 pontos. A view não guarda dados:
-- ela é apenas uma consulta salva e roda sobre a tabela casa a cada uso. O
-- trigger atualizou casa.pontos e a view já refletiu isso, sem ser recriada.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT c.nome_casa, c.fundador, c.pontos
FROM casa c
ORDER BY c.pontos DESC;

SELECT * FROM vw_placar_casas;
