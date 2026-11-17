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
--SELECT * FROM hogwarts.vw_placar_casas;
--Funciona: filch tem SELECT nessa view. (A view roda com os privilégios do
--seu DEFINER, por isso filch não precisa de acesso à tabela casa.)
--SELECT * FROM hogwarts.aluno;
--Resultado : ERRO 1142 (42000): SELECT command denied to user 'filch'@'localhost' for
--table 'aluno'. Filch só recebeu SELECT na view; não tem nenhum privilégio
--sobre a tabela aluno (princípio do menor privilégio).

-- Questão 45
-- a) INSERT INTO hogwarts.registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
--    VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
--    Funciona; a Grifinória passa a ter 110 pontos.
-- b) UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;
--    ERRO 1142 (42000): UPDATE command denied to user 'mcgonagall'@'localhost'
--    for table 'casa'.

-- Como o trigger conseguiu atualizar a casa: Como o trigger conseguiu atualizar casa? Triggers executam com os privilégios
-- do seu DEFINER (quem criou o trigger, aqui o usuário administrador), e não
-- com os do usuário que disparou o INSERT. A McGonagall só precisa de INSERT em
-- registro_pontos; o UPDATE em casa é feito dentro do trigger com os direitos
-- do criador. Assim ela altera o placar só pelo caminho controlado (o
-- registro de pontos), nunca diretamente.

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

SHOW GRANTS FOR 'percy'@'localhost' USING 'monitor';

-- Vantagem dos papéis: as permissões são definidas uma única vez no papel e
-- depois atribuídas a quantos monitores forem necessários. Para mudar o acesso
-- de todos basta alterar o papel (GRANT/REVOKE no papel), em vez de repetir
-- para cada usuário. Isso reduz erros, facilita a auditoria e o onboarding
-- (novo monitor = um único GRANT do papel).

-- Questão 48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE 'monitor';
