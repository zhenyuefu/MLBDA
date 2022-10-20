CREATE TABLE Les_Matiere OF t_matiere;

CREATE TABLE les_pieces_base OF t_piece_base
    NESTED TABLE entre_dans STORE AS PB_ENTRE_DANS;

CREATE TABLE les_pieces_composite OF t_piece_composite
    NESTED TABLE entre_dans STORE AS PC_ENTRE_DANS
    NESTED TABLE contient_pieces STORE AS PC_CONTIENT_PIECES;



-- instanciation des objets
-- ========================
INSERT ALL
INTO les_matiere VALUES ('bois', 10, 2)
INTO les_matiere VALUES ('fer', 5, 3)
INTO les_matiere VALUES ('ferrite', 6, 10)
SELECT 1 FROM dual;

CREATE OR REPLACE PROCEDURE p1 AS
    bois    Ref t_matiere;
    fer     Ref t_matiere;
    ferrite Ref t_matiere;
    plateau Ref t_piece_base;
    pied   Ref t_piece_base;
    clou ref t_piece_base;
BEGIN
    SELECT REF(m) INTO bois FROM les_matiere m WHERE m.nom = 'bois';
    SELECT REF(m) INTO fer FROM les_matiere m WHERE m.nom = 'fer';
    SELECT REF(m) INTO ferrite FROM les_matiere m WHERE m.nom = 'ferrite';

    INSERT ALL
    INTO les_pieces_base
    VALUES (t_cylindre('canne', NULL, bois, 2, 30))
    INTO les_pieces_base
    VALUES (t_paral('plateau', NULL, bois, 1, 100, 80))
    INTO les_pieces_base
    VALUES (t_sphere('boule', NULL, fer, 30))
    INTO les_pieces_base
    VALUEs (t_sphere('pied', NULL, bois, 30))
    into les_pieces_base
    values (t_cylindre('clou', NULL, fer, 1, 20))
    into les_pieces_base
    values (t_cylindre('aimant', NULL, ferrite, 2, 5))
    SELECT 1
    FROM dual;

    SELECT REF(m) INTO plateau FROM les_pieces_base m WHERE m.nom = 'plateau';
    SELECT ref(p) INTO pied FROM les_pieces_base p WHERE p.nom = 'pied';
    SELECT ref(c) INTO clou FROM les_pieces_base c WHERE c.nom = 'clou';

    insert all
    INTO les_pieces_composite
    VALUES ('table', null, 100, t_contient_plusieurs(t_contient(plateau, 1), t_contient(pied, 4), t_contient(clou, 12)))
    into les_pieces_composite
    values ('billard', null, 10, t_contient_plusieurs(t_contient(plateau, 1)))
    SELECT 1
    FROM dual;

END;
/

BEGIN
    P1;
END;
/

SELECT nom, m.est_en.nom AS matiere
FROM les_pieces_base m;

SELECT c.nom, t.quoi.nom
FROM les_pieces_composite c,
     TABLE (c.contient_pieces) t;
