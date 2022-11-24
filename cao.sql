CREATE TYPE t_matiere AS OBJECT
(
    nom             Varchar2(30),
    prix_au_kilo    Number,
    masse_volumique Number
);
-- compiler chaque d�finition de type
-- un type utilis� avant d'�tre d�fini doit �tre pr�-d�clar�
CREATE TYPE t_piece;
CREATE TYPE t_piece_composite;
-- L'association ENTRE_DANS : une piece (de base ou composite) ENTRE_DANS la fabrication d'une ou plusieurs pieces composites,
-- en pr�cisant la quantit� de composants n�cessaire pour fabriquer la pi�ce composite.
CREATE TYPE t_entre_dans AS OBJECT
(
    quoi     Ref t_piece_composite,
    quantite Number
);
-- cardinalit� de l'association : 1-N
CREATE TYPE t_entre_dans_plusieurs AS Table Of t_entre_dans;
-- L'association contient : une piece composite CONTIENT des pieces (de base ou composite),
-- en pr�cisant la quantit� contenue.
CREATE TYPE t_contient AS OBJECT
(
    quoi     Ref t_piece,
    quantite Number
);
-- cardinalit� de l'association : 1-N
CREATE TYPE t_contient_plusieurs AS Table Of t_contient;
-- PIECE
-- est une sur-classe de Piece_base et Piece_Composite
CREATE TYPE t_piece AS OBJECT
(
    nom        Varchar2(30),
    entre_dans t_entre_dans_plusieurs,
    MEMBER FUNCTION masse RETURN Number,
    MEMBER FUNCTION prix RETURN Number
) NOT FINAL;
-- PIECE de BASE
CREATE TYPE t_piece_base UNDER t_piece
(
    est_en Ref t_matiere,
    MEMBER FUNCTION volume RETURN Number,
    OVERRIDING MEMBER FUNCTION masse RETURN Number,
    OVERRIDING MEMBER FUNCTION prix RETURN Number
) NOT FINAL;
-- Les pi�ces de base r�elles : cube, sphere et cylindre
CREATE TYPE t_cube UNDER t_piece_base
(
    cote Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
CREATE TYPE t_sphere UNDER t_piece_base
(
    rayon Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
CREATE TYPE t_cylindre UNDER t_piece_base
(
    diametre Number,
    hauteur  Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
-- un parall�l�pip�de rectangle
CREATE TYPE t_paral UNDER t_piece_base
(
    hauteur    Number,
    largeur    Number,
    profondeur Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
CREATE TYPE t_piece_composite UNDER t_piece
(
    cout_assemblage Number,
    contient_pieces t_contient_plusieurs,
    OVERRIDING MEMBER FUNCTION masse RETURN Number,
    OVERRIDING MEMBER FUNCTION prix RETURN Number
);
CREATE TABLE les_matiere OF t_matiere;
CREATE TABLE les_pieces_base OF t_piece_base
    NESTED TABLE entre_dans STORE AS pb_entre_dans;
CREATE TABLE les_pieces_composite OF t_piece_composite
    NESTED TABLE entre_dans STORE AS pc_entre_dans
    NESTED TABLE contient_pieces STORE AS pc_contient_pieces;
-- instanciation des objets
INSERT ALL
    INTO les_matiere
VALUES ('bois', 10, 2)
INTO les_matiere
VALUES ('fer', 5, 3)
INTO les_matiere
VALUES ('ferrite', 6, 10)
SELECT 1
FROM dual;

CREATE OR REPLACE PROCEDURE p1 AS
    bois    Ref t_matiere;
    fer     Ref t_matiere;
    ferrite Ref t_matiere;
    plateau Ref t_piece_base;
    pied    Ref t_piece_base;
    clou    Ref t_piece_base;
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
    VALUES (t_sphere('pied', NULL, bois, 30))
    INTO les_pieces_base
    VALUES (t_cylindre('clou', NULL, fer, 1, 20))
    INTO les_pieces_base
    VALUES (t_cylindre('aimant', NULL, ferrite, 2, 5))
    SELECT 1
    FROM dual;

    SELECT REF(m) INTO plateau FROM les_pieces_base m WHERE m.nom = 'plateau';
    SELECT REF(p) INTO pied FROM les_pieces_base p WHERE p.nom = 'pied';
    SELECT REF(c) INTO clou FROM les_pieces_base c WHERE c.nom = 'clou';

    INSERT ALL
        INTO les_pieces_composite
    VALUES ('table', NULL, 100, t_contient_plusieurs(t_contient(plateau, 1), t_contient(pied, 4), t_contient(clou, 12)))
    INTO les_pieces_composite
    VALUES ('billard', NULL, 10, t_contient_plusieurs(t_contient(plateau, 1)))
    SELECT 1
    FROM dual;
END;
/

BEGIN
    p1;
END;
/

SELECT nom, m.est_en.nom AS matiere
FROM les_pieces_base m;

SELECT c.nom, t.quoi.nom
FROM les_pieces_composite c,
     TABLE (c.contient_pieces) t;

-- calculer le volume, la masse et le prix d'une piece de base
CREATE OR REPLACE TYPE BODY t_piece_base AS
    MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 0;
    END volume;
    OVERRIDING MEMBER FUNCTION masse RETURN Number IS
        mv Number;
    BEGIN
        SELECT DEREF(self.est_en).masse_volumique INTO mv FROM dual;
        RETURN self.volume() * mv;
    END;
    OVERRIDING MEMBER FUNCTION prix RETURN Number IS
        pv Number;
    BEGIN
        SELECT DEREF(self.est_en).prix_au_kilo INTO pv FROM dual;
        RETURN self.volume() * pv;
    END;
END;


CREATE OR REPLACE TYPE BODY t_cube AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN cote * cote * cote;
    END;
END;

CREATE OR REPLACE TYPE BODY t_cylindre AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 3.14 * diametre / 2 * diametre / 2 * hauteur;
    END;
END;

CREATE OR REPLACE TYPE BODY t_sphere AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 4 / 3 * 3.14 * rayon * rayon * rayon;
    END;
END;

CREATE OR REPLACE TYPE BODY t_paral AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN hauteur * largeur * profondeur;
    END;
END;

SELECT pb.prix()
FROM les_pieces_base pb
WHERE pb.nom = 'clou';
