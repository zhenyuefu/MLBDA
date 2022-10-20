CREATE TYPE etudiant AS OBJECT
(
    numero  Number(7),
    annee   Number(4),
    nom     Varchar2(30),
    age     Number(3),
    contrat unites,
    MEMBER FUNCTION notes RETURN ensc1
);
/
CREATE TYPE etudiants AS Table Of Ref etudiant;
/
CREATE TYPE unites AS Table Of Ref unite;
/
CREATE TYPE unite AS OBJECT
(
    nom          Varchar2(30), --example MLBDA
    code         Varchar2(5),  --example 4I801
    credit       Number,
    contenu      seances,
    noteinscrits ensc2
);
/
CREATE TYPE seances AS Table Of seance;
/
CREATE TYPE seance AS OBJECT
(
    numero   Number,
    sujet    Varchar2(30),
    presents etudiants
);
/

CREATE TYPE c2 AS OBJECT
(
    etu  Ref etudiant,
    note Number
);
/
CREATE TYPE ensc2 AS Table Of c2;

CREATE TABLE lesue OF unite
    NESTED TABLE contenu STORE AS t1
        (NESTED TABLE presents STORE AS t11)
    NESTED TABLE noteinscrits STORE AS t2;
/
CREATE TABLE lesetudiants OF etudiant
    NESTED TABLE contrat STORE AS t3;

INSERT INTO lesue
VALUES (unite('MLBDA', '4I801', 6, seances(
        seance(1, 'SQL', etudiants()),
        seance(2, 'SQL3', etudiants()),
        seance(3, 'XML', etudiants())
    ), ensc2()));

INSERT INTO lesue
VALUES (unite('PLDAC', '4I101', 6, seances(
        seance(1, 'Intro', NULL),
        seance(2, 'Methodologie', NULL)
    ), NULL));

INSERT INTO lesetudiants
VALUES (etudiant(123, 2022, 'Alice', 28, unites((SELECT REF(u) FROM lesue u WHERE u.code = '4I801'),
                                                (SELECT REF(u) FROM lesue u WHERE u.code = '4I101'))));

INSERT INTO TABLE (
    SELECT s.presents
    FROM lesue u,
         TABLE (u.contenu) s
    WHERE u.nom = 'MLBDA'
      AND s.numero = 3
    )
VALUES ((SELECT REF(e) FROM lesetudiants e WHERE e.nom = 'Alice'));

SELECT e.nom, VALUE(c).nom
FROM lesetudiants e,
     TABLE (e.contrat) c,
     lesue u,
     TABLE (u.contenu) s,
     TABLE (s.presents) p
WHERE VALUE(p) = REF(e)
  AND u.nom = 'MLBDA'
  AND s.numero = 3;

-- Pour chaque séance de chaque unité d’enseignement, quel est le nombre de présents? Afficher le code de l’unité, le numéro de la séance et le nombre de présents.
SELECT u.code, s.numero AS nemero_scance, COUNT(*) AS nombre_present
FROM lesue u,
     TABLE (u.contenu) s,
     TABLE (s.presents) p
GROUP BY u.code, s.numero;

SELECT u.code,
       s.numero,
       (SELECT COUNT(VALUE(p))
        FROM TABLE (s.presents) p)
FROM lesue u,
     TABLE (u.contenu) s;

-- On considère la méthode créditTotal() du type Etudiant, retournant la somme des crédits des unités d’enseignement pour lesquelles l’étudiant a une note supérieure ou égale à 10 (en supposant qu’on connait les notes d’un étudiant).
-- a) Afficher le nom et le crédit total des étudiants qui ont un crédit total supérieur à 600.
SELECT e.nom, e.credittotal()
FROM lesetudiants e
WHERE e.credittotal() > 600;
-- b) On considère la méthode nbUCommunes qui renvoie le nombre d’unités d’enseignement communes entre 2 étudiants. En invoquant cette méthode, écrire la requête qui affiche les paires d’objets étudiants qui ont 10 unités en commun. La signature de nbUCommunes est .
-- Member function nbUCommune(Etudiant e) return number ;
SELECT VALUE(e1), VALUE(e2)
FROM lesetudiants e1,
     lesetudiants e2
WHERE REF(e1) < REF(e2)
  AND e1.nbucommune(e2) = 10;

-- c) On complète le type Etudiant avec la méthode notes() qui retourne l’ensemble des couples (codeU, note) de l’étudiant, et dont la signature est :
-- member function notes return EnsC1;
-- en supposant que les types EnsC1 et C1 ont préalablement été définis comme suit :
CREATE TYPE c1 AS OBJECT
(
    code Varchar2(30),
    note Number
); -- un couple (code unité, note)
/
CREATE TYPE ensc1 AS Table Of c1; -- un ensemble de couples
/
-- En invoquant la méthode `notes()`, écrire la requête : quel est le code des unités d’enseignement où l’étudiant numéro 3456 a une note inférieure à 10 ? Ne pas afficher les notes mais seulement le code des unités.
SELECT c.code
FROM lesetudiants e,
     TABLE (e.notes()) c --c type C1
WHERE e.numero = 3456
  AND VALUE(c).note < 10;

-- On connait les notes des étudiants inscrits à cette unité :
-- Écrire le corps de la méthode notes (définie dans la question précédente) du type Etudiant.
CREATE OR REPLACE TYPE BODY etudiant AS
    MEMBER FUNCTION notes RETURN ensc1 IS
        ens ensc1;
    BEGIN
        SELECT c1(VALUE(u).code, c.note) BULK COLLECT
        INTO ens -- bulk collect 可以一次性把数据插入
        FROM TABLE (self.contrat) u,
             TABLE (VALUE(u).noteinscrits) c
        WHERE self = DEREF(c.etu);
        RETURN ens;
    END;
END;