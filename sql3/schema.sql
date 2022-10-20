CREATE TYPE t_matiere AS OBJECT
(
    nom             Varchar2(30),
    prix_au_kilo    Number,
    masse_volumique Number
);
-- compiler chaque d�finition de type
@compile


-- un type utilis� avant d'�tre d�fini doit �tre pr�-d�clar�
CREATE TYPE t_piece;
@compile

CREATE TYPE t_piece_composite;
@compile


-- L'association ENTRE_DANS : une piece (de base ou composite) ENTRE_DANS la fabrication d'une ou plusieurs pieces composites,
-- en pr�cisant la quantit� de composants n�cessaire pour fabriquer la pi�ce composite.

CREATE TYPE t_entre_dans AS OBJECT
(
    quoi     Ref t_piece_composite,
    quantite Number
);
@compile

-- cardinalit� de l'association : 1-N
CREATE TYPE t_entre_dans_plusieurs AS Table Of t_entre_dans;
@compile


-- L'association contient : une piece composite CONTIENT des pieces (de base ou composite),
-- en pr�cisant la quantit� contenue.

CREATE TYPE t_contient AS OBJECT
(
    quoi     Ref t_piece,
    quantite Number
);
@compile

-- cardinalit� de l'association : 1-N
CREATE TYPE t_contient_plusieurs AS Table Of t_contient;
@compile


-- PIECE
-- est une sur-classe de Piece_base et Piece_Composite

PROMPT T_Piece

CREATE TYPE t_piece AS OBJECT
(
    nom        Varchar2(30),
    entre_dans t_entre_dans_plusieurs,
    MEMBER FUNCTION masse RETURN Number,
    MEMBER FUNCTION prix RETURN Number
) NOT FINAL;
@compile


-- PIECE de BASE
PROMPT T_Piece_base

CREATE TYPE t_piece_base UNDER t_piece
(
    est_en Ref t_matiere,
    MEMBER FUNCTION volume RETURN Number,
    OVERRIDING MEMBER FUNCTION masse RETURN Number,
    OVERRIDING MEMBER FUNCTION prix RETURN Number
) NOT FINAL;
@compile

-- Les pi�ces de base r�elles : cube, sphere et cylindre

PROMPT T_Cube

CREATE TYPE t_cube UNDER t_piece_base
(
    cote Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
@compile

PROMPT T_Sphere

CREATE TYPE t_sphere UNDER t_piece_base
(
    rayon Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
@compile

PROMPT T_Cylindre

CREATE TYPE t_cylindre UNDER t_piece_base
(
    diametre Number,
    hauteur  Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
@compile

-- un parall�l�pip�de rectangle
PROMPT T_Paral
CREATE TYPE t_paral UNDER t_piece_base
(
    hauteur    Number,
    largeur    Number,
    profondeur Number,
    OVERRIDING MEMBER FUNCTION volume RETURN Number
);
@compile


-- PIECE COMPOSITE
PROMPT T_Piece_Composite

CREATE TYPE t_piece_composite UNDER t_piece
(
    cout_assemblage Number,
    contient_pieces t_contient_plusieurs,
    OVERRIDING MEMBER FUNCTION masse RETURN Number,
    OVERRIDING MEMBER FUNCTION prix RETURN Number
);
@compile

